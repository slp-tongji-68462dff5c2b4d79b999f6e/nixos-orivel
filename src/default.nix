{
  ...
}:
{
  imports = [
    # ./hardware
    ./parts
    ./nix
    ./openssh
  ];

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
  
  networking.hostName = "orivel";
  system.stateVersion = "26.05";
  
  boot.zswap.enable = true;
  swapDevices = [
    {
      device = "/swapfile";
      options = [ "discard" ];
    }
  ];
}
