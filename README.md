# DevOps_Project_Files

### **Step 1**

Command to run the Terraform code to create 2 Roles, 2 Policies, 2 Instance Profiles and a VPC  -  ```vpc_ec2role.tf``` [works on this file]
```
terraform apply
```

### **Step 2**

Go inside the ```playbook_k8sMultiNodeCluster``` folder and add 2 files
1. Copy the .pem file downloaded from AWS as it is. This will be used to configure the EC2 Instances
2. Create an Ansible Vault to store the AWS Secret Key & Access Key in a secure fashion using the command:
```
ansible-vault create credentials.yml

access_key: ******************
secret_key: *******************************
```
Then you can run the playbook using the command 
```
ansible-playbook ec2.yml --ask-vault-pass
```
#### This will automatically call the role as well and complete the setting up of Kubernetes Multi-node Cluster on AWS Cloud with 1 Master node & 2 Worker nodes.

### **Step 3**

Now setup Helm
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh
```
Then add the required Helm repo
```
helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update
```
Then install the required Prometheus Helm chart in a new namespace - monitoring
```
kubectl create ns monitoring

helm install prometheus bitnami/kube-prometheus --namespace monitoring
```
Then to make sure Grafana can pull the metrics from Prometheus we need to make it work outside the ClusterIP. This can be done by using port-forwarding
```
kubectl port-forward --namespace default service/prometheus-kube-prometheus-prometheus  9090:9090 -n monitoring
```
**Now Prometheus will run on localhost:9090 in the host machine.**

### **Step 4**

Now we need to setup the e-mail notification in Grafana server. This will e-mail to the admin whenever an alert notifies.

To do this we need to make changes in the ```grafana.ini``` file

```
#################################### SMTP / Emailing ##########################
[smtp]
enabled = true
host = smtp.gmail.com:587
user = <Enter sender's e-mail here>
# If the password contains # or ; you have to wrap it with triple quotes. Ex """#password;"""
password = <Enter password here>
;cert_file =
;key_file =
skip_verify = true
;from_address = admin@grafana.localhost
;from_name = Grafana
# EHLO identity in SMTP dialog (defaults to instance_name)
;ehlo_identity = dashboard.example.com

[emails]
;welcome_email_on_sign_up = false
;templates_pattern = emails/*.html
```

### **Step 5**

Now when Developer will push the code from Git Bash, Jenkins Assembly Pipeline will be triggered:
•	Jenkins pulls the application code

•	Creates a Docker image with the updated code

•	Updates the Deployment file of Kubernetes 

•	Launches the Deployment pods & External Service

•	Ansible Playbook adds the worker nodes to the Load Balancer created - Present in the ```playbook_k8sMultiNodeCluster``` folder

•	Prometheus pulls the metrics of entire Kubernetes environment

•	Grafana keeps on monitoring the Memory Usage of the Pods and alerts the admin about any excessive usage by notifying via e-mail

•	Simultaneously Jenkins scales the pods as the load varies


