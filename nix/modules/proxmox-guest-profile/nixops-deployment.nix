{ pkgs, lib, options, ...}:
let
  secretCommand = secret: 
    ''${pkgs.sops}/bin/sops --extract '["${secret}"]' -d ${../../../proxmox.json}'';
  isNixops = (builtins.hasAttr "deployment" options);
in {
  config = if isNixops then {
    deployment.hasFastConnection = true;
    deployment.targetEnv = "proxmox";
    deployment.proxmox = {
      serverUrl = "pve.faultymuse.com:8006";
      username.command = secretCommand "username";
      tokenName.command = secretCommand "tokenName";
      tokenValue.command = secretCommand "tokenValue";

      uefi = {
        enable = true;
        volume = "nvme0";
      };
      network = lib.mkDefault [
        ({bridge = "vmbr0"; })
      ];
      installISO = "local:iso/nixos-23.05.20221229.677ed08-x86_64-linux.isonixos.iso";
      usePrivateIPAddress = true;
      partitions = ''
        set -x
        set -e
        wipefs -f /dev/sda

        parted --script /dev/sda -- mklabel gpt
        parted --script /dev/sda -- mkpart primary 512MB -2GiB 
        parted --script /dev/sda -- mkpart primary linux-swap -2GiB 100% 
        parted --script /dev/sda -- mkpart ESP fat32 1MB 512MB
        parted --script /dev/sda -- set 3 esp on

        sleep 0.5

        mkfs.ext4 -L nixroot /dev/sda1
        mkswap -L swap /dev/sda2
        swapon /dev/sda2
        mkfs.fat -F 32 -n NIXBOOT /dev/sda3

        mount /dev/disk/by-label/nixroot /mnt

        mkdir -p /mnt/boot
        mount /dev/disk/by-label/NIXBOOT /mnt/boot
      '';

      fileSystems = {
        "/" = {
          device = "/dev/sda2";
          fsType = "ext4";
        };
        "/boot" = {
          device = "/dev/sda1";
          fsType = "vfat";
        };
      };
      swapDevices = [
        { device = "/dev/sda2"; }
      ];
    };
  } else {};
}