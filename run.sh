#!/bin/bash

set -eu
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o pipefail

_print_help() {
  cat <<HEREDOC
./run.sh setup or ./run.sh all or ./run.sh full: setup infra with terraform and ansible
./run.sh terraform: setup infra with terraform only
./run.sh ansible: setup infra with ansible only
./run.sh destroy: destroy infra with terraform
./run.sh recreate: recreate infra with terraform and ansible
HEREDOC
}

###############################################################################
# Program Functions
###############################################################################

_setup_full() {
  _setup_terraform
  printf "Sleeping 15s to wait for VMs to boot fully\\n"
  printf "##############################################\\n"
  sleep 15
  _setup_ansible
}

_setup_terraform() {
  printf "Setup Terraform resources\\n"
  printf "##############################################\\n"
  cd "$TERRAFORM_DIR"
  tfenv use 0.14.9
  terraform init
  terraform plan
  terraform apply -auto-approve 
  cd "$PROJECT_DIR"
}

_setup_ansible() {
  printf "Setup infra VPS using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"

  # ansible-galaxy install -i -r roles/requirements.yml -p roles
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_GUAC} &
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_VNC}
  cd "$PROJECT_DIR"
}
_setup_ansible_guac() {
  printf "Setup Guac server only using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"

  # ansible-galaxy install -i -r roles/requirements.yml -p roles
  # ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_GUAC} $@
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_GUAC}
  cd "$PROJECT_DIR"
}

_reboot_ansible() {
  printf "Reboot infra VPS using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"
  # ansible-galaxy install -i -r roles/requirements.yml -p roles
  ansible all -a reboot -i ${ANSIBLE_INVENTORY}
  cd "$PROJECT_DIR"
}


_destroy_infra() {
  printf "DESTROY Terraform resources\\n"
  printf "##############################################\\n"
  cd "$TERRAFORM_DIR"
  terraform destroy -auto-approve
}

_recreate_infra() {
  printf "DESTROY AND REPROVISION\\n"
  printf "##############################################\\n"
  _destroy_infra
  _setup_full
}

_main() {
  source ./env

  if [[ "${1:-}" =~ ^-h|--help$  ]]
  then
    _print_help
  elif [[ "${1:-}" =~ ^terraform[\ setup]?$  ]]
  then
    _setup_terraform
  elif [[ "${1:-}" =~ ^ansible[\ setup]?$  ]]
  then
    _setup_ansible
  elif [[ "${1:-}" =~ ^[ansible\ ]?guac$  ]]
  then
    _setup_ansible_guac $@
  elif [[ "${1:-}" =~ ^[ansible\ ]?reboot$  ]]
  then
    _reboot_ansible
  elif [[ "${1:-}" =~ ^destroy$  ]]
  then
    _destroy_infra
  elif [[ "${1:-}" =~ ^recreate$  ]]
  then
    _recreate_infra
  elif [[ "${1:-}" =~ ^setup|all|full$  ]]
  then
    _setup_full
  else
    # _setup_full
    _print_help
  fi
}

# Call `_main` after everything has been defined.
_main "$@"
