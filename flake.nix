{
  description = "NixOS configuration with flake-parts, home-manager, nixvim, zen-browser, nixgl, and hyprland for AMD Ryzen 5 6600H";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Desktop
    home-manager = { # User ENV
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = { # Hyprland for Wayland compositor
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprcursor = { # Cursor
      url = "github:hyprwm/hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = { # OpenGL Compability
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    #Editor
    nixvim = { # NixVim for Neovim configuration
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #Browser
    zen-browser = { # Zen Browser flake
      url = "github:MarceColl/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable,flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Define supported systems
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # Per-system configuration
      perSystem = { system, ... }: {
        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
        devShells.default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            nixpkgs-fmt
            git
          ];
        };
      };

      # Flake modules
      flake = {
        nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
	   # ./dnscrypt-proxy.nix
            inputs.nixos-hardware.nixosModules.common-cpu-amd
            inputs.nixos-hardware.nixosModules.common-gpu-amd
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
		useGlobalPkgs = true;
                useUserPackages = true;
		users.omo = import ./home.nix;
                extraSpecialArgs = { inherit inputs; };
                sharedModules = [ inputs.nixvim.homeManagerModules.nixvim ];
              };
            }
          ];
        };

        # Home-manager standalone configurations
        homeConfigurations."omo@nixos" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs; };
          modules = [
            inputs.nixvim.homeManagerModules.nixvim
            ./home.nix
          ];
        };

        # Optional: Add overlays for custom packages
        overlays.default = final: prev: {
          unstable = inputs.nixpkgs-unstable.legacyPackages.${prev.system};
          nixgl = inputs.nixgl.packages.${prev.system};
          hyprland = inputs.hyprland.packages.${prev.system}.hyprland;
          hyprcursor = inputs.hyprcursor.packages.${prev.system}.hyprcursor;
        };
      };
    };
}
