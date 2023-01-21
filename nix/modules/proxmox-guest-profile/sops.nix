{ config, lib, pkgs, ...}: {
  config = lib.mkIf config.scott.sops.enable {
    scott.sops.ageKeyFile = "/var/lib/.secrets/sops-age-key";

    deployment.keys.sops-age-key = {
      destDir = "/var/lib/.secrets";
      keyCommand = [
        "${pkgs.sops}/bin/sops" 
        "--extract" ''["server_key"]''
        "-d" ../../../secrets.yaml
      ];
    };
  };
}