# flake.nix
{
  description = "ROG Ally Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
  };

  outputs = { nixpkgs, jovian, nixos-hardware, nix-cachyos-kernel, ... }: {
    nixosConfigurations = {
      bbh-ally-nixos = nixpkgs.lib.nixosSystem { # Replace "hostname" with your system's hostname
        system = "x86_64-linux";
        specialArgs = { inherit nix-cachyos-kernel; };
        modules = [
          ./configuration.nix
          ./hardware.nix
          jovian.nixosModules.default
          nixos-hardware.nixosModules.asus-ally-rc71l
          ({ pkgs, ... }: {
            nixpkgs.overlays = [ nix-cachyos-kernel.overlay ];
            boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
            })
        ];
      };
    };
  };
}
