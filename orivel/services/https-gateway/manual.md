# https-gateway 手动步骤

## 1. 放置 Cloudflare API token

两个文件，各一个 key：

- `/etc/https-gateway/acme.env`（ACME 读 `CLOUDFLARE_DNS_API_TOKEN`）
- `/etc/https-gateway/ddns.env`（cloudflare-ddns 读 `CLOUDFLARE_API_TOKEN`）

模板已由 `environment.etc` 软链到 `/etc/https-gateway/*.env.sample`（首次 rebuild 后可见），复制并填入 token：

```sh
sudo cp /etc/https-gateway/acme.env.sample /etc/https-gateway/acme.env
sudo cp /etc/https-gateway/ddns.env.sample /etc/https-gateway/ddns.env
sudo chmod 600 /etc/https-gateway/acme.env /etc/https-gateway/ddns.env
# 编辑这两个文件，把 REPLACE_ME... 换成真实 token
```

（首次部署前模板还没被 link，也可直接从仓库的 `acme.env.sample`、`ddns.env.sample` 复制。）

## 2. 设基础配置

- ACME 邮箱：写在 `https-gateway/acme.nix` 的 `email`（想给不同域名用不同邮箱，再下沉到 backend 选项）。

## 3. 声明后端服务

在 `orivel/services/<名字>/default.nix` 里声明（会被 `services/default.nix` 自动导入）：

```nix
{ ... }:
{
  services.https-gateway.backends.jellyfin = {
    hostname = "jellyfin.example.com";
    port = 8096;
    # host = "127.0.0.1";  # 默认 127.0.0.1（宿主机本地服务）；别的设备填其内网 IP
  };
}
```

配在这里的每个域名都会被本 gateway 反代 + 签证书 + 维护 A 记录；不归本 gateway 管的域名，不要配置在这里。

## 4. 应用

```sh
sudo nixos-rebuild switch
```

注意：`/etc/https-gateway/acme.env`、`/etc/https-gateway/ddns.env` 是手动放置的文件，不进 git；`*.env.sample` 是模板（无真实 token），进 git。
