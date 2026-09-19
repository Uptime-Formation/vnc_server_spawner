#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154,SC2164
#
# cloud_cli.lib.sh -- Library of functions for cloud CLI
#

# Function: panic
# --------------
# Prints an error message and exits with code 1.
#
# Arguments:
#   $@: The error message to print.
#
# Returns:
#   Exits the script.
panic(){ echo $@; exit 1; }

VERBOSITY="-v"

# ANSIBLE_DIR, ANSIBLE_INVENTORY, ANSIBLE_PLAYBOOK_GUACAMOLE (and other
# path vars used below, e.g. PROJECT_DIR, TERRAFORM_DIR) are actually
# defined in ./env_file, sourced from _main() below. That source runs
# after this point and exports over anything set here, so keep them
# defined in env_file only to avoid the two silently drifting apart.

# ACTIONS and ACTIONS_HELP
# --------------
# Define arrays to store allowed actions and their help messages.
#
# Arguments:
#   None
#
# Returns:
#   Sets the ACTIONS and ACTIONS_HELP arrays.

# Records all allowed actions
ACTIONS=()
ACTIONS_HELP=()

###############################################################################
# Program Functions
###############################################################################

# Action: help
# --------------
# Displays the help message.
#
# Arguments:
#   None
#
# Returns:
#   Prints the help message to standard output.
ACTIONS+=("help")
ACTIONS_HELP+=("This help")

_help() {
  cat <<HEREDOC
Usage ${BASH_SOURCE[0]} [ACTION]

ACTIONS:
$( for i in ${!ACTIONS[@]}; do [[ $i ]] && printf "  %20s | %-20s" "${ACTIONS[$i]}" "${ACTIONS_HELP[$i]}" ; echo; done)

HEREDOC
}

# Action: setup_full
# --------------
# Runs all actions.
#
# Arguments:
#   None
#
# Returns:
#   Calls the _all function.
ACTIONS+=("setup_full")
ACTIONS_HELP+=("Run all actions")
_setup_full() {
  _all
}

# Action: all
# --------------
# Runs Terraform and Ansible.
#
# Arguments:
#   None
#
# Returns:
#   Calls the _terraform and _ansible functions.
ACTIONS+=("all")
ACTIONS_HELP+=("Run all actions (ditto)")
_all(){
  _terraform
  _ansible
}

# Action: provider
# --------------
# Allows the user to choose providers for domains and servers.
#
# Arguments:
#   None
#
# Returns:
#   Calls the _select_provider function for the selected resource type.
ACTIONS+=("provider")
ACTIONS_HELP+=("Choose providers")
_provider() {

  echo "Select the type of provider you want to choose:"
  select RESOURCE_TYPE in domains servers; do
    _select_provider $RESOURCE_TYPE
    break
  done

}

# Action: packer
# --------------
# Runs Packer to build images.
#
# Arguments:
#   None
#
# Returns:
#   Executes the Packer build command.
ACTIONS+=("packer")
ACTIONS_HELP+=("Run Packer only")
_packer() {
  # Check if Packer is installed
  [[ -z "$(which packer)" ]] && panic "Install Packer first. See packer/README.md"
  terraform_file="${APP_PATH}/terraform/secrets.auto.tfvars"
  variables_file="${APP_PATH}/packer/variables.json"
  # Verify Terraform file exists
  [[ -f "$terraform_file" ]] || panic "Missing terraform file $terraform_file"
  if [[ -f "$variables_file" ]] ; then
    # Prompt to replace existing variables file
    read -i Y -e -p "Replace existing $variables_file [Y/n] ? "
    REPLY=${REPLY:-Y}
    [[ "N" != ${REPLY^^} ]] && _convert_hcl_to_json
  fi
  # Select provider for image build
  echo "For which provider do you wish to build an image?"
  select PROVIDER in ${_SERVERS_PROVIDERS[@]}; do
    # Execute Packer build with selected provider
    packer build -on-error=ask  -var-file="${APP_PATH}/packer/variables.json" -only=${PROVIDER} "${APP_PATH}/packer/xubuntu_remote_desktop_server.json"
    break
  done
}

