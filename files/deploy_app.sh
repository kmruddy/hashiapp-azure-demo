#!/bin/bash
# Script to deploy a very simple web application.
# The web app has a customizable image and some text.

cat << EOM > /var/www/html/index.html
<html>
  <head><title>Hello Everyone!</title></head>
  <body>
  <div style="width:800px;margin: 0 auto">
  <!-- BEGIN -->
  <center><img src="${URL}"></img></center>
  <center><h1>${HAPP} says "Hello!" from Terraform ${WATFVER}!</h1></center>
  <center><h3>Sourcing Terraform ${RGTFVER} state, Resource Group Name: ${PREFIX}</h3></center>
  <center><h3>Sourcing Terraform ${NTFVER} state, FQDN: ${FQDN}</h3></center>
  <center><h3>Sourcing Terraform ${VMTFVER} state, the VM's name: ${VMNAME}</h3></center>
  <!-- END -->
  
  </div>
  </body>
</html>
EOM

echo "Script complete."