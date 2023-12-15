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
-   l'ID de votre tenant Azure
-   l'ID de votre service principal et son secret (chaîne de caractères longue faisant office de mot de passe)

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
apt install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -u awscliv2.zip
sudo ./aws/install
apt install -y openssh-client
apt install -y sshpass
```

nodejs et npm sont des pré-requis pour newman, qui permet d'exécuter des collections Postman en ligne de commande (tests d'APIs.)
La CLI AWS est utilisées dans certains steps de tests, où je vérifie la présencé de fichiers dans un bucket S3.
Le client ssh est lui utilisé dans les mêmes steps de test pour vérifier la présence de fichiers dans un serveur SFTP.


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
Si vous avez un nom de domaine et certificat TLS pour ce domaine, indiquez l'emplacement de la clé privée (au format PEM) dans la variable TLS_KEY_FILE, et celui du certificat (également au format PEM) dans TLS_CERT_FILE.
Le pipeline se chargera alors de configurer un secret Kubernetes pour ce certificat, ce qui permettra de l'utiliser dans les ingress Kubernetes.

## Configuration

### Bibliothèque de variables Azure (azure.variables)

| Name                   | Value                                                                                    |
|------------------------|------------------------------------------------------------------------------------------|
| AZ_LOCATION            | Code région Azure (par exemple westeurope)                                               |
| AZ_SANDBOX_MODE        | Indique que la souscription Azure est une sandbox acloud.guru (optionel)                 |
| AZ_SP_ID               | ID de votre service principal (c'est un uuid)                                            |
| AZ_SP_SECRET           | Secret de votre service principal                                                        |
| AZ_TENANT_ID           | ID de votre tenant Azure (c'est un uuid)                                                 |

### Bibliothèque de variables AKS (aks.variables)

| Name                   | Value                                                                                    |
|------------------------|------------------------------------------------------------------------------------------|
| AKS_RESOURCE_GROUP     | Nom du groupe de ressources Azure dans lequel le cluster est placé                       |
| AKS_CLUSTER_NAME       | Nom du cluster aks                                                                       |
| AKS_NODE_COUNT         | Nombre de worker nodes du cluster aks                                                    |
| AKS_VM_SIZE            | Type de VM Azure pour les worker nodes du cluster aks                                    |
| AKS_LOAD_BALANCER_SKU  | SKU du load balancer associé au contrôleur Ingress du cluster                            |
| AKS_DOMAIN_NAME        | Nom de domaine associé au contrôleur Ingress (optionnel)                                 |
| GANDI_PAT_TOKEN        | Token de l'api Gandi, permettant la création d'une entrée DNS pour l'ingress (optionnel) |

Notes:
- AKS_VM_SIZE et AKS_NODE_COUNT influent directement sur les coûts du cluster aks

Notes: 
- AKS_RESOURCE_GROUP est ignoré si AZ_SANDBOX_MODE = true, dans ce cas on utilise le groupe de ressource par défaut de la sandbox.
- GANDI_PAT_TOKEN est un peu un intrus dans cette liste de variables, il a été positionné ici pour éviter de créer une nouvelle bibliothèque de variables

### Bibliothèque de variables SAG (sag.variables)

| Name                   | Value                                                                                    |
|------------------------|------------------------------------------------------------------------------------------|
| SAG_ACR_URL            | URL du registre d'images SAG (devrait être une valeur fixe 'sagcr.azurecr.io')           |
| SAG_ACR_USERNAME       | Votre username au niveau du registre d'images SAG                                        |
| SAG_ACR_PASSWORD       | Votre mot de passe au niveau du registre d'images SAG                                    |
| SAG_ACR_EMAIL_ADDRESS  | L'adresse email enregistrée au niveau du registre d'images SAG                           |
| SAG_MSR_ADMIN_PASSWORD | Le mot de passe que vous souhaitez configurer pour le compte Administrator des MSR       |

### Licences des produits SAG

Le pipeline de création du cluster fonctionne avec 3 fichiers secrets (secure files) ayant les noms suivants:
- msr-license.xml: licence du MSR
- um-license.xml: licence de l'UM
- mcgw-license.xml: licence de la microgateway

### Certificat TLS

Si vous avez un nom de domaine et un certificat associé, il faut positionner 2 fichiers secrets avec les noms suivants:
- cert.crt: partie publique du certificat au format pem
- cert.key: partie privée du certificat au format pem

Dans les faits, rien ne nous oblige strictement à stocker la partie publique du certificat dans un fichier privé, on le fait par commodité. 

## Les scripts

### 00-az-login.sh

Ouvre une session Azure sur le tenant AZ_TENANT_ID avec le service provider dont les informations sont renseignées dans AZ_SP_ID et AZ_SP_SECRET.

### 01-create_rg.sh

Crée le groupe de ressources AKS_RESOURCE_GROUP dans la région AZ_LOCATION.
Si AZ_SANDBOX_MODE = true, alors on utilise le groupe de ressources par défaut de la souscription (acloud.guru empêche la création de groupes de ressources dans ses sandboxes.)

### 02-create_cluster.sh

Crée le cluster Kubernetes avec :
- le nom spécifié dans AKS_CLUSTER_NAME
- le resource group AKS_RESOURCE_GROUP
- le nombre de noeuds spécifiés dans AKS_NODE_COUNT
- des VM dont le dimensionnement est spécifié dans AKS_VM_SIZE
- un load balancer dont le SKU est spécifié dans AKS_LOAD_BALANCER_SKU

### 03-create_kubeconfig.sh

Récupère les credentials kubectl pour accéder au cluster Kubernetes CLUSTER_NAME localisé dans la région AZ_LOCATION.

### 04-create_sagacr_secret.sh

Vérifie si la variable SAG_ACR_USERNAME est positionnée, et si c'est le cas crée un secret Kubernetes en utilisant SAG_ACR_URL, SAG_ACR_USERNAME, SAG_ACR_PASSWORD et SAG_ACR_EMAIL_ADDRESS.

### 06-create_product_license_secrets.sh

Vérifie si la variable MSR_LICENSE_FILE (injectée par le pipeline) pointe vers un fichier existant, et si c'est le cas c'ée un secret Kubernetes en utilisant vers lequel MSR_LICENSE_FILE pointe.

### 07-create_env_secret.sh

### 08-create_env_configmap.sh

### 09-create_ssl_secret.sh

Vérifie si la variable TLS_PUBLICKEY_FILE_PATH pointe sur un fichier existant, et si c'est le cas crée un secret Kubernetes de type TLS stockant la clé privée TLS_PRIVATEKEY_FILE_PATH et la partie publique du certificat TLS_PUBLICKEY_FILE_PATH.
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