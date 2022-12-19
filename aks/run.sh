./00-az-login.sh || exit 1

./01-create_rg.sh || exit 2

./02-create_cluster.sh || exit 3

./03-create_kubeconfig.sh || exit 4

./04-create_sagacr_secret.sh || exit 5

./05-create_myacr_secret.sh || exit 6

./06-create_msr_license_secret.sh || exit 7

./07-create_env_secret.sh || exit 8

./08-create_env_configmap.sh || exit 9

./09-create_ssl_secret.sh || exit 10

./10-install_ingress.sh || exit 11

