

# Configure Azure Kubernetes Service (AKS) in multi cluster envoronment, with using Application Gateway for Containers with ALB Controller with basic networking

This article shows you how to set up for demo proposes a environment with many scenarios for AKS, with basic networking (working with public ip, not recomended for production environments)

# Architecture diagram

![Environment](./media/aks-alb.png)


## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).

---

## Set up Azure subscription
Register the resources providers
```bash
# Register required resource providers on Azure.
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.NetworkFunction
az provider register --namespace Microsoft.ServiceNetworking

# Install Azure CLI extensions.
az extension add --name alb
```



# Create Clusters

Create Resource Group

```bash
az group create \
    --name aks-multi-alb-rg \
    --location westus
```

Create Clusters

```bash

# Create AKS 01
az aks create --resource-group 'aks-multi-alb-rg' --name 'aks-alb01' --location 'westus' --network-plugin azure --enable-oidc-issuer --enable-workload-identity --generate-ssh-key

# Create AKS 02
az aks create --resource-group 'aks-multi-alb-rg' --name 'aks-alb02' --location 'westus' --network-plugin azure --enable-oidc-issuer --enable-workload-identity --generate-ssh-key

```

# Install Helm

If you are not using cloud shell, install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```


# Install ALB Controller - Cluster 01

Create a user managed identity for ALB controller and federate the identity as Workload Identity to use in the AKS cluster:


```bash
RESOURCE_GROUP='aks-multi-alb-rg'
AKS_NAME='aks-alb01'
IDENTITY_RESOURCE_NAME='azure-alb-identity'

mcResourceGroup=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --query "nodeResourceGroup" -o tsv)
mcResourceGroupId=$(az group show --name $mcResourceGroup --query id -otsv)

echo "Creating identity $IDENTITY_RESOURCE_NAME in resource group $RESOURCE_GROUP"
az identity create --resource-group $RESOURCE_GROUP --name $IDENTITY_RESOURCE_NAME
principalId="$(az identity show -g $RESOURCE_GROUP -n $IDENTITY_RESOURCE_NAME --query principalId -otsv)"

echo "Waiting 60 seconds to allow for replication of the identity..."
sleep 60

echo "Apply Reader role to the AKS managed cluster resource group for the newly provisioned identity"
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $mcResourceGroupId --role "acdd72a7-3385-48ef-bd42-f606fba81ae7" # Reader role

echo "Set up federation with AKS OIDC issuer"
AKS_OIDC_ISSUER="$(az aks show -n "$AKS_NAME" -g "$RESOURCE_GROUP" --query "oidcIssuerProfile.issuerUrl" -o tsv)"
echo "create federated identity"
az identity federated-credential create --name "azure-alb-identity" --identity-name "$IDENTITY_RESOURCE_NAME" --resource-group $RESOURCE_GROUP --issuer "$AKS_OIDC_ISSUER" --subject "system:serviceaccount:azure-alb-system:alb-controller-sa"
```

Install ALB Controller:

```bash
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
helm install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller --version 1.0.0 --set albController.podIdentity.clientID=$(az identity show -g $RESOURCE_GROUP -n azure-alb-identity --query clientId -o tsv)
```

# Install ALB Controller - Cluster 02
Create a user managed identity for ALB controller and federate the identity as Workload Identity to use in the AKS cluster

```bash
RESOURCE_GROUP='aks-multi-alb-rg'
AKS_NAME='aks-alb02'
IDENTITY_RESOURCE_NAME='azure-alb-identity'

mcResourceGroup=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --query "nodeResourceGroup" -o tsv)
mcResourceGroupId=$(az group show --name $mcResourceGroup --query id -otsv)

#echo "Creating identity $IDENTITY_RESOURCE_NAME in resource group $RESOURCE_GROUP"
#az identity create --resource-group $RESOURCE_GROUP --name $IDENTITY_RESOURCE_NAME
#principalId="$(az identity show -g $RESOURCE_GROUP -n $IDENTITY_RESOURCE_NAME --query principalId -otsv)"

echo "Waiting 60 seconds to allow for replication of the identity..."
sleep 60

echo "Apply Reader role to the AKS managed cluster resource group for the newly provisioned identity"
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $mcResourceGroupId --role "acdd72a7-3385-48ef-bd42-f606fba81ae7" # Reader role

