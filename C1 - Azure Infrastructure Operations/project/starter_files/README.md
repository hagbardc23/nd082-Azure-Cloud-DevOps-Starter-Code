# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

## Introduction
This project contains a sample of a scalable "Helo World" web application running in a virtual machine, which is built by a Packer template and provisioned by a Terraform template in Azure Cloud . The scaling of application deployment is customazable and can be configured in varibles file of Terraform.

## Getting Started
An Azure account is neccessary for this project. This can ve easily created on [Azure Account](https://portal.azure.com). It is also advisable to install [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) locally.

Some prerequisites need to be created and configured or at least queried  in Azure at first. You have to replace contained placeholders in the square brackets with appropriate values.
1. Run az group create to create a resource group to hold the Packer image.
```bash
az group create -n <resource_group_name> -l <location>
```
2. Run az ad sp create-for-rbac to enable Packer to authenticate to Azure using a service principal. **Key points:** Make note of the output values (appId, client_secret, tenant_id).
```bash
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/<subscription_id> --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
```
3. Run az account show to display the current Azure subscription Id.
```bash
az account show --query "{ subscription_id: id }"
```
4. For easy of management of all resources beiing created by Terraform we enforces tagging for all resources of a resource group utilizing security policy in Azure. You can enforce additinally a similar rule for resource groups too, just use another rule document `azurepolicy.rules-rg.json` instead.
```bash
az policy definition create --name tagging-policy --display-name "Enforces a tag on resource" --description "Enforces existence of a tag on resources." --rules .\azurepolicy.rules.json --mode Indexed --metadata category=Tags

az policy assignment create --name 'tagging-policy-assignment' --display-name "Enforces a tag on resource Assignment" --scope /subscriptions/<subscription_id> --policy /subscriptions/<subscription_id>/providers/Microsoft.Authorization/policyDefinitions/tagging-policy
``` 
For execution of Packer and Terraform you will also need both applicaiton installed locally. Please refer to Dependencies section for download of installation packages.
## Dependencies
* Install [Packer](https://www.packer.io/downloads)
* Install [Terraform](https://www.terraform.io/downloads.html)

## Instructions
Prior to the execution of `Packer` and `Terraform` templates you might do configuration of follwing parameters
### Customization 

## Output
**Your words here**

