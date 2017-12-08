# d4a-accoutrement

A configurable Azure Resource Manager (ARM) Template for provisioning [Docker EE for Azure](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/docker.dockerdatacenter) environments with additional Windows-specific supporting resources.

![banner](./media/banner.jpg)

## Accessories
The template currently supports a variety of accessory templates. Click the title to see setup instructions specific to each template.

| Scenario | Description |
|---|---|
| [Active Directory](./active-directory) | Adds an AD Domain Controller pre-loaded with users and groups |
| [Operations Management Suite](./oms) | Adds OMS with a variety of solution packs | 
| [VMSS](./vmss) | Separate template for provisioning infrastructure for a Docker EE cluster using Ubuntu images in a Virtual Machine Scale Set (Rather than D4A) |

## Prerequisites
The following are needed prior to running the template:

* Docker Enterprise Edition License - a free one month trial is available at the [Docker Store](https://store.docker.com/editions/enterprise/docker-ee-trial?plan=free-trial&plan=free-trial&tab=description)

* Azure Subscription - Available with an Enterprise Agreement, MSDN Subscription, or with the [free trial](https://azure.microsoft.com/en-us/free/)

* Service Principal access credentials, which you can generate by following the steps in [Docker for Azure Setup and Prerequisites](https://docs.docker.com/docker-for-azure/#configuration).

* An SSH public/private key pair, which you can generate by following the steps in [How to create and use an SSH public and private key pair for Linux VMs in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys). Save the public and private keys in a convenient location, like in the same directory as the Docker license, and be sure to remember the password for the key pair.

## Setup
This template can be deployed to an Azure Subscription via [Powershell](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy), the [Azure CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-cli) (great for OSX or Linux), or by simply clicking this button:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fstevenfollis%2Fd4a-accoutrement%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

The various accessories are controlled by template parameters. By default, each is set to `true` and requires an explicit `false` to avoid provisioning a particular feature.