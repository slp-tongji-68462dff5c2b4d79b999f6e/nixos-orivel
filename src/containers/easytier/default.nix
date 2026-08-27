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

        sops.secrets."easytier/configuration.toml" = {
          sopsFile = ../../secrets/easytier/configuration.toml;
          path = "/etc/easytier/default/configuration.toml";
          owner = "root";
          group = "root";
          mode = "0400";
          restartUnits = [ "easytier-default.service" ];
        };

        services.easytier.instances.default.configFile =
          config.sops.secrets."easytier/configuration.toml".path;

        system.stateVersion = "26.05";
      };
  };
}
