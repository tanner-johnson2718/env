{
  description = ''
    Configuration for my main system. Export parts of my main system in the 
    form of configurable modules. This flake and this repo are pinned to what
    ever is currently my main laptop and my main laptop will only use this 
    flake and this repo to declare its entire sys config.
  '';
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem 
    {
      inherit system;
      modules = [
        #######################################################################
        # Inline Module. Put hardware specific stuff here or anything that
        # pertains only to my main laptop and can't or isnt worth making into
        # a module for export
        #######################################################################
        ( {config, lib, modulesPath, ...}:{
          imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

          fileSystems."/" =
          { device = "/dev/disk/by-uuid/8a88986c-035f-46fa-bb5c-e46d36ab030c";
            fsType = "ext4";
          };

          fileSystems."/boot" =
          { device = "/dev/disk/by-uuid/D546-8500";
            fsType = "vfat";
            options = [ "fmask=0022" "dmask=0022" ];
          };

          swapDevices = [ ];

          # Main system first installed version was 24.05
          system.stateVersion = "24.05";
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          nixpkgs.hostPlatform = system;
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnsupportedSystem = true;

          networking.networkmanager.enable = true;
          networking.hostName = config.user.config.userName;
          networking.useDHCP = lib.mkDefault true;

          hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
          boot.initrd.kernelModules = [ ];
          boot.kernelModules = [ "kvm-intel" ];
          boot.extraModulePackages = [ ];

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
        })

        #######################################################################
        # My main user module for setting my system. This should be broken
        # into things like "sys-man", "term-conf", etc.
        #######################################################################
        (
          {config, ...}:{
            imports = [./user.nix];
            config.user.config.enable = true;
            config.user.config.envRepo = "env";
            config.user.config.userName = "lcars";
            config.user.config.reposPath = "/var/git";
            config.user.config.enableDE = true;
            config.user.config.enableEcryptfs = true;
            config.user.config.ecryptfsBakPath = "/var/ecryptfsBak";
            config.user.config.tmuxExtraConf = "";
            config.user.config.bashExtra = "";
          }
        )
      ];
    };

   ###########################################################################
    # Nix Modules to export sys config other systems
   ###########################################################################

    nixosModules.user = (import ./user.nix);

   ###########################################################################
    # Nix Shells to export developer environments to other system. for stuff
    # I dont know what to do with.
   ###########################################################################

    devShells.${system} =
    let
      pkgs = (import nixpkgs { inherit system; } );
    in
    {
      aircrack = (import ./aircrack/aircrack.nix){ inherit pkgs; };
      qmk = (import ./qmk/qmk.nix){ inherit pkgs; };
    };
  };
}
