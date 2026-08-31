{ ... }:
let
  domain = "dex.tjslp.yueyinqiu.top";
  port = 53678;
in
{
  orivel.caddy.reverseProxy.${domain} = "http://127.0.0.1:${port}";

  containers.dex = {
    autoStart = true;
    privateNetwork = false;

    config =
      { ... }:
      {
        services.dex = {
          enable = true;

          settings = {
            issuer = "https://${domain}";

            storage = {
              type = "sqlite3";
              config.file = "/var/lib/dex/dex.db";
            };

            web.http = "127.0.0.1:${port}";
            oauth2.skipApprovalScreen = true;

            connectors = [
              {
                type = "github";
                id = "github";

              }
            ];
          };
        };
        system.stateVersion = "26.05";
      };
  };
}
