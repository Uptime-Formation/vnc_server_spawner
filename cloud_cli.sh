#!/bin/bash

export ANSIBLE_PRIVATE_KEY_FILE=/home/alban/.ssh/id_ed25519-nopass

set -eu
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o pipefail
ABS_PATH=$( cd $(dirname "$0") && pwd )
panic(){ echo $@; exit 1; }

# Records all allowed actions
ACTIONS=()
ACTIONS_HELP=()

_RESOURCE_TYPES_PROVIDERS=("ovh" "digital_ocean")
_SERVERS_PROVIDERS=("hcloud" "scaleway")

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
  _all
}

ACTIONS+=("all")
ACTIONS_HELP+=("Run all actions (ditto)")
_all(){
  _terraform
  _ansible
}


ACTIONS+=("provider")
ACTIONS_HELP+=("Choose providers")
_provider() {

  echo "Select the type of provider you want to choose:"
  select RESOURCE_TYPE in domains servers; do
    _select_provider $RESOURCE_TYPE
    break
  done

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
  echo "For which provider do you wish to build an image?"
  select PROVIDER in ${_SERVERS_PROVIDERS[@]}; do
    packer build -on-error=ask  -var-file="${ABS_PATH}/packer/variables.json" -only=${PROVIDER} "${ABS_PATH}/packer/xubuntu_remote_desktop_server.json"
    break
  done
}

ACTIONS+=("terraform")
ACTIONS_HELP+=("Run Terraform only")
_terraform() {
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
  _get_ansible_recipe
  ANSIBLE_PLAYBOOK="${ABS_PATH}/ansible/${RECIPE}"
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK} -vv -e servers_provider=$(_get_valid_resource_type_provider servers)
  cd "$PROJECT_DIR"
}

ACTIONS+=("ansible_guacamole")
ACTIONS_HELP+=("Run Ansible on the Guacamole server only")
_ansible_guacamole() {
  printf "Setup infra VPS using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"
  # ansible-galaxy install -i -r roles/requirements.yml -p roles
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_GUACAMOLE} -vv -e servers_provider=$(_get_valid_resource_type_provider servers)
  cd "$PROJECT_DIR"
}

ACTIONS+=("ansible_vnc")
ACTIONS_HELP+=("Run Ansible on all VNCs only")
_ansible_vnc() {
  printf "Setup infra VPS using Ansible\\n"
  printf "##############################################\\n"
  cd "$ANSIBLE_DIR"
  # ansible-galaxy install -i -r roles/requirements.yml -p roles
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_VNC} -vv -e servers_provider=$(_get_valid_resource_type_provider servers)
  cd "$PROJECT_DIR"
}


ACTIONS+=("destroy")
ACTIONS_HELP+=("Destroy the infra")
_destroy() {
  printf "DESTROY Terraform resources\\n"
  printf "##############################################\\n"
  cd "$TERRAFORM_DIR"
  terraform destroy -auto-approve
}

ACTIONS+=("recreate")
ACTIONS_HELP+=("Destroys and recreates the infra")
_recreate() {
  printf "DESTROY AND REPROVISION\\n"
  printf "##############################################\\n"
  _destroy
  _all
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



_get_resource_type_provider(){
  PROVIDER_RESOURCE_TYPE="$1"
  _LINK_FILENAME="${ABS_PATH}/terraform/providers.${PROVIDER_RESOURCE_TYPE}.tf"
  [[ ! -L ${_LINK_FILENAME} ]] && echo ""
  PROVIDER_FILE=$( readlink ${_LINK_FILENAME})
  echo $PROVIDER_FILE | sed -r 's/providers.'${PROVIDER_RESOURCE_TYPE}'.(.*?).tf.off/\1/'
}

# Retrieves and dies if none set
_get_valid_resource_type_provider(){
  PROVIDER_RESOURCE_TYPE="$1"
  _CURRENT=$(_get_resource_type_provider $PROVIDER_RESOURCE_TYPE)
  [ -z "$_CURRENT"] && panic "No ${PROVIDER_RESOURCE_TYPE} selected"
  echo $_CURRENT
}

_select_provider(){
    PROVIDER_RESOURCE_TYPE="$1"
    _LINK_FILENAME="providers.${PROVIDER_RESOURCE_TYPE}.tf"
    local LIST=$( ls -1 providers.${PROVIDER_RESOURCE_TYPE}*off | sed -r "s:providers.${PROVIDER_RESOURCE_TYPE}.(.*).tf.off:\1:" )
    _CURRENT=$(_get_resource_type_provider $PROVIDER_RESOURCE_TYPE)
    echo "Please select a provider for $PROVIDER_RESOURCE_TYPE"
    echo "The current provider for $PROVIDER_RESOURCE_TYPE is '${_CURRENT}'"
    select PROVIDER in $LIST; do
      _DEST_FILE="providers.${PROVIDER_RESOURCE_TYPE}.${PROVIDER}.tf.off"
      [[ -e "${_LINK_FILENAME}" ]] && rm -f "${_LINK_FILENAME}"
      ln -s "${_DEST_FILE}" ${_LINK_FILENAME}
      break
    done
}

_ensure_providers_each(){
  PROVIDER_RESOURCE_TYPE="$1"
  _LINK_FILENAME="providers.${PROVIDER_RESOURCE_TYPE}.tf"
  cd "$TERRAFORM_DIR"
  [[ -h "${_LINK_FILENAME}" ]] && return
  _select_provider $PROVIDER_RESOURCE_TYPE
}

_ensure_providers(){
  _ensure_providers_each "domains"
  _ensure_providers_each "servers"
}

_get_ansible_recipe(){

  CACHE_FILE="${ABS_PATH}/.ansible_recipe"
  RECIPE=()
  # Find possible recipes
  while read file ; do
    RECIPES+=($( basename "$file"))
  done <<< $( ls -1 ${ANSIBLE_DIR}/site*yml )

  echo ${RECIPES[@]}

  # Get cache
  CACHED_RECIPE=""
  [[ -f "${CACHE_FILE}" ]] && CACHED_RECIPE=$(cat "${CACHE_FILE}")

  # Let user choose
  echo -e "\nPlease choose BY INDEX the ansible recipe to use:"
  CACHED_RECIPE_INDEX=""
#  for ((i=0; i<=${#RECIPES[@]}; i++))
  for i in ${!RECIPES[@]}; do
    file=${RECIPES[$i]}
    [[ "$file" == "$CACHED_RECIPE" ]] &&  CACHED_RECIPE_INDEX=$i
    echo "  - [$i] : $file"
  done
  while true; do
    CACHED_FILE_STR="(Default: $CACHED_RECIPE)"
    echo
    read -i "$CACHED_RECIPE_INDEX" -e -p "Which file number to use $CACHED_FILE_STR ? : " index
    RECIPE=${RECIPES[$index]}
    [[ -z "$RECIPE" ]] && echo "Invalid choice. Try again." && continue
    break
  done
  echo "${RECIPE}" > "${CACHE_FILE}"

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
