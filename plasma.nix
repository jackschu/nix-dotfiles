{ config, pkgs, lib, ... }:

{
  programs.plasma = {
    enable = true;
    workspace = {
      colorScheme = "BreezeDark";
    };
    panels = [
      {
        location = "bottom";
        hiding = "autohide";
      }
    ];
    configFile = {
      ksmserverrc = {
        General = {
          loginMode = "restorePreviousLogout";
        };
      };
      kwinrc = {
        "org.kde.kdecoration2" = {
          BorderSize = "None";
          BorderSizeAuto = false;
        };
        TabBox = {
          ShowDelay = 0;
          DelayTime = 0;
          HighlightWindows = false;
        };
        TabBoxAlternative = {
          ShowDelay = 0;
          DelayTime = 0;
        };
      };
      libinputrc = {
        Touchpad = {
          NaturalScroll = true;
        };
      };
      kdeglobals = {
        KDE = {
          AnimationDurationFactor = 0;  # Disable animations (0 = instant, 1 = normal)
        };
      };
      kcminputrc = {
        Keyboard = {
          RepeatDelay = 500;
          RepeatRate = 30;
        };
      };
      klipperrc = {
        General = {
          SyncClipboards = true;  # Sync PRIMARY and CLIPBOARD selections
        };
      };
      kglobalshortcutsrc = {
      };
    };
  };
}
