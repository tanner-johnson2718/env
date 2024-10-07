{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    protonmail-desktop
    protonvpn-gui
    proton-pass
    yubioath-flutter
    yubico-pam
    yubikey-manager
  ];

  security.pam.yubico = {
      enable = true;
      debug = true;
      mode = "challenge-response";
      id = [ "29490434" ];
      control = "sufficient";
    };
}