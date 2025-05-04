{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the latest kernel for AMD Ryzen 5 6600H
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # Basic system configuration
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Time zone and locale
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  hardware = {
    # Enable AMD firmware
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true;
  
    # Enable Bluetooth service
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
  };

  services.openssh.enable = true;

  nix.settings = {
    # Enable flakes and nix-command
    experimental-features = [ "nix-command" "flakes" ];

    # Hyprland Cachix settings to avoid recompilation
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  # Enable Hyprland
  programs = {
    # Enable Zsh system-wide
    zsh.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  # Enable Desktop Env. essentials
  services = {
    xserver.enable = true;
    displayManager.sddm = {
      enable = true;
      theme = "chili";
      wayland.enable = true;
    };
  };


  # Enable OpenGL for AMD GPU
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa
      libva
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    wl-clipboard
    bluez
    sddm
    sddm-chili-theme # SDDM theme
    qt5.qtquickcontrols2 # Required for SDDM theme rendering
    qt5.qtgraphicaleffects
  ];

  # SDDM theme configuration
  environment.etc."sddm.conf.d/sddm.conf".text = ''
    [Theme]
    Current=chili
    Font=JetBrainsMono Nerd Font
    CursorTheme=breeze_cursors
    [General]
    Numlock=on
  '';

  # User configuration
  users.users.omo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "input" "networkmanager" ];
    shell = pkgs.zsh;
  };

  # System state version
  system.stateVersion = "24.11";
}
