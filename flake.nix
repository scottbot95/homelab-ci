{
  description = "Various tools and configs to assit deploying to my Proxmox Homelab";

  inputs.nixpkgs.url = "github:NixOs/nixpkgs";
  inputs.nixos-generators.url = "github:nix-community/nixos-generators";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixos-generators, ... }: {
    nixosModules = {
      proxmox-guest-profile = import ./nix/modules/proxmox-guest-profile;
    };

    lib = {
      mkNetwork = args@{
        nixpkgs,
        stateName ? "homelab.nixops",
        ...
      }:
      let
        hciConfig = {
          inherit stateName;
          project = "github/scottbot95/nixos-config";
        };
        sharedConfig = {
          network = {
            storage.hercules-ci = hciConfig;
            lock.hercules-ci = hciConfig;
            enableRollback = true;
          };

          defaults = {
            imports = [
              self.nixosModules.proxmox-guest-profile
            ];
          };

        };
        extraArgs = builtins.removeAttrs args [ "stateName" ];
      in nixpkgs.lib.recursiveUpdate sharedConfig extraArgs;
    };

    packages.x86_64-linux.proxmox-qemu-template = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "proxmox";
      modules = [ ./nix/proxmox-qemu-template.nix ];
    };
  };
}
