let
  keys = [
    # yueyinqiu@earth-latitude-7490
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKc1wIB537oVrGzzolKRX1Yfp0fKoUSg4pQRFxiUZyDF"
  ];

  root = builtins.path {
    path = ./src;
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
          path = "${prefix}${name}";
        in
        if type == "directory" then
          listAgeFiles (directory + "/${name}") (path + "/")
        else if (type == "regular") && builtins.match ".*\\.age$" name != null then
          [ path ]
        else
          [ ];
    in
    builtins.concatLists (map collect names);

  ageFiles = listAgeFiles root "src/";
in
builtins.listToAttrs (
  map (p: {
    name = p;
    value = {
      publicKeys = keys;
    };
  }) ageFiles
)
