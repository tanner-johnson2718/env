{lib, config, pkgs, ...}:
let
  cfg = config.firefox;

  # Create an attr set with all the nix docs urls. Some will have "@X" shortcuts
  # as a firefox search engine but not all site support this. All elements will
  # get a bookmark.
  nixdoc = {
    nix-packages = {
      name = "nix-packages";
      url = https://search.nixos.org/packages?channel=unstable&size=50&sort=relevance&type=packages;
    };
    home-manager = {
      name = "home-manager";
      url = "https://home-manager-options.extranix.com/?release=master";
    };
    nix-options = {
      name = "nix-options";
      url = "https://search.nixos.org/options?channel=unstable&size=50&sort=relevance&type=options";
    };
    nix-dev = {
      name = "nix-dev";
      url = "https://nix.dev";
    };
    nix-man = {
      name = "nix-man";
      url = "https://nix.dev/manual/nix/development/";
    };
    nixpkgs-man = {
      name = "nixpkgs-man";
      url = "https://nixos.org/manual/nixpkgs/unstable/";
    };
    nixos-man = {
      name = "nixos-man";
      url = "https://nixos.org/manual/nixos/unstable/";
    };
    nixos-wiki = {
      name = "nixos-wiki";
      url = "https://wiki.nixos.org/wiki/NixOS_Wiki";
    };  
  };

  # converts the above attr set to one matching the bookmark schema
  boomarkify = {name, url} : {
    Title = "${name}";
    URL = "${url}";
    Placement = "toolbar";
    Folder = "nix";
  };
in
{
  options = {
    firefox.enable = lib.mkEnableOption "Enable Firefox";
    firefox.bookmarks = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ./bookmarks.nix ];
    };
    firefox.extraSeachEngines = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [];
    };
  };

  config = {
    programs.firefox = lib.mkIf cfg.enable {
      enable = true;
      package = pkgs.firefox-esr;
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
        Bookmarks = lib.lists.flatten (map import cfg.bookmarks)
          ++(map boomarkify (lib.attrsets.mapAttrsToList (name: value: value) nixdoc));
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
        SearchEngines = {
          Default = "DuckDuckGo"; 
          Add = [
            ({
              Name = "${nixdoc.nix-packages.name}";
              URLTemplate =  "${nixdoc.nix-packages.url}&query={searchTerms}";
              Alias = "@np";
            })
            ({
              Name = "${nixdoc.nix-options.name}";
              URLTemplate =  "${nixdoc.nix-options.url}&query={searchTerms}";
              Alias = "@no";
            })
            ({
              Name = "${nixdoc.nix-dev.name}";
              URLTemplate =  "${nixdoc.nix-dev.url}/search.html?q={searchTerms}";
              Alias = "@nd";
            })
            ({
              Name = "${nixdoc.home-manager.name}";
              URLTemplate =  "${nixdoc.home-manager.url}&query={searchTerms}";
              Alias = "@hm";
            })
            ({
              Name = "${nixdoc.nixos-wiki.name}";
              URLTemplate =  "${nixdoc.nixos-wiki.url}&query={searchTerms}";
              Alias = "@nw";
            })
          ]
        ++ cfg.extraSeachEngines;
        };
      };
      preferences = {
        "privacy.donottrackheader.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true;
      };
    };
  };
}