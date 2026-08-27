{ config, ... }:
let
  # Decrypt on the host, mount into the container.
  secretName = "easytier-network-secret-env";
  secretInContainer = "/run/easytier.env";
in
{
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets.${secretName}.file = ./network-secret.env.age;

  containers.easytier = {
    autoStart = true;

    enableTun = true;
    additionalCapabilities = [
      "CAP_NET_ADMIN"
      "CAP_NET_RAW"
    ];

    bindMounts.${secretInContainer} = {
      hostPath = config.age.secrets.${secretName}.path;
      isReadOnly = true;
    };
    
    config = { ... }: {
      services.easytier.enable = true;

      # Match configuration.toml.example, but keep network_secret out of plaintext.
      services.easytier.instances.default = {
        environmentFiles = [ secretInContainer ];
        settings = {
          ipv4 = "10.126.126.1/24";
          listeners = [ ];
          network_name = "xxxxxxxxxxxxxxx";
          # network_secret is provided via ET_NETWORK_SECRET in environmentFiles.
          peers = [
            "tcp://161.33.207.13:51010"
            "tcp://et-hk.clickor.click:11010"
            "tcp://us01.225284.xyz:11010"
            "tcp://225284.xyz:11010"
            "tcp://183.230.36.171:11010"
            "tcp://easytier.weiai.org.cn:11010"
            "txt://net.qicwken.top"
            "wss://et.chinokou.cn"
          ];
        };
        extraSettings = {
          tcp_whitelist = [ ];
          udp_whitelist = [ ];
          flags.dev_name = "et-default";
        };
      };

      system.stateVersion = "26.05";
    };
  };
}
