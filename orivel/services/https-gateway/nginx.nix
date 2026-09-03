{ container, lib, ... }:
{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    virtualHosts =
      lib.mapAttrs' (name: b: lib.nameValuePair b.hostname {
        useACMEHost = b.hostname;
        forceSSL = true;
        locations."/" = { proxyPass = "http://${b.host}:${toString b.port}"; };
      }) container.backends;
  };
}
