{
  description = "Various tools and configs to assit deploying to my Proxmox Homelab";

  outputs = { self }: {
    nixosModules = {
      proxmox-guest-profile = import ./nix/modules/proxmox-guest-profile;
    };

    lib = {
      mkNetwork = args@{
        nixpkgs,
        ...
      }: 
      let
        sharedConfig = {
          inherit nixpkgs;

          network = {
            storage.hercules-ci.stateName = "homelab.nixops";
            lock.hercules-ci.stateName = "homelab.nixops";
            enableRollback = true;
          };

          defaults = {
            imports = [
              self.nixosModules.proxmox-guest-profile
            ];
          };

        };
        extraArgs = builtins.removeAttrs [ "description" ] args;
      in nixpkgs.lib.recursiveUpdate sharedConfig extraArgs;
    };
  };
}
