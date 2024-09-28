# This expression should set up a Asus GU603 w/ gnome, all nvidia and intel
# graphics and acceleration drivers setup, a functioning networking stack and
# just generally a fully functioning sysetm as if you bought it that way and 
# its ready for your customization.

{ config, lib, pkgs, modulesPath, ... }:
let
  cfg = config.asus_gu603;
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  options = {
    asus_gu603.enable = lib.mkEnableOption "Enable Module";
    asus_gu603.hostName = lib.mkOption { type = lib.types.str; };
  };

  config = {
    fileSystems = {
      "/" = { 
        device = "/dev/disk/by-uuid/3f986e0c-dd3e-42d8-8693-c46c02c06e94";
        fsType = "ext4";
      };
      "/boot" = { 
        device = "/dev/disk/by-uuid/1ED3-74FC";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };
    };

    swapDevices = [ ];

    nixpkgs.hostPlatform = "x86_64-linux";

    security.rtkit.enable = true;

    services = {
      xserver = { 
        videoDrivers = [ "nvidia" ];
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
        xkb = {
          layout = "us";
          variant = "";
        };
      };

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };

    hardware = {
      cpu.intel.updateMicrocode = true;
      pulseaudio.enable = false;

      # For hardware graphics acceleration
      graphics = {
        enable = true;
      };

      nvidia = {
        package            = config.boot.kernelPackages.nvidiaPackages.stable;
        open               = false;
        modesetting.enable = true;
        nvidiaSettings     = true;

        powerManagement = {
          enable = true;
          finegrained = false;
        };

        prime = {
          sync.enable   = true;
          intelBusId    = "PCI:0:2:0";
          nvidiaBusId   = "PCI:1:0:0";
        };
      };
    };

    boot = {
      kernelPackages = pkgs.linuxPackages_6_11;
      initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
      initrd.kernelModules = [ ];
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
    };

    networking = {
      useDHCP               = lib.mkDefault true;
      hostName              = lib.mkDefault cfg.hostName;
      networkmanager.enable = lib.mkDefault true;
    };
  };
}
