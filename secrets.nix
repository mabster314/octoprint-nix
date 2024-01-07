{ config, sops-nix, ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;

    secrets = {
      "wireless.env" = {};

      "x509_cert" = {
        owner = "nginx";
        group = "nginx";
      };

      "x509_key" = {
        owner = "nginx";
        group = "nginx";
      };
    };
  };
}