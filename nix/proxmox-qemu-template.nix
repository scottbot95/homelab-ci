{ config, lib, pkgs, ...}:
let
in {
  imports = [ ./modules/proxmox-guest-profile ];
  
  proxmox.qemuConf = {
    cores = 4;
    memory = 4096;
    bios = "ovmf";
    virtio0 = "nvme0:vm-9999-disk-0";
  };

  system.stateVersion = "23.05";
}