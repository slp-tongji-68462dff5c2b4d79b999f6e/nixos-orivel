# edge 手动步骤

## 1. 创建 secret 目录（宿主机）

```sh
sudo mkdir -p /var/lib/secrets
```

## 2. 放置 Cloudflare API token

一个文件，两行（ACME 读 `CLOUDFLARE_DNS_API_TOKEN`，cloudflare-ddns 读 `CLOUDFLARE_API_TOKEN`）：

- `/var/lib/secrets/cf_api.env` → 参照 `cf_api.env.sample`

权限：

```sh
sudo chmod 600 /var/lib/secrets/cf_api.env
```

## 3. 设基础配置

在 `edge/default.nix` 顶部的 `let` 里改（一次性）：

```nix
email = "you@example.com";       # ACME 联系邮箱
secretsDir = "/var/lib/secrets"; # 宿主机上的 secret 目录
```

## 4. 声明后端服务

在 `orivel/services/<名字>/default.nix` 里声明（会被 `services/default.nix` 自动导入）：

```nix
{ ... }:
{
  services.edge.backends.jellyfin = {
    hostname = "jellyfin.example.com";
    port = 8096;
    # host = "127.0.0.1";  # 默认 127.0.0.1（宿主机本地服务）；别的设备填其内网 IP
  };
}
```

配在这里的每个域名都会被本 edge 反代 + 签证书 + 维护 A 记录；不归本 edge 管的域名，不要配置在这里。

## 5. 应用

```sh
sudo nixos-rebuild switch
```

注意：`/var/lib/secrets` 在宿主机上，不在仓库内，不会进 git。
