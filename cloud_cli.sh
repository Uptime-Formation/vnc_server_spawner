#!/bin/bash

set -eu
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o pipefail

_print_help() {
  cat <<HEREDOC

HEREDOC
}

###############################################################################
# Program Functions
###############################################################################

_setup_full() {
  _setup_terraform
  _setup_ansible
}

_setup_terraform() {
  printf "Setup Terraform resources\\n"
  printf "##############################################\\n"
  cd "$TERRAFORM_DIR"
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
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK} -vv
  cd "$PROJECT_DIR"
}

_setup_ansible_guacamole() {
  printf "Setup infra VPS using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"
  # ansible-galaxy install -i -r roles/requirements.yml -p roles
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_GUACAMOLE} -vv
  cd "$PROJECT_DIR"
}

_setup_ansible_vnc() {
  printf "Setup infra VPS using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"
  # ansible-galaxy install -i -r roles/requirements.yml -p roles
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_VNC} -vv
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

_ensure_providers_each(){
  PROVIDER_NAME="$1"
  DEST_FILENAME="providers.${PROVIDER_NAME}.tf"
  cd "$TERRAFORM_DIR"
  [[ -h "${DEST_FILENAME}" ]] && return
  local LIST=$( ls -1 providers.${PROVIDER_NAME}*off | sed -r "s:providers.${PROVIDER_NAME}.(.*).tf.off:\1:" )
  echo "Please select a provider for $PROVIDER_NAME"
  select PROVIDER in $LIST; do
    ln -s "providers.${PROVIDER_NAME}.${PROVIDER}.tf.off" ${DEST_FILENAME}
    break
  done

}

_ensure_providers(){
  _ensure_providers_each "domains"
  _ensure_providers_each "servers"
}

_main() {
  source ./env_file
  _ensure_providers
  if [[ "${1:-}" =~ ^-h|--help$  ]]
  then
    _print_help
  elif [[ "${1:-}" =~ ^setup_terraform$  ]]
  then
    _setup_terraform
  elif [[ "${1:-}" =~ ^setup_ansible$  ]]
  then
    _setup_ansible
  elif [[ "${1:-}" =~ ^setup_ansible_guacamole$  ]]
  then
    _setup_ansible_guacamole
  elif [[ "${1:-}" =~ ^setup_ansible_vnc$  ]]
  then
    _setup_ansible_vnc
  elif [[ "${1:-}" =~ ^destroy_infra$  ]]
  then
    _destroy_infra
  elif [[ "${1:-}" =~ ^recreate_infra$  ]]
  then
    _recreate_infra
  elif [[ "${1:-}" =~ ^setup_full$  ]]
  then
    _setup_full
  elif [[ "${1:-}" =~ ^setup_all$  ]]
  then
    _setup_full
  else
    _print_help
  fi
}

# Call `_main` after everything has been defined.
_main "$@"
