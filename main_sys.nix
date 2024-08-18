# Nix Main development sys

{ config, pkgs, inputs, ... }:

let
  main_user_name="lcars";
  repos_path="/var/git";
in
{
  #############################################################################
  # Flakes and system version and other core features
  #############################################################################
  
  system.stateVersion = "24.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set Time and location
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Networking
  networking.networkmanager.enable = true;
  networking.hostName = "${main_user_name}";

  # Needed Encrypted Home Drive
  security.pam.enableEcryptfs = true;
  boot.kernelModules = ["ecryptfs"];

  # To emulate arm64 devices
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Make a systemwide git repository dir
  systemd.tmpfiles.rules = [
    "d ${repos_path} - ${main_user_name} users -"
  ];

  #############################################################################
  # DE, Audio,KB
  #############################################################################

  # xserver is bad name, this is a GUI catch all attr
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    displayManager = {
      gdm.enable = true;
    };
    desktopManager = {
      gnome.enable = true;
    };
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  #############################################################################
  # System packages
  #############################################################################
  environment.systemPackages = with pkgs; [
    vim
    vscode
    prusa-slicer
    xclip
    btop
    rpi-imager
    valgrind
    libreoffice
    minicom
    wget
    ecryptfs
    zip
    unzip
    tree
    git
  ];

  # Install firefox
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  #############################################################################
  # Main System User
  #############################################################################
  users.users.${main_user_name} = {
    isNormalUser = true;
    description = "Main System User";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  #############################################################################
  # Tmux Conf
  #############################################################################
  programs.tmux = {
    enable = true;
    extraConfig = ''
      # Tmux color settings
      set -g default-terminal "screen-256color"
      set-window-option -g window-status-current-style bg="#7c3e8e"

      # split panes using | and -
      bind / split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # Allow the arrow key to be used immediately after changing windows
      set-option -g repeat-time 0

      # dont confirm on kill pane
      bind-key x kill-pane

      # Change prefix key
      unbind C-b
      set-option -g prefix C-Space
      bind-key C-Space send-prefix

      # Makes space hightlight in copy mode, make space enter copy mode, and enter to
      # copy highlighted
      setw -g mode-keys vi
      unbind Space
      bind Space copy-mode
      bind-key -T copy-mode-vi c send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"

      # Window Changes
      bind-key -T prefix NPage next-window
      bind-key -T prefix PPage previous-window

      # Rebind pane size chnage to control wasd
      unbind C-Right
      unbind C-Left
      unbind C-Up
      unbind C-Down
      bind-key -r -T prefix C-d resize-pane -R
      bind-key -r -T prefix C-s resize-pane -D
      bind-key -r -T prefix C-a resize-pane -L
      bind-key -r -T prefix C-w resize-pane -U

      # Paragraph and word Jumps 
      # (Add a new line at begining of PS1 to make thep aragraph jumps more useful)
      bind-key -T copy-mode-vi C-Up send-keys -X previous-paragraph
      bind-key -T copy-mode-vi C-Down send-keys -X next-paragraph
      bind-key -T copy-mode-vi C-Left send-keys -X previous-word
      bind-key -T copy-mode-vi C-Right send-keys -X next-word-end
    '';
  };

  #############################################################################
  # Bash Settings
  #############################################################################
  users.defaultUserShell = pkgs.bash;
  programs.bash.shellAliases = {
    ll = "ls -al";
    la = "ls -A";
    l = "ls -CF";
    gs = "git status";
    gdpush = "git add -u && git commit -m \"AUTO COMMIT\" && git push";
    user_confirm=''
    read -p \"Continue? (Y/N): \" confirm && 
    [[ \$confirm == [yY] || \$confirm == [yY][eE][sS] ]] || 
    return
    '';
    nix_rebuild = ''
      pushd . > /dev/null ;
      cd ${repos_path}/env ;
      sudo nixos-rebuild --flake .#default switch ;
      popd > /dev/null
    '';
    home_bak=''
      pushd . > /dev/null ;
      cd /home ;
      sudo tar -czvf ${main_user_name}.tar.gz .ecryptfs ;
      sudo cp ${main_user_name}.tar.gz ${main_user_name}.tar.gz.bak
      sudo mv ${main_user_name}.tar.gz /run/media/${main_user_name}/SNAPSHOTS ;
      popd > /dev/null
    '';
    pushall=''
      pushd . > /dev/null
      for d in ${repos_path}/* ; do
        cd $d
        gdpush
      done
      popd > /dev/null
    '';
    pullall=''
      pushd . > /dev/null
      for d in ${repos_path}/* ; do
        cd $d
        git pull
      done
      popd > /dev/null
    '';
    statall=''
      pushd . > /dev/null
      for d in ${repos_path}/* ; do
        echo $d
        cd $d
        git status --porcelain
        echo   
      done
      popd > /dev/null
    '';
    cloneall=''
      pushd . > /dev/null ;
      cd ${repos_path} ;
      git clone git@github:tanner-johnson2718/ESP32_Deluminator.git ;
      git clone git@github:tanner-johnson2718/MEME_ETH_LAB.git ;
      git clone git@github:tanner-johnson2718/MEME_OS_3.git ;
      git clone git@github:tanner-johnson2718/PI_JTAG_DBGR.git ;
      git clone git@github:tanner-johnson2718/MEME_OS_Project.git ;
      git clone git@github:tanner-johnson2718/Ricks_Designs.git ;
      git clone git@github:tanner-johnson2718/GPS.git ;
      git clone git@github:tanner-johnson2718/MEME_OS.git ;
      git clone git@github:tanner-johnson2718/Klipper_C137.git ;
      git clone git@github:tanner-johnson2718/MEME_OS_2.git ;
      git clone git@github:tanner-johnson2718/Calc_N_Phys.git ;
      git clone git@github:tanner-johnson2718/Crypto.git ;
      git clone git@github:tanner-johnson2718/A-Car.git ;
      git clone git@github:tanner-johnson2718/ESP32_Enclosure_CTLR.git ;
	    git clone git@github:tanner-johnson2718/env.git ;
      git clone git@github:tanner-johnson2718/C_Ref.git ;
      git clone git@github:tanner-johnson2718/Nix_RPI_0.git ;
      git clone git@github:tanner-johnson2718/Angry_Hexy.git ;
      git clone git@github:tanner-johnson2718/InsultingEarlyBird.git ;
      popd> /dev/null ;
    '';
  };

  programs.bash.promptInit = ''
    export GIT_PS1_SHOWCOLORHINTS=true
    export GIT_PS1_SHOWDIRTYSTATE=true
    export GIT_PS1_SHOWUNTRACKEDFILES=true
    source /run/current-system/sw/share/bash-completion/completions/git-prompt.sh
    

    if [[ "$SHLVL" -eq "2" ]]; then
      export PROMPT_COLOR='34'
    else
      export PROMPT_COLOR='31'
    fi

    export PS1='\n\[\033[01;''${PROMPT_COLOR}m\]\W\[\033[01;32m\]$(__git_ps1 " (%s)") \[\033[00m\] '
  '';

  programs.bash.interactiveShellInit = ''
    if [ -z $TMUX ];then
      tmux attach
    fi
  '';
 
}

