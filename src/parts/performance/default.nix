{
  ...
}:
{
  services.auto-cpufreq.enable = true;
  services.thermald.enable = true;
  boot.zswap.enable = true;
  swapDevices = [
    {
      device = "/swapfile";
      options = [ "discard" ];
    }
  ];
}