echo "Set up federation with AKS OIDC issuer"
AKS_OIDC_ISSUER="$(az aks show -n "$AKS_NAME" -g "$RESOURCE_GROUP" --query "oidcIssuerProfile.issuerUrl" -o tsv)"
az identity federated-credential create --name "azure-alb-identity" --identity-name "azure-alb-identity" --resource-group $RESOURCE_GROUP --issuer "$AKS_OIDC_ISSUER" --subject "system:serviceaccount:azure-alb-system:alb-controller-sa"
```

Delete context of other clusters:
```bash
kubectl config delete-context aks-alb01
```

Install ALB Controller:

```bash
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
helm install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller --version 1.0.0 --set albController.podIdentity.clientID=$(az identity show -g $RESOURCE_GROUP -n azure-alb-identity --query clientId -o tsv)
```

# Create Application Gateway for Containers

Subnet for Cluster 01
```bash
AKS_NAME='aks-alb01'
RESOURCE_GROUP='aks-multi-alb-rg'

MC_RESOURCE_GROUP=$(az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP --query "nodeResourceGroup" -o tsv)
CLUSTER_SUBNET_ID=$(az vmss list --resource-group $MC_RESOURCE_GROUP --query '[0].virtualMachineProfile.networkProfile.networkInterfaceConfigurations[0].ipConfigurations[0].subnet.id' -o tsv)
read -d '' VNET_NAME VNET_RESOURCE_GROUP VNET_ID <<< $(az network vnet show --ids $CLUSTER_SUBNET_ID --query '[name, resourceGroup, id]' -o tsv)


#Create Subnet
SUBNET_ADDRESS_PREFIX='10.225.0.0/24'
ALB_SUBNET_NAME='subnet-alb' # subnet name can be any non-reserved subnet name (i.e. GatewaySubnet, AzureFirewallSubnet, AzureBastionSubnet would all be invalid)
az network vnet subnet create --resource-group $VNET_RESOURCE_GROUP --vnet-name $VNET_NAME --name $ALB_SUBNET_NAME --address-prefixes $SUBNET_ADDRESS_PREFIX --delegations 'Microsoft.ServiceNetworking/trafficControllers'
ALB_SUBNET_ID=$(az network vnet subnet show --name $ALB_SUBNET_NAME --resource-group $VNET_RESOURCE_GROUP --vnet-name $VNET_NAME --query '[id]' --output tsv)

```
Subnet for Cluster 02
```bash
AKS_NAME='aks-alb02'
RESOURCE_GROUP='aks-multi-alb-rg'

MC_RESOURCE_GROUP=$(az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP --query "nodeResourceGroup" -o tsv)
CLUSTER_SUBNET_ID=$(az vmss list --resource-group $MC_RESOURCE_GROUP --query '[0].virtualMachineProfile.networkProfile.networkInterfaceConfigurations[0].ipConfigurations[0].subnet.id' -o tsv)
read -d '' VNET_NAME VNET_RESOURCE_GROUP VNET_ID <<< $(az network vnet show --ids $CLUSTER_SUBNET_ID --query '[name, resourceGroup, id]' -o tsv)

SUBNET_ADDRESS_PREFIX='10.225.0.0/24'
ALB_SUBNET_NAME='subnet-alb' # subnet name can be any non-reserved subnet name (i.e. GatewaySubnet, AzureFirewallSubnet, AzureBastionSubnet would all be invalid)
az network vnet subnet create --resource-group $VNET_RESOURCE_GROUP --vnet-name $VNET_NAME --name $ALB_SUBNET_NAME --address-prefixes $SUBNET_ADDRESS_PREFIX --delegations 'Microsoft.ServiceNetworking/trafficControllers'
ALB_SUBNET_ID=$(az network vnet subnet show --name $ALB_SUBNET_NAME --resource-group $VNET_RESOURCE_GROUP --vnet-name $VNET_NAME --query '[id]' --output tsv)

```

Delegate permissions to managed identity for Cluster 01
```bash
AKS_NAME='aks-alb01'
IDENTITY_RESOURCE_NAME='azure-alb-identity'

MC_RESOURCE_GROUP=$(az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP --query "nodeResourceGroup" -otsv | tr -d '\r')

mcResourceGroupId=$(az group show --name $MC_RESOURCE_GROUP --query id -otsv)
principalId=$(az identity show -g $RESOURCE_GROUP -n $IDENTITY_RESOURCE_NAME --query principalId -otsv)

# Delegate AppGw for Containers Configuration Manager role to AKS Managed Cluster RG
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $mcResourceGroupId --role "fbc52c3f-28ad-4303-a892-8a056630b8f1"

