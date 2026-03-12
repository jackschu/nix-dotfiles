{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  llm-agents-pkgs,
  task_task,
  ...
}:

let
  packages = import ../installed_packages.nix { inherit pkgs pkgs-unstable llm-agents-pkgs task_task; };
in
{
  imports = [
    ./sops.nix
    ./gpg.nix
    ./git.nix
    ./emacs.nix
  ];

  # Common configuration for all machines
  home.stateVersion = "25.11";

  home.packages = packages.home.common;

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "emacs --no-desktop";
  };

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    formatter = false;
    permission = {
      read = "allow";
      edit = "ask";
      grep = "allow";
      bash = "ask";
      webfetch = "ask";
      websearch = "ask";
      codesearch = "allow";
      external_directory = "ask";
    };
    provider.ollama = {
      npm = "@ai-sdk/openai-compatible";
      name = "Ollama (gpu server)";
      options = {
        baseURL = "http://ollama.taild3c1e.ts.net:11434/v1";
        apiKey = "ollama";
        timeout = 600000;
        chunkTimeout = 60000;
      };
      models."qwen3-coder:30b" = {
        name = "Qwen3 Coder 30B";
        tool_call = true;
        limit = {
          context = 100000;
          output = 8192;
        };
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };


  programs.starship = let
    g = import ./starship_glyphs.nix;
    colors = [
      "#090c0c" # 0: dark text
      "#a3aed2" # 1: header accent
      "#769ff0" # 2: directory/highlight
      "#394260" # 3: mid dark
      "#e3e5e5" # 4: light text
      "#1d2230" # 5: darkest bg
    ];
    c = i: builtins.elemAt colors i;
    # Leading separator uses prev_bg to dynamically transition from
    # whatever module was last rendered, then content with fg/bg.
    segment = fg: bg: content:
      "[${g.separator}](fg:prev_bg bg:${c bg})"
      + "[${content}](fg:${c fg} bg:${c bg})";
  in {
    enable = true;
    enableBashIntegration = true;
    package = pkgs.starship.overrideAttrs (old: {
      patches = (old.patches or []) ++ [ ../patches/starship_nix_shell_trim_env.patch ];
    });
    settings = {
      format = ''
        [${g.gradient}](${c 1})[  ](fg:${c 0} bg:${c 1})$directory$git_branch$git_status$nix_shell$env_var[${g.separator}](fg:prev_bg)
        $character'';

      git_branch = {
        disabled = false;
        format = segment 2 3 " $symbol$branch ";
      };

      git_status = {
        format = "[($all_status$ahead_behind)](fg:${c 2} bg:${c 3})";
      };

      nix_shell = {
        format = segment 2 5 " $symbol$name";
        symbol = "❄ ";
        disabled = false;
      };

      env_var.context = {
        variable = "SHELL_CONTEXT";
        format = segment 2 5 " $env_value ";
        disabled = false;
      };

      directory = {
        format = segment 4 2 " $path ";
        truncation_length = 3;
        truncation_symbol = "${g.ellipsis}/";
        home_symbol = "${g.home}";
      };

      character = {
        format = "[${g.prompt} ](bold purple)";
      };

      time = {
        disabled = true;
      };
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      cd = "z";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      identityFile = [ "~/.ssh/id_ed25519" ];
      identitiesOnly = true;
      addKeysToAgent = "yes";
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      background-image = builtins.toString ./terminal_bg.png;
      background-image-opacity = 1;
      background-image-fit = "cover";
      background-opacity = 0.9;
      font-feature = ["-liga" "-dlig" "-calt"];
      desktop-notifications = false;
      cursor-color = "#ff55ff";
      keybind = [
        # Clipboard
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        # Tab navigation
        "alt+one=goto_tab:1"
        "alt+two=goto_tab:2"
        "alt+three=goto_tab:3"
        "alt+four=goto_tab:4"
        "alt+five=goto_tab:5"
        "alt+six=goto_tab:6"
        "alt+seven=goto_tab:7"
        "alt+eight=goto_tab:8"
        "alt+nine=goto_tab:9"
        # Disabled shortcuts
        "ctrl+tab=unbind"
        "ctrl+enter=unbind"
      ];
    };
  };

  programs.readline = {
    enable = true;
    extraConfig = "set bell-style none";
  };
}
