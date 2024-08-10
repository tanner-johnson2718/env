# NixOs Global System Configuration

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # Enable the GNOME Desktop Environment and X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
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

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define my pernsonal user account. Put applications in here that strictly
  # user applications and not needed by system services.
  users.users.tanner = {
    isNormalUser = true;
    description = "tanner";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  	vim
  	vscode
  	prusa-slicer
    gnupg
    pinentry-curses
    wireshark-qt
    wireshark-cli
    git
    xclip
    gcc
    gnumake
    btop
    rpi-imager
    aircrack-ng
    tcpdump
    valgrind
    nix-derivation
    libreoffice
    zstd
    minicom
    wget
  ];

  # Install firefox
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install tmux and 
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

  # Bash Setting
  programs.bash.shellAliases = {
    ll = "ls -al";
    la = "ls -A";
    l = "ls -CF";
    gs = "git status";
    gdpush = "git add ./\* && git commit -m \"..\" && git push";
    user_confirm="read -p \"Continue? (Y/N): \" confirm && [[ \$confirm == [yY] || \$confirm == [yY][eE][sS] ]] || return";
    ng_start="sudo airmon-ng start wlp5s0";
    ng_stop="sudo airmon-ng stop wlp5s0mon";
  };

  # Enable GPG agent
  programs.gnupg.agent = {
   enable = true;
   pinentryPackage = pkgs.pinentry-curses;
   enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Version of first installed version of nixos
  system.stateVersion = "24.05"; # Did you read the comment?

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
