

## Packer to build yunohost image on hetzner cloud

Packer is a tool to automate image building for different cloud providers or docker etc.

Here we use it to build a preinstalled a yunohost image on hetzner cloud to then speed up molecule testing by skipping the installation step.

"apt-get install -yq htop vim xubuntu-desktop light-locker dbus-x11 tigervnc-standalone-server tigervnc-xorg-extension tigervnc-common apt-transport-https ca-certificates gnupg2 python3-pip python3-setuptools curl",

- install the packer binary
- Rename `hcloud_token.json.dist` into `hcloud_tocken.json` and complete the token value in it (hcloud_token.json is ignored by git).
- Use `packer build -var-file=hcloud_token.json xubuntu_vncserver.json` this create a snapshot in hcloud with an image id but no image name.
- get the snapshot image id displayed at the end of packer build output or afterwards with curl `export HCLOUD_TOKEN=your_api_token && curl -H "Authorization: Bearer $HCLOUD_TOKEN" 'https://api.hetzner.cloud/v1/images' | less`. The snapshot appears last.


<!-- - In the `molecule.yml`  file of scenario `hcloud_from_image` replace `image: name` par `image: your_snapshot_id`
- You can then (probably) run `molecule test -s hcloud_from_image` without reinstalling yunohost at every run. -->