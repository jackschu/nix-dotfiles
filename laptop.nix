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

  xdg.dataFile."easyeffects/output/thinkpad-unsuck.json".source = ./thinkpad-unsuck.json;

  xdg.dataFile."easyeffects/output/jabra-85t.json".source = ./jabra-85t.json;

}
