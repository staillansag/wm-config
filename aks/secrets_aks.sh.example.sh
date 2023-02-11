export AZ_TENANT_ID=ID of your Azure tenant
export AZ_ACR_URL=URL of your Azure Container Registry (if you want to use one)
export AZ_SP_ID=Azure service principal ID (this service principal is used to connect to AKS and ACR)
export AZ_SP_SECRET=Azure service principal secret

export SAG_DOCKER_USERNAME=ID of your SAG container registry (containers.softwareag.com) user
export SAG_DOCKER_PASSWORD=Secret of your SAG container registry user
export EMAIL_ADDRESS=The email address attached to your SAG container registry user

export TLS_KEY_FILE=Path to the PEM file where your TLS certificate key is located
export TLS_CERT_FILE=Path to the PEM file where your TLS certificate is located
export MSR_LICENSE_FILE=Path to your MSR license XML file