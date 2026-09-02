{
  ...
}:
{
  imports = [
    # ./hardware
    ./services
    ./nix
    ./openssh
  ];

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "orivel";
  system.stateVersion = "26.05";
}
