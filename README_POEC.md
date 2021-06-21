## Setup des laptops pour le mix distanciel/présentiel

1. Récupérer la configuration wireguard personnelle fournie par le formateur et enregistrez là dans le ficher `/etc/wireguard/wg1.conf`
2. Identifier votre nom d'utilisateur unix.
3. Changez la valeur `stagiaire` par ce nom d'utilisateur dans le dossier `ansible/host_vars/localhost.yaml` de ce projet.
4. Lancez le script `install_vnc_localhost.sh` de ce projet
5. Vérifiez que wireguard est bien configuré avec `sudo systemctl status wg-quick@wg1.service` et `ping 10.171.2.1` pour voir si le serveur wireguard/guacamole est accessible
6. Connectez vous à https://guacamole.formation.dopl.uk avec votre prénom et le mdp `devops101`
6. Vous devriez pouvoir vous connecter a une machine en choisissant la ligne portant votre prénom dans l'interface de guacamole.