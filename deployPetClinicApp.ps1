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
C:\ProgramData\chocolatey\lib\maven\apache-maven-3.6.3\bin\mvn clean package -DskipTests -Denv=cloud

# ==== Service and App Instances ====
$API_GATEWAY='api-gateway'
$ADMIN_SERVER='admin-server'
$CUSTOMERS_SERVICE='customers-service'
$VETS_SERVICE='vets-service'
$VISITS_SERVICE='visits-service'

# ==== JARS ====
$API_GATEWAY_JAR='C:\source-code\spring-petclinic-microservices\spring-petclinic-api-gateway\target\spring-petclinic-api-gateway-2.3.6.jar'
$ADMIN_SERVER_JAR='C:\source-code\spring-petclinic-microservices\spring-petclinic-admin-server\target\spring-petclinic-admin-server-2.3.6.jar'
$CUSTOMERS_SERVICE_JAR='C:\source-code\spring-petclinic-microservices\spring-petclinic-customers-service\target\spring-petclinic-customers-service-2.3.6.jar'
$VETS_SERVICE_JAR='C:\source-code\spring-petclinic-microservices\spring-petclinic-vets-service\target\spring-petclinic-vets-service-2.3.6.jar'
$VISITS_SERVICE_JAR='C:\source-code\spring-petclinic-microservices\spring-petclinic-visits-service\target\spring-petclinic-visits-service-2.3.6.jar'

# ==== MYSQL INFO ====
$MYSQL_SERVER_FULL_NAME="$MYSQL_SERVER_NAME.privatelink.mysql.database.azure.com"
$MYSQL_SERVER_ADMIN_LOGIN_NAME="$MYSQL_SERVER_ADMIN_NAME@$MYSQL_SERVER_FULL_NAME"
$MYSQL_DATABASE_NAME='petclinic'

Set-Location 'C:\source-code\spring-petclinic-microservices'

az login
az account set --subscription $SUBSCRIPTION

az configure --defaults group=$RESOURCE_GROUP location=$REGION spring-cloud=$SPRING_CLOUD_SERVICE
az spring-cloud config-server set --config-file application.yml --name $SPRING_CLOUD_SERVICE

az spring-cloud app create --name $API_GATEWAY --instance-count 1 --is-public true `
    --memory 2 --jvm-options='-Xms2048m -Xmx2048m'
az spring-cloud app create --name $ADMIN_SERVER --instance-count 1 --is-public true `
    --memory 2 --jvm-options='-Xms2048m -Xmx2048m'
az spring-cloud app create --name $CUSTOMERS_SERVICE `
    --instance-count 1 --memory 2 --jvm-options='-Xms2048m -Xmx2048m'
az spring-cloud app create --name $VETS_SERVICE `
    --instance-count 1 --memory 2 --jvm-options='-Xms2048m -Xmx2048m'
az spring-cloud app create --name $VISITS_SERVICE `
    --instance-count 1 --memory 2 --jvm-options='-Xms2048m -Xmx2048m'

# increase connection timeout
az mysql server configuration set --name wait_timeout `
 --resource-group $RESOURCE_GROUP  `
 --server $MYSQL_SERVER_NAME --value 2147483

#mysql Configuration 
mysql -h"$MYSQL_SERVER_FULL_NAME" -u"$MYSQL_SERVER_ADMIN_LOGIN_NAME" `
     -p"$MYSQL_SERVER_ADMIN_PASSWORD" `
     -e  "CREATE DATABASE petclinic;CREATE USER 'root' IDENTIFIED BY 'petclinic';GRANT ALL PRIVILEGES ON petclinic.* TO 'root';"

mysql -h"$MYSQL_SERVER_FULL_NAME" -u"$MYSQL_SERVER_ADMIN_LOGIN_NAME" `
     -p"$MYSQL_SERVER_ADMIN_PASSWORD" `
     -e  "CALL mysql.az_load_timezone();"

az mysql server configuration set --name time_zone `
  --resource-group $RESOURCE_GROUP `
  --server $MYSQL_SERVER_NAME --value "US/Eastern"

az spring-cloud app deploy --name $API_GATEWAY `
    --jar-path $API_GATEWAY_JAR `
    --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql'

az spring-cloud app deploy --name $ADMIN_SERVER `
    --jar-path $ADMIN_SERVER_JAR `
    --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql'

az spring-cloud app deploy --name $CUSTOMERS_SERVICE `
--jar-path $CUSTOMERS_SERVICE_JAR `
--jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' `
--env MYSQL_SERVER_FULL_NAME=$MYSQL_SERVER_FULL_NAME `
      MYSQL_DATABASE_NAME=$MYSQL_DATABASE_NAME `
      MYSQL_SERVER_ADMIN_LOGIN_NAME=$MYSQL_SERVER_ADMIN_LOGIN_NAME `
      MYSQL_SERVER_ADMIN_PASSWORD=$MYSQL_SERVER_ADMIN_PASSWORD

az spring-cloud app deploy --name $VETS_SERVICE `
--jar-path $VETS_SERVICE_JAR `
--jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' `
--env MYSQL_SERVER_FULL_NAME=$MYSQL_SERVER_FULL_NAME `
      MYSQL_DATABASE_NAME=$MYSQL_DATABASE_NAME `
      MYSQL_SERVER_ADMIN_LOGIN_NAME=$MYSQL_SERVER_ADMIN_LOGIN_NAME `
      MYSQL_SERVER_ADMIN_PASSWORD=$MYSQL_SERVER_ADMIN_PASSWORD
      

az spring-cloud app deploy --name $VISITS_SERVICE `
--jar-path $VISITS_SERVICE_JAR `
--jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' `
--env MYSQL_SERVER_FULL_NAME=$MYSQL_SERVER_FULL_NAME `
      MYSQL_DATABASE_NAME=$MYSQL_DATABASE_NAME `
      MYSQL_SERVER_ADMIN_LOGIN_NAME=$MYSQL_SERVER_ADMIN_LOGIN_NAME `
      MYSQL_SERVER_ADMIN_PASSWORD=$MYSQL_SERVER_ADMIN_PASSWORD

az spring-cloud app show --name $API_GATEWAY
