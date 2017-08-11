# Docker EE for Azure with Active Directory

The Docker Universal Control Plane (UCP) is capable of managing its own set of user accounts for authentication and authorization. However, customers with existing investments in Microsoft Active Directory may leverage AD for user management.

This Azure Resource Manager (ARM) Template provisions the following:

* [Docker Enterprise Edition for Azure](https://docs.docker.com/datacenter/install/azure/)

* Windows Server 2016 

* Desired State Configuration (DSC) VM Extension to enable and configure the Active Directory Domain Services Role

* PowerShell Custom Script Extension to pre-populate the directory with sample users and groups

## Prerequisites
The following are needed prior to running the template:

* Docker Enterprise Edition License - a free one month trial is available at the [Docker Store](https://store.docker.com/editions/enterprise/docker-ee-trial?plan=free-trial&plan=free-trial&tab=description)

* Azure Subscription - Available with an Enterprise Agreement, MSDN Subscription, or with the [free trial](https://azure.microsoft.com/en-us/free/)

* Service Principal access credentials, which you can generate by following the steps in [Docker for Azure Setup and Prerequisites](https://docs.docker.com/docker-for-azure/#configuration).

* An SSH public/private key pair, which you can generate by following the steps in [How to create and use an SSH public and private key pair for Linux VMs in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys). Save the public and private keys in a convenient location, like in the same directory as the Docker license, and be sure to remember the password for the key pair.

## Deploy the ARM Template

Click the following button to begin the provisioning process via the Azure Portal:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fstevenfollis%2Fshipyard%2Fmaster%2Factive-directory%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This file is also deployable via the [Azure CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-cli) or [PowerShell](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy).

## Architecture

Docker EE for Azure is the stock template that you'd be using if you provisioned via the Azure Marketplace. It deploys first.

After Docker EE finishes deploying its virtual network,  a Windows Server 2016 VM + NIC are provisioned inside of the existing VNet and Subnet. 

A Public IP resource is added for remoting into the machine via RDP. 

![image](./media/architecture.png) 

## Parameters
Before deployment you will need to provide parameters:

* **Ddc License Key** - the entire JSON file from `docker_subscription.lic` downloaded from Docker Store -> My Content -> Your Subscription. Simply copy + paste, doesn't need any encoding love.

* **Ad Service Principal App ID** - GUID representing the ID you generated for the SP

* **Ad Service Principal App ID** - GUID repesenting the password generated for the SP

* **Ssh Public Key** - `.pub` part of the public/private key pair. Paste right on into the box

* **Manager Count** - Odd number to ensure quorum can be maintained for the cluster

* **Manager VM Size** - Defaults to `Standard_D2_v2`

* **Worker Count** - Number of VMs for the worker nodes. Recommended to have 3+ to show workloads moving across workers

* **Worker VM Size** - Default to `Standard_D2_v2`

* **Domain Name** - Name used by AD. Defaults to `contoso.local` to match most AD starter guides. Feel free to adjust to another name

* **Number Users** - Max number of sample users to be generated. Will likely be slightly lower than this number, as duplicates will be dropped

> Be sure to scroll down and click the checkbox for `I agree to the terms and conditions stated above`. It's easy to miss

![image](./media/screen00.png)

## Configuration
The template provisions all necessary infrastructure, however a bit of configuration will be necessary to plumb the components together.

### Configure LDAP
Once the deployment finishes, open the [Azure Portal](https://portal.azure.com) and navigate to **Resource Groups** -> **\<your RG Name>** -> **Deployments**.  The Deployments blade lists all deployments that have been executed within our Resource Group. 

![image](./media/screen01.png)

Click the **dfa** row to open the deployment of Docker EE for Azure. Here you will find the **outputs** section of an ARM Template, including links to the UCP URL, DTR URL, and SSH URL. 

![image](./media/screen02.png)

![image](./media/screen03.png)

Click the square next to **UCPLOGINURL** to copy the URL to the clipboard. Then paste into a new browser tab. At the Docker UCP login screen, enter username `admin` and password `Docker123!` and click **Login**.

![image](./media/screen04.png)

On the top navigation bar, select **Admin** to open the settings. Then from the left hand navigation, select **Auth**.  This page is where LDAP is configured for UCP, and where we will set UCP to talk to our Active Directory server. 

* **Method**: `LDAP`
* **Default Permission for New Users**: `View Only`
* **Recovery Admin Username**: `admin`
* **Recovery Admin Password**: `Docker123!`
* **LDAP Server URL**: `ldap://172.31.0.10` 
* **Reader DN**: `cn=reader,cn=Users,dc=contoso,dc=local`
* **Reader Password**: `Docker123!`
* **Skip Validation of server certficate**: checked

![image](./media/screen05.png)

* **Base DN**: `cn=users,dc=contoso,dc=local`
* **Username Attribute**: `sAMAccountName`
* **Full Name Attribute**: `cn`
* **Filter**: `(&(objectClass=person)(objectClass=user))`

![image](./media/screen06.png)

Save the settings by clicking the **Update Auth Settings** button and confirm the configuration. Click **Sync Now** and ensure the status indicator is green.

![image](./media/screen07.png)

Finally, on the top navigation bar select **User Management** and verify that names are now present. LDAP sync has been enabled with a Windows Server Active Directory machine, all running in Azure.

![image](./media/screen08.png)

### Configure Groups
To sync group memberships between Active Directory and UCP, we need to establish mappings between the two systems. On the **User Management** tab, select the **+ Create** button from the left navigation window. 

The script that pre-populated Active Directory with sample users also placed each user into one of two groups: "Engineering" or "Operations". To configure Engineering:

* Name the UCP team "Engineering"
* Enable Sync of Team Members to keep the membership up to date
* Match on LDAP Group Members from `cn=engineering members,cn=users,dc=contoso,dc=local` and on attribute `member`
* Repeat the process for "Operations"

![image](./media/screen09.png)

Once the groups are established and syncing, permissions can be assigned to them. For the Developers group, click the **Permissions** tab and add a label for `prod` set to `View Only`. This should keep our trigger happy developers from mistakenly taking down any production nodes. 

## Remote Desktop
To remote desktop into the Domain Controller, use username `docker` and password `Docker123456!`. To download a pre-configured .rdp file, click the **Connect** button on the Overview Blade for the DC VM within the Azure Portal.