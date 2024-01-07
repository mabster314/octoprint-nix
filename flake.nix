{
  description = "Max's octoprint server on raspberry pi 4";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, nixos-hardware, sops-nix, ... }: 
  {
    packages.aarch64-linux = {
      octoprint = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        format = "sd-aarch64";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          sops-nix.nixosModules.sops
          ./raspberry-pi-4.nix
          ./configuration.nix
          ./secrets.nix
        ];
      };
    };
  };
}