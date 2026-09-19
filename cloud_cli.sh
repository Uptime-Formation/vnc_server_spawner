#!/bin/bash


INTERACTIVE=$( [[ -e /proc/self/fd/0 ]] && echo true || echo false ; )

APP_PATH=$( cd $(dirname ${BASH_SOURCE}) && pwd )
cd $APP_PATH


ANSIBLE_CACHE_FILE="${APP_PATH}/.ansible_recipe"
_RESOURCE_TYPES_PROVIDERS=("ovh" "digital_ocean")
_SERVERS_PROVIDERS=("hcloud" "scaleway")

source ./cloud_cli.lib.sh

set -eu
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o pipefail


# Call `_main` after everything has been defined.
_main "$@"

# EOF
