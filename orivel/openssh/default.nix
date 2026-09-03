{
  ...
}:
{
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    # yueyinqiu@earth-latitude-7490
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKc1wIB537oVrGzzolKRX1Yfp0fKoUSg4pQRFxiUZyDF"
  ];
}
