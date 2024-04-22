

# Configure Azure Kubernetes Service (AKS) in multi cluster envoronment, with basic netowrking

This article shows you how to set up for demo proposes a environment with many scenarios for AKS, with basic networking (working with public ip, not recomended for production environments)


## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).

---

## Configure networking

Set up the virtual networking for the environment

```bash
az group create \
    --name aks-multi-b-rg \
    --location brazilsouth
```
Create Cluster 01

```bash
# Create AKS 01
az aks create -n aks-agic01 -g aks-multi-b-rg --network-plugin azure --enable-managed-identity -a ingress-appgw --appgw-name agic01 --appgw-subnet-cidr "10.255.0.0/16" --generate-ssh-keys

# Get application gateway id from AKS addon profile
appGatewayId=$(az aks show -n aks-agic01 -g aks-multi-b-rg -o tsv --query "addonProfiles.ingressApplicationGateway.config.effectiveApplicationGatewayId")

# Get Application Gateway subnet id
appGatewaySubnetId=$(az network application-gateway show --ids $appGatewayId -o tsv --query "gatewayIPConfigurations[0].subnet.id")

# Get AGIC addon identity
agicAddonIdentity=$(az aks show -n aks-agic01 -g aks-multi-b-rg -o tsv --query "addonProfiles.ingressApplicationGateway.identity.clientId")

# Assign network contributor role to AGIC addon identity to subnet that contains the Application Gateway
az role assignment create --assignee $agicAddonIdentity --scope $appGatewaySubnetId --role "Network Contributor"

```
Create Cluster 02

```bash
# Create AKS 02
az aks create -n aks-agic02 -g aks-multi-b-rg --network-plugin azure --enable-managed-identity -a ingress-appgw --appgw-name agic02 --appgw-subnet-cidr "10.255.0.0/16" --generate-ssh-keys

# Get application gateway id from AKS addon profile
appGatewayId=$(az aks show -n aks-agic02 -g aks-multi-b-rg -o tsv --query "addonProfiles.ingressApplicationGateway.config.effectiveApplicationGatewayId")

# Get Application Gateway subnet id
appGatewaySubnetId=$(az network application-gateway show --ids $appGatewayId -o tsv --query "gatewayIPConfigurations[0].subnet.id")

# Get AGIC addon identity
agicAddonIdentity=$(az aks show -n aks-agic02 -g aks-multi-b-rg -o tsv --query "addonProfiles.ingressApplicationGateway.identity.clientId")

# Assign network contributor role to AGIC addon identity to subnet that contains the Application Gateway
az role assignment create --assignee $agicAddonIdentity --scope $appGatewaySubnetId --role "Network Contributor"
```

Deploy App to test

```bash
az aks get-credentials -n aks-agic01 -g aks-multi-b-rg
kubectl apply -f https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/aspnetapp.yaml

az aks get-credentials -n aks-agic02 -g aks-multi-b-rg
kubectl apply -f https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/aspnetapp.yaml

```
---

## Next steps



