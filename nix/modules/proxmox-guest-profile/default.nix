{ config, options, lib, pkgs, modulesPath, ... }:
let
  secretCommand = secret: 
    ''${pkgs.sops}/bin/sops --extract '["${secret}"]' -d ${../../../proxmox.json}'';
  isNixops = (builtins.hasAttr "deployment" options);
in with lib; {
  imports = [
     "${modulesPath}/profiles/qemu-guest.nix"
  ];

  config = 
    if !isNixops then # Only apply if we're in nixops
      {}
    else {
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
        network = mkDefault [
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
      };

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];

      fileSystems = {
        "/" = {
          device = "/dev/sda1";
          fsType = "ext4";
        };
        "/boot" = {
          device = "/dev/sda3";
          fsType = "vfat";
        };
      };
      swapDevices = [
        { device = "/dev/sda2"; }
      ];

      services.qemuGuest.enable = true;
      services.cloud-init.network.enable = true;

      services.openssh = {
        enable = true;
      };

      networking.domain = mkDefault "lan.faultymuse.com";

      # Turn of extra docs
      documentation.nixos.enable = false;
    };
}