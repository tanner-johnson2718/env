# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
export GIT_PS1_SHOWCOLORHINTS=true
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
source ~/.bash_git

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

PS1='\n\[\033[01;34m\]\W\[\033[01;32m\]$(__git_ps1 " (%s)") \[\033[00m\] '

# Only show most immediate directory
PROMPT_DIRTRIM=1

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

###############################################################################
# Global ENV Variables
###############################################################################

# Local Network IP's
export HOME_PI="192.168.0.14"
export DEPLOY_PI="192.168.0.17"
export MINI="192.168.0.4"
export LAPTOP="192.168.0.5"

# Important dirs
export NFS_ROOT=$HOME/nfs_root
export REPOS=$HOME/repos
export ENV_REPO_PATH=$REPOS/env

# Import binaries
export SLCR="$HOME/PrusaSlicer_2.7.1/prusa-slicer"
export CAD="$HOME/Ondsel_1.0.35694"

# Alias
alias ll='ls -al'
alias la='ls -A'
alias l='ls -CF'
alias git_dummy_push="git add ./\* && git commit -m \"..\" && git push"
alias user_confirm="read -p \"Continue? (Y/N): \" confirm && [[ \$confirm == [yY] || \$confirm == [yY][eE][sS] ]] || return"
alias tmux_source="tmux source ${HOME}/.tmux.conf"
alias get_idf='. $ESP_IDF_INSTALL/export.sh'
alias cam=cheese

###############################################################################
# Script to set up my env. Will clone 
###############################################################################