# Action: terraform
# --------------
# Runs Terraform to provision infrastructure.
#
# Arguments:
#   None
#
# Returns:
#   Executes Terraform init, plan, and apply commands.
ACTIONS+=("terraform")
ACTIONS_HELP+=("Run Terraform only")
_terraform() {
  printf "Setup Terraform resources\n"
  printf "##############################################\n"
  cd "$TERRAFORM_DIR"
  terraform init
  terraform plan
  terraform apply -auto-approve 
  cd "$PROJECT_DIR"
}

# Action: ansible
# --------------
# Runs Ansible to configure servers.
#
# Arguments:
#   None
#
# Returns:
#   Executes the Ansible playbook.
ACTIONS+=("ansible")
ACTIONS_HELP+=("Run Ansible only")
_ansible() {
  # Setup infra VPS using Ansible
  printf "Setup infra VPS using Ansible\n"
  # Print separator line
  printf "##############################################\n"
  # Change directory to Ansible roles directory
  cd "$ANSIBLE_DIR"
  # Install Ansible dependencies from requirements.yml
#  __install_galaxy_deps
  # Get Ansible recipe configuration
#  _get_ansible_recipe
  # Load cached recipe value
#  RECIPE=$(__load_cached_recipe)
  RECIPE="site-K8S.yml"
  # Set Ansible playbook path using recipe value
  ANSIBLE_PLAYBOOK="${APP_PATH}/ansible/${RECIPE}"
  # Execute Ansible playbook with inventory, variables, and verbose output
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK} $VERBOSITY -e servers_provider=$(_get_valid_resource_type_provider servers)
  # Return to project root directory
  cd "$PROJECT_DIR"
}

# Action: ansible_guacamole
# --------------
# Runs Ansible on the Guacamole server only.
#
# Arguments:
#   None
#
# Returns:
#   Executes the Ansible playbook for Guacamole.
ACTIONS+=("ansible_guacamole")
ACTIONS_HELP+=("Run Ansible on the Guacamole server only")
_ansible_guacamole() {
  printf "Setup infra VPS using Ansible\n"
  printf "##############################################\n"
  cd "$ANSIBLE_DIR"
  # Install Ansible dependencies from requirements.yml
  __install_galaxy_deps
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_GUACAMOLE} $VERBOSITY -e servers_provider=$(_get_valid_resource_type_provider servers)
  cd "$PROJECT_DIR"
}

# Action: ansible_vnc
# --------------
# Runs Ansible on all VNC servers only.
#
# Arguments:
#   None
#
# Returns:
#   Executes the Ansible playbook for VNC servers.
ACTIONS+=("ansible_vnc")
ACTIONS_HELP+=("Run Ansible on all VNCs only")
_ansible_vnc() {
  printf "Setup infra VPS using Ansible\n"
  printf "##############################################\n"
  cd "$ANSIBLE_DIR"
  # Install Ansible dependencies from requirements.yml
  __install_galaxy_deps
  ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK_VNC} $VERBOSITY -e servers_provider=$(_get_valid_resource_type_provider servers)
  cd "$PROJECT_DIR"
}

# Action: destroy
# --------------
# Destroys Terraform resources.
#
# Arguments:
#   None
#
# Returns:
#   Executes Terraform destroy command.
ACTIONS+=("destroy")
ACTIONS_HELP+=("Destroy the infra")
_destroy() {
  printf "DESTROY Terraform resources\n"
  printf "##############################################\n"
  cd "$TERRAFORM_DIR"
  terraform destroy -auto-approve
}

# Action: recreate
# --------------
# Destroys and recreates the infrastructure.
#
# Arguments:
#   None
#
# Returns:
#   Calls the _destroy and _all functions.
ACTIONS+=("recreate")
ACTIONS_HELP+=("Destroys and recreates the infra")
_recreate() {
  printf "DESTROY AND REPROVISION\n"
  printf "##############################################\n"
  _destroy
  _all
}


