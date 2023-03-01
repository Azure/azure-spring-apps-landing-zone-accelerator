# Cleanup

Remember to destroy resources that are not in use. The instructions below assume your terminal is at the "Scenarios/ASA-SecureBaseline/Terraform". If you are not there navigate there first. Delete in the order specified below to allow for resource dependancies. 

Ensure the following state management environment variables have been defined:
- STORAGEACCOUNTNAME = 'xxxxx'
- CONTAINERNAME      = 'xxxxx'
- TFSTATE_RG         = 'xxxxx'

1. Delete the Application gateway

   ```bash
   cd 07-AppGateway 
   ```

   ```bash
   terraform plan -destroy -out my.plan --var-file ../parameters.tfvars
   ```

   ```bash
   terraform apply my.plan
   ```

2. Delete Azure Spring Apps Standard (if you deployed Standard)

   ```bash
   cd ../06-LZ-SpringApps-Standard
   ```

   ```bash
   terraform plan -destroy -out my.plan --var-file ../parameters.tfvars
   ```

   ```bash
   terraform apply my.plan
   ```

   

3. Delete Azure Spring Apps Enterprise (if you deployed Enterprise)

   ```bash
   cd ../06-LZ-SpringApps-Enterprise
   ```

   ```bash
   terraform plan -destroy -out my.plan --var-file ../parameters.tfvars
   ```

   ```bash
   terraform apply my.plan
   ```

4. Delete the Azure Firewall (if you deployed the firewall)

   ```bash
   cd ../05-Hub-AzureFirewall
   ```

   ```bash
   terraform plan -destroy -out my.plan --var-file ../parameters.tfvars
   ```

   ```bash
   terraform apply my.plan
   ```

5. Delete the User Defined Routes for BYO Firewall (if you deployed this)

   ```bash
   cd ../05-Hub-BYO-Firewall-Routes
   ```

   ```bash
   terraform plan -destroy -out my.plan --var-file ../parameters.tfvars
   ```

   ```bash
   terraform apply my.plan
   ```

6. Delete the Shared Resources

   ```bash
   cd ../04-LZ-SharedResources
   ```

   ```bash
   terraform plan -destroy -out my.plan --var-file ../parameters.tfvars
   ```

   ```bash
   terraform apply my.plan
   ```

7. Delete the Spoke Virtual Network

   ```bash
   cd ../03-LZ-Network
   ```

   ```bash
   terraform plan -destroy -out my.plan --var-file ../parameters.tfvars
   ```

   ```bash
   terraform apply my.plan
   ```

8. Delete the Hub Virtual Network

   ```bash
   cd ../02-Hub-Network
   ```

   ```bash
   terraform plan -destroy -out my.plan --var-file ../parameters.tfvars
   ```

   ```bash
   terraform apply my.plan
   ```