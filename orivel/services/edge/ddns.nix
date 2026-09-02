{ edge, lib, ... }:
{
  services.cloudflare-ddns = lib.mkIf (edge.domainNames != []) {
    enable = true;
    credentialsFile = "${edge.secretsDir}/cf_api.env";
    domains = edge.domainNames;
  };
}
