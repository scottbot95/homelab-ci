{ config, lib, pkgs, ...}:
let
in {
  imports = [ ./modules/proxmox-guest-profile ];
  
  proxmox.qemuConf = {
    cores = 4;
    memory = 4096;
    bios = "ovmf";
    virtio0 = "local-lvm:vm-9999-disk-0";
  };
  proxmox.qemuExtraConf = {
    # efidisk doesn't autocreate storage, must be manually added
    # efidisk0 = "local-lvm:vm-9999-disk-1,efitype=4m,size=4M";
    ide2 = "local-lvm:vm-9999-cloudinit,media=cdrom";
    template = 1;
  };

  services.cloud-init.enable = true;
  services.cloud-init.network.enable = true;

  users.users.root.initialPassword = "";

  system.stateVersion = "23.05";
}