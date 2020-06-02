# Helm Install

SSH to your master node pi and run :

> from https://helm.sh/docs/intro/install/#helm
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update
```

Export k3s kubeconfig file as ENV var to override helm default get config path :
> from https://helm.sh/docs/helm/helm/

```bash
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bash_aliases
```

# Install Traefik :
```
kubectl create namespace traefik
helm install traefik stable/traefik -f traefik.yaml --namespace traefik
```

## Edit loadbalancer Nodeport :

Edit the port mapping to 443 => 32443 & 80 => 32080
```
kubectl edit service/traefik -n traefik
```

## Generate traefik dashboard user password :

> from https://www.digitalocean.com/community/tutorials/how-to-use-traefik-as-a-reverse-proxy-for-docker-containers-on-ubuntu-16-04

We’ll use the htpasswd utility to create this encrypted password. First, install the utility, which is included in the apache2-utils package:

```bash
sudo apt-get install -y apache2-utils
```
Then generate the password with htpasswd. Substitute `secure_password` with the password you’d like to use for the Traefik admin user:

```bash
htpasswd -nb admin secure_password
```
The output from the program will look like this:

```
admin: xxxxxxxxxxxxxx
```
  
## Edit traefik manifest 

> from https://github.com/helm/charts/tree/master/stable/traefik#configuration

At `/var/lib/rancher/k3s/server/manifests/traefik.yaml`
And add the following lines at the end :
```yaml
    serviceType: NodePort
    service:
      nodePorts:
        http: xxxxx # custom nodeport
        https: xxxxx # custom nodeport
    dashboard:
      enabled: true
      domain: "traefik.mydomain.com"
      auth:
        basic:
          admin: xxxxxxxxxxxxxx # the admin htpasswd you just generated
    acme:
      enabled: true
      logging: true
      staging: false
      caServer: "https://acme-v02.api.letsencrypt.org/directory"
      email: xxxxxxxxxxxxxx  # your email
      challengeType: "dns-01"
      dnsProvider:
        name: gcloud
        gcloud:
          GCE_PROJECT: "xxxxxxxxxxxxxx" # your Google Cloud Project
          GCE_SERVICE_ACCOUNT_FILE: "/secrets/gcloud-credentials.json"
      domains:
        enabled: true
        domainsList:
          - main: "*.mydomain.com"
          - sans:
            - "mydomain.com"
    secretFiles:
      gcloud-credentials.json: '{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}'
```

Then go to : `https://traefik.mydomain.com/dashboard/` to check if you succeed resolving the host, get correctly routed & get a response from a container on your cluster. If so, then you have a fully functionnal cluster !

> Nice tips for recreating a kube job :
> You can simulate a rerun by replacing the job with itself:
>
> `kubectl get job "your-job" -o json | kubectl replace --force -f -`

# Install Rancher

> from https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/helm-rancher/

```
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
kubectl create namespace cattle-system
helm install rancher rancher-latest/rancher -f rancher.yaml --namespace cattle-system
```

Wait a little bit, then go to : https://rancher.mydomain.com/

Edit deployements to `rancher/rancher-agent:v2.4.4-linux-arm64`

> ## Remove rancher :
> `helm uninstall rancher -n cattle-system`
>
> This is a known issue with removing an imported cluster (and in the process of being fixed) but you can remove it by running 
`kubectl edit namespace cattle-system` 
and remove the finalizer called `controller.cattle.io/namespace-auth` then save. Kubernetes won't delete an object that has a finalizer on it.
>
> `kubectl delete namespace cattle-system`

# Install Prometheus 

> from https://github.com/helm/charts/tree/master/stable/prometheus

```
kubectl create namespace prometheus
helm install prometheus stable/prometheus -f prometheus.yaml --namespace prometheus
```

# Install Grafana

> from https://github.com/helm/charts/tree/master/stable/grafana

```
helm install grafana stable/grafana -f grafana.yaml --namespace prometheus
```

Settings : https://grafana.com/docs/grafana/latest/installation/configuration/#admin-user

# Install Gitlab Runners

> from https://docs.gitlab.com/runner/install/kubernetes.html

```
helm repo add gitlab https://charts.gitlab.io
helm repo update
kubectl create namespace helm
kubectl create namespace docker
helm install --namespace helm gitlab-runner-helm -f gitlab-runner-helm.yaml gitlab/gitlab-runner
helm install --namespace docker gitlab-runner-docker -f gitlab-runner-docker.yaml gitlab/gitlab-runner
```
