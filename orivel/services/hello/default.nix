{ ... }:
let
  port = 58951;
in
{
  services.https-gateway.sites.hello = {
    domain = "hello.example.com";
    upstream = "http://127.0.0.1:${toString port}";
  };

  containers.hello = {
    autoStart = true;
    privateNetwork = false;
    config = { ... }: {
      services.go-httpbin = {
        enable = true;
        settings.PORT = port;
      };
    };
  };
}
