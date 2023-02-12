# The resource group in which the AKS cluster is to be created
export RESOURCE_GROUP=${RESOURCE_GROUP:-"aks_rg"} 
# The region in which the AKS cluster is to be created                          
export LOCATION=${LOCATION:-"westeurope"} 
# The VM size to be used for worker nodes                                  
export VM_SIZE=${VM_SIZE:-"Standard_B4ms"} 
# The name of the AKS cluster                                 
export CLUSTER_NAME=${CLUSTER_NAME:-"myaks"} 
# The prefix for the DNS name allocated to the ingress, full path is ${DNS_LABEL_NAME}.${LOCATION}.cloudapp.azure.com                               
export DNS_LABEL_NAME=${DNS_LABEL_NAME:-$CLUSTER_NAME"ingress"}  
# The number of node in the cluster           
export NODE_COUNT=${NODE_COUNT:-"1"}  
# The load balancer SKU                                      
export LOAD_BALANCER_SKU=${LOAD_BALANCER_SKU:-"basic"}  
# The URL of the SAG container registry                    
export SAG_DOCKER_URL=${SAG_DOCKER_URL:-"sagcr.azurecr.io"}  
# The url of the elastic search to which FluentD can send log data               
export FLUENT_ELASTICSEARCH_HOST=${FLUENT_ELASTICSEARCH_HOST:-"localhost"}  
# The port of the elastic search
export FLUENT_ELASTICSEARCH_PORT=${FLUENT_ELASTICSEARCH_PORT:-"8080"}    
# The scheme to be use to connect to Elastic search (http or https)  
export FLUENT_ELASTICSEARCH_SCHEME=${FLUENT_ELASTICSEARCH_SCHEME:-"http"}
# Your domain name (used to configure ingresses)
export DOMAIN_NAME=${DOMAIN_NAME:-"example.com"}  