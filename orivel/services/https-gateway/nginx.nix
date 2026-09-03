{ container, lib, ... }:
{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    virtualHosts =
      lib.mapAttrs' (name: host: lib.nameValuePair host.domain {
        useACMEHost = host.domain;
        forceSSL = true;
        locations."/" = { proxyPass = host.upstream; };
      }) container.sites;
  };
}
