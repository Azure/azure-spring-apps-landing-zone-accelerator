# ==== Resource Group ====
$env:SUBSCRIPTION='43fb1e17-a50d-49df-98c1-056e68b19779'
$env:RESOURCE_GROUP='sc-corp-rg'
$env:REGION='eastus'

# ==== Service and App Instances ====
$env:SPRING_CLOUD_SERVICE='spring-zxzmcnomysx17'
$env:API_GATEWAY='api-gateway'
$env:ADMIN_SERVER='admin-server'
$env:CUSTOMERS_SERVICE='customers-service'
$env:VETS_SERVICE='vets-service'
$env:VISITS_SERVICE='visits-service'

# ==== JARS ====
$env:API_GATEWAY_JAR='C:\Users\azureuser\source-code\spring-petclinic-microservices\spring-petclinic-api-gateway\target\spring-petclinic-api-gateway-2.3.6.jar'
$env:ADMIN_SERVER_JAR='C:\Users\azureuser\source-code\spring-petclinic-microservices\spring-petclinic-admin-server\target\spring-petclinic-admin-server-2.3.6.jar'
$env:CUSTOMERS_SERVICE_JAR='C:\Users\azureuser\source-code\spring-petclinic-microservices\spring-petclinic-customers-service\target\spring-petclinic-customers-service-2.3.6.jar'
$env:VETS_SERVICE_JAR='C:\Users\azureuser\source-code\spring-petclinic-microservices\spring-petclinic-vets-service\target\spring-petclinic-vets-service-2.3.6.jar'
$env:VISITS_SERVICE_JAR='C:\Users\azureuser\source-code\spring-petclinic-microservices\spring-petclinic-visits-service\target\spring-petclinic-visits-service-2.3.6.jar'

# ==== MYSQL INFO ====
$env:MYSQL_SERVER_NAME='mysql-zxzmcnomysx17' # customize this
$env:MYSQL_SERVER_FULL_NAME="${MYSQL_SERVER_NAME}.mysql.database.azure.com"
$env:MYSQL_SERVER_ADMIN_NAME='myadmin' # customize this
$env:MYSQL_SERVER_ADMIN_LOGIN_NAME="${MYSQL_SERVER_ADMIN_NAME}\@${MYSQL_SERVER_NAME}"
$env:MYSQL_SERVER_ADMIN_PASSWORD='P@ssw0rd12345' # customize this
$env:MYSQL_DATABASE_NAME='petclinic'

# ==== KEY VAULT Info ====
$env:KEY_VAULT='kv-zxzmcnomysx17' # customize this

Set-Location 'C:\Users\azureuser\source-code\spring-petclinic-microservices'

az login
az account list -o table
az account set --subscription $env:SUBSCRIPTION
az group create --name $env:RESOURCE_GROUP --location $env:REGION
az configure --defaults group=$env:RESOURCE_GROUP location=$env:REGION spring-cloud=$env:SPRING_CLOUD_SERVICE
az spring-cloud config-server set --config-file application.yml --name $env:SPRING_CLOUD_SERVICE

az spring-cloud app create --name $env:API_GATEWAY --instance-count 1 `
    --memory 2 --jvm-options='-Xms2048m -Xmx2048m'
az spring-cloud app create --name $env:ADMIN_SERVER --instance-count 1 `
    --memory 2 --jvm-options='-Xms2048m -Xmx2048m'
az spring-cloud app create --name $env:CUSTOMERS_SERVICE `
    --instance-count 1 --memory 2 --jvm-options='-Xms2048m -Xmx2048m'
az spring-cloud app create --name $env:VETS_SERVICE `
    --instance-count 1 --memory 2 --jvm-options='-Xms2048m -Xmx2048m'
az spring-cloud app create --name $env:VISITS_SERVICE `
    --instance-count 1 --memory 2 --jvm-options='-Xms2048m -Xmx2048m'

az spring-cloud app deploy --name $env:API_GATEWAY `
    --jar-path $env:API_GATEWAY_JAR `
    --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' --debug

az spring-cloud app deploy --name $env:ADMIN_SERVER `
    --jar-path $env:ADMIN_SERVER_JAR `
    --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql'


az spring-cloud app deploy --name $env:CUSTOMERS_SERVICE `
--jar-path $env:CUSTOMERS_SERVICE_JAR `
--jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' `
--env MYSQL_SERVER_FULL_NAME=$env:MYSQL_SERVER_FULL_NAME `
      MYSQL_DATABASE_NAME=$env:MYSQL_DATABASE_NAME `
      MYSQL_SERVER_ADMIN_LOGIN_NAME=$env:MYSQL_SERVER_ADMIN_LOGIN_NAME `
      MYSQL_SERVER_ADMIN_PASSWORD=$env:MYSQL_SERVER_ADMIN_PASSWORD


az spring-cloud app deploy --name $env:VETS_SERVICE `
--jar-path $env:VETS_SERVICE_JAR `
--jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' `
--env MYSQL_SERVER_FULL_NAME=$env:MYSQL_SERVER_FULL_NAME `
      MYSQL_DATABASE_NAME=$env:MYSQL_DATABASE_NAME `
      MYSQL_SERVER_ADMIN_LOGIN_NAME=$env:MYSQL_SERVER_ADMIN_LOGIN_NAME `
      MYSQL_SERVER_ADMIN_PASSWORD=$env:MYSQL_SERVER_ADMIN_PASSWORD
      

az spring-cloud app deploy --name $env:VISITS_SERVICE `
--jar-path $env:VISITS_SERVICE_JAR `
--jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' `
--env MYSQL_SERVER_FULL_NAME=$env:MYSQL_SERVER_FULL_NAME `
      MYSQL_DATABASE_NAME=$env:MYSQL_DATABASE_NAME `
      MYSQL_SERVER_ADMIN_LOGIN_NAME=$env:MYSQL_SERVER_ADMIN_LOGIN_NAME `
      MYSQL_SERVER_ADMIN_PASSWORD=$env:MYSQL_SERVER_ADMIN_PASSWORD