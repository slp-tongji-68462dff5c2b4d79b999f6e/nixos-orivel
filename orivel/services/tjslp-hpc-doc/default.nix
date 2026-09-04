{
  config,
  ...
}:
let
  port = 54560;
  domain = "hpc-doc.tjslp.yueyinqiu.top";
  oidcSecret = config.services.tjslp-id.clients.hpc-doc.secretFile;
in
{
  config = {
    services.https-gateway.sites.hpc-doc = {
      domain = domain;
      upstream = "http://127.0.0.1:${toString port}";
    };

    services.tjslp-id.clients.hpc-doc = {
      name = "HPC Documentation";
      callbacks = [ "https://${domain}/oauth2/callback" ];
    };

    containers.tjslp-hpc-doc = {
      autoStart = true;
      privateNetwork = false;

      bindMounts.${oidcSecret} = {
        hostPath = oidcSecret;
        isReadOnly = true;
      };

      specialArgs.serviceConfigurations = {
        port = port;
        domain = domain;
        oidcSecret = oidcSecret;
      };

      config = {
        imports = [
          ./oauth2-proxy.nix
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
