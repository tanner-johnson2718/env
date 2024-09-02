{config, lib, pkgs,  name, ... }:
let
  cfg = config.argp.${name};
in
{
  options = {

    argp.${name}.cmdInit = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "echo 'base cmd set up'";
      description = ''
        Bash shell code to run on init of cmd??
      '';
    };

    argp.${name}.subCmdNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = "[ 'sub1' 'sub2' 'sub3' ]";
      description = "List of possible sub cmds";
    };

    argp.${name}.subCmdScripts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = "[ 'echo sub1' 'echo sub2' 'echo sub3' ]";
      description = "List of possible sub cmds";
    };

    argp.${name}.subCmdDescriptions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = "[ 'Sub1 does x' 'Sub1 does y' 'Sub1 does z' ]";
      description = "List of possible sub cmds";
    };

    argp.${name}.flags = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = ''
        -f:--force:Force my thing to do a thing
        -g:--go:Go
      '';
      description = "TODO";
    };
  };

  config = {
  };
}