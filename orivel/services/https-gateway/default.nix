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

      specialArgs.container = {
        sites = config.services.https-gateway.sites;
      };

      config = {
        imports = [
          ./acme.nix
          ./nginx.nix
          ./ddns.nix
        ];
      };
    };
  };
}
