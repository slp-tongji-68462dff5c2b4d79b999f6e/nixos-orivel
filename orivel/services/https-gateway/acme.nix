{ container, lib, ... }:
{
  security.acme = {
    acceptTerms = true;
    certs =
      lib.mapAttrs' (name: site: lib.nameValuePair site.domain {
        dnsProvider = "cloudflare";
        domain = site.domain;
        environmentFile = "/etc/https-gateway/acme.env";
        group = "nginx";
        reloadServices = [ "nginx" ];
      }) container.sites;
  };
}
