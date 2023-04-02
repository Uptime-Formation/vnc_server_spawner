# Packer for hetzner cloud

## Versions 

Packer >= 1.9.0

## Usage

Packer is a tool to automate image building for different cloud providers or docker etc.

- install the packer binary
- Rename `hcloud_token.json.dist` into `hcloud_tocken.json` and complete the token value in it (hcloud_token.json is ignored by git).
- Use `packer build -var-file=hcloud_token.json xubuntu_remote_desktop_server.json` this create a snapshot in hcloud with an image id but no image name.
- get the snapshot image id displayed at the end of packer build output or afterwards with curl `export HCLOUD_TOKEN=your_api_token && curl -H "Authorization: Bearer $HCLOUD_TOKEN" 'https://api.hetzner.cloud/v1/images?type=snapshot' | less`. The snapshot appears last.
