{
  pkgs,
  serviceConfigurations,
  ...
}:
let
  hugoDirectory = "/var/lib/${serviceConfigurations.stateDirectoryName}/hugo";
  sourceDirectory = "${hugoDirectory}/source";

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

    # 记录切换前 public 指向的旧版本（symlink 本身就是“上一次的名字”）。
    old=""
    if [ -L "${serviceConfigurations.outputDirectory}" ]; then
      old="$(${pkgs.coreutils}/bin/readlink "${serviceConfigurations.outputDirectory}")"
    fi

    # 构建到唯一的临时目录（随机名字），完成后原子地把 public 符号链接切到新版本，
    # 避免访问者看到构建到一半的目录（否则会出现随机 404 / 资源不匹配）。
    tmp="$(${pkgs.coreutils}/bin/mktemp -d "${serviceConfigurations.outputDirectory}.tmp.XXXXXX")"
    ${pkgs.hugo}/bin/hugo \
      --source "${sourceDirectory}" \
      --destination "$tmp"

    ln -sfn "$tmp" "${serviceConfigurations.outputDirectory}"

    # 删除被切走的旧版本（只删我们自己生成的 public.tmp.* 目录）。
    if [ -n "$old" ] && [ "$old" != "$tmp" ]; then
      case "$old" in
        "${serviceConfigurations.outputDirectory}".tmp.*) rm -rf "$old" ;;
      esac
    fi
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
