
#Install CLI extension
az extension add --name spring-cloud
az extension update --name spring-cloud

#Clone and build repo
mkdir source-code
cd .\source-code
git clone http://github.com/azure-samples/spring-petclinic-microservices

cd .\spring-petclinic-microservices
mvn clean package -DskipTests -Denv=cloud
