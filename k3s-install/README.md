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
**Server** install command:

```bash
/usr/local/bin/k3s-killall.sh
export INSTALL_K3S_VERSION="v1.18.13+k3s1"
export INSTALL_K3S_EXEC="server \
  --cluster-init \
  --disable=traefik \
  --disable=local-storage \
  --disable=metrics-server \
  --kubelet-arg=system-reserved=cpu=1500m,memory=1500Mi \
  --kubelet-arg=kube-reserved=cpu=1500m,memory=1500Mi"
curl -sfL https://get.k3s.io | sh -s -
sudo cat /var/lib/rancher/k3s/server/node-token
systemctl restart k3s
```

Then SSH to you worker nodes pi and run :
Agent install command:
```bash
/usr/local/bin/k3s-killall.sh
export INSTALL_K3S_VERSION="v1.18.13+k3s1"
export K3S_TOKEN=""
export K3S_URL="https://192.168.2.39:6443"
curl -sfL https://get.k3s.io | sh -s -
systemctl restart k3s-agent
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
### Clean Nodes : 

```bash
# Drop exited containers
sudo k3s crictl ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo k3s crictl rm
# Drop unused images
sudo k3s crictl rmi --prune
```
