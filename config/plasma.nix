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
        widgets = [
          "org.kde.plasma.kickoff"
          {
            iconTasks = {
              launchers = [
                "applications:com.mitchellh.ghostty.desktop"
                "applications:google-chrome.desktop"
                "applications:discord.desktop"
                "applications:spotify.desktop"
              ];
              behavior.minimizeActiveTaskOnClick = false;
            };
          }
          "org.kde.plasma.panelspacer"
          {
            systemTray = {
              items = {
                shown = [
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.bluetooth"
                  "org.kde.plasma.battery"
                  "org.kde.plasma.volume"
                ];
              };
            };
          }
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
      {
        location = "top";
        height = 26;
        hiding = "none";
        widgets = [
          "org.kde.plasma.panelspacer"
          {
            systemMonitor = {
              displayStyle = "org.kde.ksysguard.textonly";
              sensors = [
                { name = "cpu/all/usage"; color = "180,190,254"; label = "CPU"; }
                { name = "memory/physical/usedPercent"; color = "245,194,231"; label = "RAM"; }
              ];
            };
          }
          {
            systemTray = {
              items = {
                shown = [
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.bluetooth"
                  "org.kde.plasma.battery"
                ];
                hidden = [
                  "org.kde.plasma.notifications"
                  "org.kde.plasma.volume"
                  "org.kde.plasma.brightness"
                  "org.kde.plasma.clipboard"
                ];
              };
            };
          }
          "org.kde.plasma.digitalclock"
        ];
      }
    ];
    hotkeys.commands.sioyek = {
      # Untested: verify key combo and app name on Plasma host.
      name = "Sioyek";
      key = "Ctrl+Shift+2";
      command = "sioyek";
    };
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
          SyncClipboards = false;  # Keep PRIMARY and CLIPBOARD separate (GNOME-like behavior)
          IgnoreSelection = true;  # Don't track PRIMARY (text highlight) in clipboard history
          KeepClipboardContents = false;  # Don't persist clipboard contents
          MaxClipItems = 1;  # Only keep current item (disables history)
        };
      };
      kglobalshortcutsrc = {
      };
    };
  };
}
