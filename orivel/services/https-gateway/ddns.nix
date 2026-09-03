{ container, lib, ... }:
{
  services.cloudflare-ddns = lib.mkIf (container.backends != {}) {
    enable = true;
    credentialsFile = "/etc/https-gateway/ddns.env";
    domains = map (backend: backend.domain) (lib.attrValues container.backends);
    provider.ipv4 = "local.iface:eth0";
    provider.ipv6 = "none";
  };
}
