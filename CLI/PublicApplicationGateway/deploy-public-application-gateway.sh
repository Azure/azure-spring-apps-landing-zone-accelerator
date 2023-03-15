#!/bin/bash
echo "Enter name of application gateway: "
read name
appgw_name=$name

echo "Azure Spring Apps application backend URL: "
read ascapp
fqdn=$ascapp

echo "Enter file name of PFX Certificate in this directory: "
read namecert
cert=$namecert

echo "Enter password for PFX Certificate: "
read -s passcert
cert_pw=$passcert

echo "Enter Firewall name: "
read fwname
fw_name=$fwname 

az network public-ip create --resource-group ApplicationGateway --name appgw-pip --sku Standard --location eastus



az network application-gateway create \
  --name  $appgw_name \
  --location eastus \
  --resource-group sc-corp-rg \
  --vnet-name vnet-hub \
  --subnet application-gateway-subnet \
  --frontend-port appGatewayFrontendport \
  --capacity 2 \
  --sku WAF_V2 \
  --public-ip-address appgw-pip \
  --private-ip-address 10.9.3.10 \
  --http-settings-cookie-based-affinity Disabled \
  --http-settings-port 443 \
  --http-settings-protocol Https \
  --frontend-port 443 \
  --cert-file $cert \
  --cert-password $cert_pw


az network application-gateway address-pool update \
  --gateway-name $appgw_name \
  --name appGatewayBackendPool \
  --resource-group sc-corp-rg \
  --add backendAddresses fqdn=$fqdn


az network application-gateway http-settings update \
  --gateway-name $appgw_name \
  --resource-group sc-corp-rg \
  --name appGatewayBackendHttpSettings \
  --protocol Https \
  --port 443 \
  --timeout 60 \
  --path "//" \
  --host-name-from-backend-pool true

