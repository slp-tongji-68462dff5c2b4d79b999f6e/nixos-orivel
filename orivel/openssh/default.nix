{
  ...
}:
{
  services.openssh.enable = true;
  # 没有 password 会导致容器里没有身份。不知道为什么。
  users.users.root.initialPassword = "123456";
  users.users.root.openssh.authorizedKeys.keys = [
    # yueyinqiu@earth-latitude-7490
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKc1wIB537oVrGzzolKRX1Yfp0fKoUSg4pQRFxiUZyDF"
  ];
}
