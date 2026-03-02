{
  outputs = _: {
    nixosModules.host =
      { lib, ... }:
      {
        options.services.agent-microvm = {
          enable = lib.mkEnableOption "agent microvm";
          externalInterface = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Host interface used by the agent microvm.";
          };
        };
      };
  };
}
