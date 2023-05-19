
# Deploying the Landing Zones and Pet-Clinic microservices E2E using GitHub Actions

 To deploy the Azure Spring App Landing Zoner and deploy the petclinic microservices to Azure Spring Apps, we'll setup a GitHub Actions CI/CD workflow that will build and deploy our application whenever we push new commits to the main branch of our repository.

## What's CI/CD?

CI/CD stands for _Continuous Integration_ and _Continuous Delivery_.

Continuous Integration is a software development practice that requires developers to integrate code into a shared repository several times a day.
Each integration can then be verified by an automated build and automated tests.
By doing so, you can detect errors quickly, and locate them more easily.

Continuous Delivery pushes this practice further, by preparing for a release to production after each successful build.
By doing so, you can get working software into the hands of users faster.

## What's GitHub Actions?

[GitHub Actions](https://github.com/features/actions) is a service that lets you automate your software development workflows.
It allows you to run workflows that can be triggered by any event on the GitHub platform, such as opening a pull request or pushing a commit to a repository.

It's a great way to automate your CI/CD pipelines, and it's free for public repositories.

## Setting Up GitHub Actions for deployment

To set up GitHub Actions for deployment, we'll need to use the new workflow file in our repository.
This file will contain the instructions for our CI/CD pipeline.

## Setup secrets

We are using different secrets in our workflow: JUMP_BOX_PASSWORD and MYSQL_ADMIN_PASSWORD. Secrets in GitHub are encrypted and allow you to store sensitive information such as passwords or API keys, and use them in your workflows using the ${{ secrets.MY_SECRET }} syntax.

In GitHub, secrets can be defined at three different levels:

* Repository level: secrets defined at the repository level are available in all workflows of the repository.

* Organization level: secrets defined at the organization level are available in all workflows of the GitHub organization.

* Environment level: secrets defined at the environment level are available only in workflows referencing the specified environment.

For this workshop, we’ll define our secrets at the repository level. To do so, go to the Settings tab of your repository, and select Secrets then Actions under it, in the left menu.

Then select New repository secret and create secrets for JUMP_BOX_PASSWORD and MYSQL_ADMIN_PASSWORD.

## [!TIP]

You can also use the [GitHub CLI](https://cli.github.com) to define your secrets, using the command `gh secret set <MY_SECRET> -b"<SECRET_VALUE>" -R <repository_url>`

## Creating an Azure Service Principal

In order to deploy our Landing Zone and application to Azure Spring Apps, we'll need to create an Azure Service Principal.
This is an identity that can be used to authenticate to Azure, and that can be granted access to specific resources.

To create a new Service Principal, run the following commands:

```bash
    SUBSCRIPTION_ID=$(
      az account show \
        --query id \
        --output tsv \
        --only-show-errors
    )

    # Modify --name to your liking - must be unique in the directory
    AZURE_CREDENTIALS=$(
      MSYS_NO_PATHCONV=1 az ad sp create-for-rbac \
        --name="sp-${PROJECT}-${UNIQUE_IDENTIFIER}" \
        --role="Owner" \
        --scopes="/subscriptions/$SUBSCRIPTION_ID" \
        --sdk-auth \
        --only-show-errors
    )

    echo $AZURE_CREDENTIALS
    echo $SUBSCRIPTION_ID     
```

Then just like in the previous step, create a new secret in your repository named `AZURE_SUBSCRIPTION_ID`, `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`. You can copy paste these values from the AZURE_CREDENTIALS value returned in the cli. Also create another secret for  `AZURE_CREDENTIALS` and paste the value of the `AZURE_CREDENTIALS` variable as the secret value (make sure to _copy the entire JSon_).

![GitHub Secrets](../../../images/github_asa_secrets.png)

## Modify variables in `deploy_standard.yml`

The workflow file can be found in your repository with the path [`.github/workflows/deploy_standard.yml`](../../../.github/workflows/deploy_standard.yml) :

* Replace the value of the `SRINGAPPS_SPN_OBJECT_ID` environment variable in the [deploy_standard.yaml](../../../.github/workflows/deploy_standard.yml) file with the value of the the Object ID for the "Azure Spring Apps Resource Provider" service principal in your Azure AD Tenant.
You use the command below to obtain the value of the variable:

      az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv

* Replace the value of  TFSTATE_RG, STORAGEACCOUNTNAME and CONTAINERNAME in [deploy_standard.yaml](../../../.github/workflows/deploy_standard.yml) to point to your Terraform backend.
* You can also set the deploy_firewall and destroy values in [deploy_standard.yaml](../../../.github/workflows/deploy_standard.yml) depending on your usecase.

This workflow will be triggered every time a commit is pushed to the `main` branch.
It will then run a job with the following steps:

* Deploy 02 Hub Network
* Deploy 03 LZ Network
* Deploy 04 LZ Shared Resources
* Deploy 05 Hub Firewall
* Deploy 06 LZ Spring Apps Standard
* Deploy Pet Clinic Infrastructure

After the above steps are successful, you will have a functioning landing zone and the Azure Spring App instance available. After the above, the workflow also runs the below build step to build and deploy the petclinic microservices in the Azure Spring Apps instance.

* Build and Deploy Pet Clinic Microservices

Make sure to keep the correct indentation for the steps if you make changes to the deploy.yaml file directly.
YAML is very sensitive to indentation.

## [!TIP]

* If you do not want to provision the firewall or destroy the E2E infra once the pipeline run in complete, make sure to set those values to false in the deploy.yaml
* If a particular step errors out you can run only that step from the pipeline directly.Most errors should be transient errors.

## Running the workflow

Now that we've defined our workflow and prepared everything, we can run it to deploy our landing zone and the petclinic application to Azure Spring Apps.
Commit and push your changes to your repository, and go to the `Actions` tab of your repository to see the workflow running.
It should take a few minutes to complete.
A successful run using github actions should look like below:

![successful e2e run](../../../images/github_asa_successful_run.png)

## Testing the deployed application

Once your workflow is completed, let's make a quick test on our deployed apps.
First we need to get the ingress URL by running the following command:

```bash
    az spring app show -g rg-springlza-APPS -s spring-springlza-dev-o7o6 \
    --name api-gateway --query "properties.url" --output tsv    
```

Then we can use `curl` to test our applications using the above endpoint. This assumes that there's no Application Gateway and you would access your spring app using the spring apps ingress url for the api-gateway app instance. Since the applications are deployed in an internal only environment you would need to do the curl from a jumpbox or bastion host.
