Kubernetes Multi Node Cluster 
=========

A role to create a Kubernetes Multi Node Cluster - with 1 Master node & mutiple Worker nodes (by default 2, but scalable). The role can be used to setup the cluster on AWS Cloud.

Requirements
------------

If you already have EC2 instances created (master and worker instances) then you need to manually create the inventory - 
`
[master]
IP 1
[worker]
IP 2
IP 3
`
Meaning that 1 IP (of master) should have hostgroup name explicitly setup as "master" and rest IPs should have hostgroup name explicitly setup as "worker".

* If you want to even create the EC2 instances using ansible playbook automatically then you can use this playbook that I have created -
[AWS EC2 Instance Playbook](https://github.com/Dakshjain1/DevOps_Project_Files/tree/main/playbook_k8sMultiNodeCluster)
Go through the [README.md](https://github.com/Dakshjain1/DevOps_Project_Files/blob/main/README.md) of this repository for the requirements to run the `ec2.yml` file.
You will need to specify your AWS Access Key & AWS Secret Key.

Role Variables
--------------

This role doesn't require any variable to be specified by the user.

Dependencies
------------

This is a stand alone role, that will work as it is without any dependency on other Galaxy roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```
- hosts: master
  gather_facts: no
  tasks:
          - command: curl http://ipv4.icanhazip.com
            register: ip
          - debug:
                  var:  ip.stdout

          - name: Call the role
            include_role:
                    name: Dakshjain1.Ansible-Galaxy_K8SMultiNodeCluster_Role
            vars:
                    master_ip: "{{ ip.stdout }}"

- hosts: worker
  gather_facts: no
  tasks:
          - command: curl http://ipv4.icanhazip.com
            register: ip
          - debug:
                  var: ip.stdout
          - name: Call the role
            include_role:
                  name: Dakshjain1.Ansible-Galaxy_K8SMultiNodeCluster_Role

```

License
-------

BSD

Author Information
------------------

This Role is created by Daksh Jain.
For any queries, suggestions, corrections please contact here:

[![Daksh Jain LinkedIn](https://github.com/Dakshjain1/photo/raw/master/linkedin.png)](https://www.linkedin.com/in/dakshjain09/)  [![Daksh Jain Medium](https://github.com/Dakshjain1/photo/raw/master/medium.png)](https://daksh-jain00.medium.com/)

I am always open to learn from the best minds !! :)
