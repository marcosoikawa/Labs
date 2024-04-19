

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

az network vnet create \
    --resource-group aks-multi-rg \
    --name multi-vnet \
    --address-prefixes 10.2.0.0/8 \
    --subnet-name myAKSSubnet \
    --subnet-prefix 10.240.0.0/16

az aks create \
    --resource-group aks-multi-rg \
    --name aks-cluster \
    --network-plugin azure \
    --generate-ssh-keys
```

---

## Next steps



