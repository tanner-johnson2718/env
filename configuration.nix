# NixOs Global System Configuration

{ config, pkgs, inputs, ... }:

{
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lcars";

  # Enable networking
  networking.networkmanager.enable = true;

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

  #############################################################################
  # DE and HID
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
  # LCARS User, Home Manager, and Secrets
  #############################################################################
  users.users.lcars = {
    isNormalUser = true;
    description = "Main System User";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  home-manager.users.lcars = 
  { pkgs, ... }: 
  {
    programs.git = 
    {
      enable = true;
      userName = "LCARS";
      userEmail = "tanner.johnson2718@gmail.com";
    };

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.05";
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
    nix-derivation
    libreoffice
    minicom
    wget
    gnupg
    home-manager
    git
  ];

  # Install firefox
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
  #    - WARN nix_rebuild targets home directory with hardcoded path
  #############################################################################
  programs.bash.shellAliases = {
    ll = "ls -al";
    la = "ls -A";
    l = "ls -CF";
    gs = "git status";
    gdpush = "git add ./\* && git commit -m \"..\" && git push";
    user_confirm=''
    read -p \"Continue? (Y/N): \" confirm && 
    [[ \$confirm == [yY] || \$confirm == [yY][eE][sS] ]] || 
    return
    '';
    ng_start="sudo airmon-ng start wlp5s0";
    ng_stop="sudo airmon-ng stop wlp5s0mon";
    nix_rebuild = ''
      pushd . > /dev/null ;
      cd /home/lcars/repos/env ;
      sudo nixos-rebuild --flake .#lcars switch ;
      popd > /dev/null
    '';
  };

  programs.bash.promptInit = ''
    export GIT_PS1_SHOWCOLORHINTS=true
    export GIT_PS1_SHOWDIRTYSTATE=true
    export GIT_PS1_SHOWUNTRACKEDFILES=true
    source /run/current-system/sw/share/bash-completion/completions/git-prompt.sh
    PS1='\n\[\033[01;34m\]\W\[\033[01;32m\]$(__git_ps1 " (%s)") \[\033[00m\] '
  '';

  programs.bash.interactiveShellInit = ''
    if [ -z $TMUX ];then
      tmux attach
    fi
  '';

  #############################################################################
  # Install GPG and Enable GPG agent (for using gpg encrypt)
  #############################################################################
  programs.gnupg = {
    agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-curses;
      enableSSHSupport = true;
    };
  };

  # Version of first installed version of nixos
  system.stateVersion = "24.05"; # Did you read the comment?

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
