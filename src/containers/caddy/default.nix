{
  config,
  lib,
  ...
}:
{
  options.orivel.caddy.reverseProxy = lib.mkOption {
    type = with lib.types; attrsOf str;
    default = { };
    example = {
      "dex.tjslp.yueyinqiu.top" = "http://127.0.0.1:5556";
    };
  };

  config = {
    containers.caddy = {
      autoStart = true;
      privateNetwork = false;

      config =
        { ... }:
        {
          services.caddy = {
            enable = true;
            virtualHosts = lib.mapAttrs (host: upstream: {
              extraConfig = "reverse_proxy ${upstream}";
            }) config.orivel.caddy.reverseProxy;
          };
          system.stateVersion = "26.05";
        };
    };
  };
}
