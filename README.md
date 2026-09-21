# VNC server spawner

With Ansible, Terraform, Tigervnc and Guacamole.

# Usage


## 1. Install Terraform for Ansible inventory plugin

To use Ansible as provider in Terraform, you need the Ansible provider here

> https://github.com/nbering/terraform-provider-ansible/

Copy the downloaded binary to `~/.terraform.d/plugins/`.

## 2. Configure Terraform variables

#### 2.1 Configure your cloud providers accounts

* You MUST have access to ONE cloud instances provider and ONE cloud DNS records provider amongst the following.

* You MUST retrieve the API tokens for each provider, pleaser refer to their documentations by following the links below. 

##### 2.1.1. Instances
**You MUST add SSH keys to your cloud provider account.**

Required informations


1. [Scaleway](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs)
   - scaleway_api_access_key
   - scaleway_api_secret_key  
   - scaleway_orga_id  
2. [Hertner](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs) 
   - hcloud_guacamole_server_type 
   - hcloud_token 
   - hcloud_vnc_server_type 
   

##### 2.1.2 DNS

**You MUST have a domain recorded in your cloud DNS provider account.**

Required informations

- formation_subdomain : the name of your session, any string works 
- global_lab_domain : a domain configured available in your provider account

1. OVH
   - ovh_application_key 
   - ovh_application_secret 
   - ovh_consumer_key 
2. Digital Ocean
   - digitalocean_token 


#### 2.2 Configure your Terraform variable file

##### 2.2.1 Copy the template file 


```bash
$ cp terraform/secrets.auto.tfvars.dist terraform/secrets.auto.tfvars
```

##### 2.2.2 Copy the template file 

Edit the file to add your tokens and other required informations 


## 3.  Run the shell script

```bash
./cloud_cli.sh setup_full
```

You will be asked to select the providers you want to use.



### Ansible-only

With Ansible installed and an inventory configured:
`ansible-playbook -i $INVENTORY_PATH site.yml`

Running a single playbook (or limiting to one host) directly, bypassing
`cloud_cli.sh`:

```bash
cd ansible
export ANSIBLE_TF_DIR=$(pwd)/../terraform
ansible-playbook -i terraform-inventory.py playbooks/<playbook>.yml [--limit <hostname>]
```

`ANSIBLE_TF_DIR` is required so `terraform-inventory.py` can find your
Terraform state — it's normally exported by `env_file`, which
`cloud_cli.sh` sources for you, but that only happens when going through
`cloud_cli.sh`.

## Quiz CLI (formations-quiz)

`ansible/roles/albancrommer.formations_quiz` installs the `quiz` CLI on
student servers (`vnc_servers_stagiaires`), and two playbooks drive it:

- `playbooks/install_quiz.yml` — install/update the CLI on every student
  server (already wired into `site-K8S.yml`).
- `playbooks/fetch_quiz_results.yml` — after a training session, pull every
  student's quiz result files into a fresh local temp directory (one
  subfolder per host), then prints the exact `qcompile <tmp_dir>` command
  to run next.

```bash
cd ansible
export ANSIBLE_TF_DIR=$(pwd)/../terraform
ansible-playbook -i terraform-inventory.py playbooks/fetch_quiz_results.yml
```

`qcompile` merges the fetched result files into one CSV report (one row
per attempt). It is **not** part of this repo — it's a separate CLI
installed from the
[quiz-cli](https://github.com/albancrommer/formations-quiz) project, on
your own machine:

```bash
git clone https://github.com/albancrommer/formations-quiz
cd formations-quiz
pip install -e .
qcompile <tmp_dir> [--out report.csv]
```

