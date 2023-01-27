# ==== Must Cusomize the below for your environment====
$SUBSCRIPTION=''
$RESOURCE_GROUP='sc-corp-rg'
$REGION='eastus'
$SPRING_CLOUD_SERVICE=''
$MYSQL_SERVER_NAME=''
$MYSQL_SERVER_ADMIN_NAME='' 
$MYSQL_SERVER_ADMIN_PASSWORD=''


#Add Required extensions
az extension add --name spring-cloud

#Create directory for github code
Set-Location c:\
mkdir source-code
cd c:\source-code

#Clone GitHub Repo
git clone https://github.com/azure-samples/spring-petclinic-microservices
cd spring-petclinic-microservices
.\mvnw clean package -DskipTests

# ==== Service and App Instances ====
$API_GATEWAY='api-gateway'
$ADMIN_SERVER='admin-server'
$CUSTOMERS_SERVICE='customers-service'
$VETS_SERVICE='vets-service'
$VISITS_SERVICE='visits-service'

# ==== JARS ====
$API_GATEWAY_JAR='spring-petclinic-api-gateway\target\spring-petclinic-api-gateway-2.5.1.jar'
$ADMIN_SERVER_JAR='spring-petclinic-admin-server\target\spring-petclinic-admin-server-2.5.1.jar'
$CUSTOMERS_SERVICE_JAR='spring-petclinic-customers-service\target\spring-petclinic-customers-service-2.5.1.jar'
$VETS_SERVICE_JAR='spring-petclinic-vets-service\target\spring-petclinic-vets-service-2.5.1.jar'
$VISITS_SERVICE_JAR='spring-petclinic-visits-service\target\spring-petclinic-visits-service-2.5.1.jar'

# ==== MYSQL INFO ====
$MYSQL_SERVER_FULL_NAME="$MYSQL_SERVER_NAME.privatelink.mysql.database.azure.com"
$MYSQL_SERVER_ADMIN_LOGIN_NAME="$MYSQL_SERVER_ADMIN_NAME@$MYSQL_SERVER_FULL_NAME"
$MYSQL_DATABASE_NAME='petclinic'

Set-Location 'C:\source-code\spring-petclinic-microservices'

az login
az account set --subscription $SUBSCRIPTION

az configure --defaults group=$RESOURCE_GROUP location=$REGION spring=$SPRING_CLOUD_SERVICE
az spring config-server set --config-file application.yml --name $SPRING_CLOUD_SERVICE

az spring app create --name $API_GATEWAY --instance-count 1 --assign-endpoint true `
    --memory 2Gi --jvm-options='-Xms2048m -Xmx2048m' 
az spring app create --name $ADMIN_SERVER --instance-count 1 --assign-endpoint true `
    --memory 2Gi --jvm-options='-Xms2048m -Xmx2048m' 
az spring app create --name $CUSTOMERS_SERVICE `
    --instance-count 1 --memory 2Gi --jvm-options='-Xms2048m -Xmx2048m' 
az spring app create --name $VETS_SERVICE `
    --instance-count 1 --memory 2Gi --jvm-options='-Xms2048m -Xmx2048m' 
az spring app create --name $VISITS_SERVICE `
    --instance-count 1 --memory 2Gi --jvm-options='-Xms2048m -Xmx2048m' 

# increase connection timeout
az mysql server configuration set --name wait_timeout `
 --resource-group $RESOURCE_GROUP  `
 --server $MYSQL_SERVER_NAME --value 2147483

$MY_IP=(invoke-webrequest http://whatismyip.akamai.com).Content
az mysql server firewall-rule create `
    --resource-group $RESOURCE_GROUP `
    --server-name $MYSQL_SERVER_NAME `
    --name AllowCurrentMachineToConnect `
    --start-ip-address $MY_IP `
    --end-ip-address $MY_IP
#mysql Configuration 
mysqlsh -h"$MYSQL_SERVER_FULL_NAME" -u"$MYSQL_SERVER_ADMIN_LOGIN_NAME" `
     -p"$MYSQL_SERVER_ADMIN_PASSWORD" `
     -e  "CREATE DATABASE IF NOT EXISTS petclinic;CREATE USER IF NOT EXISTS 'root' IDENTIFIED BY 'petclinic';GRANT ALL PRIVILEGES ON petclinic.* TO 'root';CALL mysql.az_load_timezone();"

echo 'remove firewall rule for current machine in mysql server'
az mysql server firewall-rule delete `
    --resource-group $RESOURCE_GROUP `
    --server-name $MYSQL_SERVER_NAME `
    --yes `
    --name AllowCurrentMachineToConnect

az mysql server configuration set --name time_zone `
  --resource-group $RESOURCE_GROUP `
  --server $MYSQL_SERVER_NAME --value "US/Eastern"

az spring app deploy --name $API_GATEWAY `
    --artifact-path $API_GATEWAY_JAR `
    --runtime-version Java_17 `
    --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql'

az spring app deploy --name $ADMIN_SERVER `
    --artifact-path $ADMIN_SERVER_JAR `
    --runtime-version Java_17 `
    --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql'

az spring app deploy --name $CUSTOMERS_SERVICE `
--artifact-path $CUSTOMERS_SERVICE_JAR `
--runtime-version Java_17 `
--jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' `
--env MYSQL_SERVER_FULL_NAME=$MYSQL_SERVER_FULL_NAME `
      MYSQL_DATABASE_NAME=$MYSQL_DATABASE_NAME `
      MYSQL_SERVER_ADMIN_LOGIN_NAME=$MYSQL_SERVER_ADMIN_LOGIN_NAME `
      MYSQL_SERVER_ADMIN_PASSWORD=$MYSQL_SERVER_ADMIN_PASSWORD

az spring app deploy --name $VETS_SERVICE `
--artifact-path $VETS_SERVICE_JAR `
--runtime-version Java_17 `
--jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' `
--env MYSQL_SERVER_FULL_NAME=$MYSQL_SERVER_FULL_NAME `
      MYSQL_DATABASE_NAME=$MYSQL_DATABASE_NAME `
      MYSQL_SERVER_ADMIN_LOGIN_NAME=$MYSQL_SERVER_ADMIN_LOGIN_NAME `
      MYSQL_SERVER_ADMIN_PASSWORD=$MYSQL_SERVER_ADMIN_PASSWORD
      

az spring app deploy --name $VISITS_SERVICE `
--artifact-path $VISITS_SERVICE_JAR `
--runtime-version Java_17 `
--jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' `
--env MYSQL_SERVER_FULL_NAME=$MYSQL_SERVER_FULL_NAME `
      MYSQL_DATABASE_NAME=$MYSQL_DATABASE_NAME `
      MYSQL_SERVER_ADMIN_LOGIN_NAME=$MYSQL_SERVER_ADMIN_LOGIN_NAME `
      MYSQL_SERVER_ADMIN_PASSWORD=$MYSQL_SERVER_ADMIN_PASSWORD

az spring app show --name $API_GATEWAY
