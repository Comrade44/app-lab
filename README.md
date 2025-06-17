# app-lab
This repository provides a template for deploying Terraform code to Azure using GitHub Actions, and one or more sets of demo infrastructure for various App Services architectures.

# Pre-requisites
1. Configure an app registration and federated workload identity in Azure - https://docs.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation
2. Grant the identity "Contributor" access on the target subscription.
4. Create the following variables in GitHub:
  - ARM_CLIENT_ID - The app ID of the app registration for GitHub Actions
  - ARM_TENANT_ID - The target Entra Tenant's ID
  - ARM_SUBSCRIPTION_ID - The target subscription ID
  - TF_STATE_STORAGE_ACCOUNT_NAME - The name of the storage account to hold TF state
  - TF_STATE_STORAGE_ACCOUNT_CONTAINER_NAME - The name of the storage container to hold the TF state
5. Create a storage account and container to host TF state.
6. Grant the workload identity the 'Storage Blob Data Owner' role on the storage account.
7. All code added to the "terraform" folder will be deployed when the pipeline is run. There are multiple solutions in this repository, all designed to be deployed independently. Copy the required solution into the "terraform" folder.
