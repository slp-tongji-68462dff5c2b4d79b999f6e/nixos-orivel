{ container, lib, ... }:
{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    virtualHosts =
      lib.mapAttrs' (name: site: lib.nameValuePair site.domain {
        useACMEHost = site.domain;
        forceSSL = true;
        locations."/" = { proxyPass = site.upstream; };
      }) container.sites;
  };
}
