{
  pkgs,
  serviceConfigurations,
  ...
}:
let
  hugoDirectory = "${serviceConfigurations.stateDirectoryName}/hugo";
  sourceDirectory = "/var/lib/${hugoDirectory}/source";
  deployRecordFile = "/var/lib/${hugoDirectory}/deployed";

  sshCommand = pkgs.writeShellScript "tjslp-hpc-doc-git-ssh" ''
    exec ${pkgs.openssh}/bin/ssh \
      -o StrictHostKeyChecking=accept-new \
      -o "UserKnownHostsFile=/var/lib/${hugoDirectory}/known_hosts" \
      -i "${serviceConfigurations.deployKeyFile}" \
      "$@"
  '';

  script = pkgs.writeShellScript "tjslp-hpc-doc-pull-and-build" ''
    set -euo pipefail

    export GIT_SSH_COMMAND="${sshCommand}"
    if [ ! -d "${sourceDirectory}/.git" ]; then
      "${pkgs.git}/bin/git" clone \
        git@github.com:yueyinqiu/TjslpHpcHandbook.git \
        "${sourceDirectory}"
    else
      "${pkgs.git}/bin/git" -C "${sourceDirectory}" fetch origin --tags --prune --prune-tags
    fi

    latestTag="$("${pkgs.git}/bin/git" -C "${sourceDirectory}" \
      for-each-ref --sort=-v:refname 'refs/tags/v*' \
      --format='%(refname:short)' \
      | "${pkgs.coreutils}/bin/head" -n 1)"
    target="$("${pkgs.git}/bin/git" -C "${sourceDirectory}" rev-parse "$latestTag")"

    if [ -f "${deployRecordFile}" ] \
      && [ "$("${pkgs.coreutils}/bin/cat" "${deployRecordFile}")" = "$target" ]; then
      exit 0
    fi

    "${pkgs.git}/bin/git" -C "${sourceDirectory}" reset --hard "$target"

    temp="$("${pkgs.coreutils}/bin/mktemp" -d -p "/var/lib/${hugoDirectory}")"
    "${pkgs.coreutils}/bin/chmod" 755 "$temp"
    "${pkgs.hugo}/bin/hugo" \
      --source "${sourceDirectory}" \
      --destination "$temp"

    "${pkgs.coreutils}/bin/printf" '%s' "$target" > "${deployRecordFile}"

    previous=""
    if [ -L "${serviceConfigurations.outputDirectory}" ]; then
      previous="$("${pkgs.coreutils}/bin/readlink" "${serviceConfigurations.outputDirectory}")"
    fi
    ln -sfn "$temp" "${serviceConfigurations.outputDirectory}"
    if [ -n "$previous" ]; then
      case "$previous" in
        "/var/lib/${hugoDirectory}"/*) rm -rf "$previous" ;;
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
      StateDirectory = hugoDirectory;
      ExecStart = "${script}";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };

  systemd.timers.tjslp-hpc-doc-update = {
    description = "Timer for tjslp-hpc-doc content update";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = 0;
      OnUnitActiveSec = "1min";
      Persistent = true;
    };
  };
}
