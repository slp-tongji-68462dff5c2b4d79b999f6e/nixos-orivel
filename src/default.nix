{
  agenix,
  ...
}:
{
  imports = [
    agenix.nixosModules.default

    ./agenix

    # ./hardware
    ./containers
    ./nix
    ./openssh
  ];

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "orivel";

  # Caddy (in a container using host networking) needs to accept inbound traffic.
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  system.stateVersion = "26.05";
}
