Here I am explaining this folder and what are the files present in it.
=========

0. As mentioned in this [step](https://github.com/Dakshjain1/DevOps_Project_Files#step-2) create 2 files -> The key and the vault.
---------------

1. `ansible.cfg`
---------------
This is the local Ansible Configuration file containing the details about what user to connect with in the [defaults] section & details about the [privilege_escalation] part.  

2. `vaultpass.txt`
------------------
Since the setup is completely automated so there s nobody to input the password of the vault. In this file the password to unlock the vault is stored & is directly passed while running the ansible playbook command.

3. `ec2.yml`
------------
This is the main file that setups the K8S Multi Node Cluster. It has 3 parts:
* Setting up Security Groups, Master & Worker Nodes.
* Calls the role files based on whetehr the working node is a worker or a master.
* Finally fetches the kubeconfig file from the master node to the work station.

4. `add_worker_to_elb.yml`
--------------------------
This file gathers the worker node IPs after the webApp is launched & presents the final DNS Hostname to the client/user where the site is launched.

-----------------------------------------
These playbooks are created by Daksh Jain.
For any queries, suggestions to improve the project, corrections please contact here:

[![Daksh Jain LinkedIn](https://github.com/Dakshjain1/photo/raw/master/linkedin.png)](https://www.linkedin.com/in/dakshjain09/)  [![Daksh Jain Medium](https://github.com/Dakshjain1/photo/raw/master/medium.png)](https://daksh-jain00.medium.com/)

I am always open to learn from the best minds !! :)
