# WSL2 guest. Deliberately not built on linux_configuration.nix: that file is for
# physical machines (bootloader, NetworkManager, SDDM/Plasma, PipeWire, Bluetooth,
# printing), none of which a WSL guest uses. NixOS-WSL provides the root filesystem
# and the boot path, so these machines have no hardware-configuration.nix either.
#
# nixosWslFlake, not nixos-wsl: the module it carries owns the `wsl.*` option
# namespace, so sharing the name would read as the options tree.
{ nixosWslFlake, username, ... }:

{
  imports = [
    nixosWslFlake.nixosModules.default
    ./linux_base.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = username;
}
