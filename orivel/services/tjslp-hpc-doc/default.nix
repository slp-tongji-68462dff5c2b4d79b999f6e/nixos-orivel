{
  config,
  ...
}:
let
  port = 54560;
  domain = "hpc-doc.tjslp.yueyinqiu.top";
  callback = "https://${domain}/oauth2/callback";
  oidcSecret = config.services.tjslp-id.clients.hpc-doc.secretFile;
  configurationDirectory = "service-config/tjslp-hpc-doc";
  deployKeyFile = "${configurationDirectory}/key";
  stateDirectoryName = "tjslp-hpc-doc";
in
{
  config = {
    services.https-gateway.sites.hpc-doc = {
      domain = domain;
      upstream = "http://127.0.0.1:${toString port}";
    };

    environment.etc."${deployKeyFile}.sample".source = ./key.sample;

    services.tjslp-id.clients.hpc-doc = {
      name = "HPC Documentation";
      callbacks = [ callback ];
    };

    containers.tjslp-hpc-doc = {
      autoStart = true;
      privateNetwork = false;

      bindMounts.${oidcSecret} = {
        hostPath = oidcSecret;
        isReadOnly = true;
      };

      bindMounts."/etc/${configurationDirectory}" = {
        hostPath = "/etc/${configurationDirectory}";
        isReadOnly = true;
      };

      specialArgs.serviceConfigurations = {
        port = port;
        callback = callback;
        oidcSecret = oidcSecret;
        deployKeyFile = "/etc/${deployKeyFile}";
        stateDirectoryName = stateDirectoryName;
        outputDirectory = "/var/lib/${stateDirectoryName}/public";
      };

      config = {
        imports = [
          ./oauth2-proxy.nix
          ./hugo.nix
        ];
        system.stateVersion = "26.05";
      };

      # useHostResolvConf 底层是复制 resolv.conf ，有时序问题，可能在宿主 resolv.conf 还未创建时复制，这里改为手动 mount
      # https://github.com/NixOS/nixpkgs/issues/162686#issuecomment-3295385984
      bindMounts."/etc/resolv.conf" = {
        hostPath = "/etc/resolv.conf";
        isReadOnly = true;
      };
      config.networking.resolvconf.enable = false;
    };
  };
}
