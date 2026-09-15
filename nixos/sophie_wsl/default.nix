{ ... }:

{
  networking.hostName = "sophie-wsl";

  # Match the NixOS-WSL release this instance was installed from; never bump it after.
  system.stateVersion = "26.05";
}
