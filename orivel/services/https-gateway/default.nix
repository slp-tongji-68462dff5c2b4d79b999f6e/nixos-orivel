{ config, lib, ... }:
{
  options.services.https-gateway = {
    sites = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          domain = lib.mkOption {
            type = lib.types.str;
            description = "公网域名";
          };
          upstream = lib.mkOption {
            type = lib.types.str;
            description = "反代上游，如 http://127.0.0.1:8096";
          };
        };
      });
      default = { };
      description = "对外暴露的域名清单，各服务模块自行声明；配置在此处即反代 + 证书 + DDNS";
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
