{
  config,
  pkgs,
  lib,
  llm-agents-pkgs,
  ...
}:

let
  packages = import ../installed_packages.nix { inherit pkgs llm-agents-pkgs; };
  isX86 = pkgs.stdenv.hostPlatform.isx86;
  browserPkg = if isX86 then pkgs.google-chrome else pkgs.chromium;
  browser = if isX86 then "google-chrome.desktop" else "chromium-browser.desktop";
in
{
  imports = [
    ./common.nix
    ./plasma.nix
  ];

  custom.secrets.enable = true;
  custom.gpg.enable = true;

  home.packages = packages.home.linux;

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
    package = browserPkg;
    commandLineArgs = [
      "--enable-features=TouchpadOverscrollHistoryNavigation"
    ];
  };

}
