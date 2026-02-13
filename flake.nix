{
  description = "Home Manager configuration of devbox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code.url = "github:sadjow/claude-code-nix";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      claude-code,
      sops-nix,
      nix-darwin,
      plasma-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ claude-code.overlays.default ];
      };
      baseModules = [
        sops-nix.homeManagerModules.sops
        plasma-manager.homeModules.plasma-manager
        ./home.nix
      ];
    in
    {
      homeConfigurations."laptop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = baseModules ++ [ ./laptop.nix ];
      };

      homeConfigurations."desktop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = baseModules ++ [ ./desktop.nix ];
      };

      darwinConfigurations."macbook_air" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { username = "jackschumann"; };
        modules = [
          ./nixos/darwin_configuration.nix
        ];
      };

      nixosConfigurations."dev_thinkpad" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { username = "devbox"; userDescription = "Jack Schumann"; };
        modules = [
          ./nixos/linux_configuration.nix
          ./nixos/dev_thinkpad
        ];
      };

      nixosConfigurations."desktop" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { username = "jackschu"; userDescription = "Jack S"; };
        modules = [
          ./nixos/linux_configuration.nix
          ./nixos/desktop
        ];
      };
    };
}