# Delegate Network Contributor permission for join to association subnet
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $ALB_SUBNET_ID --role "4d97b98b-1d4f-4787-a291-c67834d212e7"
```

Delegate permissions to managed identity for Cluster 02
```bash
AKS_NAME='aks-alb02'
IDENTITY_RESOURCE_NAME='azure-alb-identity'

MC_RESOURCE_GROUP=$(az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP --query "nodeResourceGroup" -otsv | tr -d '\r')

mcResourceGroupId=$(az group show --name $MC_RESOURCE_GROUP --query id -otsv)
principalId=$(az identity show -g $RESOURCE_GROUP -n $IDENTITY_RESOURCE_NAME --query principalId -otsv)

# Delegate AppGw for Containers Configuration Manager role to AKS Managed Cluster RG
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $mcResourceGroupId --role "fbc52c3f-28ad-4303-a892-8a056630b8f1"

# Delegate Network Contributor permission for join to association subnet
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $ALB_SUBNET_ID --role "4d97b98b-1d4f-4787-a291-c67834d212e7"
```



# Create ALB Resources

Cluster 01
```bash

kubectl config delete-context aks-alb02
az aks get-credentials --resource-group aks-multi-alb-rg --name aks-alb01

kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: alb-test-infra
EOF


#get subnet ID
AKS_NAME='aks-alb01'
RESOURCE_GROUP='aks-multi-alb-rg'

MC_RESOURCE_GROUP=$(az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP --query "nodeResourceGroup" -o tsv)
CLUSTER_SUBNET_ID=$(az vmss list --resource-group $MC_RESOURCE_GROUP --query '[0].virtualMachineProfile.networkProfile.networkInterfaceConfigurations[0].ipConfigurations[0].subnet.id' -o tsv)
read -d '' VNET_NAME VNET_RESOURCE_GROUP VNET_ID <<< $(az network vnet show --ids $CLUSTER_SUBNET_ID --query '[name, resourceGroup, id]' -o tsv)
ALB_SUBNET_ID=$(az network vnet subnet show --name 'subnet-alb' --resource-group $VNET_RESOURCE_GROUP --vnet-name $VNET_NAME --query '[id]' --output tsv)


kubectl apply -f - <<EOF
apiVersion: alb.networking.azure.io/v1
kind: ApplicationLoadBalancer
metadata:
  name: alb-test
  namespace: alb-test-infra
spec:
  associations:
  - $ALB_SUBNET_ID
EOF

kubectl get applicationloadbalancer alb-test -n alb-test-infra -o yaml -w

```
# Deploy sample application
```bash
kubectl apply -f https://trafficcontrollerdocs.blob.core.windows.net/examples/traffic-split-scenario/deployment.yaml

kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway-01
  namespace: test-infra
  annotations:
    alb.networking.azure.io/alb-namespace: alb-test-infra
    alb.networking.azure.io/alb-name: alb-test
spec:
  gatewayClassName: azure-alb-external
  listeners:
  - name: http-listener
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
EOF

kubectl get gateway gateway-01 -n test-infra -o yaml


kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: contoso-route
  namespace: test-infra
spec:
  parentRefs:
  - name: gateway-01
  hostnames:
  - "alb.oikawa.net.br"
  rules:
  - backendRefs:
    - name: backend-v1
      port: 8080
EOF


kubectl get httproute contoso-route -n test-infra -o yaml
```

# Test Application
```bash
fqdn=$(kubectl get gateway gateway-01 -n test-infra -o jsonpath='{.status.addresses[0].value}')


fqdnIp=$(dig +short $fqdn)
curl -k --resolve alb.oikawa.net.br:80:$fqdnIp http://alb.oikawa.net.br

```

## Create Application Gateway

```bash 
#create vnet
az network vnet create --name alb-vnet --resource-group aks-multi-alb-rg --location westus --address-prefix 10.21.0.0/16 --subnet-name appgtwsubnet --subnet-prefix 10.21.0.0/24

#create public ip
az network public-ip create --resource-group aks-multi-alb-rg --name appgtw-pip --allocation-method Static --sku Standard

#create Application Gateway
az network application-gateway create --name appgtw --location westus --resource-group aks-multi-alb-rg --capacity 2 --sku Standard_v2 --public-ip-address appgtw-pip --vnet-name alb-vnet --subnet appgtwsubnet --priority 100

```

## Create API Management

```bash

let "randomId=$RANDOM"
az apim create --name "apim$randomId" --resource-group aks-multi-alb-rg --publisher-name Contoso --publisher-email admin@contoso.com --no-wait 

```




## Clean Up

1. Access Azure Preview Portal
2. Delete Resource Group where your resources got provisioned.
