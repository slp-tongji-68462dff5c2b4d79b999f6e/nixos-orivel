{ container, lib, ... }:
{
  services.cloudflare-ddns = lib.mkIf (container.sites != {}) {
    enable = true;
    credentialsFile = "/etc/https-gateway/ddns.env";
    domains = map (site: site.domain) (lib.attrValues container.sites);
    provider.ipv4 = "local.iface:eth0";
    provider.ipv6 = "none";
  };
  # https://github.com/NixOS/nixpkgs/pull/505505#issuecomment-4193234755
  systemd.services.cloudflare-ddns.serviceConfig.RestrictAddressFamilies = [ "AF_NETLINK" ];
}
