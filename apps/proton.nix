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
}