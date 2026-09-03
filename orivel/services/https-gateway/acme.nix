{ container, lib, ... }:
{
  security.acme = {
    acceptTerms = true;
    certs =
      lib.mapAttrs' (name: backend: lib.nameValuePair backend.hostname {
        dnsProvider = "cloudflare";
        email = "yueyinqiu@outlook.com";
        domain = backend.hostname;
        environmentFile = "/etc/https-gateway/acme.env";
        group = "nginx";
        reloadServices = [ "nginx" ];
      }) container.backends;
  };
}
