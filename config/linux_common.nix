{
  config,
  pkgs,
  lib,
  ...
}:

let
  browser = "google-chrome.desktop";
in
{
  imports = [
    ./common.nix
    ./sops.nix
    ./gpg.nix
    ./plasma.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard
    kdePackages.kdbusaddons
  ];

  home.file = { };

  # Reduce Bluetooth audio latency (default is ~200ms buffer)
  xdg.configFile."wireplumber/wireplumber.conf.d/51-bluetooth-latency.conf".text = ''
    monitor.bluez.rules = [
      {
        matches = [
          {
            node.name = "~bluez_output.*"
          }
        ]
        actions = {
          update-props = {
            # Reduce buffer to ~50ms (in microseconds)
            api.bluez5.a2dp.latency.msec = 50
          }
        }
      }
    ]
  '';

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = browser;
      "application/xhtml+xml" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
    commandLineArgs = [
      "--enable-features=TouchpadOverscrollHistoryNavigation"
    ];
  };

}
