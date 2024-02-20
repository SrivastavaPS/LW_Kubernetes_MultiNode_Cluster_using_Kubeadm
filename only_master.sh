#only in Master:-
kubeadm init --pod-network-cidr 192.168.0.0/16 # to set the IP range you need to provide for pods, calico suggests to use this 192.168.0.0/16 range, we can change the IP address range of svc, dns name , node name, k8s versions, api-server IP address, etc. (check detiails with kubeadm init -h)

#to make master as one of the user, internally configures your system as client system
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config


kubectl get pods                #verify if k8s is installed correctly
kubectl get pods -n kube-system #verify if k8s is installed correctly

kubectll get nodes # will give nodes details, here you will see list of nodes, currently this system only

# By default, apps won’t get scheduled on the master node. If you want to use the master node for scheduling apps, taint the master node.
$ kubectl taint nodes --all node-role.kubernetes.io/control-plane-

