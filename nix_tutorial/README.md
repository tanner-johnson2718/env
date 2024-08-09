# Nix Tutorial

# Concepts

* Store
* Flakes
* Composition
* Pills
* `nix repl` - Open a repl to the Nix Language
* `nix-instantiate --eval` -> evaluates file containing nix expr
* built-ins, import, pkgs, pkgs.lib, stdenv, callPackage,
* NixOS configuration
* How does `nix-build` work
    * Different Build Phases
* Overrides
* Nix Shells
* `NIX_PATH`

## Nix Profile (User Environment)

The nix profile is the mechanism by which nix-os users add application binaries (contained in the store) to their ENV path. A users ENV binary search path is itself added to the store. Each change to the ENV gets a new store entry and a new sym link to that entry in the path shown below. The ENV store entry has a bin dir that itself contains symlinks to the path of each binary in the store.

```
/home/user/.local/state/nix/profiles
    - profile -> profile3
    - profile 1 -> /nix/store/<hash_1>-user
    - profile 2 -> /nix/store/<hash_2>-user
    - profile 3 -> /nix/store/<hash_3>-user
        - /nix/store/<hash_3>-user/bin
            - app_A -> /nix/store/<hash_A>-A/bin/a.sh
            - app_B -> /nix/store/<hash_B>-B/bin/b.sh
```

### Commands

| Command | Desc |
| --- | --- |
| `nix-env -f <pkgs_list> -i <p>` | Search `pkgs_list`, which should return an attribute set of drv's, and install `p`. Add link in users Nix Profile to `p`. |
| `nix-env -q` | Query users installed packages. |
| `nix-env -f <pkgs_list> -qa` | List all possible packages to install from passed `pkgs_list`. |
| `nix-env -I <pkgs_list>` | Set default `pkgs_list` to the passed `pkgs_list`. `-f` can now be omitted. |
| `nix-env --delete-generations old` | Delete all the old user profiles except current. |
| `nix-env -e <p>` | Remove Package `p` from user environment. |

**NOTE** When the `-f` flag is not supplied it searches the directory (or file) `~/.nix-defexpr`. There are semantics for how this default expressions is searched and is detailed [here](https://nix.dev/manual/nix/2.22/command-ref/nix-env).

### Questions

* Does this support a mechanism for maintaining things like my .bashrc and other user ENV configs?

## Channels / The Nixpkgs Repo

The high-level overview of a what a channel is can be read [here](https://nixos.wiki/wiki/Nix_channels). Put simply, a channel is a set of verified commits of the official [Nixpkgs repo](https://github.com/NixOS/nixpkgs) (although they may reference a general remote nix expression, but in practice referencing the nixpkgs repo is the most common use case). This repo contains the "build derivation" nix code of every package. As an example the [prusa slicer package](https://github.com/NixOS/nixpkgs/blob/9962bb4f68e17c586da9d97f1ecb8b0ec071f726/pkgs/applications/misc/prusa-slicer/default.nix) has a make derivation nix script in the nixpkgs repo, which points to a very specific version / revision of the prusa-slicer code and describes its build process. Also within the nixpkgs is the [master composition list](https://github.com/NixOS/nixpkgs/blob/9962bb4f68e17c586da9d97f1ecb8b0ec071f726/pkgs/top-level/all-packages.nix) which contains the `callPackage` invocation of each packages make derivation script.

So a channel is verified revision of the nixpkgs repo which contains all the meta data on packages added to nix, pins each package to a specific revision or hash of that packages source code, and also provides some of the core nix functionality but we will ignore that for now. You can add a channel to your user channels:

```
nix-channel --add nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channels --list
```

The second command will dump the contents of the users `~/.nix-channels` file. These commands can also be ran with `sudo` in which case one adds and lists the system channels (file found at `/root/.nix-channels`. This `/root` dir also contains the system wide `~/.nix-defexpr`).



* Lookup Path `<nixos/pkgs>` -> `/nix/var/nix/profiles/per-user/root/channels/nixos/pkgs`
* We see at `/nix/var/nix/profiles/per-user/root/` a sym link structure like that for [user envs](./README.md/#nix-profile-user-environment).
* `nix-build '<nixpkgs/nixos>' -A vm -I nixpkgs=channel:nixos-23.11 -I nixos-config=./configuration.nix`.
* [nix-channel cmd ref](https://nix.dev/manual/nix/2.18/command-ref/nix-channel)
* For users `~/.nix-defexpr` points to channels
* `/nix/var/nix/profiles` contains all the old system configs i.e. when I update my system conf and do a nix-rebuild this dir contains all the old backed up system configs. 


## Derivations

Derivation is an intermediate artifact that describes all the relevant components, inputs, etc in building a package.

* `nix-instantiate a.nix`
* Can install `nix-derivation` to provide binary `pretty-derivation` that takes a `.drv` as an input and outputs a pretty print of it.
* `nix-store -qR <path to pkg in store>` - Gives the "runtime closure" or the packages needed to run the application binary.
* `nix-store -qR <path to pkg drv in store>` - Gives the "build time closure" or the packages needed to build the application binary.

## Garbage Collection

`nix-store --gc`

# Examples

## RPI 4 Image

* [Follow instructions](https://nix.dev/tutorials/nixos/installing-nixos-on-a-raspberry-pi to get base image
* Clone this repo onto the board
* GPIO)   
    * [PR](https://github.com/NixOS/nixpkgs/pull/316936)
        * Took [pigpio.nix](./pigpio.nix)
    * Added boiler plate composition [default.nix](./default.nix)
    *  run `nix-env -f ./default.nix -i pigpio` in repo on pi
    *  sudo pigpiod fails  -> [Issue](https://github.com/NixOS/nixpkgs/issues/122993)
    

# References

* [VM Tutorial](https://alberand.com/nixos-linux-kernel-vm.html)
* [Nix Dev](https://nix.dev/)
* [PhD Thesis](https://edolstra.github.io/pubs/phd-thesis.pdf)
* [Starting Rpi Zero 2 conf](https://github.com/plmercereau/nixos-pi-zero-2)
