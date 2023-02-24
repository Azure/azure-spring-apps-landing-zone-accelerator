# Get the local egress IP
data "http" "myip" {
  url = "http://whatismyip.akamai.com"
}

## If the above site is blocked in your environment
## here is a list of alternative sites
# https://ipv4.icanhazip.com
# https://ipecho.net/plain
# https://ident.me
# https://myexternalip.com/raw
# http://whatismyip.akamai.com

   
locals {
   myexternalip = ( var.My_External_IP == "" ? "${chomp(data.http.myip.response_body)}/32" : var.My_External_IP )  
}