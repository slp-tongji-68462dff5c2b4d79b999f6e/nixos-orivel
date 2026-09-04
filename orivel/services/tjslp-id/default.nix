{
  config,
  lib,
  pkgs,
  ...
}:
let
  port = 25621;
  configurationDirectory = "service-config/tjslp-id";
  dexSecret = "dex.env";
  domain = "id.tjslp.yueyinqiu.top";
  clientSecrets = "/etc/${configurationDirectory}/client-secrets";
in
{
  options.services.tjslp-id.clients = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }: {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "名称";
            };
            callbacks = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              description = "回调地址";
            };
            secretFile = lib.mkOption {
              type = lib.types.str;
              readOnly = true;
              default = "${clientSecrets}/${name}.raw";
              description = "secret 文件";
            };
            secretEnvironmentFile = lib.mkOption {
              type = lib.types.str;
              readOnly = true;
              default = "${clientSecrets}/${name}.env";
              description = "secret 文件（环境变量形式）";
            };
          };
        }
      )
    );
    default = { };
  };

  config = {
    services.https-gateway.sites.tjslp-id = {
      domain = domain;
      upstream = "http://127.0.0.1:${toString port}";
    };

    environment.etc."${configurationDirectory}/${dexSecret}.sample".source = ./dex.env.sample;

    # 生成各 client 的随机 secret（仅当文件不存在时）。放 activation 里：
    # nixos-rebuild switch 和开机时都跑，且早于所有服务/容器（secret 本质是 build 的一部分，只是 nix 做不了随机）
    system.activationScripts.tjslp-id-client-secrets = {
      text = lib.concatMapStringsSep "\n" (client: ''
        install -d -m 700 "${clientSecrets}"

        if [ ! -s "${client.secretFile}" ]; then
          ${pkgs.openssl}/bin/openssl rand -hex 32 | ${pkgs.coreutils}/bin/tr -d '\n' > "${client.secretFile}"
          chmod 600 "${client.secretFile}"
        fi

        printf 'TJSLP_ID_CLIENT_SECRET=%s\n' "$(cat "${client.secretFile}")" > "${client.secretEnvironmentFile}"
        chmod 600 "${client.secretEnvironmentFile}"
      '') (lib.attrValues config.services.tjslp-id.clients);
    };

    containers.tjslp-id = {
      autoStart = true;
      privateNetwork = false;

      bindMounts."/etc/${configurationDirectory}" = {
        hostPath = "/etc/${configurationDirectory}";
        isReadOnly = true;
      };

      specialArgs.serviceConfigurations = {
        environmentFile = "/etc/${configurationDirectory}/${dexSecret}";
        port = port;
        domain = domain;
        clients = config.services.tjslp-id.clients;
      };

      config = {
        imports = [
          ./dex.nix
        ];
        system.stateVersion = "26.05";
      };

      # useHostResolvConf 底层是复制 resolv.conf ，有时序问题，可能在宿主 resolv.conf 还未创建时复制，这里改为手动 mount
      # https://github.com/NixOS/nixpkgs/issues/162686#issuecomment-3295385984
      bindMounts."/etc/resolv.conf" = {
        hostPath = "/etc/resolv.conf";
        isReadOnly = true;
      };
      config.networking.resolvconf.enable = false;
    };
  };
}
