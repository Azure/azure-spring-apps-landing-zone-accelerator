#!/bin/bash
ARG=`az spring-cloud list --resource-group $1 --query '[0].properties.networkProfile.appNetworkResourceGroup' -o tsv`
RRG=`az spring-cloud list --resource-group $1 --query '[0].properties.networkProfile.serviceRuntimeNetworkResourceGroup' -o tsv`
AZFIP=`az network firewall list --resource-group $1 --query '[0].ipConfigurations[0].privateIpAddress' -o tsv`

for RG in $ARG $RRG
do
    RT=`az network route-table list --resource-group $RG --query '[0].{Name:name}' -o tsv`
    echo "Adding default route to the route table $RT in the resource group $RG"
    az network route-table route create --resource-group $RG --route-table-name $RT --name udr-default --next-hop-type VirtualAppliance --address-prefix 0.0.0.0/0 --next-hop-ip-address $AZFIP
done