push_repos() {
    pushd ~/
    for d in $REPOS/* ; do
        echo $d
        cd $d 
        gdpush
    done

    popd
}

pull_repos() {
    pushd ~/
    for d in $REPOS/* ; do
        echo $d
        cd $d 
        git pull
    done

    popd
}

save_env() {
    cp -i /etc/nixos/configuration.nix $ENV_REPO_PATH

	pushd $REPOS/env
	gdpush
    popd
}

deploy_env() {
    echo "Copying ${ENV_REPO_PATH}/configuration.nix"
    sudo cp -i $ENV_REPO_PATH/configuration.nix /etc/nixos/configuration.nix
}

cloneall() {
    if [ -d $REPOS ]; then
        echo "${REPOS} dir already exists, deleting and recloning"
        user_confirm    # return on no
    fi 

    mkdir $REPOS
    pushd $REPOS
    git clone https://github.com/tanner-johnson2718/ESP32_Deluminator.git
    git clone https://github.com/tanner-johnson2718/MEME_ETH_LAB.git
    git clone https://github.com/tanner-johnson2718/MEME_OS_3.git
    git clone https://github.com/tanner-johnson2718/PI_JTAG_DBGR
    git clone https://github.com/tanner-johnson2718/MEME_OS_Project
    git clone https://github.com/tanner-johnson2718/Ricks_Designs
    git clone https://github.com/tanner-johnson2718/GPS
    git clone https://github.com/tanner-johnson2718/MEME_OS
    git clone https://github.com/tanner-johnson2718/MEME_OS_2
    git clone https://github.com/tanner-johnson2718/Calc_N_Phys
    git clone https://github.com/tanner-johnson2718/Crypto
	git clone https://github.com/tanner-johnson2718/env
    git clone https://github.com/tanner-johnson2718/C_Ref
    popd
}

# Take in a package name and search the store for all paths.
# Ask the user which store entity they'd like to find the closure of
# Print the closure of that enity. The closure is all the dependancies of that
# package. The closure of the binary of the packge give the runtime deps while
# the closure of the drv gives the build time dependancies
closure() {
    if [[ $# != 1 ]]; then
        echo "closure <pname>"
        return
    fi

    paths=$(ls ${STORE} | grep $1)
    paths=$(echo $paths | tr " " "\n")
    i=0
    echo "Store Entries for ${1}:"
    for p in $paths
    do
        echo "   ${i} | ${p}"
        i=$((${i}+1))
    done

    echo ""
    read -p "Index: " index
    echo ""

    i=0
    for p in $paths
    do
        if [[ "${i}" == "${index}" ]]; then
            key=$p
        fi
        i=$((${i}+1))
    done
    echo "Closure of ${key}: "
    nix-store -qR "${STORE}/${key}"
}
