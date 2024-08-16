# Nix Main development sys

{ config, pkgs, inputs, ... }:

let
  main_user_name="lcars";
in
{
  # Networking
  networking.networkmanager.enable = true;
  networking.hostName = "${main_user_name}";

  # Needed Encrypted Home Drive
  security.pam.enableEcryptfs = true;
  boot.kernelModules = ["ecryptfs"];

  #############################################################################
  # DE and Sound
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
    qmk
    zip
    unzip
    tree
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
    gdpush = "git add ./\* && git commit -m \"..\" && git push";
    user_confirm=''
    read -p \"Continue? (Y/N): \" confirm && 
    [[ \$confirm == [yY] || \$confirm == [yY][eE][sS] ]] || 
    return
    '';
    nix_rebuild = ''
      pushd . > /dev/null ;
      cd /home/${main_user_name}/repos/env ;
      sudo nixos-rebuild --flake .#default switch ;
      popd > /dev/null
    '';
    bak=''
      pushd . > /dev/null ;
      cd /home ;
      sudo tar -czvf ${main_user_name}.tar.gz .ecryptfs ;
      sudo cp ${main_user_name}.tar.gz ${main_user_name}.tar.gz.bak
      sudo mv ${main_user_name}.tar.gz /run/media/${main_user_name}/SNAPSHOTS ;
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
  # QMK Keyboard Config
  #   - Overwrite qmk nic package so that it downloads source 
  #############################################################################

  # kbConf = ''
  # [0] = LAYOUT_65_ansi_blocker(
  # QK_GESC,  KC_1,     KC_2,     KC_3,     KC_4,     KC_5,     KC_6,     KC_7,     KC_8,     KC_9,     KC_0,     KC_MINS,  KC_EQL,   KC_BSPC,  KC_DEL,
  # KC_TAB,   KC_Q,     KC_W,     KC_E,     KC_R,     KC_T,     KC_Y,     KC_U,     KC_I,     KC_O,     KC_P,     KC_LBRC,  KC_RBRC,  KC_BSLS,  RGB_MODE_FORWARD,
  # KC_CAPS,  KC_A,     KC_S,     KC_D,     KC_F,     KC_G,     KC_H,     KC_J,     KC_K,     KC_L,     KC_SCLN,  KC_QUOT,  KC_ENT,             KC_HOME,
  # KC_LSFT,  KC_Z,     KC_X,     KC_C,     KC_V,     KC_B,     KC_N,     KC_M,     KC_COMM,  KC_DOT,   KC_SLSH,  KC_GRV,            KC_UP,    KC_END,
  # KC_LCTL,  KC_LGUI,  KC_LALT,                                KC_SPC,                                 KC_PGUP,  KC_PGDN,    KC_LEFT,  KC_DOWN,  KC_RGHT
  # ),
  # '';
  # upstreamQMKSrc = "https://github.com/qmk/qmk_firmware";
}

