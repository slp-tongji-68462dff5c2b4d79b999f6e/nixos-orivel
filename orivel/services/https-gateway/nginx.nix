{ container, lib, ... }:
{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    virtualHosts =
      lib.mapAttrs' (name: backend: lib.nameValuePair backend.domain {
        useACMEHost = backend.domain;
        forceSSL = true;
        locations."/" = { proxyPass = "http://${backend.host}:${toString backend.port}"; };
      }) container.backends;
  };
}
