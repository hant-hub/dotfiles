# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

let 
    custom = pkgs.callPackage ./pkgs/sddm.nix {};
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.

  networking.hostName = "elilaptop"; # Define your hostname.
  networking.dhcpcd.enable = true;
  networking.dhcpcd.extraConfig = ''
    elilaptop
  '';
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.



  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
    #virtualisation.virtualbox = {
    #      host.enable = true;
    #      #host.enableKvm = true;
    #      #host.addNetworkInterface = false;
    #};
  users.extraGroups.vboxusers.members = [ "elijahh" ];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.elijahh = {
    isNormalUser = true;
    description = "Elijah Hantman";
    extraGroups = [ "networkmanager" "wheel" "wireshark" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  services.power-profiles-daemon.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.nginx = {
      enable = true;
      virtualHosts."ehantman.freemyip.com" = {
          listen = [
            { addr = "0.0.0.0"; port = 8000; ssl = true; } # disable ssl for testing
            { addr = "[::]"; port = 8000; ssl = true; }
            { addr = "0.0.0.0"; port = 80; ssl = false; }
          ];

          sslCertificate = "/var/lib/acme/ehantman.freemyip.com/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/ehantman.freemyip.com/key.pem";

          forceSSL = true;
          useACMEHost = "ehantman.freemyip.com";
          locations."/.well-known/".root = "/var/lib/acme/acme-challenge/";
          locations."/".proxyPass = "http://localhost:4000";
      };
  };

  security.acme = {
      acceptTerms = true;
      #defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      defaults.email = "elihantman@gmail.com";
      defaults.webroot = "/var/lib/acme/acme-challenge/";
      certs."ehantman.freemyip.com".group = config.services.nginx.group;
  };
  networking.firewall.allowedTCPPorts = [ 80 8000 ];


  programs.neovim = {
        enable = true;
        package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
	pkgs.vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    pkgs.tree-sitter
    pkgs.clang
    pkgs.nodejs
	pkgs.mesa
	pkgs.mesa-demos
	pkgs.git
	pkgs.pciutils
	pkgs.zsh
	pkgs.wezterm
	pkgs.firefox
    pkgs.perf

	pkgs.waybar

	pkgs.hyprpaper

    pkgs.libX11

	pkgs.libnotify
	pkgs.dunst

	pkgs.wofi
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default

    pkgs.man-db
    pkgs.man-pages
    pkgs.man-pages-posix
    pkgs.glibcInfo
    pkgs.clang-manpages

    pkgs.power-profiles-daemon

    pkgs.zip
    pkgs.unzip
    pkgs.brightnessctl

    pkgs.libX11

    pkgs.duo-unix

    pkgs.networkmanager-openconnect

    pkgs.findutils
    pkgs.openssl
    pkgs.ocamlPackages.ca-certs-nss
    pkgs.networkmanager-openconnect
    pkgs.openconnect

    pkgs.cacert
    pkgs.wireshark

    pkgs.steam
    pkgs.ripgrep
    pkgs.docker
    pkgs.rpi-imager

    pkgs.sddm-astronaut
    pkgs.rgp

    pkgs.dhcpcd
    pkgs.rustc
    pkgs.cargo

    custom.sddm-rocket

    pkgs.kdePackages.qtdeclarative
  #  wget
 # M
  ];

    programs.nix-ld.enable = true;
    virtualisation.docker.enable = true;

    programs.nix-ld.libraries = with pkgs; [
        sdl2-compat
        (python311.withPackages (ps: [ ps.pygame ]))
        python312Packages.pygame-sdl2

    ];

  documentation = {
        dev.enable = true;
        man.cache.enable = true;
        nixos.includeAllModules = true;                                         
  };

  fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        powerline-fonts
  ];

  programs.git.enable = true;
  programs.zsh.enable = true;

  programs.wireshark = {
    enable = true;
    dumpcap.enable = true;
    package = pkgs.wireshark;
  };

  services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
      extraPackages = with pkgs; [
          kdePackages.qt5compat
              kdePackages.qtmultimedia
              kdePackages.qtsvg
              kdePackages.qtvirtualkeyboard
      ];

      theme = "sddm-rocket";
  };
    


  programs.hyprland = {
	enable = true;
	xwayland.enable = true;
  };

  hardware = {
  	graphics.enable = true;
  };

  programs.steam.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };


  system.stateVersion = "25.05"; # Did you read the comment?

}
