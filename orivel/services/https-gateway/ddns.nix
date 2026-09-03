{ container, lib, ... }:
{
  services.cloudflare-ddns = lib.mkIf (container.backends != {}) {
    enable = true;
    credentialsFile = "/etc/https-gateway/ddns.env";
    domains = map (b: b.hostname) (lib.attrValues container.backends);
  };
}
