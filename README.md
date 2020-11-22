# VNC server spawner

With Ansible, Terraform, Tigervnc and Guacamole.

## Usage

### Ansible-only

With Ansible installed and an inventory configured:
`ansible-playbook -i $INVENTORY_PATH lab.yml`

### Terraform

Configure your Terraform tokens and install the required plugins (see below), then:
```bash
./run.sh full
```

#### Ansible plugin

To use Ansible as provider in Terraform, you need the Ansible provider here: <https://github.com/nbering/terraform-provider-ansible/>
Copy the downloaded binary to `~/.terraform.d/plugins/`.
