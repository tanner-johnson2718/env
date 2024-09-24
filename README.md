# Env

Export of my terminal config.

## Non-NixOS Installation
* Install Nix pkg manager: `sh <(curl -L https://nixos.org/nix/install) --daemon`
* Install homemananger: [follow me!](https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone)
* Load and Reload configuration: `./push.sh`

**Notes**
* Targets Ubuntu 24.04 but should work on all platforms
* Color Schemes used target [catppuccin](https://github.com/catppuccin/gnome-terminal) on gnome terminal
* Targets Gnome DE w. xserver

## NixOS Installation (flake)

```nix
...

```

### TODO
* Fix the weird color paren issue after git ps1
* Want a "t-flip" that swaps a vert split to a hor split and vice verses
* Integrate Vim and fd options, Go over `programs.*` attr sets in general and set good values / pull cool stuff in
* Make a notes module that syncs with a calender?? That'd be cool
* Switch to xfce?