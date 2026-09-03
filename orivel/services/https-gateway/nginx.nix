{ container, lib, ... }:
{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    virtualHosts =
      lib.mapAttrs' (name: backend: lib.nameValuePair backend.hostname {
        useACMEHost = backend.hostname;
        forceSSL = true;
        locations."/" = { proxyPass = "http://${backend.host}:${toString backend.port}"; };
      }) container.backends;
  };
}
