1. 用 `ssh-keygen` 生成密钥对；
2. 在 https://github.com/yueyinqiu/TjslpHpcHandbook/settings/keys 添加公钥；
3. 将私钥放入 `/etc/service-config/tjslp-hpc-doc/key` ；
4. 设置权限 `chmod 600 /etc/service-config/tjslp-hpc-doc/key` （必须，否则会拒绝使用）。
