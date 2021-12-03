# Setting up local pi

## Base

Use pi flasher to create SD card with rasbian

hostname: niss-local
ssh: public key only, copy darp pub key
, wifi credentials, and ssh auth
with darp (my laptop) authorized.

## Useful tools

```bash
pi@niss-local> sudo apt install -y neovim dnsutils
```

## Wireguard

Based on <https://upcloud.com/community/tutorials/get-started-wireguard-vpn/>

```bash
pi@niss-local> sudo apt install -y wireguard
darp> rsync net/priv_wg_for_local pi@niss-local.local:/home/pi/
pi@niss-local> sudo mv priv_wg_for_local /etc/wireguard/wg0.conf
pi@niss-local> wg-quick up wg0
```

Check to confirm it's up by looking at output of

```bash
pi@niss-local> sudo wg show
```

Enable automatic start at boot

```bash
pi@niss-local> sudo systemctl enable wg-quick@wg0
```

Ensure kernel module loaded. If successful you see no output.

```bash
pi@niss-local> sudo modprobe wireguard
```

Reboot, then check it works again.

```bash
pi@niss-local> sudo reboot
```

```bash
pi@niss-local> sudo wg show
```

## Asdf

```bash
pi@niss> sudo apt install libssl-dev automake autoconf libncurses5-dev
pi@niss> git clone https://github.com/asdf-vm/asdf.git ~/.asdf
pi@niss> asdf plugin add erlang
pi@niss> asdf plugin add elixir
```

Edit `~/.bashrc` to include

```bash
source "$HOME/.asdf/asdf.sh"
```

```bash
pi@niss-local> sudo apt install -y erlang elixir
```

## TinyTuya

```bash
pi@niss-local> sudo apt install -y python3-crypto python3-pip
pi@niss-local> python3 -m pip install tinytuya
```

## Setup env variables

Copy the contents of the 1password note "niss local env" to `/home/pi/env`

Edit `~/.bashrc` to include the

```bash
source "$HOME/env"
```
