# Env

This repo will house my nix configuration for my main personal laptop. Nix is an amazing tool giving one a declarative and reproducible way to configure a Linux system. It has a strong community that presents the "proper" or "nix" way of doing things when using nix tooling. However, even with the strong standards that exist in the nix ecosystem, there is a very very large space of possible system configurations such that one has a lot of lee way in how they configure their systems. This document will present additional "policy" or "constraints" placed on how I personally use the nix ecosystem to configure my computer systems. The goal of this repo is into implement this policy for my personal laptop using nix.

# The Policy of One

* 1 HW - For every piece of hardware there is a single configurable special repo called the env repo
* 1 Repo - All git repos needed on the system will be stored at a single configurable location. 
* 1 flake.nix - The env repo will contain a singular flake.nix which will contain the entire system's config
* 1 flake.lock - All nixpkgs', external modules, and ANY source code needed is pinned to specific url's here.
* 1 user - Lol might be fun to see if I can get down to actually only one user.
* 1 and only 1 - One browser installed and the rest uninstalled. One terminal editor and the rest not, etc..

The idea here is to impose a 1-1 correspondence between the physical hardware I mess around with and a single repo containing ALL the instructions needed to bring that system to a state I want. These instructions should be in a single file flake.nix. These instructions will obviously need to reach out to other git repos and other sources of code to build and configure the system. EVERY such source of external code (repos, tar balls, other flakes, etc) will be pinned using the flake.lock file.

Moreover, we can extend the Policy of One to further constrain what we might put in the single file containing our systems' build and configuration instructions. We should configure our system so that there is only one of a given thing and its in a single specified but configurable location. Example, ALL git repos the system will store on disk WILL go into `/var/git`. We should also remove redundant things such as multiple browsers, terminal emulators, ways of booting the system, home directories, etc. Per system, there is one place a particular thing goes and one way of performing the operations that this system supports. 

# The Policy of Modularity

The Policy of One is very general and is the primary sentiment I will use when building out my systems. However there is some much needed errata. Placing ALL the configuration needed for an entire system in only one file, flake.nix, is silly. This isn't maintainable and would lead to code duplication, which goes against the Policy of One as we would now have multiple copies of the same semantic thing. To add some concrete policies and to correct the paradox in the previous sentence, we introduce the Policy of Modularity which imposes the following structure on our env repos:

* Env Repo Dir Structure:
    * `env` or `env_<system_name>` with be the env repo name
        * `flake.nix`
        * `flake.lock`
        * `README.md`
        * `mod_1`
            * `mod1.nix`
            * `README.md`
            * .. Arbitrary Tree
        * `mod_N`
            * ...'
* `flake.nix` Structure
    * `inputs`
    * `outputs`
        * `nixosConfigurations.default` One and only configuration for the system
            * `{}: { ... }` inline module definition which has hardware and one off config
            * `{}:{ import mod_1 }` Import and Configure in repo Sub System modules
            * `{}:{ import mod_N }` Import and Configure in repo Sub System modules
            * `{}:{ import input_mod_1 }` Import and Configure modules declared as inputs
            * `{}:{ import input_mod_N }` Import and Configure modules declared as inputs
        * `nixosModules` Exports Sub System modules this repo implements
            * `mod_1`
            * `mod_N`


# The Policy of Hub and Spoke

