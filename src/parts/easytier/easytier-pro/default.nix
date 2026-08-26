{ pkgs, ... }: {
  environment.etc."easytier/easytier-pro/configuration.env.example" = {
    source = ./configuration.env.example;
  };
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "easytier-cli-easytier-pro" ''
      easytier-cli --rpc-portal 127.0.0.1:31572 $@
    '')
  ];
  services.easytier.instances.easytier-pro = {
    configServer = "$CONFIG_SERVER";
    environmentFiles = [
      "/etc/easytier/easytier-pro/configuration.env"
    ];
    extraArgs = [
      "--rpc-portal=31572"
      "--secure-mode=true"
    ];
  };
}
