# Personal Nix Flake

### Layout

- `nixos/computers/`: Per-host configuration.
- `nixos/modules/`: Reusable NixOS modules.
- `nixos/profiles/`: Optional groups of related configuration.
- `pkgs/`: Local packages.
- `apps.nix`: Runnable flake applications.
- `overlay.nix`: Package overrides and additions.

### TODO

- Configure Sway idle and suspend locking.
- Add flake checks for NixOS and Disko outputs.

### Formatting

```sh
nix fmt
```

### erowiki droplet

`nixos/computers/erowiki` is the DigitalOcean droplet behind erowiki.net: the
landing page, the Foxtato Softworks wiki (MediaWiki + MariaDB), and the
magicalcamp redirect. Nothing in it is specific to one droplet. Addresses come
from the droplet metadata service at boot
(`nixos/modules/digitalocean_network.nix`), so the same system goes onto a
test droplet or production.

Build it, and the small kexec installer used to bootstrap it:

```sh
nix build .#nixosConfigurations.erowiki.config.system.build.toplevel
nix build .#nixosConfigurations.do-kexec.config.system.build.nixosAnywhereKexec --out-link kexec
```

Install onto a droplet running any Linux. This **wipes the whole disk**:

```sh
nix run github:nix-community/nixos-anywhere -- \
  --kexec kexec/do-kexec.tar \
  --flake .#erowiki \
  --target-host root@<droplet-ip>
```

Later deploys, built here and pushed:

```sh
nixos-rebuild switch --flake .#erowiki --target-host root@<droplet-ip>
```

#### Secrets (by hand, not in the repo or the nix store)

- `/var/lib/mediawiki/secrets/admin-password`: only read by `install.php` on
  an empty database, but must exist before the first boot's `mediawiki-init`.
- `/var/lib/mediawiki/secrets/secrets.php`: `$wgTurnstileSiteKey`,
  `$wgTurnstileSecretKey`, `$wgUpgradeKey` and `$wgAuthenticationTokenVersion`
  from the old `LocalSettings.php` (changing the last one logs everyone out).
- `/var/lib/mediawiki/secret.key`: the old `$wgSecretKey` value, no newline.

All owned by `mediawiki`, mode 0600 (the `secrets` directory is 0700).

#### Moving the wiki over from the Docker setup

1. On the old host:
   `docker exec magicalcamp_database_1 mariadb-dump --single-transaction my_wiki > wiki.sql`
   plus `/root/docker/magicalcamp/images/`.
2. On the new host: `mariadb mediawiki < wiki.sql` (the database is named
   `mediawiki` now; a single-database dump has no `USE`, so it lands there).
3. Copy `images/` into `/var/lib/mediawiki/uploads/` and
   `chown -R mediawiki:nginx` it.
4. `systemctl restart mediawiki-init` runs `update.php` for the 1.43 -> 1.46
   schema changes.

Old URLs (`/index.php/Page`, `/images/...`) redirect to the module's
`/wiki/Page` and `/w/images/...` layout.

#### Network

`do-network.service` renders `/etc/systemd/network/10-do-public.network` from
metadata and reloads networkd only when the result differs from what is
there. To see what it would change without changing anything:

```sh
DO_NETWORK_DRY_RUN=1 do-network
```

### Setting up the playground image in a VM

It is nice to have a VM that I can just try out random configs in and having the ability to start from scratch to keep things clean is great to have. Without going through the nixos handbook to install nixos, I have found some random resources online showing how to use this nixos-anywhere repo to do the install. It seems to be about the easiest solution to just drop an install onto a disk that follows some disko config.

1. Make the ISO to boot in the VM
  * nix build .#nixosConfigurations.playground.config.system.build.images.iso-installer --out-link iso
1. Boot the VM with the iso above
  * nix run .#playground-vm -- --iso iso/iso/*.iso
  * The first run prompts for the maximum size of the persistent virtual disk
1. From the installer shell, provision the disk and install the system
  * sudo install-image
1. Reboot into the installed system
1. First boot, take care of a couple things
  * change the user password

Later boots do not need the installer image:

```sh
nix run .#playground-vm
```

Alternatively, `nixos-anywhere` can provision and install the system over SSH:

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake '.#playground' \
  --target-host nixos@localhost \
  --ssh-port 2222 \
  --post-kexec-ssh-port 2222
```
