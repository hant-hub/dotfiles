# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.

  networking.hostName = "elilaptop"; # Define your hostname.
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
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  services.power-profiles-daemon.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.neovim = {
        enable = true;
        package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
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

	pkgs.waybar

	pkgs.hyprpaper


	pkgs.libnotify
	pkgs.dunst

	pkgs.wofi
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default

    pkgs.man-db
    pkgs.man-pages
    pkgs.man-pages-posix
    pkgs.glibcInfo
    pkgs.clang-manpages

    pkgs.power-profiles-daemon

    pkgs.zip
    pkgs.unzip
    pkgs.brightnessctl

    pkgs.xorg.libX11

    pkgs.duo-unix

    pkgs.networkmanager-openconnect

    pkgs.findutils
    pkgs.openssl
    pkgs.ocamlPackages.ca-certs-nss
    pkgs.networkmanager-openconnect
    pkgs.openconnect

    pkgs.cacert
  #  wget
 # M
  ];

    programs.nix-ld.enable = true;

    programs.nix-ld.libraries = with pkgs; [
        sdl2-compat
        (python311.withPackages (ps: [ ps.pygame ]))
        python312Packages.pygame-sdl2

    ];

  documentation = {
        dev.enable = true;
        man.generateCaches = true;
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
  };

  programs.hyprland = {
	enable = true;
	xwayland.enable = true;
  };

  hardware = {
  	graphics.enable = true;
  };

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

  security.pki = {
     certificates = [ ''
            -----BEGIN CERTIFICATE-----
MIIEoTCCA4mgAwIBAgIJAOSNPtSPcGOVMA0GCSqGSIb3DQEBCwUAMIGRMQswCQYD
VQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTETMBEGA1UEBxMKU2FudGEgQ3J1
ejERMA8GA1UEChMIVUNTQy1OT0MxHDAaBgkqhkiG9w0BCQEWDW5vcHNAdWNzYy5l
ZHUxJzAlBgNVBAMTHlVDU0MtTk9DIENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0x
NjA5MjEyMTQ0NDlaFw0zNjA5MTYyMTQ0NDlaMIGRMQswCQYDVQQGEwJVUzETMBEG
A1UECBMKQ2FsaWZvcm5pYTETMBEGA1UEBxMKU2FudGEgQ3J1ejERMA8GA1UEChMI
VUNTQy1OT0MxHDAaBgkqhkiG9w0BCQEWDW5vcHNAdWNzYy5lZHUxJzAlBgNVBAMT
HlVDU0MtTk9DIENlcnRpZmljYXRlIEF1dGhvcml0eTCCASIwDQYJKoZIhvcNAQEB
BQADggEPADCCAQoCggEBAK4TFSlLcPsuBHt7NyEk2iqHYBUKLe090NC+O/5s1hLS
aEMWljZMTp1A5dM7Bvw9swx3ZEIupKfY/AObGcgYCSPSFfkeg3qnbSojRl5JCg2i
uZJxHZ7kwCGkF8DFjmsAmszVRuJmRfyUML1fYDBR+xjqnBbeDaPCSEpLC3e+mzy4
EWYHmi/CEDOu9uD28ROFfJxdOg+MuabQzHXMO4IBD/CVgJEpxXiKz/C32A5yPALT
Z7rfVyIFPPezGwkmcwCqFQH88ALYkrfe6sJ8BEtmc8zDgji/2T5dIubycvCaPKHp
xqanlkUb6Dy1Q1sHM6Z1Oq+wT2oA+NQX3JIW5VzdJL0CAwEAAaOB+TCB9jAdBgNV
HQ4EFgQUCJ3qctdMoYobhLfks1jzhQ0D7d4wgcYGA1UdIwSBvjCBu4AUCJ3qctdM
oYobhLfks1jzhQ0D7d6hgZekgZQwgZExCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpD
YWxpZm9ybmlhMRMwEQYDVQQHEwpTYW50YSBDcnV6MREwDwYDVQQKEwhVQ1NDLU5P
QzEcMBoGCSqGSIb3DQEJARYNbm9wc0B1Y3NjLmVkdTEnMCUGA1UEAxMeVUNTQy1O
T0MgQ2VydGlmaWNhdGUgQXV0aG9yaXR5ggkA5I0+1I9wY5UwDAYDVR0TBAUwAwEB
/zANBgkqhkiG9w0BAQsFAAOCAQEAXKsm8hgrP60onNajQp964bMclF4tDhhmpKko
eWCn8D2j5/SN9w9bMLBX5GA9BLFpw/zreP42IkkpByvxafTtK0zn4lx6Otu0Yfxx
RgNUumrQDTKf8JBqLfWS0FOwt582hhEgZtZ8Yk8pyZuqHAqruzLTfhgyCW7bqka+
9jpJdrZDXG5+vpDRkpmZv0O22IV6YsERtaqrFzcc6tDS4m1JoC5idpniwcPxYDFX
ZsrLBqW8FO4Pq/OMNxQ/Vtai/n0+vJmtaeGYpqL5Lw3xAP9lLl4B9QWx/APTNsvZ
nEHvzeSc0WOxossRSbvDBlXehoCF+YtncnkkfjhDF9XcUo6RZw==
-----END CERTIFICATE-----
       ''
     ]
     ;
  };
 
    security.duosec = {
        pam.enable = true;
        autopush = true;
    };

    




  system.stateVersion = "25.05"; # Did you read the comment?

}
