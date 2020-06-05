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
export INSTALL_K3S_EXEC="server --cluster-init --docker --disable=traefik --disable=local-storage --disable=metrics-server --datastore-endpoint=etcd"
curl -sfL https://get.k3s.io | sh -s -
sudo cat /var/lib/rancher/k3s/server/node-token
```

Then SSH to you worker nodes pi and run :
Agent install command:
```bash
export K3S_TOKEN=""
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

## Set user rights on master node : 

```bash
sudo chown -R pi:pi /etc/rancher/
```

# Install Local-path-provisioner (OpenEBS) : 

```
sudo cp openebs-operator-arm-dev.yaml /var/lib/rancher/k3s/server/manifests/

sudo kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
sudo kubectl get storageclass
```

## [Bonus] Add custom storage class (SSD/HDD/NVME external drives) :

> from https://docs.openebs.io/docs/next/uglocalpv-hostpath.html#create-storageclass

```bash
kubectl apply -f local-nvme-hostpath-sc.yaml
```
