# SDP_TempCertGen

Script that automates the generation of a certificate for the Appgate SDP admin console.

The certificate will be converted to PKCS and uploaded to the Controler config.

Expects three arguments hostname password for PKCS cert email to register cert, the script will need you to allow port 80 access on the FW

The script is meant to be used with Appgate SDP collectives with only one appliance deployed.
