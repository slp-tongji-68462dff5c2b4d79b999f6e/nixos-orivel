{ lib, ... }:

let
  agenixLib = import ../lib/agenix.nix { inherit lib; };
  root = builtins.path {
    path = ./..;
    name = "orivel-src";
  };
  listAgeFiles =
    directory: prefix:
    let
      entries = builtins.readDir directory;
      names = builtins.attrNames entries;
      collect =
        name:
        let
          type = entries.${name};
          rel = "${prefix}${name}";
        in
        if type == "directory" then
          listAgeFiles (directory + "/${name}") (rel + "/")
        else if (type == "regular") && builtins.match ".*\\.age$" name != null then
          [ rel ]
        else
          [ ];
    in
    builtins.concatLists (map collect names);

  ageFiles = listAgeFiles root "src/";
in
{
  config.age.secrets = builtins.listToAttrs (
    map (rel: {
      name = agenixLib.agenixName (root + "/${rel}");
      value.file = root + "/${rel}";
    }) ageFiles
  );
}
