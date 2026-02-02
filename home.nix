{
  config,
  pkgs,
  lib,
  ...
}:
let
  sopsAgeRelPath = "sops/age";
  ageKeyDir = "${config.xdg.configHome}/${sopsAgeRelPath}";
  ageKeyFile = "${ageKeyDir}/keys.txt";

  # Age public keys for all devices that can decrypt secrets
  # Add new devices here and run 'home-manager switch' to update the sops-edit wrapper
  ageKeys = {
    devbox = "age12x8hm7w8nns7w7z2ufsfz4ey9yyklatv3pfu508va4ej5hxq3dcsydq9as";
    # laptop = "age1...";  # Add more devices here
  };

  # Comma-separated list of age public keys for sops --age flag
  ageRecipients = lib.concatStringsSep "," (lib.attrValues ageKeys);

  # Wrapper for sops that bakes in the age keys - no .sops.yaml needed
  sopsEdit = pkgs.writeShellScriptBin "sops-edit" ''
    export SOPS_AGE_KEY_FILE="${ageKeyFile}"
    exec ${pkgs.sops}/bin/sops --age "${ageRecipients}" "$@"
  '';

  showAgeKey = pkgs.writeShellScriptBin "show-age-pubkey" ''
    if [ -f "${ageKeyFile}" ]; then
      ${pkgs.gnused}/bin/sed -n 's/.*public key: \(.*\)/\1/p' "${ageKeyFile}"
    else
      echo "No age key found. Run 'home-manager switch' first." >&2
      exit 1
    fi
  '';
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "devbox";
  home.homeDirectory = "/home/devbox";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.age
    pkgs.sops
    pkgs.claude-code
    pkgs.delta
    showAgeKey
    sopsEdit
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/devbox/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  xdg.configFile."${sopsAgeRelPath}/.keep".text = "";

  home.activation.generateAgeKey = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ ! -f "${ageKeyFile}" ]; then
      run ${pkgs.age}/bin/age-keygen -o "${ageKeyFile}"
    fi
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # sops-nix configuration for secrets management
  sops = {
    age.keyFile = ageKeyFile;
    defaultSopsFile = ./secrets/secrets.yaml;

    secrets."github-gpg-key" = { };
  };

  # Import GPG key from sops secret after decryption
  home.activation.importGpgKey = lib.hm.dag.entryAfter [ "sops-nix" ] ''
    GPG_KEY_FILE="${config.sops.secrets."github-gpg-key".path}"
    if [ -f "$GPG_KEY_FILE" ]; then
      # Check if key is already imported by looking for the signing key
      if ! ${pkgs.gnupg}/bin/gpg --list-secret-keys "${config.programs.git.signing.key}" &>/dev/null; then
        run ${pkgs.gnupg}/bin/gpg --batch --import "$GPG_KEY_FILE"
        echo "GPG key imported successfully"
      fi
    fi
  '';
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.bash = {
    enable = true;
    shellAliases = {
      cd = "z";
    };
  };

  programs.gpg = {
    enable = true;
    # Home-manager will manage your GPG configuration
    # Keys are stored in ~/.gnupg/
  };

  # Enable GPG agent for key management and caching passphrases
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 28800;
    enableSshSupport = false;
    # Options: curses (terminal), gtk2, qt, gnome3
    pinentry.package = pkgs.pinentry-curses;
  };

  programs.git = {
    enable = true;

    signing.key = "2A0AF30A3BD43ABB";

    settings = {
      user = {
        name = "jackschu";
        email = "31808950+jackschu@users.noreply.github.com";
      };

      commit = {
        gpgsign = true;
      };

      init = {
        defaultBranch = "main";
      };

      push = {
        autoSetupRemote = true;
      };

      merge = {
        conflictStyle = "diff3";
      };

      core = {
        pager = "delta";
        editor = "emacs -nw --no-desktop";
      };

      interactive = {
        diffFilter = "delta --color-only";
      };

      delta = {
        side-by-side = true;
        navigate = true;

        line-numbers = true;

        light = false;
      };

      diff = {
        colorMoved = "default";
      };

      color = {
        ui = true;
      };

      alias = {
        check = "checkout";
        unshelve = "stash apply";
        shelve = "stash";
        revert = "checkout";
        branches = "branch -a --sort=-committerdate";
      };

      # GitHub credential helper using gh CLI
      credential = {
        "https://github.com" = {
          helper = "!/etc/profiles/per-user/devbox/bin/gh auth git-credential";
        };
        "https://gist.github.com" = {
          helper = "!/etc/profiles/per-user/devbox/bin/gh auth git-credential";
        };
      };
    };
  };
}
