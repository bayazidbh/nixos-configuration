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
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, jovian, nixos-hardware, nix-cachyos-kernel, aagl, ... }: {
    nixosConfigurations = {
      bbh-ally-nixos = nixpkgs.lib.nixosSystem { # Replace "hostname" with your system's hostname
        system = "x86_64-linux";
        specialArgs = { inherit nix-cachyos-kernel; };
        modules = [
          # ./basic.nix # template ./configuration.nix file

          ./configuration.nix
          ./hardware.nix
          jovian.nixosModules.default
          nixos-hardware.nixosModules.asus-ally-rc71l

          # nix-cachyos-kernel:
          ({ pkgs, ... }: {
            nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
            boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4;
            })

          # hoyo games launchers:
          {
            imports = [ aagl.nixosModules.default ];
            nix.settings = aagl.nixConfig; # Set up Cachix
            programs.anime-game-launcher.enable = true; # Adds launcher and /etc/hosts rules
            # programs.anime-games-launcher.enable = true;  # unified launcher (beta)
            programs.honkers-railway-launcher.enable = true;
            programs.honkers-launcher.enable = true;
            programs.wavey-launcher.enable = true;
            programs.sleepy-launcher.enable = true;
          }
        ];
      };
    };
  };
}
