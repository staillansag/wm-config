export RESOURCE_GROUP=${RESOURCE_GROUP:-"aks_rg"}
export LOCATION=${LOCATION:-"westeurope"}
export VM_SIZE=${VM_SIZE:-"Standard_B4ms"}
export CLUSTER_NAME=${CLUSTER_NAME:-"myaks"}
export NODE_COUNT=${NODE_COUNT:-"1"}
export LOAD_BALANCER_SKU=${LOAD_BALANCER_SKU:-"basic"}
export SAG_DOCKER_URL=${SAG_DOCKER_URL:-"sagcr.azurecr.io"}
