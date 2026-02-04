{ pkgs, ... }:

{
  home.username = "devbox";
  home.homeDirectory = "/home/devbox";

  services.easyeffects = {
    enable = true;
    preset = "thinkpad-unsuck";
  };

  xdg.dataFile."easyeffects/output/thinkpad-unsuck.json".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/sebastian-de/easyeffects-thinkpad-unsuck/a14f11afcba9f1d1d2a75de3155e7de3293dae90/thinkpad-unsuck.json";
    sha256 = "0vfmc5rslza8nnk59hw25rff3pg1jbs7jb0ms36j2cp82zxvbbca";
  };
}
