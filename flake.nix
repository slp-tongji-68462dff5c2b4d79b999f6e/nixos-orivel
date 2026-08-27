{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-26.05";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
  };

  outputs = inputs: {
    nixosConfigurations.orivel =
      let
        system = "x86_64-linux";
      in
      inputs.nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = {
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
            pkgs.agenix-cli
          ];
        };
      }
    );
  };
}
