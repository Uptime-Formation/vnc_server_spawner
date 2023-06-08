# Packer for hetzner and scaleway cloud

**Packer is a tool to automate image building for different cloud providers or docker etc.**

## Versions 

Packer >= 1.9.0

## Usage

### Mandatory  

- Install the packer binary 
- For scaleway : install the packer plugin 

```shell
# Scaleway only
$ cat << EOF > ~/.packer.d/plugins.pkr.hcl 
packer {
  required_plugins {
    scaleway = {
      version = ">= 1.0.5"
      source  = "github.com/scaleway/scaleway"
    }
  }
}
EOF
$ packer init ~/.packer.d/plugins.pkr.hcl 
```

### Option 1 : Automatic run 

**The package build is done via the `cloud_cli.sh` command.**

```shell

# Runs only packer
$ ./cloud_cli.sh packer

```

This will install the `yj` command line tool to convert the terraform secrets and run Packer for you.

### Option 2 : Manual run

- Rename `variables.json.dist` into `variables.json` 
- Complete it (**variables.json is ignored by git**).
- Run 
```shell

$ packer build -var-file=variables.json xubuntu_remote_desktop_server.json

```
  

## Image ID 

### Hcloud 

**This creates a snapshot in hcloud with an image id but no image name.**

The Terraform recipe should find your snapshot automatically.

Otherwise get the snapshot image id displayed at the end of packer build output. 

Or afterwards with 

```shell

$ export HCLOUD_TOKEN=your_api_token 
$ curl -H "Authorization: Bearer $HCLOUD_TOKEN" 'https://api.hetzner.cloud/v1/images?type=snapshot' | less
 
```
   
The snapshot appears last.

### Scaleway

> An image was created: 'image-packer-0000000000' (ID: 00e00b00-0d00-00dd-0000-00000000000d) in zone 'fr-par-0' based on snapshot 'snapshot-packer-0000000000' (ID: 0dcbbe0d-00dc-0000-b000-0b0db000a0d0)

