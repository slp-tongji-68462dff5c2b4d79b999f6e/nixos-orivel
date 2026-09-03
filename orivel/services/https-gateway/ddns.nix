{ container, lib, ... }:
{
  services.cloudflare-ddns = lib.mkIf (container.sites != {}) {
    enable = true;
    credentialsFile = "/etc/https-gateway/ddns.env";
    domains = map (host: host.domain) (lib.attrValues container.sites);
    provider.ipv4 = "local.iface:eth0";
    provider.ipv6 = "none";
  };
}
