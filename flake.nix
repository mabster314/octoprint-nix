{
  description = "Base system for raspberry pi 4";
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
    nixosModules = {
      system = {
        # Disabling the whole `profiles/base.nix` module, which is responsible
        # for adding ZFS and a bunch of other unnecessary programs:
        disabledModules = [
          "profiles/base.nix"
        ];
        nixpkgs.overlays = [ (final: super: {
            makeModulesClosure = x:
              super.makeModulesClosure (x // { allowMissing = true; });
        }) ];
      };
    };
   
    packages.aarch64-linux = {
      octoprint = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        format = "sd-aarch64";
        modules = [
          self.nixosModules.system
          nixos-hardware.nixosModules.raspberry-pi-4
          ./octoprint/configuration.nix
        ];
      };
    };
  };
}