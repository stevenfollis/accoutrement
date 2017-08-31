# Docker EE for Ubuntu (on Azure)

The best experience for running Docker Enterprise Edition on the Azure platform is [Docker EE for Azure](https://store.docker.com/editions/enterprise/docker-ee-azure?tab=description). It includes Azure-specific features such as Virtual Machine Scale Sets and pre-configured logging.

However, you may also run Docker EE for Ubuntu on Azure. This template will set up a specified number of manager, worker, and DTR nodes for such an installation. 

TODO:
* Setup DTR automatically. For now, the nodes are provisioned but you will need to manually setup DTR and replicas.