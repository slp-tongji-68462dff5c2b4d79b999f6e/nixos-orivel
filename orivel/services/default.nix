{ ... }: {
  imports =
    let
      dir = builtins.readDir ./.;
      hasDefault = name: builtins.pathExists (./. + "/${name}/default.nix");
      subdirs = builtins.filter (name: dir.${name} == "directory" && hasDefault name) (
        builtins.attrNames dir
      );
    in
    map (name: ./. + "/${name}") subdirs;
}
