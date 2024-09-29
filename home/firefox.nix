# https://github.com/yokoffing/Betterfox/blob/main/user.js
# https://github.com/oddlama/nix-config/blob/main/users/myuser/graphical/firefox.nix
{ pkgs, home, config, lib, ... }:
let
  betterfox = pkgs.fetchFromGitHub {
    owner = "yokoffing";
    repo = "Betterfox";
    rev = "129.0";
    hash = "sha256-hpkEO5BhMVtINQG8HN4xqfas/R6q5pYPZiFK8bilIDs=";
  };
in
{
    programs.firefox = {
        enable = true;
        profiles ={
          default = {
            extraConfig =  builtins.concatStringsSep "\n" [ 
              (builtins.readFile "${betterfox}/user.js")
              (''
                user_pref("services.sync.prefs.sync-seen.privacy.clearOnShutdown.cookies", true);
                user_pref("services.sync.prefs.sync-seen.privacy.clearOnShutdown_v2.cookiesAndStorage", true);
                user_pref("privacy.clearOnShutdown.cache", true);
                user_pref("privacy.clearOnShutdown.cookies", true);
                user_pref("privacy.clearOnShutdown.downloads", true);
                user_pref("privacy.clearOnShutdown.formdata", true);
                user_pref("privacy.clearOnShutdown.history", true);
                user_pref("privacy.clearOnShutdown.sessions", true);
                user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", true);
                user_pref("dom.webnotifications.enabled",			false);
                user_pref("browser.urlbar.placeholderName", "DuckDuckGo");
                user_pref("privacy.sanitize.pending", "[{\"id\":\"shutdown\",\"itemsToClear\":[\"cache\",\"siteSettings\",\"historyFormDataAndDownloads\",\"cookiesAndStorage\"],\"options\":{}}]");
                user_pref("privacy.sanitize.sanitizeOnShutdown", true);
                user_pref("privacy.donottrackheader.enabled", true);
                user_pref("privacy.clearOnShutdown_v2.siteSettings", true);
                user_pref("extensions.formautofill.addresses.enabled", false);
                user_pref("extensions.formautofill.creditCards.enabled", false);
              '')
            ];
          };
        };
    };
}