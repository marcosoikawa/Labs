

# Configure Azure Kubernetes Service (AKS) in multi cluster envoronment, with using Application Gateway for Containers with ALB Controller with basic networking

This article shows you how to set up for demo proposes a environment with many scenarios for AKS, with basic networking (working with public ip, not recomended for production environments)


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
    --name aks-multi-b-rg \
    --location brazilsouth
```

Create Clusters

```bash

# Create AKS 01
az aks create --resource-group 'aks-multi-b-rg' --name 'aks-alb01' --location 'brazilsouth' --network-plugin azure --enable-oidc-issuer --enable-workload-identity --generate-ssh-key

# Create AKS 02
az aks create --resource-group 'aks-multi-b-rg' --name 'aks-alb01' --location 'brazilsouth' --network-plugin azure --enable-oidc-issuer --enable-workload-identity --generate-ssh-key

```

# Install Helm

If you are not using cloud shell, install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```


# Install ALB Controller

Cluster 01
Create a user managed identity for ALB controller and federate the identity as Workload Identity to use in the AKS cluster:


```bash
RESOURCE_GROUP='aks-multi-b-rg'
AKS_NAME='aks-alb01'
IDENTITY_RESOURCE_NAME='alb-id01'

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
az identity federated-credential create --name "azure-alb-identity" --identity-name "$IDENTITY_RESOURCE_NAME" --resource-group $RESOURCE_GROUP --issuer "$AKS_OIDC_ISSUER" --subject "system:serviceaccount:azure-alb-system:alb-controller-sa"
```

Install ALB Controller:

```bash
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
helm install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller --version 1.0.0 --set albController.namespace=<alb-controller-namespace> --set albController.podIdentity.clientID=$(az identity show -g $RESOURCE_GROUP -n azure-alb-identity --query clientId -o tsv)
```

Cluster 02
Create a user managed identity for ALB controller and federate the identity as Workload Identity to use in the AKS cluster

```bash
RESOURCE_GROUP='aks-multi-b-rg'
AKS_NAME='aks-alb02'
IDENTITY_RESOURCE_NAME='alb-id02'

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
az identity federated-credential create --name "azure-alb-identity" --identity-name "$IDENTITY_RESOURCE_NAME" --resource-group $RESOURCE_GROUP --issuer "$AKS_OIDC_ISSUER" --subject "system:serviceaccount:azure-alb-system:alb-controller-sa"
```

Install ALB Controller:

```bash
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
helm install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller --version 1.0.0 --set albController.namespace=<alb-controller-namespace> --set albController.podIdentity.clientID=$(az identity show -g $RESOURCE_GROUP -n azure-alb-identity --query clientId -o tsv)
```


Create API Management

```bash

let "randomId=$RANDOM"
az apim create --name "apim$randomId" --resource-group aks-multi-b-rg --publisher-name Contoso --publisher-email admin@contoso.com --no-wait 

```
## Next steps



