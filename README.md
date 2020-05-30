# Raspberry Install Scripts
Scripts and configuration tunning i use to setup my raspberry cluster.

> For hardware & infrastructure requirements go see my other repo : https://github.com/armandleopold/raspberry-cluster

# Summary :

* [1. Download and install Operating System](#1-download-and-install-operating-system)
* [2. Boot Config](#2-boot-config)
* [3. Net Config](#3-net-config)
* [4. Install K3S](#4-install-k3s)
* [5. Install Rancher](#5-install-rancher)

# 4. Install Cluster Orchestrator environment

## Enabling legacy iptables on Raspbian Buster

Raspbian Buster defaults to using nftables instead of iptables. K3S networking features require iptables and do not work with nftables. Follow the steps below to switch configure Buster to use legacy iptables:

```
sudo iptables -F
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo reboot
```

## (Bonus) External storage configuration :

> from https://www.raspberrypi.org/documentation/configuration/external-storage.md

## K3S Install
> from https://rancher.com/docs/k3s/latest/en/installation/
> from https://k3s.io/
> from https://blog.alexellis.io/test-drive-k3s-on-raspberry-pi/

SSH to your master node pi and run :
Server install command:

```bash
export INSTALL_K3S_EXEC="server --cluster-init --disable=traefik --disable=local-storage --disable=metrics-server"
curl -sfL https://get.k3s.io | sh -s -
sudo cat /var/lib/rancher/k3s/server/node-token
```

Then SSH to you worker nodes pi and run :
Agent install command:
```bash
export K3S_TOKEN="K10c849c8167d47c8c174c1e42ad038ae06f2510cc7e77884308e4e3bb6c663f3d6::server:3e5e927f029c27d1cf12cc6522c9590f"
export K3S_URL="https://192.168.2.41:6443"
export INSTALL_K3S_EXEC="agent"
curl -sfL https://get.k3s.io | sh -s -
```

Check nodes : 

```bash
sudo kubectl get node -o wide
```

### Restart k3s

`sudo systemctl restart k3s`

## Helm Install

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

## Set user rights on master node : 

```bash
sudo chown -R pi:pi /etc/rancher/
```

# Install Local-path-provisioner (OpenEBS) : 

```
sudo cp openebs-operator-arm-dev.yaml /var/lib/rancher/k3s/server/manifests/

kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl get storageclass
```

# Install Traefik :
```
kubectl create namespace traefik
helm install traefik stable/traefik -f traefik.yaml --namespace traefik
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

# 5. Install Rancher

> from https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/helm-rancher/

```
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
kubectl create namespace cattle-system
helm install rancher rancher-latest/rancher -f rancher.yaml --namespace cattle-system
```

Wait a little bit, then go to : https://rancher.mydomain.com/

> ## Remove rancher :
> `helm uninstall rancher -n cattle-system`
>
> This is a known issue with removing an imported cluster (and in the process of being fixed) but you can remove it by running 
`kubectl edit namespace cattle-system` 
and remove the finalizer called `controller.cattle.io/namespace-auth` then save. Kubernetes won't delete an object that has a finalizer on it.
>
> `kubectl delete namespace cattle-system`

# 6. Install Prometheus 

> from https://github.com/helm/charts/tree/master/stable/prometheus

```
kubectl create namespace prometheus
helm install prometheus stable/prometheus -f prometheus.yaml --namespace prometheus
```

# 7. Install Grafana

> from https://github.com/helm/charts/tree/master/stable/grafana

```
helm install grafana stable/grafana -f grafana.yaml --namespace prometheus
```

Settings : https://grafana.com/docs/grafana/latest/installation/configuration/#admin-user

# 8. Install Gitlab Runners

> from https://docs.gitlab.com/runner/install/kubernetes.html

```
helm repo add gitlab https://charts.gitlab.io
helm repo update
kubectl create namespace gitlab
helm install --namespace gitlab gitlab-runner -f gitlab-runner.yaml gitlab/gitlab-runner
```

## Sources : 
* http://www.pidramble.com/wiki
* https://blog.alexellis.io/serverless-kubernetes-on-raspberry-pi/
* https://gitlab.com/xavki/raspberry-tricks
* https://github.com/likamrat/ARMadillo
* https://github.com/Raspbernetes
