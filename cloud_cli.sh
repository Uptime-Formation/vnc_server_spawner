#!/bin/bash

set -eu
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o pipefail
ABS_PATH=$( cd $(dirname "$0") && pwd )
panic(){ echo $@; exit 1; }

# Records all allowed actions
ACTIONS=()
ACTIONS_HELP=()

###############################################################################
# Program Functions
###############################################################################
ACTIONS+=("help")
ACTIONS_HELP+=("This help")

_help() {
  cat <<HEREDOC
Usage ${BASH_SOURCE[0]} [ACTION]

ACTIONS:
$( for i in ${!ACTIONS[@]}; do [[ $i ]] && printf "  %20s | %-20s" "${ACTIONS[$i]}" "${ACTIONS_HELP[$i]}" ; echo; done)

HEREDOC
}

ACTIONS+=("setup_full")
ACTIONS_HELP+=("Run all actions")
_setup_full() {
  _setup_all
}

ACTIONS+=("setup_all")
ACTIONS_HELP+=("Run all actions (ditto)")
_setup_all(){
  _setup_terraform
  _setup_ansible
}

ACTIONS+=("packer")
ACTIONS_HELP+=("Run Packer only")
_packer() {
  [[ -z "$(which packer)" ]] && panic "Install Packer first. See packer/README.md"
  terraform_file="${ABS_PATH}/terraform/secrets.auto.tfvars"
  variables_file="${ABS_PATH}/packer/variables.json"
  [[ -f "$terraform_file" ]] || panic "Missing terraform file $terraform_file"
  if [[ -f "$variables_file" ]] ; then
    read -i Y -e -p "Replace existing $variables_file [Y/n] ? "
    REPLY=${REPLY:-Y}
    [[ "N" != ${REPLY^^} ]] && _convert_hcl_to_json
  fi
  PROVIDER=$(_get_domain_provider servers)
  packer build -var-file="${ABS_PATH}/packer/variables.json" -only=${PROVIDER} "${ABS_PATH}/packer/xubuntu_remote_desktop_server.json"

}

ACTIONS+=("setup_terraform")
ACTIONS_HELP+=("Run Terraform only")
_setup_terraform() {
  printf "Setup Terraform resources\\n"
  printf "##############################################\\n"
  cd "$TERRAFORM_DIR"
  terraform init
  terraform plan
  terraform apply -auto-approve 
  cd "$PROJECT_DIR"
}

ACTIONS+=("ansible")
ACTIONS_HELP+=("Run Ansible only")
_ansible() {
  printf "Setup infra VPS using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"
  ansible-galaxy collection install -i -r roles/requirements.yml
  ansible-galaxy role install -i -r roles/requirements.yml
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK} -vv
  cd "$PROJECT_DIR"
}

ACTIONS+=("ansible_guacamole")
ACTIONS_HELP+=("Run Ansible on the Guacamole server only")
_ansible_guacamole() {
  printf "Setup infra VPS using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"
  # ansible-galaxy install -i -r roles/requirements.yml -p roles
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_GUACAMOLE} -vv
  cd "$PROJECT_DIR"
}

ACTIONS+=("ansible_vnc")
ACTIONS_HELP+=("Run Ansible on all VNCs only")
_ansible_vnc() {
  printf "Setup infra VPS using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"
  # ansible-galaxy install -i -r roles/requirements.yml -p roles
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_VNC} -vv
  cd "$PROJECT_DIR"
}


ACTIONS+=("destroy_infra")
ACTIONS_HELP+=("Destroy the infra")
_destroy_infra() {
  printf "DESTROY Terraform resources\\n"
  printf "##############################################\\n"
  cd "$TERRAFORM_DIR"
  terraform destroy -auto-approve
}

ACTIONS+=("recreate_infra")
ACTIONS_HELP+=("Destroys and recreates the infra")
_recreate_infra() {
  printf "DESTROY AND REPROVISION\\n"
  printf "##############################################\\n"
  _destroy_infra
  _setup_all
}

_convert_hcl_to_json(){
  [[ -z "$(which jq)" ]] && panic "Please install jq."
  YJ="${ABS_PATH}/bin/yj"
  if [[ ! -f "${ABS_PATH}/bin/yj" ]] ; then
    wget "https://github.com/sclevine/yj/releases/download/v5.1.0/yj-linux-amd64" -O "${YJ}"
    echo "8ce43e40fda9a28221dabc0d7228e2325d1e959cd770487240deb47e02660986 ${YJ}" | sha256sum --check
    chmod +x "${YJ}"
  fi
  "${YJ}" -cj < "${ABS_PATH}/terraform/secrets.auto.tfvars" | jq 'del(.stagiaires_names, .formateurs_names)' > "${ABS_PATH}/packer/variables.json"
}

_get_domain_provider(){
  PROVIDER_DOMAIN="$1"
  DEST_FILENAME="${ABS_PATH}/terraform/providers.${PROVIDER_DOMAIN}.tf"
  [[ ! -L ${DEST_FILENAME} ]] && panic "No ${PROVIDER_DOMAIN} selected"
  PROVIDER_FILE=$( readlink ${DEST_FILENAME})
  echo $PROVIDER_FILE | sed -r 's/providers.servers.(.*?).tf.off/\1/'
}

_ensure_providers_each(){
  PROVIDER_DOMAIN="$1"
  DEST_FILENAME="providers.${PROVIDER_DOMAIN}.tf"
  cd "$TERRAFORM_DIR"
  [[ -h "${DEST_FILENAME}" ]] && return
  local LIST=$( ls -1 providers.${PROVIDER_DOMAIN}*off | sed -r "s:providers.${PROVIDER_DOMAIN}.(.*).tf.off:\1:" )
  echo "Please select a provider for $PROVIDER_DOMAIN"
  select PROVIDER in $LIST; do
    ln -s "providers.${PROVIDER_DOMAIN}.${PROVIDER}.tf.off" ${DEST_FILENAME}
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

# EOF