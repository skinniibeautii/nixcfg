{ config, pkgs, lib, inputs, ... }:

	let

    hookScript = pkgs.writeScriptBin "hook" ''
      #!${pkgs.bash}/bin/bash
      echo "hello $1"
      whoami
    '';

    sshScript = pkgs.writeScriptBin "ssh-hook" ''
      #!${pkgs.bash}/bin/bash
      set -eu
      set -o pipefail
      [[ -z "''${SSH_ORIGINAL_COMMAND:-}" ]] && exit 1
      case "''${SSH_ORIGINAL_COMMAND}" in
        "hook"*)
          exec sudo ${lib.getExe hookScript} $*
          ;;
        *)
          echo "invalid command"
          exit 1
          ;;
      esac
    '';

  in {

    services.openssh.enable = true;

    services.openssh.extraConfig = ''
      Match User hook
        PasswordAuthentication no
        AllowAgentForwarding no
        AllowTcpForwarding no
        X11Forwarding no
        ForceCommand ${sshScript}/bin/ssh-hook
    '';

    users.users.hook = {
      isNormalUser = true;
      packages = [ hookScript ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA2CLOzyXcqk4uo6hCkkQAtozJCebA/Dh4ps6Vr2GVNTC7j7nF5HuT+penp/Y9yPAuTorxunmFn7BPwZggzopEgfmUQ4gf0CysTwPQMxt9yK3ZHpxgkGoJyR0n91OdPAbukqwWZHYxGGxvHNoap59kobUrIImIa97gKxW+IVKwL9iyWXyqonRpue1mf1N1ioDtPLS1yvzf4Jo7aDND+4I/34X6436VwZItUwzvhFcuNh/gQmvKpmVjD+ED2Q/yRtGq0EzsPfrDZg1ZKV5V1cT/3w7QtYFcZB9+AQxq88jVRcIlf3K45kpmbsWVfBFN6ND+NeZK1mlp/3TV8C6dNVqU2w== tcurdt@shodan.local"
      ];
    };

    security.sudo = {
      enable = true;
      extraRules = [{
        commands = [
          {
            #command = "${hookScript}/bin/hook";
            command = lib.getExe hookScript;
            options = [ "NOPASSWD" ];
          }
          {
            command = "/etc/profiles/per-user/hook/bin/hook";
            options = [ "NOPASSWD" ];
          }
        ];
        users = [ "hook" ];
      }];
    };

}
