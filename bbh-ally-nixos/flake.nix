# flake.nix
{
  description = "ROG Ally Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
    nix-alien.url = "github:thiagokokada/nix-alien";
  };

  outputs = { nixpkgs, nixos-hardware, nix-cachyos-kernel, nix-alien, ... }: {
    nixosConfigurations = {
      bbh-ally-nixos = nixpkgs.lib.nixosSystem { # Replace "hostname" with your system's hostname
        system = "x86_64-linux";
        specialArgs = { inherit nix-cachyos-kernel; };
        modules = [
          ./configuration.nix
          ./hardware.nix
          nixos-hardware.nixosModules.asus-ally-rc71l
          ({ pkgs, ... }: {
            nixpkgs.overlays = [ nix-cachyos-kernel.overlay ];
            boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
            })
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
