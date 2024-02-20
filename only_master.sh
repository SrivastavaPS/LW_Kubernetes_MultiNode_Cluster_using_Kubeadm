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

# run in master node, in case you forgot the token
kubeadm token create --print-join-command 

# to add label/ROLES name to worker node
$ kubectl label node  <host name of worker node> (e.g. ip-172-31-42-227.ap-south-1.compute.internal)   node-role.kubernetes.io/worker=worker 

# You verify all the cluster component health statuses using the following command.
$ kubectl get --raw='/readyz?verbose'

Kubeadm doesn’t install metrics server component during its initialization.
$ kubectl apply -f https://raw.githubusercontent.com/techiescamp/kubeadm-scripts/main/manifests/metrics-server.yaml
$ kubectl top nodes # will show all resources, CPU(cores), CPU%, MEMORY(bytes), MEMORY%

-------------------------
by default, pods will get IP from local container, but as we have mentioned earlier in init command, it must take IP from 192.168.0.0/16 CIDR. 
Also, pods are not able to connect/ping pods of another worker
again, they are getting this IP from CRI-O
CRI-O can give same IP to pods in different nodes, for e.g. pod1 in worker node1 and pod2 in worker node2 can have same IPs. 
to overcome this, we need CNI program (Container Network Interface). and to implement the CNI, we will use CALICO software as below:- 

After Installing Calico CNI, nodes state will change to Ready state, DNS service inside the cluster would be functional and containers can start communicating with each other.
To install Calico CNI, run the following command from the master node
$ kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
or 
$ kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml

Before creating this manifest, read its contents and make sure its settings are correct for your environment. For example, you may need to change the default IP pool CIDR to match your pod network CIDR.

$ kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml
$ watch kubectl get pods -n calico-system
or 
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
or
(this link work perfectly)
https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml
----------------------------
curl -o https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml
edit the calico.yaml file as:-
# Auto-detect the BGP IP address.
            - name: IP
              value: "autodetect"
            - name: IP_AUTODETECTION_METHOD  # add this
              value: "interface=eth0"        # add this

$ kubectl apply -f calico.yaml   ----> it will create three pods of calico as we have two worker and one master

verify via kubectl get pods -n kube-system
calico-node -show-status  # to see the calico node status, run this command inside the calico pod
#calico behind the scene use bird program of BGP to connect to other nodes

calico-node -bird-live  # to see if bird is live or not
-------------------------

