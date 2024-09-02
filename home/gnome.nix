{config, lib, ...}:
let
  cfg = config.gnome.config;
in {
  options = {
    gnome.config.enable = lib.mkEnableOption "Enable Module";
    gnome.config.extraDEPkgs =  lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [];
      example = "[vscode]";
      description = "Extra gui apps to add";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = cfg.extraDEPkgs;

    programs.firefox = {
      enable = true;
    };

    security.rtkit.enable = true;
    hardware.pulseaudio.enable = false;

    # xserver is bad name, this is a GUI catch all attr
    services.xserver = {
      enable = true;
      xkb.layout = "us";
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

  };
}