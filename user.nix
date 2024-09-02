{config, pkgs, lib, ...}:
let
  cfg = config.user.config;
in
{
  options = {
    user.config.enable = lib.mkEnableOption "Enable Module";
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
      description = "Whether to enable a GNOME DE w/ vs code and ";
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
    environment.systemPackages = with pkgs; []
      ++ (if cfg.enableDE then [
        vscode
        prusa-slicer
        rpi-imager
        firefox
        nil 
      ] else [] )
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
    # DE specific stuff
    #############################################################################

    security.rtkit.enable = true;
    hardware.pulseaudio.enable = false;

    # xserver is bad name, this is a GUI catch all attr
    services.xserver = lib.mkIf cfg.enableDE{
      enable = true;
      xkb.layout = "us";
      displayManager = {
        gdm.enable = true;
      };
      desktopManager = {
        gnome.enable = true;
      };
    };
    
    services.pipewire = lib.mkIf cfg.enableDE {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    #############################################################################
    # Encrypted Home Drive
    #############################################################################
    security.pam.enableEcryptfs = cfg.enableEcryptfs;
    boot.kernelModules = lib.mkIf cfg.enableEcryptfs ["ecryptfs"];
  };
}