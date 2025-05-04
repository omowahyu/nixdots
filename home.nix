{ config, pkgs, inputs, ... }:

let
  axShellSrc = pkgs.fetchFromGitHub {
    owner = "Axenide";
    repo = "Ax-Shell";
    rev = "main";
    sha256 = "1jkrxvkbalmb63ysvcys12v5y2hg6vig3y78hjhjllvjqi5qwdhv";
  };
in

{

  home.username = "omo";
  home.homeDirectory = "/home/omo";
  home.stateVersion = "24.11"; # Home Manager state version

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
    themeFile = "GruvboxDark";
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
        "swww init && swww img /home/omo/.dots/Wallpapers/wall1.jpg --transition-type fade --transition-fps 60"
        "mako"
        "nm-applet"
        "blueman-applet"
        "python ~/.config/Ax-Shell/main.py"
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
        touchpad.natural_scroll = true;
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
        bezier = [ "myBezier, 0.05, 0.9, 0.1, 1.05" ];
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
        vrr = 1;
        vfr = true;
        enable_hyprcursor = true;
      };
    };
    # Include additional Hyprland config if needed
    extraConfig = ''
      # Add custom Hyprland settings from dots/hyprland/config/hyprland.conf here if necessary
      # For example:
      # bind = SUPER, Q, exec, kitty
    '';
  };

  # Waybar configuration (disabled, replaced by Ax-Shell)
  programs.waybar.enable = false;

# NixVim configuration with LazyVim
  programs.nixvim = {
    enable = true;
    extraConfigLua = ''
      -- Bootstrap lazy.nvim
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable",
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)

      -- Setup lazy.nvim
      require("lazy").setup({
        {
          "catppuccin/nvim",
          name = "catppuccin",
          config = function()
            require("catppuccin").setup({
              flavour = "mocha",
              transparent_background = false,
            })
            vim.cmd.colorscheme "catppuccin"
          end,
        },
        {
          "nvim-telescope/telescope.nvim",
          dependencies = { "nvim-lua/plenary.nvim" },
        },
        {
          "kyazdani42/nvim-tree.lua",
          dependencies = { "kyazdani42/nvim-web-devicons" },
          config = function()
            require("nvim-tree").setup {}
          end,
        },
        {
          "neovim/nvim-lspconfig",
          config = function()
            local lspconfig = require("lspconfig")
            lspconfig.nil_ls.setup {}
            lspconfig.pyright.setup {}
          end,
        },
      }, {
        performance = {
          rtp = {
            disabled_plugins = {
              "gzip",
              "matchit",
              "matchparen",
              "netrwPlugin",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
      })
    '';
    extraPackages = with pkgs; [
      git # Required for lazy.nvim to clone plugins
      nil # LSP for Nix
      pyright # LSP for Python
    ];
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
    xfce.thunar # For open
    python3 # For Ax-Shell
    python3Packages.fabric # For Ax-Shell
    matugen # For Ax-Shell color theming
  ];

  # Hyprland configuration files
  home.file = {
    ".config/hypr/keymap.conf".source = ./modules/hyprland/keymap.conf;
    ".config/hypr/rules.conf".source = ./modules/hyprland/rules.conf;
    ".config/hypr/scripts/change_wallpaper.sh" = {
      source = ./modules/hyprland/scripts/change_wallpaper.sh;
      executable = true;
    };
    ".config/hypr/scripts/powermenu.sh" = {
      source = ./modules/hyprland/scripts/powermenu.sh;
      executable = true;
    };
    ".config/hypr/scripts/bluetooth.sh" = {
      source = ./modules/hyprland/scripts/bluetooth.sh;
      executable = true;
    };
    ".config/hypr/hyprpaper.conf".text = ''
      wallpaper = ,/home/omo/.dots/Wallpapers/wall1.jpg
    '';
    ".config/mako/config".text = ''
      width=300
      height=100
      max-visible=5
      timeout=5
      text=<b>%s</b>: %b
      path=/usr/share/icons/Arc/24x24/status/
    '';
    ".config/sddm/wallpaper.jpg".source = ./Wallpapers/wall1.jpg;

    # Ax-Shell configuration
    ".config/Ax-Shell/main.py".source = "${axShellSrc}/main.py";
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
    ".local/share/icons/CursorBibataModernIce".source = fetchTarball {
      url = "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Ice.tar.xz";
      sha256 = "01acywlhs45hisa16ydmyq5r8zr49f7rnf6smz6k3x6avm0wsvs8";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
