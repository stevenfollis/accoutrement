# Docker EE for Azure with OMS

Microsot's [Operations Management Suite](https://www.microsoft.com/en-us/cloud-platform/operations-management-suite) is a set of tools for operating workloads.  

This Azure Resource Manager (ARM) Template provisions the following:

* [Docker Enterprise Edition for Azure](https://docs.docker.com/datacenter/install/azure/)

* Operations Management Suite deployed via [template](https://github.com/Azure/azure-quickstart-templates/tree/master/oms-all-deploy)

* OMS Solutions including Containers

## Deploy the ARM Template

Click the following button to begin the provisioning process via the Azure Portal:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fstevenfollis%2Fshipyard%2Fmaster%2Foms%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>