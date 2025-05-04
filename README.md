# NixOS Configuration

## Directory Structure
- `configuration.nix`: System configuration
- `flake.nix`: Flake inputs and outputs
- `home.nix`: Home Manager configuration
- `dots/hyprland/`: Hyprland settings
- `dots/sddm/`: SDDM theme settings

## Usage
- Rebuild: `sudo nixos-rebuild switch --flake .#myHost`
- Update aliases: Edit `home.nix`
