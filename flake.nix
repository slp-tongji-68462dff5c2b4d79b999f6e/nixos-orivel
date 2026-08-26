{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    NixVirt = {
      url = "github:AshleyYakeley/NixVirt/v0.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
  };

  outputs = inputs: {
    nixosConfigurations.earth-latitude7490 =
      let
        system = "x86_64-linux";
      in
      inputs.nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = {
          nixvirt = inputs.NixVirt;
          nur = inputs.nur.legacyPackages.${system}.repos;
        };
        modules = [
          ./src
        ];
      };

    devShells = inputs.nixpkgs.lib.genAttrs inputs.nixpkgs.lib.systems.flakeExposed (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in
      {
        default = pkgs.mkShell {
          packages = [
            (pkgs.writeShellScriptBin "dev-switch-local-proxy" ''
              ssh localhost -t "cd '$PWD' && sudo all_proxy=socks5h://127.0.0.1:26290 nixos-rebuild switch --flake ."
            '')
          ];
        };
      }
    );
  };
}