pushall() {
    for d in $REPOS/* ; do
        echo $d
        cd $d 
        git_dummy_push
    done
}

pullall() {
    for d in $REPOS/* ; do
        echo $d
        cd $d 
        git pull
    done
}

git_backup_env() {
	cp -i .bash_git $REPOS/env
	cp -i .bashrc $REPOS/env
	cp -i .tmux.conf $REPOS/env

	cd $REPOS/env
	git_dummy_push
	cd ~
}

cloneall() {
    if [ -d $REPOS ]; then
        echo "${REPOS} dir already exists, deleting and recloning"
        user_confirm    # return on no
    fi 

    mkdir $REPOS
    cd $REPOS
    git clone https://github.com/tanner-johnson2718/ESP32_Deluminator.git
    git clone https://github.com/tanner-johnson2718/MEME_ETH_LAB.git
    git clone https://github.com/tanner-johnson2718/MEME_OS_3.git
    git clone https://github.com/tanner-johnson2718/PI_JTAG_DBGR
    git clone https://github.com/tanner-johnson2718/MEME_OS_Project
    git clone https://github.com/tanner-johnson2718/Ricks_Designs
    git clone https://github.com/tanner-johnson2718/GPS
    git clone https://github.com/tanner-johnson2718/MEME_OS
    git clone https://github.com/tanner-johnson2718/Klipper_C137
    git clone https://github.com/tanner-johnson2718/MEME_OS_2
    git clone https://github.com/tanner-johnson2718/Calc_N_Phys
    git clone https://github.com/tanner-johnson2718/Crypto
    git clone https://github.com/tanner-johnson2718/A-Car
    git clone https://github.com/tanner-johnson2718/ESP32_Enclosure_CTLR
	git clone https://github.com/tanner-johnson2718/env
}

install_env() {
	read -p "Install APT Packages? (y/n)" answer
	if [[ "${answer}" == "y" ]]; then
		sudo apt-get install firefox
		sudo apt-get install tmux
		sudo apt-get install htop
		sudo apt-get install jq
		sudo apt-get install tshark
		sudo apt-get install vim-gtk3
		sudo apt-get install gdb
		sudo apt-get install git
	fi

	read -p "Clone repos? (y/n)" answer
	if [[ "${answer}" == "n" ]]; then 
		echo "Skipping... please ensure ${ENV_REPO_PATH} exists"
		sleep 1
	else
		echo "Cloning all to ${REPOS}"
		cloneall
		cd ~
	fi

	cp -r -i $ENV_REPO_PATH/.bashrc $HOME
	cp -r -i $ENV_REPO_PATH/.bash_git $HOME
	cp -r -i $ENV_REPO_PATH/.tmux.conf $HOME
}

###############################################################################
# Back up and Clean a Machine Scripts
###############################################################################

# Wipe system logs and home dir shit. Might free up some space and shouldnt?
# break your distro
soft_wipe() {
    echo "DELETING ALL FILES PLZ RUN A BACK UP FRIST!!!"
    
    user_confirm    # return on no

    echo "[ INFO ] Deleting ~/.bash_history"
    sudo rm -rf $HOME/.bash_history
    echo "[ INFO ] Deleting ~/.cache"
    sudo rm -rf $HOME/.cache
    echo "[ INFO ] Deleting ~/.local"
    sudo rm -rf $HOME/.local
    echo "[ INFO ] Deleting ~/.pki"
    sudo rm -rf $HOME/.pki
    echo "[ INFO ] Deleting ~/Downloads"
    sudo rm -rf $HOME/Downloads
    echo "[ INFO ] Deleting ~/.dotnet"
    sudo rm -rf $HOME/.dotnet
    echo "[ INFO ] Deleting ~/.lesshst"
    sudo rm -rf $HOME/.lesshst
    echo "[ INFO ] Deleting ~/.gnupg"
    sudo rm -rf $HOME/.gnupg
    echo "[ INFO ] Deleting ~/.cmake"
    sudo rm -rf $HOME/.cmake
    echo "[ INFO ] Deleting ~/.pp_backup"
    sudo rm -rf $HOME/.pp_backup
    echo " [INFO] Deleting .~/.mozilla"
    sudo rm -rf $HOME/.mozilla
    echo "[ INFO ] Deleting snap/firefox"
    sudo rm -rf $HOME/snap/firefox
    echo "[ INFO ] Deleting ~/.git-credentials"
    sudo rm $HOME/.git-credentials
    echo "[ INFO ] Deleting ~/.python_history"
    sudo rm -rf $HOME/.python_history
    echo "[ INFO ] Deleting /var/log/*"
    sudo rm -rf /var/log/*
    echo "[ INFO ] Deleting /var/cache/*"
    sudo rm -rf /var/cache/*
}

snapshot() {
    if [ ! $# == 1 ]; then
        echo "Usage) snapshot <output location>"
        return
    fi

    mkdir ~/temp
    cp -r ~/.bashrc ~/temp
    cp -r ~/.bash_git ~/temp
    cp -r ~/.git-credentials ~/temp
    cp -r ~/.gitconfig ~/temp
    cp -r ~/snap/firefox ~/temp
    cp -r $REPOS ~/temp
    cp -r ~/.tmux.conf ~/temp

    tar -cvzf ~/$(date +%B_%d_%Y).tar.gz ~/temp
    rm -rf temp
    gpg -v -c  ~/$(date +%B_%d_%Y).tar.gz
    mv -v ~/$(date +%B_%d_%Y).tar.gz.gpg $1
    rm -rf ~/$(date +%B_%d_%Y).tar.gz
}

###############################################################################
# NFS Management
###############################################################################

setup_nfs() {
    if [ ! $# == 1 ]; then
        echo "Usage) setup_nfs <output location>"
        return
    fi

    sudo apt-get update
    sudo apt-get install nfs-kernel-server
    sudo mkdir $NFS_ROOT
    sudo chmod 777 $NFS_ROOT

    sudo echo "${NFS_ROOT} ${DEPLOY_PI} (rw,sync,no_subtree_check)" >> /etc/exports

    sudo exportfs -a #making the file share available
    sudo systemctl restart nfs-kernel-server #restarting the NFS kernel
}
