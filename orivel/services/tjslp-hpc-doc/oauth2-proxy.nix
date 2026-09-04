{
  serviceConfigurations,
  pkgs,
  ...
}:
let
  stateDirectoryName = "tjslp-hpc-doc";
  cookieSecret = "/var/lib/${stateDirectoryName}/cookie-secret";
  ensureCookieSecret = pkgs.writeShellScript "ensure-cookie-secret" ''
    set -euo pipefail
    if [ ! -s "${cookieSecret}" ]; then
      "${pkgs.openssl}/bin/openssl" rand -hex 32 > "${cookieSecret}"
      "${pkgs.coreutils}/bin/chmod" 600 "${cookieSecret}"
    fi
  '';
  siteDir = pkgs.writeTextDir "index.html" ''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
      <meta charset="utf-8">
      <title>tjslp-hpc-doc</title>
    </head>
    <body>
      <h1>tjslp-hpc-doc 占位页</h1>
      <p>如果你能看到这个页面，说明 oauth2-proxy 的 OIDC 鉴权链路已打通。</p>
    </body>
    </html>
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
    trustedProxyIP = [ "127.0.0.1" "::1" ];

    redirectURL = serviceConfigurations.callback;
    cookie.secure = true;

    scope = "openid profile email groups";

    httpAddress = "127.0.0.1:${toString serviceConfigurations.port}";

    upstream = [ "file://${siteDir}#/" ];

    extraConfig = {
      "allowed-group" = [ "slp-tongji-68462dff5c2b4d79b999f6e:*" ];
      "cookie-secret-file" = cookieSecret;
    };
  };

  systemd.services.oauth2-proxy.serviceConfig = {
    StateDirectory = stateDirectoryName;
    ExecStartPre = "${ensureCookieSecret}";
  };
}
