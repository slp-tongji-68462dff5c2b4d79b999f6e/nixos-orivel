let
  keys = [
    # yueyinqiu@earth-latitude-7490
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKc1wIB537oVrGzzolKRX1Yfp0fKoUSg4pQRFxiUZyDF"
  ];

  allFiles = builtins.filter (p: builtins.isPath p) (builtins.filesystem.listFilesRecursive ./.);

  ageFiles = builtins.filter (p: builtins.match ".*\\.age$" (toString p) != null) allFiles;
  toRelPath = p: builtins.substring (builtins.stringLength (toString ./.) + 1) (-1) (toString p);
in
builtins.listToAttrs (map (p: {
  name = toRelPath p;
  value = { publicKeys = keys; };
}) ageFiles)