{
  description = "Max's octoprint server on raspberry pi 4";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-generators, nixos-hardware, ... }: 
  {
    packages.aarch64-linux = {
      octoprint = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        format = "sd-aarch64";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./raspberry-pi-4.nix
          ./configuration.nix
        ];
      };
    };
  };
}