{ config, lib, ... }:
let
  email = "you@example.com";
  secretsDir = "/var/lib/secrets";
  edgeCfg = config.services.edge;
  compiledBackends =
    lib.mapAttrs (name: b:
      b // {
        upstream = "http://${b.host}:${toString b.port}";
      }
    ) edgeCfg.backends;
  domainNames = map (b: b.hostname) (lib.attrValues edgeCfg.backends);
in
{
  options.services.edge = {
    backends = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          hostname = lib.mkOption {
            type = lib.types.str;
            description = "公网域名";
          };
          port = lib.mkOption {
            type = lib.types.port;
            description = "后端监听端口";
          };
          host = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "后端地址；默认 127.0.0.1（宿主机本地服务），其他设备填其内网 IP";
          };
        };
      });
      default = { };
      description = "对外服务清单，各服务模块自行声明；配置在此处即反代 + 证书 + DDNS";
    };
  };

  config = {
    containers.edge = {
      autoStart = true;
      # 共享宿主网络，才能反代宿主机上 127.0.0.1 的服务
      privateNetwork = false;

      bindMounts."${secretsDir}" = {
        hostPath = secretsDir;
        isReadOnly = true;
      };

      specialArgs.edge = {
        inherit email secretsDir;
        backends = compiledBackends;
        domainNames = domainNames;
      };

      config = {
        imports = [
          ./proxy.nix
          ./ddns.nix
        ];
      };
    };
  };
}
