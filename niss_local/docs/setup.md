# Setting up local pi

## Base

Use pi flasher to create SD card with rasbian

hostname: niss-local
ssh: public key only, copy darp pub key
, wifi credentials, and ssh auth
with darp (my laptop) authorized.

## Useful tools

```bash
pi@niss-local> sudo apt install -y neovim
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

## Setup env variables

Copy the contents of the 1password note "niss local env" to `/home/deploy/env`

## Copy over deploy scripts

```bash
darp> rsync niss_local/deploy_scripts/* deploy@niss-local.local:/home/deploy/
```

## Setup systemd service

TODO: Write systemd service

```bash
pi@niss-local> sudo mv /home/deploy/niss-local.service /etc/systemd/system/
pi@niss-local> sudo systemctl enable niss-local
```

Copy the following into a new file `/etc/sudoers.d/deploy
(based on <https://unix.stackexchange.com/questions/192706/how-could-we-allow-non-root-users-to-control-a-systemd-service>)

```text
%deploy ALL= NOPASSWD: /bin/systemctl start niss-local
%deploy ALL= NOPASSWD: /bin/systemctl stop niss-local
%deploy ALL= NOPASSWD: /bin/systemctl restart niss-local
```

```bash
pi@niss-local> sudo chmod 0440 /etc/sudoers.d/deploy
```
