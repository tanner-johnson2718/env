# Env

## Terminal and UX 

Export of my terminal config.

* Install Nix pkg manager: `sh <(curl -L https://nixos.org/nix/install) --daemon`
* Install homemananger: [follow me!](https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone)
* Load and Reload configuration: `./push.sh`

**Notes**
* Targets Ubuntu 24.04 but should work on all platforms
* Color Schemes used target [catppuccin](https://github.com/catppuccin/gnome-terminal) on gnome terminal
* Targets Gnome DE w. xserver

### TODO
* Finish your wswap
* Fix the weird color paren issue after git ps1
* Want a "t-flip" that swaps a vert split to a hor split and vice verses
* Flake-ify it and make it exportable with a reasonable interface
* Integrate Vim and fd options, Go over `programs.*` attr sets in general and set good values / pull cool stuff in
* Make a notes module that syncs with a calender?? That'd be cool
* Lock down VScode things till I get vim up?