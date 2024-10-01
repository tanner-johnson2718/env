{config, lib, pkgs, ...}:
let
  cfg = config.home;
in
{
  options = {
    home.enable = lib.mkEnableOption "Enable My Home Manager Modules";
    home.userName = lib.mkOption { type = lib.types.str; };
    home.term.enable = lib.mkEnableOption "Enable My Terminal";
    home.kitty.enable = lib.mkEnableOption "Enable My Kitty Settings";
    home.vscode.enable = lib.mkEnableOption "Enable My VSCode Settings";
    home.firefox.enable = lib.mkEnableOption "Enable My FireFox Settings";
    home.threeD.enable = lib.mkEnableOption "Enable 3d printing stuff";
    home.steam.enable = lib.mkEnableOption "Enable steam";
  };

  config = lib.mkIf cfg.enable {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users."${cfg.userName}" = (import ./home.nix){ 
      userName = "${cfg.userName}";
      modules = []
        ++ (if cfg.term.enable then [./term.nix] else [])
        ++ (if cfg.kitty.enable then [./kitty.nix] else [])
        ++ (if cfg.vscode.enable then [./vscode.nix] else []);
    };

    environment.systemPackages = with pkgs; []
      ++ (if cfg.kitty.enable then [kitty] else [])
      ++ (if cfg.firefox.enable then [firefox] else [])
      ++ (if cfg.threeD.enable then [prusa-slicer] else [])
      ++ (if cfg.steam.enable then [discord] else []);

    programs.steam = lib.mkIf cfg.steam.enable {
      enable = true;
      extraCompatPackages = with pkgs; [proton-ge-bin];
    };
    
    programs.firefox = lib.mkIf cfg.firefox.enable {
      enable = true;
      policies = {
        AllowFileSelectionDialogs = true;
        AppAutoUpdate = false;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        BackgroundAppUpdate = false;
        BlockAboutAddons = false;
        BlockAboutConfig = false;
        BlockAboutProfiles = false;
        BlockAboutSupport = false;
        Bookmarks = [
          ({
            Title = "proton-mail";
            URL = "https://account.proton.me/mail";
            Placement = "toolbar";
            Folder = "proton";
          })
          ({
            Title = "proton-calendar";
            URL = "https://calendar.proton.me/u/0/";
            Placement = "toolbar";
            Folder = "proton";
          })
          ({
            Title = "proton-pass";
            URL = "https://pass.proton.me/u/0/";
            Placement = "toolbar";
            Folder = "proton";
          })
          ({
            Title = "amazon-shopping";
            URL = "https://www.amazon.com/";
            Placement = "toolbar";
            Folder = "amazon";
          })
          ({
            Title = "amazon-aws";
            URL = "https://iq.aws.amazon.com/p/create";
            Placement = "toolbar";
            Folder = "amazon";
          })
          ({
            Title = "amazon-video";
            URL = "https://www.amazon.com/gp/video/storefront";
            Placement = "toolbar";
            Folder = "amazon";
          })
          ({
            Title = "nix search";
            URL = "https://search.nixos.org/packages?channel=unstable";
            Placement = "toolbar";
            Folder = "nix";
          })
          ({
            Title = "nix pkgs";
            URL = "https://github.com/NixOS/nixpkgs";
            Placement = "toolbar";
            Folder = "nix";
          })
          ({
            Title = "nix home manager";
            URL = "https://home-manager-options.extranix.com/";
            Placement = "toolbar";
            Folder = "nix";
          })
          ({
            Title = "nix nvidia";
            URL = "https://nixos.wiki/wiki/Nvidia";
            Placement = "toolbar";
            Folder = "nix";
          })
          ({
            Title = "nix flakes";
            URL = "https://nixos.wiki/wiki/flakes";
            Placement = "toolbar";
            Folder = "nix";
          })
          ({
            Title = "nix hardware";
            URL = "https://github.com/NixOS/nixos-hardware";
            Placement = "toolbar";
            Folder = "nix";
          })
          ({
            Title = "rippling";
            URL = "https://app.rippling.com";
            Placement = "toolbar";
            Folder = "finance";
          })
          ({
            Title = "fidelity";
            URL = "https://nb.fidelity.com";
            Placement = "toolbar";
            Folder = "finance";
          })
          ({
            Title = "nelnet";
            URL = "https://nelnet.studentaid.gov/welcome";
            Placement = "toolbar";
            Folder = "finance";
          })
          ({
            Title = "progressive";
            URL = "https://account.apps.progressive.com";
            Placement = "toolbar";
            Folder = "finance";
          })
          ({
            Title = "guardian life";
            URL = "https://login.guardianlife.com";
            Placement = "toolbar";
            Folder = "finance";
          })
          ({
            Title = "kaiser health";
            URL = "https://kaiserpermanente.org";
            Placement = "toolbar";
            Folder = "finance";
          })
          ({
            Title = "electrity";
            URL = "https://www.sce.com/";
            Placement = "toolbar";
            Folder = "finance";
          })
          ({
            Title = "wm";
            URL = "https://www.wm.com/us/en/mywm/user/dashboard";
            Placement = "toolbar";
            Folder = "finance";
          })
          ({
            Title = "cox";
            URL = "https://www.cox.com/residential/home.html";
            Placement = "toolbar";
            Folder = "finance";
          })
          ({
            Title = "turboo tax";
            URL = "https://myturbotax.intuit.com/";
            Placement = "toolbar";
            Folder = "finance";
          })
          ({
            Title = "chase";
            URL = "https://secure.chase.com";
            Placement = "toolbar";
          })
          ({
            Title = "discord";
            URL = "https://discord.com";
            Placement = "toolbar";
          })
          ({
            Title = "github";
            URL = "https://github.com";
            Placement = "toolbar";
          })
          ({
            Title = "spotify";
            URL = "https://spotify.com";
            Placement = "toolbar";
          })
        ];
        CaptivePortal = false;
        ContentAnalysis = { Enabled = false; };
        Cookies = {
          Behavior = "reject-tracker";
          Locked = false;
        };
        DisableAccounts = true;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        DisableFirefoxStudies = true;
        DisableFormHistory = true;
        DisablePocket = true;
        DisableSystemAddonUpdate = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = "newtab";
        DontCheckDefaultBrowser = true;
        DNSOverHTTPS = {
          Enabled = true;
          ProviderURL = "https://1.1.1.1";
        };
        EnableTrackingProtection = {
          Value = true;
          Locked = false;
          Cryptomining = true;
          Fingerprinting = true;
        };
        ExtensionSettings = {
          "*".installation_mode = "blocked";
          "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
          	"78272b6fa58f4a1abaac99321d503a20@proton.me" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
              installation_mode = "force_installed";
            };
        };
        ExtensionUpdate = false;
        SearchBar = "unified";
        FirefoxHome = {
          Search = true ;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket =  false;
          SponsoredPocket = false;
          Snippets = false;
          Locked =  false;
        };
        FirefoxSuggest = {
          webSuggestions = false;
          sponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = false;
        };
        HardwareAcceleration = true;
        HttpsOnlyMode = "enabled";
        NetworkPrediction = true;
        NoDefaultBookmarks = false;
        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        PasswordManagerEnabled = false;
        PictureInPicture = {
          Enabled = false;
        };
        PopupBlocking = {
          Default = true;
          Locked = false;
        };
        SanitizeOnShutdown = {
          Cache = true;
          Cookies = true;
          Downloads = true;
          FormData = true;
          History = true;
          Sessions = true;
          SiteSettings = true;
          OfflineApps = true;
          Locked = false;
        };
        SearchSuggestEnabled = false;
        ShowHomeButton = false;
      };
      preferences = {
        "privacy.donottrackheader.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true;
      };
    };
  };
} 