{ pkgs, ... }:

let
  # Note that the the escaping here is load bearing
  touchpadName = "ETPS\\/2 Elantech Touchpad";
in
{
  home.username = "devbox";
  home.homeDirectory = "/home/devbox";

  programs.plasma.configFile.kcminputrc = {
    "Libinput/2/14/${touchpadName}" = {
      ClickMethod = 2;  # Two-finger right click
      NaturalScroll = true;
      ScrollFactor = 0.5;
    };
  };

  services.easyeffects = {
    enable = true;
    preset = "thinkpad-unsuck";
  };

  xdg.dataFile."easyeffects/output/thinkpad-unsuck.json".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/sebastian-de/easyeffects-thinkpad-unsuck/a14f11afcba9f1d1d2a75de3155e7de3293dae90/thinkpad-unsuck.json";
    sha256 = "0vfmc5rslza8nnk59hw25rff3pg1jbs7jb0ms36j2cp82zxvbbca";
  };

  xdg.dataFile."easyeffects/output/jabra-85t.json".source = ./jabra-85t.json;
}
