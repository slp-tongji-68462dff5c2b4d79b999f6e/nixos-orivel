{ config, lib, ... }:
{
  options.services.https-gateway = {
    backends = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          domain = lib.mkOption {
            type = lib.types.str;
            description = "域名";
          };
          host = lib.mkOption {
            type = lib.types.str;
            description = "后端地址；默认 127.0.0.1（宿主机本地服务），其他设备填其内网 IP";
          };
          port = lib.mkOption {
            type = lib.types.port;
            description = "后端监听端口";
          };
        };
      });
      default = { };
      description = "对外服务清单，各服务模块自行声明；配置在此处即反代 + 证书 + DDNS";
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
        backends = config.services.https-gateway.backends;
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
