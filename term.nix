{config, pkgs, lib, ...}:
let
  cfg = config.term.config;
in
{
  options = {
    term.config.enable = lib.mkEnableOption "Enable Module";
    term.config.bashExtra = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "alias short='cut'";
      description = "Extra init shell hook you want to add to an interactive shell";
    };
    term.config.tmuxExtraConf = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "set-window-option -g window-status-current-style bg='#7c3e8e'";
      description = "Extra tmux conf you want to add post plugin";
    };
    term.config.extraTerminalPkgs = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [];
      example = "[ jq ]";
      description = "Any extra system packages you need for termainal work";
    };
    term.config.leader = lib.mkOption {
      type = lib.types.str;
      default = "b";
      example = "Space";
      description = "Tmux escape leader key";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.variables.EDITOR = "vim";
    users.defaultUserShell = pkgs.bash;

    environment.systemPackages = with pkgs; [
      vim
      xclip
      btop
      wget
      zip
      unzip
      tree
      socat
      nmap
      jq
      git
      bintools
      usbutils
      pciutils
      util-linux
    ] ++ cfg.extraTerminalPkgs;

    console.enable = false;

    programs.tmux = {
      enable = true;
      newSession = true;
      withUtempter = true;
      terminal = "tmux-direct";
      shortcut = cfg.leader;
      secureSocket = true;
      reverseSplit = false;
      resizeAmount = 5;
      plugins = [];
      keyMode = "vi";
      historyLimit = 5000;
      extraConfigBeforePlugins = "";
      escapeTime = 500;
      customPaneNavigationAndResize = false;
      clock24 = true;
      baseIndex = 1;
      aggressiveResize = false;
      extraConfig = ''
        set-option -g status-right ""
        set -g status-bg "#b4befe"
        set -g status-fg "#f9e2af"
        set-window-option -g window-status-current-style bg="#89b4fa"
        set -g mouse on
        set -g renumber-windows on
        set-option -g status-position top

        setw -g mode-keys vi
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi C-v send -X rectangle-toggle

        bind-key -T copy-mode-vi C-Up send-keys -X previous-paragraph
        bind-key -T copy-mode-vi C-Down send-keys -X next-paragraph
        bind-key -T copy-mode-vi C-Left send-keys -X previous-word
        bind-key -T copy-mode-vi C-Right send-keys -X next-word-end

        set -s command-alias[00] tj='last-pane'
        set -s command-alias[01] tp='split-window -h'
        set -s command-alias[02] tw='new-window'
        set -s command-alias[03] tc='copy-mode'
        set -s command-alias[04] tl='rename-window'
        set -s command-alias[05] ts='swap-pane -D'
        set -s command-alias[06] tg='swap-pane -D ; last-pane'
        set -s command-alias[07] th='split-window -v'

        set -s command-alias[100] t0='select-window -t 0'
        set -s command-alias[101] t1='select-window -t 1'
        set -s command-alias[102] t2='select-window -t 2'
        set -s command-alias[103] t3='select-window -t 3'
        set -s command-alias[104] t4='select-window -t 4'
        set -s command-alias[105] t5='select-window -t 5'
        set -s command-alias[106] t6='select-window -t 6'
        set -s command-alias[107] t7='select-window -t 7'
        set -s command-alias[108] t8='select-window -t 8'
        set -s command-alias[109] t9='select-window -t 9'
        
      '' + cfg.tmuxExtraConf;
    };

    programs.bash = {
      enableCompletion = true;
      enableLsColors = true;
      vteIntegration = false;
      undistractMe.enable = false;
      shellInit = "";
      loginShellInit = "";      
      blesh.enable = false;

      promptInit = ''
        export GIT_PS1_SHOWCOLORHINTS=true
        export GIT_PS1_SHOWDIRTYSTATE=true
        export GIT_PS1_SHOWUNTRACKEDFILES=true
        source /run/current-system/sw/share/bash-completion/completions/git-prompt.sh

        export PROMPT_COLOR='34'

        export PS1='\n\[\033[01;''${PROMPT_COLOR}m\]\W\[\033[01;32m\]$(__git_ps1 " (%s)") \[\033[00m\] '
      '';

      interactiveShellInit = ''
        if [ -z $TMUX ];then
          tmux attach
        fi

        function tpane {
          _n=$(tmux list-panes | wc -l)
          if [ $_n = "1" ]; then 
            tmux split-window -h $1
          else
            return
          fi
        }
        export tpane
  
        function tjump {
          _n=$(tmux list-panes | wc -l)
          if [ $_n = "1" ]; then
            return 0;
          elif [ $_n = "2" ]; then
            tmux last-pane
          fi
        }
        export tjump

        function tlabel {
          if [ $_n = "1" ]; then
            return 0;
          elif [ $_n = "2" ]; then
            tmux rename-window $1
          fi
        }
        export tlabel
      '' 
      + cfg.bashExtra;
        
        
      shellAliases = {
        # Use these for fast navigation of the terminal
        a = "alias";
        l = "ls -CF";
        g = "grep";
        e = "exit";
        c = "clear";
        ll = "ls -la";
        lf = "declare -F";               # LIST FUNCTIONS 
        lF = "declare";                  # REALLY LIST FUNCTIONS
        lc = "complete";                 # LIST COMPLETIONS
        lv = "echo shell levl = ''$SHLVL";
        gs = "git status";
        tc = "tmux copy-mode            # T COPY";
        tw = "tmux new-window           # T WINDOW";
        tp = "tpane                     # T PANE";
        tj = "tjump                     # T JUMP";
        tl = "tlabel                    # T LABEL";
        ts = "tmux swap-pane -D         # T SWAP";
        tg = "tmux swap-pane -D; tjump  # T GRAB";
        th = "tmux split-window -v      # T HALF";
        t0 = "tmux select-window -t 0";
        t1 = "tmux select-window -t 1";
        t2 = "tmux select-window -t 2";
        t3 = "tmux select-window -t 3";
        t4 = "tmux select-window -t 4";
        t5 = "tmux select-window -t 5";
        t6 = "tmux select-window -t 6";
        t7 = "tmux select-window -t 7";
        t8 = "tmux select-window -t 8";
        t9 = "tmux select-window -t 9"; 
      };
    };
  };
}