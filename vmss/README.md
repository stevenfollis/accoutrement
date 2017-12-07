# docker-ee-vmss

Azure Resource Manager (ARM) Template for deploying [Docker Enterprise Edition](https://www.docker.com/enterprise-edition) to Azure utilizing Virtual Machine Scale Sets. This template::

1. Provisions Azure infrastructure to support a Docker EE cluster

1. Installs the latest Docker EE engine to the virtual machines

> This template does not fully setup and configure the Docker Universal Control Plane (UCP) and Docker Trusted Registry (DTR).

## Deploy to Azure

This template can be deployed with [PowerShell](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy) or the [Azure CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-cli)

## Design Considerations

* Vanilla virtual machine images are used (non-custom) to enable scale sets with [>300 instances](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-overview#frequently-asked-questions-for-scale-sets)

* The Azure Load Balancer Basic is limited to one VMSS instance for use as a backendpool. While the [Load Balancer Standard](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-overview) is in Public Preview and will alleviate this issue (with [Public IP Standard](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm#public-ip-addresses) instances) the Windows Worker VMSS is currently not tied into the `apps` load balancer. This is due to the lack of ingress routing capabilities with Windows containers, currently being rectified with Windows Server 1709.

* There is not an automated mechanism for opening ports on the `apps` Azure Load Balancer, however to expedite the setup there is a loop that opens ports `30000` through `30025`. Feel free to remove this from the template or focus on `80` + `443`.

* NAT rules are not used on the Azure Load Balancers. The only way to access individual virtual machines is to first ssh or remote desktop to the two "jumpbox" servers, and then remote into a specific virtual machine. This [bastion host](https://en.wikipedia.org/wiki/Bastion_host) model is a smidge more secure than leveraging NAT rules.

## Parameters

| Parameter | Description |
--- | ---
| `labName` | Globally unique name used for the Public IP address DNS names |
| `dockerEEURL` | Docker EE Subscription URL (located at [store.docker.com](http://store.docker.com) -> My Content)
| `vmInstancesManagers` | Integer for number of manager nodes to provision |
| `vmInstancesWorkers` | Integer for number of worker nodes to provision |
| `vmInstancesDTR` | Integer for number of Docker Trusted Registry (DTR) nodes to provision |

> If Windows nodes are unneeded, simply delete the VMSS instance after provisioning is completed

## Architecture Diagram
TBD