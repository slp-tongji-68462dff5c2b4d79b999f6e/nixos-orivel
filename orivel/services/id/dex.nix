{ serviceConfigurations, ... }:
let
  stateDirectoryName = "dex";
in
{
  services.dex = {
    enable = true;
    environmentFile = serviceConfigurations.environmentFile;
    settings = {
      issuer = "https://${serviceConfigurations.domain}";
      storage = {
        type = "sqlite3";
        config.file = "/var/lib/${stateDirectoryName}/dex.db";
      };
      web.http = "127.0.0.1:${toString serviceConfigurations.port}";
      connectors = [
        {
          type = "github";
          id = "github";
          name = "GitHub";
          config = {
            # https://github.com/organizations/slp-tongji-68462dff5c2b4d79b999f6e/settings/applications/3817467
            clientID = "Ov23liu7nBtgRFMngGX7";
            clientSecret = "$DEX_GITHUB_CLIENT_SECRET";
            redirectURI = "https://${serviceConfigurations.domain}/callback";
          };
        }
      ];
    };
  };
  systemd.services.dex.serviceConfig.StateDirectory = stateDirectoryName;
}
