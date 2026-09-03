{ container, lib, ... }:
{
  security.acme = {
    acceptTerms = true;
    certs =
      lib.mapAttrs' (name: backend: lib.nameValuePair backend.domain {
        dnsProvider = "cloudflare";
        domain = backend.domain;
        environmentFile = "/etc/https-gateway/acme.env";
        group = "nginx";
        reloadServices = [ "nginx" ];
      }) container.backends;
  };
}
