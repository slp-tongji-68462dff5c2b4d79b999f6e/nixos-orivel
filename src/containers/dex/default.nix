{
  config,
  lib,
  ...
}:
let
  agenixLib = import ../../lib/agenix.nix { inherit lib; };
  domain = "dex.tjslp.yueyinqiu.top";
  port = 53678;

  secretInContainer = "/run/dex/github.env";
in
{
  orivel.caddy.reverseProxy.${domain} = "http://127.0.0.1:${toString port}";

  containers.dex = {
    autoStart = true;
    privateNetwork = false;

    bindMounts.${secretInContainer} = {
      hostPath = config.age.secrets.${agenixLib.agenixName ./environment.age}.path;
      isReadOnly = true;
    };

    config =
      { ... }:
      {
        services.dex = {
          enable = true;
          environmentFile = secretInContainer;

          settings = {
            issuer = "https://${domain}";

            storage = {
              type = "sqlite3";
              config.file = "/var/lib/dex/dex.db";
            };

            web.http = "127.0.0.1:${toString port}";
            oauth2.skipApprovalScreen = true;

            connectors = [
              {
                type = "github";
                id = "github";

                name = "GitHub";
                config = {
                  clientID = "$GITHUB_CLIENT_ID";
                  clientSecret = "$GITHUB_CLIENT_SECRET";
                  redirectURI = "https://${domain}/callback";

                  # Optional example restrictions:
                  # orgs = [ { name = "my-organization"; } ];
                  # loadAllGroups = false;
                  # teamNameField = "slug";
                };
              }
            ];
          };
        };
        system.stateVersion = "26.05";
      };
  };
}
