# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Change kernel:
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "bbh-server-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Disable NetworkManager's internal DNS resolution
  # networking.networkmanager.dns = "none";

  # These options are unnecessary when managing DNS ourselves
  # networking.useDHCP = false;
  # networking.dhcpcd.enable = false;

  # Configure DNS servers manually (this example uses Cloudflare and Google DNS)
  # IPv6 DNS servers can be used here as well.
  # networking.nameservers = [
  #   "94.140.14.14"
  #   "94.140.15.15"
  # ];

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_SG.UTF-8";
  i18n.extraLocales = [ "en_US.UTF-8/UTF-8" "id_ID.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" ];
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_SG.UTF-8";
    LC_IDENTIFICATION = "en_SG.UTF-8";
    LC_MEASUREMENT = "en_SG.UTF-8";
    LC_MONETARY = "en_SG.UTF-8";
    LC_NAME = "en_SG.UTF-8";
    LC_NUMERIC = "en_SG.UTF-8";
    LC_PAPER = "en_SG.UTF-8";
    LC_TELEPHONE = "en_SG.UTF-8";
    LC_TIME = "en_SG.UTF-8";
  };
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc-ut fcitx5-gtk ];
  };

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure SDDM with x11 as defaults
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = false;
      settings.General.DisplayServer = "x11-user"; # "wayland"
    };
    defaultSession = "plasmax11"; # "plasmawayland"
    autoLogin = {
      enable = true;
      user = "fenglengshun";
    };
  };

  # Enable Flatpak
  xdg.portal.enable = true; # only needed if you are not doing Gnome
  services.flatpak.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # TEMPORARY allow insecure packages RECHECK nix-tree!
  # nixpkgs.config.permittedInsecurePackages = [ ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fenglengshun = {
    isNormalUser = true;
    description = "Feng Lengshun";
    extraGroups = [ "fenglengshun" "networkmanager" "wheel" "podman" "libvirtd" ];
    packages = with pkgs; [
      git gh github-desktop git-lfs cosign cachix # subversion # build tools
      inxi grc highlight rmtrash libwebp unrar xdg-ninja # CLI utils
      fsearch krename rsync grsync zsync czkawka # file management
      kdePackages.kate normcap masterpdfeditor4 # document editing
      junction brave google-chrome microsoft-edge vivaldi vivaldi-ffmpeg-codecs # browser
      qbittorrent resilio-sync rquickshare # file transfer
      protonvpn-gui proton-pass proton-authenticator # proton
      discord vencord vesktop # social media
      haruna vlc mcomix mangayomi koreader kdePackages.arianna # multimedia # remove stremio due to "qtwebengine-5.15.19"
      distrobox gearlever boxbuddy # app management
      protonup-qt lutris-unwrapped heroic-unwrapped # faugus-launcher # game management
      whitesur-kde whitesur-cursors whitesur-gtk-theme whitesur-icon-theme # whitesur theme
      mediawriter # other utilities
    ];
  };

  # Enable system autoupgrade:
  system.autoUpgrade = {
    enable = true;
    dates = "Fri";
    allowReboot = true;
    rebootWindow = {
      lower = "02:00";
      upper = "05:00";
    };
    runGarbageCollection = true;
  };

  # Install firefox.
  programs.firefox.enable = true;

  programs.chromium = {
    enable = true;
    enablePlasmaBrowserIntegration = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    busybox wget aria2 chkcrontab
    kdePackages.sddm-kcm kdePackages.kcron kdePackages.fcitx5-configtool
    kdePackages.partitionmanager kdePackages.applet-window-buttons6
    waydroid-helper networkmanagerapplet
    ibm-plex meslo-lgs-nf noto-fonts-emoji-blob-bin noto-fonts-cjk-sans noto-fonts-cjk-serif
  ];

  # Registers AppImage files to be run with appimage-run as interpreter
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Enable qbittorrent-nox service.
  services.qbittorrent.enable = true;

  # Enable hardware acceleration
    hardware.graphics = { # hardware.graphics since NixOS 24.11
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ intel-media-driver intel-vaapi-driver ];
  };
  # environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    extraCompatPackages = with pkgs; [
      proton-ge-bin steamtinkerlaunch thcrap-steam-proton-wrapper
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable virt-manager to interface with qemu/kvm
  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd = { # enable for virtual machine support
      enable = true; # use libvirtd for qemu/kvm
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ]; # enable shared folder with guest,
    };
    containers.enable = true; # enable containers support for distrobox support
    podman = {
      enable = true; # use podman for containers
      dockerCompat = true; # help compatibility with Docker
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
    waydroid.enable = true; # wayland-based android virtualizer
  };

  # Mount host directories to waydroid
  systemd = {
    packages = [ pkgs.waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];
  };

  # GPS/Location forwarding
  services.geoclue2.enable = true;
  programs.adb.enable = true;

  # Mount harddisk to ~/Storage
  fileSystems."/home/fenglengshun/Storage" =
    { device = "/dev/disk/by-uuid/c730b671-86f6-45f3-892e-841ecacadbd3";
      options = [ "defaults" "compress=zstd:6" "noatime" ];
      fsType = "btrfs";
    };

  # Optimize power use
  services.thermald.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
