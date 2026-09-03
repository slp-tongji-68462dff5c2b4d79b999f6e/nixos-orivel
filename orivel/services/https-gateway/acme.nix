{ container, lib, ... }:
{
  environment.etc."https-gateway/acme.env.sample".source = ./acme.env.sample;
  
  security.acme = {
    acceptTerms = true;
    certs =
      lib.mapAttrs' (name: b: lib.nameValuePair b.hostname {
        dnsProvider = "cloudflare";
        email = "yueyinqiu@outlook.com";
        domain = b.hostname;
        environmentFile = "/etc/https-gateway/acme.env";
        group = "nginx";
        reloadServices = [ "nginx" ];
      }) container.backends;
  };
}