## App routines

# Function: __install_galaxy_deps
# --------------
# Installs Ansible collections and roles from requirements.yml.
#
# Arguments:
#   None
#
# Returns:
#   Executes ansible-galaxy commands to install dependencies.
__install_galaxy_deps(){
    # Install Ansible collections from requirements.yml
  ansible-galaxy collection install -i -r roles/requirements.yml
  # Install Ansible roles from requirements.yml
  ansible-galaxy role install -i -r roles/requirements.yml
}

# Function: _convert_hcl_to_json
# --------------
# Converts Terraform HCL variables to JSON format for Packer.
#
# Arguments:
#   None
#
# Returns:
#   Converts secrets.auto.tfvars to variables.json.
_convert_hcl_to_json(){
  [[ -z "$(which jq)" ]] && panic "Please install jq."
  YJ="${APP_PATH}/bin/yj"
  if [[ ! -f "${APP_PATH}/bin/yj" ]] ; then
    wget "https://github.com/sclevine/yj/releases/download/v5.1.0/yj-linux-amd64" -O "${YJ}"
    echo "8ce43e40fda9a28221dabc0d7228e2325d1e959cd770487240deb47e02660986 ${YJ}" | sha256sum --check
    chmod +x "${YJ}"
  fi
  "${YJ}" -cj < "${APP_PATH}/terraform/secrets.auto.tfvars" | jq 'del(.stagiaires_names, .formateurs_names)' > "${APP_PATH}/packer/variables.json"
}

# Function: _get_resource_type_provider
# --------------
# Retrieves the current provider for a given resource type (domains or servers).
#
# Arguments:
#   $1: The resource type (domains or servers).
#
# Returns:
#   The name of the provider.
_get_resource_type_provider(){
  PROVIDER_RESOURCE_TYPE="$1"
  _LINK_FILENAME="${APP_PATH}/terraform/providers.${PROVIDER_RESOURCE_TYPE}.tf"
  [[ ! -L ${_LINK_FILENAME} ]] && echo ""
  PROVIDER_FILE=$( readlink ${_LINK_FILENAME})
  echo $PROVIDER_FILE | sed -r 's/providers.'${PROVIDER_RESOURCE_TYPE}'.(.*?).tf.off/\1/'
}

# Function: _get_valid_resource_type_provider
# --------------
# Retrieves the current provider for a resource type and exits if none is selected.
#
# Arguments:
#   $1: The resource type (domains or servers).
#
# Returns:
#   The name of the provider.
_get_valid_resource_type_provider(){
  PROVIDER_RESOURCE_TYPE="$1"
  _CURRENT=$(_get_resource_type_provider $PROVIDER_RESOURCE_TYPE)
  [[ -z "$_CURRENT" ]] && panic "No ${PROVIDER_RESOURCE_TYPE} selected"
  echo $_CURRENT
}

# Function: _select_provider
# --------------
# Allows the user to select a provider for a given resource type.
#
# Arguments:
#   $1: The resource type (domains or servers).
#
# Returns:
#   Creates a symbolic link to the selected provider's Terraform file.
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

# Function: _ensure_providers_each
# --------------
# Ensures that a provider is selected for a given resource type.
#
# Arguments:
#   $1: The resource type (domains or servers).
#
# Returns:
#   Calls _select_provider if no provider is currently selected.
_ensure_providers_each(){
  PROVIDER_RESOURCE_TYPE="$1"
  _LINK_FILENAME="providers.${PROVIDER_RESOURCE_TYPE}.tf"
  cd "$TERRAFORM_DIR"
  [[ -h "${_LINK_FILENAME}" ]] && return
  _select_provider $PROVIDER_RESOURCE_TYPE
}

# Function: _ensure_providers
# --------------
# Ensures that providers are selected for both domains and servers.
#
# Arguments:
#   None
#
# Returns:
#   Calls _ensure_providers_each for domains and servers.
_ensure_providers(){
  _ensure_providers_each "domains"
  _ensure_providers_each "servers"
}

