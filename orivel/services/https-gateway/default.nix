{ config, lib, ... }:
{
  options.services.https-gateway = {
    sites = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          domain = lib.mkOption {
            type = lib.types.str;
            description = "访问服务时要使用的域名（域名会放在公网 DNS ，并解析出校园网地址）";
          };
          upstream = lib.mkOption {
            type = lib.types.str;
            description = "反代上游，如 http://127.0.0.1:8096";
          };
        };
      });
      default = { };
    };
  };

  config = {
    environment.etc."https-gateway/acme.env.sample".source = ./acme.env.sample;
    environment.etc."https-gateway/ddns.env.sample".source = ./ddns.env.sample;

    containers.https-gateway = {
      autoStart = true;
      privateNetwork = false;

      bindMounts."/etc/https-gateway" = {
        hostPath = "/etc/https-gateway";
        isReadOnly = true;
      };

      # useHostResolvConf 有时序问题，改为手动 mount
      # 容器内另外禁用了 networking.resolvconf.enable （以避免尝试修改 resolv.conf ，同时也隐式禁用 useHostResolvConf ）
      # https://github.com/NixOS/nixpkgs/issues/162686#issuecomment-3295385984
      bindMounts."/etc/resolv.conf" = {
        hostPath = "/etc/resolv.conf";
        isReadOnly = true;
      };

      specialArgs.container = {
        sites = config.services.https-gateway.sites;
      };

      config = {
        imports = [
          ./acme.nix
          ./nginx.nix
          ./ddns.nix
        ];
        system.stateVersion = "26.05";
        networking.resolvconf.enable = false;
      };
    };
  };
}
