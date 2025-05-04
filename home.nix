{ config, pkgs, inputs, ... }:

{

  home = {
    username = "omo";
    homeDirectory = "/home/omo";
    stateVersion = "24.11"; # Home Manager state version
  };

  programs.home-manager.enable = true; # Enable Home Manager
  fonts.fontconfig.enable = true; # Fonts 

  # Zsh configuration
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "fzf" ];
      theme = "robbyrussell";
    };
    shellAliases = {
      ls = "eza --icons";
      ll = "ls -l";
      lsa = "ls -a";
      lla = "ll -a";
      df = "df -h";
      du = "du -h";
      open = "thunar"; # File manager
      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";
      nixup = "sudo nixos-rebuild switch --flake .";
      nixup-default = "sudo nixos-rebuild switch --flake .#default";
      nixclean = "nix-collect-garbage -d";
      hyprd = "hyprctl dispatch";
      bt = "~/.config/hypr/scripts/rofi-bluetooth.sh";
    };
  };

  # Kitty terminal
  programs.kitty = {
    enable = true;
    themeFile = "Gruvbox Dark";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      tab_bar_style = "fade";
      tab_fade = "0.25 0.5 0.75 1";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";
    };
  };

  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      source = [
        "~/.config/hypr/keymap.conf"
        "~/.config/hypr/rules.conf"
      ];
      monitor = [ ",preferred,auto,1" ];
      exec-once = [
	"swww"
	"mako"
	"nm-applet"
        "blueman-applet"
        "python ~/.config/Ax-Shell/main.py" # Run Ax-Shell        
      ];
      env = [
        "HYPRCURSOR_THEME,HyprBibataModernClassicSVG"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,24"
      ];
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
      };
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = true;
      };
      decoration = {
        rounding = 10;
      };
      animations = {
        enabled = true;
        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
        ];
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      master.new_status = "master";
      gestures.workspace_swipe = true;
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        vrr = 1; # Enable Variable Refresh Rate for AMD GPU
        vfr = true; # Variable frame rate
        enable_hyprcursor = true; # Enable hyprcursor
      };
    };
  };

  # Waybar configuration (disabled, replaced by Ax-Shell)
  programs.waybar.enable = false;

  # NixVim configuration
  programs.nixvim = {
    enable = true
    colorschemes.catppuccin.enable = true;;
    plugins = {
      lsp = {
        enable = true;
        servers = 
          nil_ls.enable = true;
          pyright.enable = true;{
        };
      }
      telescope.enable = true;
      nvim-tree.enable = true;
      web-devicons.enable = true;;
    };
  };

  # Home packages
  home.packages = with pkgs; [
    hyprpaper
    rofi-wayland
    mako
    (inputs.zen-browser.packages."x86_64-linux".default)
    slock
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    bluez
    bc
    xclip # For pbcopy/pbpaste
    eza # For ls, ll, la
    thunar # For open
    python3 # For Ax-Shell
    python3Packages.fabric # For Ax-Shell
    matugen # For Ax-Shell color theming
  ];

  # Hyprland configuration files
  home.file = {
    ".config/hypr/hyprland.conf".source = ./dots/hyprland/config/hyprland.conf;
    ".config/hypr/keymap.conf".source = ./dots/hyprland/keymap/keymap.conf;
    ".config/hypr/rules.conf".source = ./dots/hyprland/rules/rules.conf;
    ".config/hypr/scripts/change_wallpaper.sh" = {
      source = ./dots/hyprland/scripts/change_wallpaper.sh;
      executable = true;
    };
    ".config/hypr/scripts/rofi_powermenu.sh" = {
      source = ./dots/hyprland/scripts/rofi_powermenu.sh;
      executable = true;
    };
    ".config/hypr/scripts/rofi-bluetooth.sh" = {
      source = ./dots/hyprland/scripts/rofi-bluetooth.sh;
      executable = true;
    };
    ".config/hypr/hyprpaper.conf".text = ''
      wallpaper = ,/home/myUser/Pictures/Wallpapers/wallpaper.jpg
    '';
    ".config/mako/config".text = ''
      width=300
      height=100
      max-visible=5
      timeout=5
      text=<b>%s</b>: %b
      path=/usr/share/icons/Arc/24x24/status/
    '';
    ".config/sddm/wallpaper.jpg".source = ./dots/sddm/wallpaper.jpg;

    # Ax-Shell configuration
    ".config/Ax-Shell/main.py".source = "${inputs.ax-shell}/main.py";
    ".config/Ax-Shell/config.json".text = ''
      {
        "theme": "auto",
        "modules": [
          {"type": "workspaces"},
          {"type": "window"},
          {"type": "clock"},
          {"type": "pulseaudio"},
          {"type": "network"},
          {"type": "tray"}
        ]
      }
    '';

    # hyprcursor theme
    ".local/share/icons/HyprBibataModernClassicSVG".source = fetchTarball {
      url = "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Classic-Hyprcursor.tar.gz";
      sha256 = "1c8z2l9j2m1z3k4v5n6w7x8y9z0a1b2c3d4e5f6g7h8i9j0k1l2m";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
