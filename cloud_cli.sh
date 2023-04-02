#!/bin/bash

set -eu
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o pipefail

# Records all allowed actions
ACTIONS=()

###############################################################################
# Program Functions
###############################################################################
ACTIONS+=("help")
_help() {
  cat <<HEREDOC
Usage ${BASH_SOURCE[0]} [ACTION]

ACTION list:
$( for f in ${ACTIONS[@]}; do echo "   - $f"; done)

HEREDOC
}

ACTIONS+=("setup_full")
_setup_full() {
  _setup_terraform
  _setup_ansible
}

ACTIONS+=("setup_all")
_setup_all(){
  _setup_full
}

ACTIONS+=("setup_terraform")
_setup_terraform() {
  printf "Setup Terraform resources\\n"
  printf "##############################################\\n"
  cd "$TERRAFORM_DIR"
  terraform init
  terraform plan
  terraform apply -auto-approve 
  cd "$PROJECT_DIR"
}

ACTIONS+=("setup_ansible")
_setup_ansible() {
  printf "Setup infra VPS using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"
  ansible-galaxy collection install -i -r roles/requirements.yml
  ansible-galaxy role install -i -r roles/requirements.yml
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK} -vv
  cd "$PROJECT_DIR"
}

ACTIONS+=("setup_ansible_guacamole")
_setup_ansible_guacamole() {
  printf "Setup infra VPS using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"
  # ansible-galaxy install -i -r roles/requirements.yml -p roles
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_GUACAMOLE} -vv
  cd "$PROJECT_DIR"
}

ACTIONS+=("setup_ansible_vnc")
_setup_ansible_vnc() {
  printf "Setup infra VPS using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"
  # ansible-galaxy install -i -r roles/requirements.yml -p roles
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_VNC} -vv
  cd "$PROJECT_DIR"
}


ACTIONS+=("destroy_infra")
_destroy_infra() {
  printf "DESTROY Terraform resources\\n"
  printf "##############################################\\n"
  cd "$TERRAFORM_DIR"
  terraform destroy -auto-approve
}

ACTIONS+=("recreate_infra")
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

pattern_matching(){
  REQUEST="$@"
  for PATTERN in ${ACTIONS[@]}; do
    CMD=""
    if [[ "$REQUEST" == "${PATTERN}" ]]; then
      FUNC="_${REQUEST}"
      if $( type "${FUNC}" &>/dev/null); then
        CMD="${FUNC}"
        break
      fi
    fi
  done
  echo "${CMD}"
}

_main() {
  source ./env_file
  CMD=$(pattern_matching ${1:-})
  if [[ -n "${CMD}" ]] ; then
    _ensure_providers
    $CMD
  else
    _help
  fi
}

# Call `_main` after everything has been defined.
_main "$@"
