#!/usr/bin/bash 

# Check that we are in the env dir at root
if [ -f .git/config ]; then
    mine=$(cat .git/config | grep url | grep -Eo 'tanner-johnson2718/env.git')
    if [ -z $mine ]; then
        echo "Please navigate to the root of the env repo"
        exit 1
    fi
else 
    echo "Please navigate to the root of the env repo"
    exit 1
fi

# Check that nix is installed
which -s nix
if ! [ $? = 0 ]; then
    echo "Please install nix"
    exit 1
fi

# Check that flakes are enabled

# Check if build is fresh otherwise build
echo "Building ... "
nix build .#nixosConfigurations.root.config.system.build.vm
export QEMU_NET_OPTS="hostfwd=tcp::2221-:22"
result/bin/run-nixos-vm &

# expect that weird thing where it get stuck
