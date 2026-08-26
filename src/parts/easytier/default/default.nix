{ pkgs, ... }: {
  environment.etc."easytier/default/configuration.toml.example" = {
    source = ./configuration.toml.example;
  };
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "easytier-cli-default" ''
      easytier-cli --rpc-portal 127.0.0.1:61204 "$@"
    '')
  ];
  services.easytier.instances.default = {
    configFile = "/etc/easytier/default/configuration.toml";
    extraArgs = [
      "--rpc-portal=127.0.0.1:61204"
    ];
  };
}
