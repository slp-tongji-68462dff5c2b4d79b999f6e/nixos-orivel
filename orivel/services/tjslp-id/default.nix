{ ... }:
let
  port = 25621;
  environmentFileDirectory = "service-config/tjslp-id";
  environmentFileName = "dex.env";
  domain = "id.tjslp.yueyinqiu.top";
in
{
  services.https-gateway.sites.tjslp-id = {
    domain = domain;
    upstream = "http://127.0.0.1:${toString port}";
  };

  environment.etc."${environmentFileDirectory}/${environmentFileName}.sample".source = ./dex.env.sample;

  containers.tjslp-id = {
    autoStart = true;
    privateNetwork = false;

    bindMounts."/etc/${environmentFileDirectory}" = {
      hostPath = "/etc/${environmentFileDirectory}";
      isReadOnly = true;
    };
    
    specialArgs.serviceConfigurations = {
      environmentFile = "/etc/${environmentFileDirectory}/${environmentFileName}";
      port = port;
      domain = domain;
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
}
