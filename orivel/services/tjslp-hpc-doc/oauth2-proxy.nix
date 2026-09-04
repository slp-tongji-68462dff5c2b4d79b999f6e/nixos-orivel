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
    # oauth2-proxy 用 URL-safe base64 解码 cookie secret（解码后须为 16/24/32 字节）；
    # 生成 32 随机字节并转成 URL-safe base64（无 `+/`、无尾随换行）。
    if [ ! -s "${cookieSecret}" ]; then
      "${pkgs.openssl}/bin/openssl" rand -base64 32 | "${pkgs.coreutils}/bin/tr" -- '+/' '-_' | "${pkgs.coreutils}/bin/tr" -d '\n' > "${cookieSecret}"
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

    email.domains = [ "*" ];

    httpAddress = "127.0.0.1:${toString serviceConfigurations.port}";

    upstream = [ "file://${siteDir}#/" ];

    extraConfig = {
      "cookie-secret-file" = cookieSecret;
      # 访问受保护路径时直接重定向到 IdP，不显示默认的 sign-in 按钮页。
      "skip-provider-button" = true;
    };
  };

  systemd.services.oauth2-proxy.serviceConfig = {
    StateDirectory = stateDirectoryName;
    ExecStartPre = "${ensureCookieSecret}";
  };
}
