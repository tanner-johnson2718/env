{config, pkgs, inputs, lib, ...}:
let
  cfg = config.user.config;
in
{
  options = {
    user.config.enable = lib.mkEnableOption "Enable User Module";
    user.config.userName = lib.mkOption {
      type = lib.types.str;
      default = "tanner";
      example = "tanner";
      description = "The name of the main system user";
    };
    user.config.reposPath = lib.mkOption {
      type = lib.types.path;
      default = "/var/git";
      example = "/var/git";
      description = "Dir with flat structure of relevant git repos for the system";
    };
    user.config.enableDE = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = "true";
      description = "Whether to enable a GNOME DE";
    };
    user.config.enableEcryptfs = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = "true";
      description = "Enable support for CURRENTLY encrypted home drive";
    };
    user.config.ecryptfsBakPath = lib.mkOption {
      type = lib.types.path;
      default = "/var/ecryptfsBak";
      example = "/var/ecryptfsBak";
      description = "Path to where encrypted home drive back ups go";
    };
  };

  config = lib.mkIf cfg.enable {
    
    system.stateVersion = "24.05";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
    # DIE PULSE AUDIO DIE!!
    hardware.pulseaudio.enable = false;

    # Always want unfree packages
    nixpkgs.config.allowUnfree = true;

    # I want real time in user space
    security.rtkit.enable = true;

    # By default and unless over-written turn on network manager which manages
    # dhcp and set host name to the main user name.
    networking.networkmanager.enable = lib.mkDefault true;
    networking.hostName = lib.mkDefault cfg.userName;

    # Make a systemwide git repository dir
    systemd.tmpfiles.rules = [
      "d ${cfg.reposPath} - ${cfg.userName} users -"
    ]
      ++ ( if cfg.enableEcryptfs then [
      "d ${cfg.ecryptfsBakPath} - ${cfg.userName} users -"
    ] else []);

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
    # Main System User
    #############################################################################
    users.users.${cfg.userName} = {
      isNormalUser = true;
      description = "Main System User";
      extraGroups = [ "networkmanager" "wheel" ];
    };

    ###########################################################################
    # System Pkgs +  Additional system packages based on flags
    ###########################################################################
    environment.systemPackages = with pkgs; [
      vim
      xclip
      btop
      valgrind
      wget
      zip
      unzip
      tree
      socat
      nmap
      jq
    ]
      ++ (if cfg.enableDE then [vscode] else [] )
      ++ (if cfg.enableDE then [prusa-slicer] else [] )
      ++ (if cfg.enableDE then [rpi-imager] else [] )
      ++ (if cfg.enableDE then [libreoffice] else [] )
      ++ (if cfg.enableDE then [firefox] else [] )
      ++ (if cfg.enableEcryptfs then [ecryptfs] else [] );

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
        cd ${cfg.userName}/env ;
        sudo nixos-rebuild --flake .#default switch ;
        popd > /dev/null
      '';
      statall=''
        pushd . > /dev/null
        for d in ${cfg.reposPath}/* ; do
          echo $d
          cd $d
          git status --porcelain
          echo   
        done
        popd > /dev/null
      '';
    };

    programs.bash.promptInit = ''
      export GIT_PS1_SHOWCOLORHINTS=true
      export GIT_PS1_SHOWDIRTYSTATE=true
      export GIT_PS1_SHOWUNTRACKEDFILES=true
      source /run/current-system/sw/share/bash-completion/completions/git-prompt.sh

      export PROMPT_COLOR='34'

      export PS1='\n\[\033[01;''${PROMPT_COLOR}m\]\W\[\033[01;32m\]$(__git_ps1 " (%s)") \[\033[00m\] '
    '';

    programs.bash.interactiveShellInit = ''
      if [ -z $TMUX ];then
        tmux attach
      fi
    '';

    #############################################################################
    # DE specific stuff
    #############################################################################

    # xserver is bad name, this is a GUI catch all attr
    services.xserver = if cfg.enableDE then {
      enable = true;
      xkb.layout = "us";
      displayManager = {
        gdm.enable = true;
      };
      desktopManager = {
        gnome.enable = true;
      };
    } else {};

    
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    #############################################################################
    # Encrypted Home Drive
    #############################################################################
    security.pam.enableEcryptfs = cfg.enableEcryptfs;
    boot.kernelModules = if cfg.enableEcryptfs then ["ecryptfs"] else [];
  };
}