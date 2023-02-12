# Provisioning (et deprovisioning) d'un cluster AKS

Cette section contient un ensemble de scripts pour créer et supprimer un cluster Azure Kubernetes Services.
Deux pipelines CI/CD Azure Pipelines permettent d'orchestrer et automatiser l'exécution de ces script:
- un pour la création du cluster et sa configuration
- un pour sa suppression

Certains éléments de configurations sont spécifiques à l'écosystème Software AG, la vocation principale de ces scripts et pipelines étant de fournir rapidement des clusters AKS pour des démos et PoC / PoV.

## Pre-requis

### Souscription Azure

Vous devez (bien entendu) avoir un tenant Azure avec un abonnement valide.
Un service principal (SP) est nécessaire pour toutes les actions automatisées dans Azure. C'est en quelque sorte un utilisateur technique.
Ce service principal doit avoir les habilitations nécessaires pour gérer les ressources Azure. J'ai alloué le rôle Contributor, mais si vous voulez allouer les autorisations au plus juste vous pouvez allouer des rôles avec une granularité plus fine (par exemple "Virtual Machine Contributor".)
Voir cette page: https://learn.microsoft.com/fr-fr/azure/active-directory/develop/howto-create-service-principal-portal (utilisez l'option 2 pour l'authentification.)

Niveau configuration vous aurez besoin de:
-   l'ID de votre tenant Azure, à positionner dans AZ_TENANT_ID
-   l'ID de votre service principal et son secret (chaîne de caractères longue faisant office de mot de passe), à positionner dans AZ_SP_ID et AZ_SP_SECRET

### Organisation Azure Pipelines

Vous aurez également besoin d'une organisation Azure Pipelines.
Rendez-vous sur https://dev.azure.com pour en obtenir une.

### Agent Azure Pipelines

Je fais tourner ces pipelines sur un agent local, dans lequel j'ai installé tout l'outillage nécessaire.

Installation d'un agent Azure Pipelines local: https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=browser

Installation des outils :
```
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" > /dev/null
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
apt install -y nodejs
apt install -y npm
npm install -g newman
```

### Azure Container Registry 

Optionnel.
Si vous avez un ACR vous pouvez configurer un secret Kubernetes en renseignant son URL dans la variable AZ_ACR_URL et votre adresse email dans EMAIL_ADDRESS.
La connexion à l'ACR s'effectue par le biais du service principal mentionné plus haut.

### Software AG container registry

Optionnel.
Si vous avez un compte sur containers.softwareag.com vous pouvez renseigner votre identifiant dans SAG_DOCKER_USERNAME, votre secret dans SAG_DOCKER_PASSWORD et votre adresse email dans EMAIL_ADDRESS.
Le pipeline se chargera alors de configurer un secret Kubernetes pour accéder à ce container registry.

### License du microservice runtime Software AG

Optionnel.
Si vous avez un fichier de licence (au format XML) pour le microservice runtime, indiquez sont emplacement (chemin complet incluant le nom du fichier XML) dans la variable MSR_LICENSE_FILE.
Le pipeline se chargera alors de configurer un secret Kubernetes pour ce fichier de licence, ce qui permettra de le monter en tant que volume dans les pods.

### Certificat serveur TLS

Optionnel.
Si vous avez un certificat TLS, indiquez l'emplacement de la clé privée (au format PEM) dans la variable TLS_KEY_FILE, et celui du certificat (également au format PEM) dans TLS_CERT_FILE.
Le pipeline se chargera alors de configurer un secret Kubernetes pour ce certificat, ce qui permettra de l'utiliser dans les ingress Kubernetes.


## Configuration

Les scripts nécessitent des éléments de configuration, qui sont divisés en deux catégories :
-   tout ce qui est non confidentiel est géré dans config_aks.sh et dans la bibliothèque de variables aks.variables d'Azure Pipelines
-   tout ce qui confidentiel est géré dans secrets_aks.sh, fichier qui est positionné dans la section "fichiers sécurisés" (secure files) d'Azure Pipeline

### config_aks.sh

Le pipeline de création contient une clause qui lit le contenu de la bibliothèque aks.variables :
```
variables:
  - group: aks.variables
```

Le script config_aks.sh reprend ces variables, et positionne des valeurs par défaut lorsqu'elles sont manquantes :
```
# The resource group in which the AKS cluster is to be created
export RESOURCE_GROUP=${RESOURCE_GROUP:-"aks_rg"} 
# The region in which the AKS cluster is to be created                          
export LOCATION=${LOCATION:-"westeurope"} 
# The VM size to be used for worker nodes                                  
export VM_SIZE=${VM_SIZE:-"Standard_B4ms"} 
# The name of the AKS cluster                                 
export CLUSTER_NAME=${CLUSTER_NAME:-"myaks"} 
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
```

### secrets_aks.sh

