# The darwin half of build_cluster.nix. Cache reads only: builderSshKeyFile stays null so no
# builder credential lands on a laptop, at the cost of no x86_64-linux offload from the Mac.
{ homelabFlake, ... }:

{
  imports = [ homelabFlake.darwinModules.buildCluster ];

  homelab.buildCluster = {
    enable = true;
    # pushTokenFile stays null: the bastion is the sole pusher, as on the NixOS hosts.
    # localMaxJobs stays null: local builds remain the normal path when off the LAN.
  };
}
