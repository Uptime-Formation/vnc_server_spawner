# VNC server spawner

With Ansible, Terraform, Tigervnc and Guacamole.

## Usage

### Ansible-only

With Ansible installed and an inventory configured:
`ansible-playbook -i $INVENTORY_PATH site.yml`

### Terraform

Configure your Terraform tokens, then:
```bash
source env_file
./cloud_cli.sh setup_full
```

### Ansible plugin to use Ansible as provider in Terraform

You need the Ansible provider for Terraform here: <https://github.com/nbering/terraform-provider-ansible/>
Copy binary to ~/.terraform.d/plugins/
