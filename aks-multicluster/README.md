

# Configure Azure Kubernetes Service (AKS) in multi cluster envoronment

This article shows you how to set up for demo proposes a environment with many scenarios for AKS.


## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).

[!INCLUDE [azure-cli-prepare-your-environment-no-header.md](~/reusable-content/azure-cli/azure-cli-prepare-your-environment-no-header.md)]

---

## Configure networking

Set up the virtual networking for the environment

```azurecli-interactive
az group create \
    --name aks-multi-rg \
    --location brazilsouth

az network nsg create --resource-group aks-multi-rg --name multi-nsg

az network vnet create \
    --resource-group aks-multi-rg \
    --name multi-vnet \
    --address-prefixes 10.10.0.0/16


```

Create the subnets
```azurecli-interactive

az network vnet subnet create \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    -n aks-cni-01 \
    --address-prefixes 10.10.0.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    -n aks-cni-02 \
    --address-prefixes 10.10.1.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    -n aks-kubnet-01 \
    --address-prefixes 10.10.2.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    -n aks-kubnet-02 \
    --address-prefixes 10.10.3.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    -n aks-kubnet-03 \
    --address-prefixes 10.10.4.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    -n aks-kubnet-04 \
    --address-prefixes 10.10.5.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    -n aks-cnio-01 \
    --address-prefixes 10.10.6.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    -n aks-cnio-02 \
    --address-prefixes 10.10.7.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    -n agic-01 \
    --address-prefixes 10.10.10.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    -n agic-02 \
    --address-prefixes 10.10.11.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -n appg-cni \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    --address-prefixes 10.10.20.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -n appg-kubnet \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    --address-prefixes 10.10.21.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -n appg-cnio \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    --address-prefixes 10.10.22.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -n appg-ngixaas \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    --address-prefixes 10.10.23.0/24 \
    --network-security-group multi-nsg

az network vnet subnet create \
    -n apim \
    -g aks-multi-rg \
    --vnet-name multi-vnet \
    --address-prefixes 10.10.30.0/24 \
    --network-security-group multi-nsg

az aks create \
    --resource-group aks-multi-rg \
    --name aks-cluster \
    --network-plugin azure \
    --generate-ssh-keys


```

---

## Next steps



