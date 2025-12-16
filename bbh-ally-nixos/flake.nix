# flake.nix
{
  description = "ROG Ally Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    # jovian.follows = "chaotic/jovian";
    nix-alien.url = "github:thiagokokada/nix-alien";
  };

  # nixpkgs, nixos-hardware, chaotic, nix-alien, # jovian,
  outputs = { nixpkgs, nixos-hardware, chaotic, nix-alien, ... }: {
    nixosConfigurations = {
      bbh-ally-nixos = nixpkgs.lib.nixosSystem { # Replace "hostname" with your system's hostname
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          nixos-hardware.nixosModules.asus-ally-rc71l
          chaotic.nixosModules.default
          # jovian.nixosModules.default
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
