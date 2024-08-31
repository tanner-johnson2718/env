# Env

This repo will house my nix configuration for my main personal laptop. Nix is an amazing tool giving one a declarative and reprodicible way to configure a Linux system. It has a strong community that presents the "proper" or "nix" way of doing things when using nix tooling. However, even with the strong standards that exist in the nix ecosystem, ther is a very very large space of possible system configurations such that one has a lot of lee way in how they configure their system. This document will present additional "policy" or "constraints" placed on how I personally use the nix ecosystem to configure my computer systems. The goal of this repo is into implement this policy using nix.

# The Policy of One

* 1 Repo - All git repos needed on the system will be stored at a single configurable location. 
* 1 HW - For every piece of hardware there is a single configurable special repo called the env repo
* 1 flake.nix - The env repo will contain a singular flake.nix which will contain the entire system's config
    * This usually looks like a small amount of hardware and one-off config in the flake.nix directly...
    * And the importing and configuring of other flakes' modules.
* 1 flake.lock - All nixpkgs' and external modules used are pinned to git repos at specific revisions.
* 1 user - Lol might be fun to see if I can get down to actually only one user.
* 1 and only 1 - One browser installed and the rest uninstalled. One terminal editor and the rest not, etc..

# The Policy of Modularity



# The Policy of Defaults

