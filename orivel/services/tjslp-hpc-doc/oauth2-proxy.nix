{
  serviceConfigurations,
  pkgs,
  ...
}:
let
  cookieSecret = "/var/lib/${serviceConfigurations.stateDirectoryName}/oauth2-proxy/cookie-secret";
  ensureCookieSecret = pkgs.writeShellScript "ensure-cookie-secret" ''
    set -euo pipefail
    if [ ! -s "${cookieSecret}" ]; then
      "${pkgs.openssl}/bin/openssl" rand -base64 32 | \
        "${pkgs.coreutils}/bin/tr" -- '+/' '-_' | \
        "${pkgs.coreutils}/bin/tr" -d '\n' > \
        "${cookieSecret}"
      "${pkgs.coreutils}/bin/chmod" 600 "${cookieSecret}"
    fi
  '';
in
{
  services.oauth2-proxy = {
    enable = true;
    provider = "oidc";
    oidcIssuerUrl = "https://id.tjslp.yueyinqiu.top";

    clientID = "hpc-doc";
    clientSecretFile = serviceConfigurations.oidcSecret;

    reverseProxy = true;
    trustedProxyIP = [
      "127.0.0.1"
      "::1"
    ];

    redirectURL = serviceConfigurations.callback;
    cookie.secure = true;

    scope = "openid profile email groups";

    email.domains = [ "*" ];

    httpAddress = "127.0.0.1:${toString serviceConfigurations.port}";

    upstream = [
      "file://${serviceConfigurations.outputDirectory}#/"
    ];

    extraConfig = {
      "cookie-secret-file" = cookieSecret;
      "skip-provider-button" = true;
    };
  };

  systemd.services.oauth2-proxy.serviceConfig = {
    StateDirectory = serviceConfigurations.stateDirectoryName;
    ExecStartPre = "${ensureCookieSecret}";
  };
}
