{ config, pkgs, ... }:

{
  imports = [];
  home.username = "user";
  home.homeDirectory = "/home/user";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
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
    lsof
    patchelf
    nix-derivation
    fd
  ];

  home.file = {  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  home.shellAliases = {
    # Use these for fast navigation of the terminal
    a = "alias";
    l = "ls -CF --color=auto";
    g = "grep --color=auto";
    e = "exit";
    c = "clear";
    ll = "ls -la --color=auto";
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g prefix C-Space
      unbind-key C-b
      bind-key C-Space send-prefix

      set-option -g status-right ""
      set -g status-bg "#5b6078"
      set -g status-fg "#f9e2af"
      set-window-option -g window-status-current-style bg="#939ab7"
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
    '';
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;

    initExtra = ''
      export GIT_PS1_SHOWCOLORHINTS=true
      export GIT_PS1_SHOWDIRTYSTATE=true
      export GIT_PS1_SHOWUNTRACKEDFILES=true
      source ~/git-prompt.sh
      export PROMPT_COLOR='34'
      export PS1='\n\[\033[01;''${PROMPT_COLOR}m\]\W\[\033[01;32m\]$(__git_ps1 " (%s)") \[\033[00m\] '

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
        if [ $# = "1" ]; then
          tmux rename-window $1
        fi
      }
      export tlabel

      LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
      export LS_COLORS
    '';
  };
}
