{ edge, lib, ... }:
let
  domainNames = map (b: b.hostname) (lib.attrValues edge.backends);
in
{
  security.acme = lib.mkIf (domainNames != []) {
    acceptTerms = true;
    defaults.email = edge.email;
    certs.edge = {
      domain = builtins.head domainNames;
      extraDomainNames = builtins.tail domainNames;
      dnsProvider = "cloudflare";
      environmentFile = "${edge.secretsDir}/cf_api.env";
      group = "nginx";
      reloadServices = [ "nginx" ];
    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    virtualHosts =
      lib.mapAttrs' (name: b: lib.nameValuePair b.hostname {
        useACMEHost = "edge";
        forceSSL = true;
        locations."/" = { proxyPass = b.upstream; };
      }) edge.backends;
  };
}
