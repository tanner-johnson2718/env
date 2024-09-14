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
    user.config.extraFontPkgs = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [pkgs.cascadia-code];
      example = "[pkgs.cascadia-code]";
      description = "Extra Font Packages";
    };
    user.config.defaultFont = lib.mkOption {
      type = lib.types.str;
      default = "Cascadia Mono";
      example = "Cascadia Mono";
      description = "Default Font";
    };
  };

  config = lib.mkIf cfg.enable {

    users.users.${cfg.userName} = {
      isNormalUser = true;
      description = "Main System User";
      extraGroups = [ "networkmanager" "wheel" ];
    };

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

    fonts.packages = cfg.extraFontPkgs;
    fonts.fontconfig.enable = true;
    fonts.fontconfig.defaultFonts.monospace = [cfg.defaultFont];
    fonts.fontconfig.defaultFonts.serif = [cfg.defaultFont];
    fonts.fontconfig.defaultFonts.sansSerif = [cfg.defaultFont];
  };
}