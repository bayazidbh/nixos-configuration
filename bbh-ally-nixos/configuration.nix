# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{

  # {BOOT}
  # {{{

  # Use latest CachyOS kernel from Chaotic Nyx..
  boot.kernelPackages = pkgs.linuxPackages_cachyos-gcc; # apparently closest to cachyos-deckify
  # activate ntsync module, preload hid drivers to prevent race condition
  boot.kernelModules = [ "ntsync" "hid_nintendo" "hid_playstation" ];
  services.scx.enable = true; # by default uses scx_rustland scheduler
  # services.scx.scheduler = "scx_rusty"; # jovian steam.nix sets "scx_lavd"


  # Enable SysRq key
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "kernel.split_lock_mitigate" = 0;
    "kernel.nmi_watchdog"        = 0;
    "kernel.sched_bore"          = "1";
    };

  # Use the systemd-boot EFI boot loader with quiet, graphical boot
  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "amd_pstate=active"
      "quiet"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "amdgpu.gttsize=8128"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        configurationLimit = 10;
        enable = true;
      };
      timeout = 5;
    };
    plymouth.enable = true; # Splash screen
  };

  # Make performance-related device attributes controllable by users.
  services.udev.extraRules = ''
    # Enables manual GPU clock control in Steam
    # - /sys/class/drm/card0/device/power_dpm_force_performance_level
    # - /sys/class/drm/card0/device/pp_od_clk_voltage
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/%p/power_dpm_force_performance_level /sys/%p/pp_od_clk_voltage"

    # https://github.com/ublue-os/bazzite/blob/f5f033424281f88f0a132ec0561a5a5f002faf24/system_files/deck/shared/usr/lib/udev/rules.d/50-ally-fingerprint.rules
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{idVendor}=="1c7a", ATTR{idProduct}=="0588", ATTR{power/control}="auto"
    '';


  # Create swapfile
  swapDevices = [{
    device = "/swap/swapfile";
    size = 20*1024; # 20GB for hibernate
  }];

  # }}}

  # {NETWORKING}
  # {{{

  # Define your hostname.
  networking.hostName = "bbh-ally-nixos";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Disable firewall, open all ports
  networking.firewall.enable = false;

  # }}}

  # {LOCALE}
  # {{{

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
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ table-chinese pinyin anthy hangul mozc ];
    ibus.panel = "${pkgs.kdePackages.plasma-desktop}/libexec/kimpanel-ibus-panel";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # }}}

  # {HARDWARE}
  # {{{

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        MultiProfile     = "multiple";
        FastConnectable  = true;
      };
    };
  };

  # Setup graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # OpenCL support using the ROCM runtime library
  hardware.amdgpu.opencl.enable = true;

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
    #jack.enable = true; # If you want to use JACK applications, uncomment this
  };

  # Enable udev rules for Steam hardware such as the Steam Controller
  hardware.steam-hardware.enable = true;
  # Enable the xone driver for Xbox One and Xbox Series X / S accessories
  # (kernel module may cause build fail)
  # hardware.xone.enable = true;
  # Enable uinput support
  hardware.uinput.enable = true;

  # }}}

  # {DESKTOP ENVIRONMENT}
  # {{{

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true; # Needed for x11 desktop mode

  # Configure SDDM with wayland as defaults
  services.displayManager = {
    sddm = {
      enable = false; # Traditional Display Managers cannot be enabled when jovian.steam.autoStart is used
      wayland.enable = true;
      settings.General.DisplayServer = "wayland"; # "wayland" or "x11-user"
    };
    defaultSession = "gamescope-wayland"; # "plasma" or "plasmax11"
    autoLogin = {
      enable = true;
      user = "fenglengshun";
    };
  };

  # Enable Flatpak
  xdg.portal.enable = true; # only needed if you are not using Gnome
  services.flatpak.enable = true;

  # }}}

  # {JOVIAN}
  # {{{
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "fenglengshun";
      updater.splash = "bgrt"; #  one of "steamos", "jovian", "bgrt", "vendor" for splash screen when launching Steam.
      environment = {
        PROTON_USE_NTSYNC       = "1";
        ENABLE_HDR_WSI          = "1";
        DXVK_HDR                = "1";
        PROTON_ENABLE_AMD_AGS   = "1";
        PROTON_ENABLE_NVAPI     = "1";
        ENABLE_GAMESCOPE_WSI    = "1";
        STEAM_MULTIPLE_XWAYLANDS = "1";
      };
    };
    hardware.has.amd.gpu = true; # https://jovian-experiments.github.io/Jovian-NixOS/options.html#jovian.hardware.amd.gpu.enableBacklightControl
    steamos.useSteamOSConfig = false; # https://jovian-experiments.github.io/Jovian-NixOS/options.html#jovian.steamos.useSteamOSConfig
    steam.desktopSession = "plasmax11"; # "plasma" or "plasmax11"
    decky-loader = {
      enable = true;
      user = "fenglengshun";
      extraPackages = with pkgs; [
        ryzenadj
      ];
    };
    workarounds.ignoreMissingKernelModules = true;
  };

  # Steam
  #
  # Set game launcher: gamemoderun %command%
  #   Set this for each game in Steam, if the game could benefit from a minor
  #   performance tweak: YOUR_GAME > Properties > General > Launch > Options
  #   It's a modest tweak that may not be needed. Jovian is optimized for
  #   high performance by default.

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility"; # For systems with AMD GPUs
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  # Enable Steam
  programs.steam = {
    enable = true;
    protontricks.enable = true; #  Enable protontricks, a simple wrapper for running Winetricks commands for Proton games.
    extest.enable = true; # Load the extest library into Steam, to translate X11 input events to uinput events (Steam Input on Wayland)
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers.
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    extraCompatPackages = with pkgs; [
      proton-ge-bin steamtinkerlaunch thcrap-steam-proton-wrapper proton-cachyos_x86_64_v4 # additional compatibility packages
    ];
  };

  # Enable InputPlumber for ROG Ally button support
  # services.inputplumber.enable = true;

  # Enable PowerStation for TDP control support
  # services.powerstation.enable = true;

  # Enable ROG Control Center
  # programs.rog-control-center.enable = true;
  # programs.rog-control-center.autoStart = true;

  # Install and configure handheld-daemon.
  services.handheld-daemon = {
    enable = true;
    user = "fenglengshun";
    ui.enable = true;
    adjustor.enable = true; # Enable Handheld Daemon TDP control plugin.
    adjustor.loadAcpiCallModule = true; # Load the acpi_call kernel module. Required for TDP control by adjustor on most devices.
    };

  # Disable PPD and TuneD to avoid conflict with HHD power profile management (optional)
  # services.power-profiles-daemon.enable = false;
  # services.tuned.enable = false;

  # }}}

  # {User Setup}
  # {{{

    users = {
    groups.fenglengshun= {
      name = "fenglengshun";
      gid = 10000;
      };
    };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fenglengshun = {
    isNormalUser = true;
    description = "Feng Lengshun";
    group = "fenglengshun";
    extraGroups = [ "fenglengshun" "networkmanager" "wheel" "podman" "libvirtd" "gamemode" "docker" "video" "seat" "audio" "uinput" ];
    home = "/home/fenglengshun";
    uid = 10000;
    packages = with pkgs; [
      decky-loader
    ];
  };
  # }}}

  # {Packages}
  # {{{

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true; # needed for flakes
  # TEMPORARY allow insecure packages RECHECK nix-tree!
  # nixpkgs.config.permittedInsecurePackages = [  ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    # background system packages
    cmake busybox btrfs-progs
    xdg-utils desktop-file-utils
    wl-clipboard wl-clipboard-x11
    libwebp libva1 libva-utils libvpx # codecs

    # CLI tools
    dust nix-du graphviz cachix # nix tools
    git gh github-desktop git-lfs cosign # build tools
    grc highlight # text coloring
    bubblewrap firejail boxxy # sandboxing
    wget aria2 rsync zsync # file transfer tools
    appimage-run inxi chezmoi sqlitebrowser rmtrash unrar xdg-ninja chkcrontab # CLI utils
    erdtree delta grex fd bottom ripgrep-all # rust CLIs
    adl gallery-dl mangal mov-cli # CLI-based media downloader
    file ryzenadj # other dependencies

    # KDE packages
    kdePackages.sddm-kcm kdePackages.kcron kdePackages.fcitx5-configtool
    kdePackages.qtbase kdePackages.applet-window-buttons6
    kdePackages.partitionmanager kdePackages.filelight
    kdePackages.arianna kdePackages.kate

    # Themes
    whitesur-kde whitesur-cursors whitesur-gtk-theme whitesur-icon-theme # whitesur theme

    # GUI Apps
    fsearch krename grsync qdirstat czkawka peazip # file management
    wpsoffice normcap # masterpdfeditor4 # document editing
    junction brave firefox google-chrome microsoft-edge vivaldi vivaldi-ffmpeg-codecs # browser
    gabutdm qbittorrent resilio-sync rquickshare # file transfer
    protonvpn-gui proton-pass proton-authenticator # proton
    discord vencord vesktop # social media
    haruna vlc mcomix mangayomi koreader # stremio # multimedia
    distrobox gearlever boxbuddy # app management
    CuboCore.corekeyboard # on-screen keyboad (x11 only)

    # Gaming
    wineWowPackages.stagingFull dxvk winetricks umu-launcher-unwrapped # wine
    protonup-qt steam-rom-manager sgdboop # steam management
    lutris-unwrapped heroic-unwrapped # game management
    faugus-launcher bottles-unwrapped # nero-umu # wine launchers
    scanmem # GameConqueror

    # Others
    mediawriter waydroid-helper networkmanagerapplet # other utilities

    # Chaotic Nyx
    applet-window-title appmenu-gtk3-module jovian-chaotic.mangohud decky-loader
  ];
  # }}}

  # Fonts: See https://wiki.nixos.org/wiki/Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
        liberation_ttf dejavu_fonts noto-fonts
        noto-fonts-color-emoji noto-fonts-emoji-blob-bin
        ibm-plex meslo-lgs-nf fira-code fira-code-symbols
        takao noto-fonts-cjk-sans noto-fonts-cjk-serif vazir-fonts
        wineWowPackages.fonts
    ];

    # fontconfig = {
    #   defaultFonts = {
    #     serif = [  "Liberation Serif" "Vazirmatn" ];
    #     sansSerif = [ "Ubuntu" "Vazirmatn" ];
    #     monospace = [ "Ubuntu Mono" ];
    #   };
    # };
  };

  # {Virtualization}
  # {{{
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
  # }}}

  # {Options}
  # {{{
  # List Options that you want to enable (services, programs, system):

  # Fix for /bin/bash scripts
  services.envfs.enable = true;

  # Needed to run non-NixOS binary (optionally used with nix-alien)
  programs.nix-ld.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Registers AppImage files to be run with appimage-run as interpreter
  programs.appimage = { enable = true; binfmt = true; };

  # Install firefox.
  programs.firefox.enable = true;

  # Enable Plasma Browser Integration in Chromium browsers.
  programs.chromium = { enable = true; enablePlasmaBrowserIntegration = true; };

  # Device off commands without sudo
  security.sudo = {
  enable = true;
  extraRules = [{
    commands = [
      {
        command = "${pkgs.systemd}/bin/systemctl suspend";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.systemd}/bin/reboot";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.systemd}/bin/poweroff";
        options = [ "NOPASSWD" ];
      }
    ];
    groups = [ "wheel" ];
  }];
  extraConfig = with pkgs; ''
    Defaults:picloud secure_path="${lib.makeBinPath [
      systemd
    ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
  '';
};

  # }}}

  # {NIX}
  # {{{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable system autoupgrade:
  system.autoUpgrade = {
    enable = true;
    dates = "Fri";
    allowReboot = true;
    rebootWindow = {
      lower = "02:00";
      upper = "05:00";
    };
  };

  # Enable garbage collection
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # DO NOT CHANGE FROM GENERATED DEFAULT
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "26.05"; # DO NOT CHANGE
  # }}}
}


