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
      nix-derivation
    ] ++ cfg.extraTerminalPkgs;

    console = {
      enable = true;
      font = null;
      keyMap = "us";
      colors = [ ];
      packages = [ ];
      earlySetup = false;
      useXkbConfig = false; 
    };

    programs.tmux = {
      enable = true;
      newSession = true;
      withUtempter = true;
      terminal = "tmux-direct";
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
        set -s command-alias[2] tw='select-window'
        set -s command-alias[3] t0='select-window- t 0'
        set -s command-alias[4] t1='select-window- t 1'
        set -s command-alias[5] t2='select-window- t 2'
        set -s command-alias[6] t3='select-window- t 3'
        set -s command-alias[7] t4='select-window- t 4'
        set -s command-alias[8] t5='select-window- t 5'
        set -s command-alias[9] t6='select-window- t 6'
        set -s command-alias[10] t7='select-window -t 7'
        set -s command-alias[11] t8='select-window -t 8'
        set -s command-alias[12] t9='select-window -t 9'
        set -s command-alias[13] ts='copy-mode'
        set -g mouse on
        set -g renumber-windows on
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

        if [[ "''${SHLVL}" -eq "2" ]]; then
          export PROMPT_COLOR='34'
        else
          export PROMPT_COLOR='31'
        fi

        export PS1='\n\[\033[01;''${PROMPT_COLOR}m\]\W\[\033[01;32m\]$(__git_ps1 " (%s)") \[\033[00m\] '
      '';

      interactiveShellInit = ''
        if [ -z $TMUX ];then
          tmux attach
        fi
        
        function gdpush {
          git add -u
          git commit -m "AUTO COMMIT"
          git push
        }
        export gdpush

        function nix_closure {
          if [ $# != 1 ]; then 
            echo "usage nix_closure <store dir>"
            return 0;
          fi
          nix path-info --recursive --closure-size --human-readable $1
          return $?
        }
        export nix_closure

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
      '' 
      + cfg.bashExtra
      +(if true then ''
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
        
        function nix_rebuild {
          if [ $# != 1]; then
            return 0;
          fi
          pushd . > /dev/null
          cd ${config.user.config.reposPath}/${config.user.config.envRepo}
          sudo nixos-rebuild --flake .#$1 switch
          popd > /dev/null
        }
        export nix_build
  
        function nix_nuke {
          sudo nix-collect-garabage -d
        }
        export nix_nuke

                function nix_flake_update {
          pushd . > /dev/null
  
          _path=${config.user.config.reposPath}/${config.user.config.reposPath}
          echo "Updating env flake at $_path"
          cd $_path
          nix flake update
          _rev=$(nix flake metadata --json | jq "[ .locks.nodes.nixpkgs.locked.rev]" | g -oe "[a-z0-9]*")
          _owner=$(nix flake metadata --json | jq "[ .locks.nodes.nixpkgs.locked.owner]" | g -oe "[a-zA-Z0-9.-]*")
          _repo=$(nix flake metadata --json | jq "[ .locks.nodes.nixpkgs.locked.repo]" | g -oe "[a-zA-Z0-9.-]*")

          echo "Updated to rev=$_rev ... Updating local nixpkgs"
          cd ..
          if ! [ -d nixpkgs ]; then
            git clone https://github.com/$_owner/$_repo.git
          fi

          cd nixpkgs
          git pull
          git checkout $_rev

          popd > /dev/null
        }
        export nix_flake_update
      '' else "");

      shellAliases = {
        # Use these for fast navigation of the terminal
        a = "alias";
        l = "ls -CF";
        g = "grep";
        e = "exit";
        ll = "ls -la";
        lf = "declare -F";               # LIST FUNCTIONS 
        lF = "declare";                  # REALLY LIST FUNCTIONS
        lc = "complete";                 # LIST COMPLETIONS  
        gs = "git status";
        ts = "tmux copy-mode";            # T SCROLL
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
  };
}