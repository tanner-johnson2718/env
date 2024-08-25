{pkgs}:
pkgs.mkShell {
  packages = with pkgs; [ aircrack-ng tcpdump wireshark ];
  shellHook = ''
    alias ng_start="sudo airmon-ng start wlp5s0"
    alias ng_stop="sudo airmon-ng stop wlp5s0mon"
  '';
}