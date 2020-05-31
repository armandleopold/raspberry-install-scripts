# Install Cluster Orchestrator environment

## Enabling legacy iptables on Raspbian Buster

Raspbian Buster defaults to using nftables instead of iptables. K3S networking features require iptables and do not work with nftables. Follow the steps below to switch configure Buster to use legacy iptables:

```
sudo iptables -F
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo reboot
```

## K3S Install
> from https://rancher.com/docs/k3s/latest/en/installation/
> from https://k3s.io/
> from https://blog.alexellis.io/test-drive-k3s-on-raspberry-pi/

SSH to your master node pi and run :
Server install command:

```bash
export INSTALL_K3S_EXEC="server --cluster-init --disable=traefik --disable=local-storage --disable=metrics-server --disable=servicelb --flannel-backend=ipsec --datastore-endpoint=etcd"
curl -sfL https://get.k3s.io | sh -s -
sudo cat /var/lib/rancher/k3s/server/node-token
```

Then SSH to you worker nodes pi and run :
Agent install command:
```bash
export K3S_TOKEN="K1062a533fdc4c61c890ea2bacb69a1bd98f1940660ada42cb8bfe1f49dfbc0531b::server:946aaba5eba13a9965954d1e79cd7e95"
export K3S_URL="https://192.168.2.39:6443"
export INSTALL_K3S_EXEC="agent"
curl -sfL https://get.k3s.io | sh -s -
```

Check nodes : 

```bash
sudo kubectl get node -o wide
```

### Restart k3s

`sudo systemctl restart k3s`

### Prioritize IO disk for K3S process

```bash
sudo ionice -c2 -n0 -p `pgrep k3s`
```

<!-- ## Set user rights on master node : 

```bash
sudo chown -R pi:pi /etc/rancher/
```

## Add k3sCredentials in kubernetes :

```bash
sudo cp /etc/rancher/k3s/k3s.yaml ./k3s.yaml
```

Edit file and replace server: `https://127.0.0.1:6443` to `https://192.168.2.39:6443`

```bash
sudo nano k3s.yaml
```

Add secret to k3s :

```bash
sudo kubectl create namespace openebs
sudo kubectl create secret generic k3screds --from-file=k3s.yaml -n openebs
```
 -->

# Install Local-path-provisioner (OpenEBS) : 

```
sudo cp openebs-operator-arm-dev.yaml /var/lib/rancher/k3s/server/manifests/

sudo kubectl patch storageclass openebs-jiva-default -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
sudo kubectl get storageclass
```