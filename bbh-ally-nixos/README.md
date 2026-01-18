## Download NixOS ISO

You can grab the stable ISO from [NixOS Download page](https://nixos.org/download/) but since Jovian only officially supports nixos-unstable, per [the forum](https://discourse.nixos.org/t/where-to-find-unstable-iso/64777), you can grab the [unstable ISO](https://channels.nixos.org/nixos-unstable/latest-nixos-graphical-x86_64-linux.iso) instead if you want to skip installing NixOS stable channel and straight into unstable instead.


## Setup BTRFS on ROG Ally:

```
sudo nix-shell -p btrfs-progs
```

Adjust partitions based on your configs. The following follows a setup where Windows are already installed on `/dev/nvme0n1p1` to `/dev/nvme0n1p5`.

```
mkfs.fat -F 32 -n NIXOS-BOOT /dev/nvme0n1p6
mkfs.btrfs -L NIXOS /dev/nvme0n1p8
```
```
mkdir -p /mnt
mount /dev/nvme0n1p8 /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/swap
btrfs subvolume create /mnt/log
umount /mnt
```
```
mount -o compress=zstd,subvol=root /dev/nvme0n1p8 /mnt
mkdir -p /mnt/{home,nix,swap,var/log}
mount -o compress=zstd,subvol=home /dev/nvme0n1p8 /mnt/home
mount -o compress=zstd,noatime,subvol=nix /dev/nvme0n1p8 /mnt/nix
mount -o compress=zstd,noatime,subvol=log /dev/nvme0n1p8 /mnt/var/log
mount -o noatime,subvol=swap /dev/nvme0n1p8 /mnt/swap
```
```
mkdir /mnt/boot
mount /dev/nvme0n1p6 /mnt/boot
```

## Setup first NixOS install on ROG Ally:

If you want to use my config as basis, you can download from Github here via the included Firefox browser on the nixos graphical ISO (or use whatever your preferred way to download stuff from github is).

After making sure `/mnt` has been mounted as root and and a `/mnt/boot` partition has been mounted:

```
nixos-generate-config --root /mnt
nano /mnt/etc/nixos/flake.nix
nano /mnt/etc/nixos/configuration.nix
nixos-install --flake /mnt/etc/nixos#bbh-ally-nixos
```

Adjust the nixos-install command based on if you're doing a barebones NixOS install first or if you want to install your config (adjust the config and hostname as necessary).

## Known issues:

A few known issues:

1. Steam on Desktop Mode cannot handle the ROG Ally input device. It will crash as soon as you press any buttons that isn't the standard keyboard and mouse input from the HHD Keyboard & Mouse mode (press and hold ROG button).
2. This uses HHD which has conflicts with SteamOS Manager. The choice is deliberate due to HHD's K&M emulation being the only way to have any sort of input at all on Desktop Mode without always using a physical keyboard and mouse.
3. Steam Game Mode may have blank screen after the initial intro animation. From my testing, this usually happens because you aren't plugging in all the usb dock/hub and peripheral you usually have, so it is likely an issue between the display device ID, Game Mode's launch setting, and how having extra USB devices messes with that.
4. There are random performance issues in Desktop Mode. nix-cachyos-kernel latest-zen4 I've found to be the least worst of them, and there are issues with both Jovian's kernel (I failed installing it) and default NixOS kernel (HHD didn't work).

In general, this setup works fine if you just really really want to use NixOS as your system management but otherwise expect to live on Game Mode with the same hardwares plugged on your USB hubs while rarely ever fully shutting down the device.

Otherwise, you are better off using SteamOS, CachyOS, or Bazzite and using Home Manager via [nix-toolbox](https://thrix.github.io/nix-toolbox/getting-started/) or normal nix install.

## Contacts:

If you have any questions, you should probably ask around in Jovian's [matrix server](https://matrix.to/#/#Jovian-Experiments:matrix.org). I am also in that server, so you can ping me if you want for any questions.
