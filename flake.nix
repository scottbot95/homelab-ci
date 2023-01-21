{
  description = "Various tools and configs to assit deploying to my Proxmox Homelab";

  outputs = { self }: {
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
  };
}
