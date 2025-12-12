# flake.nix
{
  description = "ROG Ally Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    jovian.follows = "chaotic/jovian";
    nix-alien.url = "github:thiagokokada/nix-alien";
  };

  outputs = { nixpkgs, nixos-hardware, chaotic, jovian, nix-alien ... }: {
    nixosConfigurations = {
      bbh-ally-nixos = nixpkgs.lib.nixosSystem { # Replace "hostname" with your system's hostname
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          nixos-hardware.nixosModules.asus-ally-rc71l
          jovian.nixosModules.default
          chaotic.nixosModules.default
          ({ self, system, ... }: {
            environment.systemPackages = with self.inputs.nix-alien.packages.${system}; [
              nix-alien
            ];
          })
        ];
      };
    };
  };
}
