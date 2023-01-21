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
        sharedConfig = {
          network = {
            storage.hercules-ci = { inherit stateName; };
            lock.hercules-ci = { inherit stateName; };
            enableRollback = true;
          };

          defaults = {
            imports = [
              self.nixosModules.proxmox-guest-profile
            ];
          };

        };
        extraArgs = builtins.removeAttrs [ "stateName" ] args;
      in nixpkgs.lib.recursiveUpdate sharedConfig extraArgs;
    };
  };
}
