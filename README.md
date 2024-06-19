# Helm charts
Repository contains Helm charts for Kubernetes
## Installiation
### Install Helm
#### From script
```bash
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```
#### From Homebrew (macOS)
```bash
brew install helm
```
#### From Apt (Debian/Ubuntu)
```bash
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```
### Install Helm secrets plugin
```bash
helm plugin install https://github.com/jkroepke/helm-secrets --version v3.9.1
```
## Usage
### Create a new chart
```bash
helm create $chart
```
### Install chart with helm secrets
```bash
helm secrets install -n $namespace $release $chart -f  secrets.yaml
```
### Uninstall chart
```bash
helm secrets uninstall -n $namespace $release
```
## Links
### Helm 
https://helm.sh/docs/intro/
### Helm secrets plugin
https://github.com/jkroepke/helm-secrets/blob/main/README.md
