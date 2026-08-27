let
  authorizedKeys = [
    # yueyinqiu
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKc1wIB537oVrGzzolKRX1Yfp0fKoUSg4pQRFxiUZyDF"

    # 以下密钥是 glass-break 密钥，用以避免所有私钥均丢失导致 age 文件无法访问。
    # 私钥提供在 GitHub 仓库的 agenix-glass-break 环境中。
    # 必要时，可以在 GitHub Action 中使用它，调用 agenix --rekey 来添加新的可信密钥。
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIMMiZs+QRQsjtGtvBqOH5A8HDKzjbXgkodjfGiRhVy0"
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
      publicKeys = authorizedKeys;
    };
  }) ageFiles
)
// {
  "sample-secret.age".publicKeys = authorizedKeys;
}
