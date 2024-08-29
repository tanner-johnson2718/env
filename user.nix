{config, pkgs, inputs, lib, ...}:
let
  cfg = config.user.config;
in
{
  options = {
    user.config.enable = lib.mkEnableOption "Enable User Module";
    user.config.userName = lib.mkOption {
      type = lib.types.str;
      default = "user";
      example = "user";
      description = "The name of the main system user";
    };
    user.config.reposPath = lib.mkOption {
      type = lib.types.path;
      default = "/var/git";
      example = "/var/git";
      description = "Dir with flat structure of relevant git repos for the system";
    };
    user.config.envRepo = lib.mkOption {
      type = lib.types.str;
      default = "env";
      example = "env-work";
      description = "Where the repo containing the nixosConfigurations.default system config flake i.e. this repo or one consuming it";
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
      git

      # can be wrapped up in a bin analysis module
      pev
      bintools
      nix-derivation
    ]
      ++ (if cfg.enableDE then [vscode] else [] )
      ++ (if cfg.enableDE then [prusa-slicer] else [] )
      ++ (if cfg.enableDE then [rpi-imager] else [] )
      ++ (if cfg.enableDE then [libreoffice] else [] )
      ++ (if cfg.enableDE then [firefox] else [] )
      ++ (if cfg.enableEcryptfs then [ecryptfs] else [] );

    ###########################################################################
    # Tmp Files Rules.
    #
    # Systemd timers.
    ###########################################################################

    systemd.tmpfiles.rules = [
      "d ${cfg.reposPath} - ${cfg.userName} users -"
    ]
    ++(if cfg.enableEcryptfs then [
      "d ${cfg.ecryptfsBakPath} - ${cfg.userName} users 7d"
    ] else []);

    systemd.timers."ecryptfsBakAgent" = lib.mkIf cfg.enableEcryptfs {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "1d";
        Unit = "ecryptfsBakAgent.service";
      };
    };

    systemd.services."ecryptfsBakAgent" = lib.mkIf cfg.enableEcryptfs {
      path = with pkgs; [ gnutar gzip ];
      script = ''
        /run/current-system/sw/bin/rm -rf /home/${cfg.userName}/.cache/*
        /run/current-system/sw/bin/tar cfz ${cfg.ecryptfsBakPath}/ecryptfs_$(date +"%y_%m_%d").tar.gz /home/.ecryptfs/${cfg.userName}/
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
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

        # status bar
        set-option -g status-right "#(whoami)@#(hostname)"

        # 1 index windows
        set -g base-index 1

        # split panes using | and -, new windo with c
        bind / split-window -h  -c "#{pane_current_path}"
        bind - split-window -v  -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
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
      v = "tmux split-window -h ";
      nix_rebuild = ''
        pushd . > /dev/null ;
        cd ${cfg.reposPath}/${cfg.envRepo} ;
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

      if [[ "''${SHLVL}" -eq "2" ]]; then
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

    #############################################################################
    # DE specific stuff
    #############################################################################

    security.rtkit.enable = true;
    hardware.pulseaudio.enable = false;

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