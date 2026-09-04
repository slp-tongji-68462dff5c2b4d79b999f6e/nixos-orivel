{
  pkgs,
  serviceConfigurations,
  ...
}:
let
  sourceDirectory = "/var/lib/${serviceConfigurations.stateDirectoryName}/hugo/source";
  knownHosts = "/var/lib/${serviceConfigurations.stateDirectoryName}/hugo/known_hosts";

  script = pkgs.writeShellScript "tjslp-hpc-doc-pull-and-build" ''
    set -euo pipefail

    export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=${knownHosts} -i ${serviceConfigurations.deployKeyFile}"

    mkdir -p "$(dirname "${knownHosts}")"

    if [ ! -d "${sourceDirectory}/.git" ]; then
      ${pkgs.git}/bin/git clone \
        --depth 1 \
        --branch main \
        git@github.com:yueyinqiu/TjslpHpcHandbook.git \
        "${sourceDirectory}"
    else
      ${pkgs.git}/bin/git -C "${sourceDirectory}" fetch --depth 1 origin main
      ${pkgs.git}/bin/git -C "${sourceDirectory}" reset --hard FETCH_HEAD
    fi

    ${pkgs.git}/bin/git -C "${sourceDirectory}" submodule update --init --recursive

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
