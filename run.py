#! /usr/bin/env python
from __future__ import print_function
import sys,os,subprocess,signal,glob,re

_rc0 = subprocess.call(["set","-eu"],shell=True)
signal.signal(signal.SIGERR,'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2')

_rc0 = subprocess.call(["set","-o","pipefail"],shell=True)
def _print_help () :
    subprocess.Popen("cat",shell=True,stdin=subprocess.PIPE)
    _rc0.communicate("./run.sh setup or ./run.sh all or ./run.sh full: setup infra with terraform and ansible\n./run.sh terraform: setup infra with terraform only\n./run.sh ansible: setup infra with ansible only\n./run.sh destroy: destroy infra with terraform\n./run.sh recreate: recreate infra with terraform and ansible\n")
    _rc0 = _rc0.wait()print '''
    ./run.sh setup or ./run.sh all or ./run.sh full: setup infra with terraform and ansible
    ./run.sh terraform: setup infra with terraform only
    ./run.sh ansible: setup infra with ansible only
    ./run.sh destroy: destroy infra with terraform
    ./run.sh recreate: recreate infra with terraform and ansible
'''

###############################################################################
# Program Functions
###############################################################################
def _setup_full () :
    subprocess.call(["_setup_terraform"],shell=True)
    # printf "Sleeping 15s to wait for VMs to boot fully\\n"
    # printf "##############################################\\n"
    # sleep 15
    _rc0 = subprocess.call(["_setup_ansible"],shell=True)

def _setup_terraform () :
    global TERRAFORM_DIR
    global PROJECT_DIR

    print( "Setup Terraform resources\\n" )

    print( "##############################################\\n" )

    os.chdir(str(TERRAFORM_DIR.val))
    _rc0 = subprocess.call(["terraform","init"],shell=True)
    _rc0 = subprocess.call(["terraform","plan"],shell=True)
    _rc0 = subprocess.call(["terraform","apply","-auto-approve"],shell=True)
    os.chdir(str(PROJECT_DIR.val))

def _setup_ansible () :
    global ANSIBLE_DIR
    global ANSIBLE_INVENTORY
    global ANSIBLE_PLAYBOOK
    global PROJECT_DIR

    print( "Setup infra VPS using Ansible\\n" )

    print( "##############################################\\n" )

    os.chdir(str(ANSIBLE_DIR.val))
    # ansible-galaxy install -i -r roles/requirements.yml -p roles
    _rc0 = subprocess.call(["ansible-playbook","-i",str(ANSIBLE_INVENTORY.val),str(ANSIBLE_PLAYBOOK.val)],shell=True)
    os.chdir(str(PROJECT_DIR.val))

def _destroy_infra () :
    global TERRAFORM_DIR

    print( "DESTROY Terraform resources\\n" )

    print( "##############################################\\n" )

    os.chdir(str(TERRAFORM_DIR.val))
    _rc0 = subprocess.call(["terraform","destroy","-auto-approve"],shell=True)

def _recreate_infra () :
    print( "DESTROY AND REPROVISION\\n" )

    print( "##############################################\\n" )

    _destroy_infra()
    _setup_full()

def _main () :
    subprocess.call(["source","./.env"],shell=True)
    if (re.search("^-h|--help"+"$",sys.argv[1]) ):
        _print_help()
    elif (re.search("^terraform"+"$",sys.argv[1]) ):
        _setup_terraform()
    elif (re.search("^ansible"+"$",sys.argv[1]) ):
        _setup_ansible()
    elif (re.search("^destroy"+"$",sys.argv[1]) ):
        _destroy_infra()
    elif (re.search("^recreate"+"$",sys.argv[1]) ):
        _recreate_infra()
    elif (re.search("^setup|all|full"+"$",sys.argv[1]) ):
        _setup_full()
    else:
        # _setup_full
        _print_help()

# Call `_main` after everything has been defined.
_main(Expand.at())