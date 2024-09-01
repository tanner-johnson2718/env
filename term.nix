{config, pkgs, lib, ...}:
let
  cfg = config.term.config;
in
{
  options = {
    term.config.enable = lib.mkEnableOption "Enable User Module";
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
  };

  config = lib.mkIf cfg.enable {

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
      pev
      bintools
      nix-derivation
      aircrack-ng 
      tcpdump 
      wireshark 
    ];

    programs.tmux = {
      enable = true;
      newSession = true;
      withUtempter = true;
      terminal = "screen-256color";
      shortcut = "Space";
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
        set-option -g status-right "#(whoami)@#(hostname)"
        set-window-option -g window-status-current-style bg="#7c3e8e"
        bind-key -T copy-mode-vi c send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"
        bind-key -T copy-mode-vi C-Up send-keys -X previous-paragraph
        bind-key -T copy-mode-vi C-Down send-keys -X next-paragraph
        bind-key -T copy-mode-vi C-Left send-keys -X previous-word
        bind-key -T copy-mode-vi C-Right send-keys -X next-word-end
        set -s command-alias[0] tj='last-pane'
        set -s command-alias[1] tp='split-window -h'
      '' + cfg.tmuxExtraConf;
    };

    environment.variables.EDITOR = "vim";

    users.defaultUserShell = pkgs.bash;
    programs.bash.enableCompletion = true;
    programs.bash.enableLsColors = true;

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
      
      function gdpush {
        git add -u
        git commit -m "AUTO COMMIT"
        git push
      }
      export gdpush
      
      function nix_rebuild {
        pushd . > /dev/null
        cd ${config.user.config.reposPath}/${config.user.config.envRepo}
        sudo nixos-rebuild --flake .#default switch
        popd > /dev/null
      }
      export nix_build
      
      function statall {
        pushd . > /dev/null
        for d in ${config.user.config.reposPath}/* ; do
          echo $d
          cd $d
          git status --porcelain
          echo   
        done
        popd > /dev/null
      }
      export statall

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
    '' + cfg.bashExtra;

    programs.bash.shellAliases = {
      # Use these for fast navigation of the terminal
      l = "ls -CF";
      g = "grep";
      e = "exit";
      ll = "ls -la";
      gs = "git status";
      ts = "tmux copy-mode";            # T SEARCH
      tw = "tmux new-window";           # T WINDOW
      tp = "tpane";                     # T PANE
      tj = "tjump";                     # T JUMP
      tl = "tmux rename-window";        # T LABEL
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
}