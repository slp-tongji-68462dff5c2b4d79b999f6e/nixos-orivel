ACME 和 DDNS 都使用 Cloudflare 完成，需要把域名托管给 Cloudflare ，并且在以下文件配置 Key ：
- `/etc/https-gateway/acme.env`
- `/etc/https-gateway/ddns.env`

注意调整文件权限：

```sh
sudo chmod 600 /etc/https-gateway/acme.env /etc/https-gateway/ddns.env
```

如果网络硬件变更，注意调整 ddns 的 `provider.ipv4` 到对应网卡。
