{ ... }: {
  services.easytier.enable = true;

  imports = [
    ./default
    ./easytier-pro
  ];
}
