{config, pkgs, lib, ...}:
let
  cfg = config.devVM.config;
in
{
  options = {
    # devVM.config.enable = lib.mkEnableOption "Enable Module";
    # devVM.config.bashExtra = lib.mkOption {
    #   type = lib.types.str;
    #   default = "";
    #   example = "alias short='cut'";
    #   description = "Extra init shell hook you want to add to an interactive shell";
    # };
  };

  config = lib.mkIf cfg.enable {

  };
}