# Function: _get_ansible_recipe
# --------------
# Gets the Ansible recipe to use, either interactively or non-interactively.
#
# Arguments:
#   None
#
# Returns:
#   Sets the ANSIBLE_PLAYBOOK variable.
_get_ansible_recipe(){
  local RECIPES=""
  RECIPES=$(__get_recipes)
  CACHED_RECIPE=$(__load_cached_recipe)
  if [[ $INTERACTIVE == true ]]; then
    __select_recipe_interactively "${RECIPES[@]}" "${CACHED_RECIPE}"
  else
    __select_recipe_non_interactively "${RECIPES[@]}" "${CACHED_RECIPE}"
  fi
  
}

# Function: __get_recipes
# --------------
# Gets a list of available Ansible recipes (site*.yml files).
#
# Arguments:
#   None
#
# Returns:
#   An array of recipe filenames.
__get_recipes(){
  local RECIPES=()
  while read file ; do
    RECIPES+=($( basename "$file"))
  done <<< $( ls -1 ${ANSIBLE_DIR}/site*yml )
  echo "${RECIPES[@]}"
}

# Function: __load_cached_recipe
# --------------
# Loads the cached Ansible recipe from a file.
#
# Arguments:
#   None
#
# Returns:
#   The cached recipe name, or an empty string if no cache file exists.
__load_cached_recipe(){
  if [[ -f "$ANSIBLE_CACHE_FILE" ]]; then
    cat "$ANSIBLE_CACHE_FILE"
  else
    echo ""
  fi
}

# Function: __select_recipe_interactively
# --------------
# Interactively selects an Ansible recipe from a list of available recipes.
#
# Arguments:
#   $1: An array of available recipe filenames.
#   $2: The cached recipe name (optional).
#
# Returns:
#   Saves the selected recipe to the cache file.
__select_recipe_interactively(){
  local  available_recipes=( $1 )
  local cached_recipe=${2:-}
  echo -e "\nPlease choose BY INDEX the ansible recipe to use:"
  echo "Available recipes:"
  select selected_recipe in "${available_recipes[@]}"; do
    if [[ -z "$selected_recipe" ]]; then
      __save_recipe_to_cache  "$cached_recipe"
      return
    else
      __save_recipe_to_cache "$selected_recipe"
      return
    fi
  done
}

# Function: __select_recipe_non_interactively
# --------------
# Non-interactively selects an Ansible recipe from a list of available recipes.
#
# Arguments:
#   $1: An array of available recipe filenames.
#   $2: The cached recipe name (optional).
#
# Returns:
#   The selected recipe name.
__select_recipe_non_interactively(){
  local -n recipes=$1
  local cached_recipe=$2
  if [[ -n "$cached_recipe" ]]; then
    echo "$cached_recipe"
    return
  elif [[ ${#recipes[@]} -gt 0 ]]; then
    echo "${recipes[0]}"
  else
    echo ""
  fi
}

# Function: __save_recipe_to_cache
# --------------
# Saves the selected Ansible recipe to a cache file.
#
# Arguments:
#   $1: The name of the selected recipe.
#
# Returns:
#   Saves the recipe name to the cache file.
__save_recipe_to_cache(){
  echo -n "$1" > "$ANSIBLE_CACHE_FILE"
}

# Function: pattern_matching
# --------------
# Matches a request against the list of available actions.
#
# Arguments:
#   $@: The request to match.
#
# Returns:
#   The name of the corresponding function, or an empty string if no match is found.
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

# Function: _main
# --------------
# The main entry point of the script.
#
# Arguments:
#   $1: The action to perform (optional).
#
# Returns:
#   Executes the selected action or displays the help message.
_main() {
  source $APP_PATH/env_file
  CMD=$(pattern_matching ${1:-})
  if [[ -n "${CMD}" ]] ; then
    _ensure_providers
    $CMD
  else
    _help
  fi
}
