```
sudo nix-shell -p btrfs-progs
```
```
mkfs.fat -F 32 /dev/nvme0n1p6
mkfs.btrfs /dev/nvme0n1p8
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
```
nixos-generate-config --root /mnt
nano /mnt/etc/nixos/flake.nix
nano /mnt/etc/nixos/configuration.nix
nixos-install --flake /mnt/etc/nixos#bbh-ally-nixos
```
