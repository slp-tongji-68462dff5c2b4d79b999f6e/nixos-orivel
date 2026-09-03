{ container, lib, ... }:
{
  security.acme = {
    acceptTerms = true;
    certs =
      lib.mapAttrs' (name: host: lib.nameValuePair host.domain {
        dnsProvider = "cloudflare";
        domain = host.domain;
        environmentFile = "/etc/https-gateway/acme.env";
        group = "nginx";
        reloadServices = [ "nginx" ];
      }) container.sites;
  };
}
