{ config, lib, options, modulesPath, ... }:
{
  imports = [
     "${modulesPath}/profiles/qemu-guest.nix"
     ./nixops-deployment.nix
  ];

  config = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];

    services.qemuGuest.enable = true;

    services.openssh = {
      enable = true;
    };

    networking.domain = lib.mkDefault "lan.faultymuse.com";

    # Turn of extra docs to reduce image size
    documentation.nixos.enable = false;
  };
}