{ ... }: {
  containers.easytier = {
    autoStart = true;

    enableTun = true;
    additionalCapabilities = [
      "CAP_NET_ADMIN"
      "CAP_NET_RAW"
    ];
    
    config =
      {
        config,
        ...
      }:
      {
        services.easytier.enable = true;
        system.stateVersion = "26.05";
      };
  };
}
