{
  pkgs,
  serviceConfigurations,
  ...
}:
let
  hugoDirectory = "/var/lib/${serviceConfigurations.stateDirectoryName}/hugo";
  sourceDirectory = "${hugoDirectory}/source";

  # 给 git 用的 ssh 包装脚本：git 通过 GIT_SSH_COMMAND 调用它，它再调用 ssh 并带上指定参数。
  sshCommand = pkgs.writeShellScript "tjslp-hpc-doc-git-ssh" ''
    exec ${pkgs.openssh}/bin/ssh \
      -o StrictHostKeyChecking=accept-new \
      -o "UserKnownHostsFile=${hugoDirectory}/known_hosts" \
      -i "${serviceConfigurations.deployKeyFile}" \
      "$@"
  '';

  script = pkgs.writeShellScript "tjslp-hpc-doc-pull-and-build" ''
    set -euo pipefail

    mkdir -p "${hugoDirectory}"

    export GIT_SSH_COMMAND="${sshCommand}"

    if [ ! -d "${sourceDirectory}/.git" ]; then
      "${pkgs.git}/bin/git" clone \
        --depth 1 \
        --branch main \
        git@github.com:yueyinqiu/TjslpHpcHandbook.git \
        "${sourceDirectory}"
    else
      "${pkgs.git}/bin/git" -C "${sourceDirectory}" fetch --depth 1 origin main
      "${pkgs.git}/bin/git" -C "${sourceDirectory}" reset --hard FETCH_HEAD
    fi

    mkdir -p "${serviceConfigurations.outputDirectory}"
    ${pkgs.hugo}/bin/hugo \
      --source "${sourceDirectory}" \
      --destination "${serviceConfigurations.outputDirectory}"
  '';
in
{
  systemd.services.tjslp-hpc-doc-update = {
    description = "Pull and build Tjslp HPC Handbook";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      StateDirectory = serviceConfigurations.stateDirectoryName;
      ExecStart = "${script}";
    };
  };

  systemd.timers.tjslp-hpc-doc-update = {
    description = "Timer for tjslp-hpc-doc content update";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
  };
}
