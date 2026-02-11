# oci-genai-lab
This document is to guide how to use terraform to spin off OCI Generative AI Lab environment. 
For Generative AI Lab, start with Python library and Jupyter Notebook for data science and machine learning basic environment. Then there need to test RAG using Generative AI service and Oracle 23 ai Vector Search, langChain framework, with chatbot.

# Preparation
bash script file - init-genailabs.sh
download from  the GitHub link below 
https://github.com/ou-developers/ou-generativeai-pro/tree/main/labs


# Generate RSA key pair (Private Key in PEM format)
# Note: OCI API requires the private key to be in RSA PEM format.
ssh-keygen -t rsa -b 2048 -m PEM -f ../labskey.pem -N ""

# Generate the Public Key (for Instance SSH Access)
# (This is automatically created as ../labskey.pem.pub, rename if needed)
# ssh-keygen -y -f ../labskey.pem > ../labskey.pub

# Convert Public Key to PKCS8 PEM format (for OCI Console API Key upload)
ssh-keygen -e -m PKCS8 -f ../labskey.pem.pub > ../labskey_api.pub.pem

# ====== setting note. to change update the terraform/variables.tf file ===== #
## VCN 
# GENAI-LAB-VCN
# 10.7.0.0/16
# public: 10.7.0.0/24
# private: 10.7.1.0/24
## Default Security List for GENAI-LAB-VCN
# add Ingress_Rule: 8888,8501,1521  

## Instance
# Instance: GEN-AI-lab-Instance
# AD 1; on-demand, OL 8
# VM.Standard.E5.Flex; VCPU 2, RAM 24
# shield instance, Enabled SMT
# Boot volume 100G


## API key
## add public key to user - My Profile - Tokens and Keys - add API key - use pem key

# Edit variable tf and export to local terraform folder

edit terraform/variables.tf

# --- terraform part --- #
cd terraform
export ****ENV***var*** 
terraform init
terraform plan
terraform apply

#  Enter a value: yes
# oci_core_vcn.genai_vcn: Creating...
# oci_core_nat_gateway.genai_nat: Creating...
# oci_core_internet_gateway.genai_ig: Creating...
# oci_core_service_gateway.genai_sg: Creating...
# oci_core_security_list.private_sl: Creating...
# oci_core_security_list.public_sl: Creating...


# Output 
instance_id = ""
instance_public_ip = ""

# --- SSH to the host --- #
# get public_ip from  terraform output 

cd ..
ssh -i labskey  opc@<instance_id>


# --- checking install status / Troubleshooting on instance 
sudo tail -f /var/log/cloud-init-output.log
less /var/log/cloud-init-output.log

# --- look for following ---
# Files successfully downloaded to /home/opc/labs
# ===== Cloud-Init Script Completed Successfully =====
# Cloud-init v. 24.4-4.0.1.el9_6.3 finished at Wed, 04 Feb 2026 04:39:29 +0000. Datasource DataSourceOracle.  Up 935.83 seconds

# --- Firewall seeting on instance --- #
sudo firewall-cmd --zone=public --add-port=8888/tcp --permanent
sudo firewall-cmd --zone=public --add-port=8501/tcp --permanent
sudo firewall-cmd --zone=public --add-port=1521/tcp --permanent
sudo firewall-cmd --reload

sudo iptables -A INPUT -p tcp --dport 8888 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8501 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 1521 -j ACCEPT

### Verifying the updates
cd labs/
source $HOME/.bashrc
python --version
tree $HOME/labs

## Start JupyterLab Server
nohup jupyter-lab --no-browser --ip 0.0.0.0 --NotebookApp.token='' --NotebookApp.password='' --port 8888 &

# use browser for Jupyer
access following using a browser
http://<instance_ip_address>:8888/

# --- Jupyter server ready at the instance ---
# ================= END ================= #