```
# ID du tenant Azure
export AZ_TENANT_ID=
# ID du service principal Azure
export AZ_SP_ID=
# Secret associé au service principal Azure
export AZ_SP_SECRET=

# URL de l'Azure Container Registry
export AZ_ACR_URL=

# ID de l'utilisateur de containers.softwareag.com
export SAG_DOCKER_USERNAME=
# Secret associé à l'utilisateur de containers.softwareag.com
export SAG_DOCKER_PASSWORD=

# Adresse email
export EMAIL_ADDRESS=

# Emplacement de la clé privée du certificat TLS (format PEM)
export TLS_KEY_FILE=/path/to/cert.key
# Emplacement du certificat TLS (format PEM)
export TLS_CERT_FILE=/path/to/cert.crt

# Emplacement de la license du microservice runtime
export MSR_LICENSE_FILE=/path/to/msr-license.xml
```

## Les scripts

### 00-az-login.sh

Ouvre une session Azure sur le tenant AZ_TENANT_ID avec le service provider dont les informations son renseignées dans AZ_SP_ID et AZ_SP_SECRET.

### 01-create_rg.sh

Crée le resource group RESOURCE_GROUP dans la région LOCATION.

### 02-create_cluster.sh

Crée le cluster Kubernetes avec :
- le nom spécifié dans CLUSTER_NAME
- le resource group RESOURCE_GROUP
- le nombre de noeuds spécifiés dans NODE_COUNT
- des VM dont le dimensionnement est spécifié dans VM_SIZE
- un load balancer dont le SKU est spécifié dans LOAD_BALANCER_SKU

### 03-create_kubeconfig.sh

Récupère les credentials kubectl pour accéder au cluster Kubernetes CLUSTER_NAME localisé dans la région LOCATION.

### 04-create_sagacr_secret.sh

Vérifie si la variable SAG_DOCKER_USERNAME est positionnée, et si c'est le cas crée un secret Kubernetes en utilisant SAG_DOCKER_URL, SAG_DOCKER_USERNAME, SAG_DOCKER_PASSWORD et EMAIL_ADDRESS.

### 05-create_myacr_secret.sh

Vérifie si la variable AZ_ACR_URL est positionnée, et si c'est le cas crée un secret Kubernetes en utilisant AZ_ACR_URL, AZ_SP_ID, AZ_SP_SECRET et EMAIL_ADDRESS.

### 06-create_msr_license_secret.sh

Vérifie si la variable MSR_LICENSE_FILE pointe vers un fichier existant, et si c'est le cas c'ée un secret Kubernetes en utilisant vers lequel MSR_LICENSE_FILE pointe.

### 07-create_env_secret.sh

Crée un secret Kubernetes nommé global-secrets contenant le nom de l'utilisateur et le mot de passe pour se connecté à Elastic Search, positionnés dans FLUENT_ELASTICSEARCH_USER et FLUENT_ELASTICSEARCH_PASSWORD.
Ce secret sert à la configuration de FluentD pour le monitoring applicatif du cluster.

### 08-create_env_configmap.sh

Crée une configMap Kubernetes nommée global-config contenant l'url, le port et le scheme pour se connecter à Elastic Search, positionnés dans FLUENT_ELASTICSEARCH_HOST, FLUENT_ELASTICSEARCH_PORT et FLUENT_ELASTICSEARCH_SCHEME.
Cette configMap sert à la configuration de FluentD pour le monitoring applicatif du cluster.

### 09-create_ssl_secret.sh

Vérifie si la variable TLS_KEY_FILE pointe sur un fichier existant, et si c'est le cas crée un secret Kubernetes de type TLS stockant la clé privée TLS_KEY_FILE et la partie publique du certificat TLS_CERT_FILE.
Ce secret sert ensuite à la configuration des ingress Kubernetes.

### 10-install_ingress.sh

Installe un contrôler Ingress nginx en utilisant helm, dans le namespace ingress-basic.
On utilise une annocation spécifique à Azure pour associer au contrôleur l'adresse ${CLUSTER_NAME}"ingress".${LOCATION}.cloudapp.azure.com
Cette annotation permet d'allouer une adresse DNS fixe au contrôleur ingress.
Personnellement j'associe cette adresse à un nom de domaine que je possède à l'aide d'une clé DNS de type CNAME, ça me permet d'utiliser une adresse simple pour accéder à mes microservices, et ça me permet également d'ajouter facilement la gestion du TLS avec un certificat serveur letsencrypt associé à mon nom de domaine.

### 11-install_prometheus-grafana.sh

Installe et configure Prometheus et Grafana sur le cluster Kubernetes dans le namespace monitoring, en utilisant des descripteurs yaml situés dans le répertoire monitoring.
Ces deux logiciels sont utilisés pour des démos donc je n'ai pas géré de couche de persistance des données.

### 12-install_fluentD.sh

Installe et configure FluentD en utilisant des descripteurs yaml situés dans le répertoire monitoring.
FluentD se connecte à un Elastic Search spécifié par les variables FLUENT_ELASTICSEARCH_HOST, FLUENT_ELASTICSEARCH_PORT, FLUENT_ELASTICSEARCH_SCHEME, FLUENT_ELASTICSEARCH_USER et FLUENT_ELASTICSEARCH_PASSWORD.

### 99-delete_rg.sh

Supprime le resource group RESOURCE_GROUP, avec tout ce qui s'y trouve (y compris donc le cluster Kubernetes.)
Utilisé uniquement par le pipeline de supression.