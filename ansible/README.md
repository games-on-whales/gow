# Headless Monitor install of GOW
Mainly following the default instructions from the [Getting Started](https://games-on-whales.github.io/gow/requirements.html) page to automate the install of a headless monitor instance of GOW.

You could, for instance, use this to setup GOW on an [Oracle Free Tier](https://www.oracle.com/cloud/free/) cloud VM

## Server Setup

### Cloud
Probably get a VM from [Oracle Always Free Tier](https://www.oracle.com/ie/cloud/free/).

### On-Prem
Use your own server

#### Install Ubuntu
[Ubuntu downloads page](https://ubuntu.com/download/desktop)

#### Enable ssh server (required for ansible to work)
Visit [this page](https://linuxize.com/post/how-to-enable-ssh-on-ubuntu-18-04/) for help.
```
sudo apt update
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
sudo ufw enable
sudo ufw allow ssh
```

## Client Setup

### Enable passwordless ssh access from remote machine to server (required for ansible to work)
```
ssh-keygen -t ed25519 -C "primary-key"
file ~/.ssh/id_ed25519.pub
ssh-copy-id -p <ssh-port> <remote-user>@<server-ip>
```

If youre using a machine that only allows for publickey auth, then you can upload your key that you just generated with the following command

```
ssh-copy-id -i ~/.ssh/id_ed25519.pub -o 'IdentityFile ~/.ssh/<your-existing-private-key-for-access>.key' -p <ssh-port> <remote-user>@<server-ip>
```

### Install ansible
```
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

### Update the `hosts.yaml` file to fill out the template
At the very least, search for the items with tags `# FILL OUT`

### Update the `group_vars/all` file to fill out the required information there
At the very least, search for the items with tags `# FILL OUT`

### Run the ansible runner script
- `./run.sh`
- You can add `-vvvv` to get more verbose output

### Expose required ports on your router
- Expose (port forward on your router) ports for the services you wish to have available externally based on the list below (these are required for Moonlight to be able to connect to Sunshine and you to be able to put in the PIN for this connection on the WAN):

  |  Port | Protocol |
  |-------|----------|
  | 47984 |      tcp |
  | 47985 |      tcp |
  | 47986 |      tcp |
  | 47987 |      tcp |
  | 47988 |      tcp |
  | 47989 |      tcp |
  | 47990 |      tcp |
  | 48010 |      tcp |
  | 48010 |      udp |
  | 47998 |      udp |
  | 47999 |      udp |
  | 48000 |      udp |

  **NOTE**: Security is an unknown when exposing a service to the internet.
