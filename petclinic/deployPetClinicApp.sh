#!/bin/bash

# ==== Must Cusomize the below for your environment====
subscription=''
resource_group=''
region=''
spring_cloud_service=''
mysql_server_name=''
mysql_server_admin_name=''
mysql_server_admin_password=''

#Add Required extensions
az extension add --name spring

#Create directory for github code
cd 
mkdir source-code
cd source-code

#Clone GitHub Repo
git clone https://github.com/felipmiguel/spring-petclinic-microservices
cd spring-petclinic-microservices
./mvnw clean package -DskipTests


# ==== Service and App Instances ====
api_gateway='api-gateway'
admin_server='admin-server'
customers_service='customers-service'
vets_service='vets-service'
visits_service='visits-service'


# ==== JARS ====
api_gateway_jar='spring-petclinic-api-gateway/target/spring-petclinic-api-gateway-3.0.1.jar'
admin_server_jar='spring-petclinic-admin-server/target/spring-petclinic-admin-server-3.0.1.jar'
customers_service_jar='spring-petclinic-customers-service/target/spring-petclinic-customers-service-3.0.1.jar'
vets_service_jar='spring-petclinic-vets-service/target/spring-petclinic-vets-service-3.0.1.jar'
visits_service_jar='spring-petclinic-visits-service/target/spring-petclinic-visits-service-3.0.1.jar'

# ==== MYSQL INFO ====
mysql_server_full_name="${mysql_server_name}.privatelink.mysql.database.azure.com"
mysql_server_admin_login_name="${mysql_server_admin_name}@${mysql_server_full_name}"
mysql_database_name='petclinic'

# az login
az account set --subscription ${subscription}

az configure --defaults group=${resource_group} location=${region} spring=${spring_cloud_service}
az spring config-server set --config-file application.yml --name ${spring_cloud_service}

az spring app create --name ${api_gateway} --instance-count 1 --assign-endpoint true \
    --memory 2Gi --jvm-options='-Xms2048m -Xmx2048m' &
az spring app create --name ${admin_server} --instance-count 1 --assign-endpoint true \
    --memory 2Gi --jvm-options='-Xms2048m -Xmx2048m' &
az spring app create --name ${customers_service} \
    --instance-count 1 --memory 2Gi --jvm-options='-Xms2048m -Xmx2048m' &
az spring app create --name ${vets_service} \
    --instance-count 1 --memory 2Gi --jvm-options='-Xms2048m -Xmx2048m' &
az spring app create --name ${visits_service} \
    --instance-count 1 --memory 2Gi --jvm-options='-Xms2048m -Xmx2048m' &

wait 

# increase connection timeout
az mysql server configuration set --name wait_timeout \
 --resource-group ${resource_group} \
 --server ${mysql_server_name} --value 2147483 

echo 'Create firewall rule for current machine in mysql server'
my_ip=$(curl http://whatismyip.akamai.com)
az mysql server firewall-rule create \
    --resource-group ${resource_group} \
    --server-name ${mysql_server_name} \
    --name AllowCurrentMachineToConnect \
    --start-ip-address ${my_ip} \
    --end-ip-address ${my_ip}

#mysql Configuration 
mysql -h"${mysql_server_full_name}" -u"${mysql_server_admin_login_name}" \
     -p"${mysql_server_admin_password}" \
     -e "CREATE DATABASE IF NOT EXISTS petclinic;CREATE USER IF NOT EXISTS 'root' IDENTIFIED BY 'petclinic';GRANT ALL PRIVILEGES ON petclinic.* TO 'root';CALL mysql.az_load_timezone();"

echo 'remove firewall rule for current machine in mysql server'
az mysql server firewall-rule delete \
    --resource-group ${resource_group} \
    --server-name ${mysql_server_name} \
    --yes \
    --name AllowCurrentMachineToConnect


az mysql server configuration set --name time_zone \
  --resource-group ${resource_group} \
  --server ${mysql_server_name} --value "US/Eastern"

az spring app deploy --name ${api_gateway} \
    --artifact-path ${api_gateway_jar} \
    --runtime-version Java_17 \
    --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' &

az spring app deploy --name ${admin_server} \
    --artifact-path ${admin_server_jar} \
    --runtime-version Java_17 \
    --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' &

az spring app deploy --name ${customers_service} \
--artifact-path ${customers_service_jar} \
--runtime-version Java_17 \
--jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' \
--env mysql_server_full_name=${mysql_server_full_name} \
      mysql_database_name=${mysql_database_name} \
      mysql_server_admin_login_name=${mysql_server_admin_login_name} \
      mysql_server_admin_password=${mysql_server_admin_password} &

az spring app deploy --name ${vets_service} \
--artifact-path ${vets_service_jar} \
--runtime-version Java_17 \
--jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' \
--env mysql_server_full_name=${mysql_server_full_name} \
      mysql_database_name=${mysql_database_name} \
      mysql_server_admin_login_name=${mysql_server_admin_login_name} \
      mysql_server_admin_password=${mysql_server_admin_password} &
      

az spring app deploy --name ${visits_service} \
--artifact-path ${visits_service_jar} \
--runtime-version Java_17 \
--jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql' \
--env mysql_server_full_name=${mysql_server_full_name} \
      mysql_database_name=${mysql_database_name} \
      mysql_server_admin_login_name=${mysql_server_admin_login_name} \
      mysql_server_admin_password=${mysql_server_admin_password} &

wait 

az spring app show --name ${api_gateway}
