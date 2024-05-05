{ nixpkgs, hostName, hostPlatform, impermanence, ... } @ inputs: let

  pkgs = nixpkgs.legacyPackages.${hostPlatform};

in nixpkgs.lib.nixosSystem {

  specialArgs = { inherit inputs; };

  modules = [

    # inputs.nixos-generators.nixosModules.all-formats
    # inputs.release-go.nixosModules.default

    ../hardware/contabo.nix
    ../modules/server.nix
    ../modules/users.nix

    ../modules/docker.nix
    # ../modules/podman.nix
    # ../modules/k3s.nix
    # ../modules/rke2.nix

    # ../modules/telegraf.nix
    # ../modules/db-influx.nix

    # ../modules/db-postgres.nix
    # ../modules/redis.nix

    # ../modules/zerotierone.nix
    # ../modules/tailscale.nix

    # ../modules/hook-ssh.nix
    # ../modules/hook-web.nix

    # ../modules/backup.nix

    {
      nixpkgs.hostPlatform = hostPlatform;
      networking.hostName = hostName;
      networking.domain = "nixos";
      system.stateVersion = "23.11";
      # system.stateVersion = "24.05";
    }

    ../users/root.nix
    ../users/tcurdt.nix
    # ../users/ops.nix
    # {
    #   ops.keyFiles = [
    #     ../keys/tcurdt.pub
    #   ];
    # }

    # {
    #   users.users.root.password = "secret";
    # }

    # {
    #   services.release-go = {
    #     enable = true;
    #     port = 2020;
    #   };
    # }

    {
      networking.firewall.allowedTCPPorts = [ 80 443 ];
    }

    {
      services.caddy = {
        enable = true;
        email = "tcurdt@vafer.org";
        globalConfig = ''
          admin 127.0.0.1:2019
          servers { metrics }
          # acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
        '';

        virtualHosts."dev.vafer.org" = {
          extraConfig = ''
            reverse_proxy http://127.0.0.1:8888
          '';
        };

        virtualHosts."auth.vafer.org" = {
          extraConfig = ''
            reverse_proxy http://127.0.0.1:9999
          '';
        };

        virtualHosts."mailings.vafer.org" = {
          extraConfig = ''
            reverse_proxy http://127.0.0.1:4000
          '';
        };

        virtualHosts."stats.vafer.org" = {
          extraConfig = ''
            reverse_proxy http://127.0.0.1:3000
          '';
        };

        virtualHosts."red.vafer.org" = {
          extraConfig = ''
            @auth not path /public/*
            forward_auth @auth 127.0.0.1:9999 {
              uri /
            }
            reverse_proxy http://127.0.0.1:1880
          '';
        };

        # virtualHosts."metrics.vafer.org" = {
        #   extraConfig = ''
        #     import auth
        #     reverse_proxy http://influxdb:8086
        #   '';
        # };

        # virtualHosts."foo.vafer.org" = {
        #   extraConfig = ''
        #     basicauth bcrypt Elasticsearch {
        #       import elasticsearch.auth
        #     }
        #     basicauth {
        #       # Username "Bob", password "hiccup"
        #       Bob $2a$14$Zkx19XLiW6VYouLHR5NmfOFU0z2GTNmpkT/5qqR7hx4IjWJPDhjvG
        #     }
        #     forward_auth 127.0.0.1:9091 {
        #       uri /api/verify?rd=https://auth.vafer.org
        #       copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
        #     }
        #     reverse_proxy 127.0.0.1:2015
        #     reverse_proxy echo1.default.svc.cluster.local:80
        #   '';
        # };

      };
    }

    # {
    #   virtualisation.oci-containers.containers = {

    #     test = {
    #       image = "ghcr.io/tcurdt/test-project";
    #       ports = [ "127.0.0.1:2015:2015" ];
    #       #environment = {
    #       #  PASSWORD = "foo";
    #       #};
    #       environmentFiles = [
    #         /run/credentials/live.password
    #       ];
    #       # extraOptions = [
    #       #   "--network=testing"
    #       # ];
    #       login = {
    #         registry = "ghcr.io";
    #         username = "tcurdt";
    #         passwordFile = "/run/credentials/registry.github";
    #       };
    #     };

    #     test2 = {
    #       image = "ghcr.io/tcurdt/test-project";
    #       ports = [ "127.0.0.1:2016:2016" ];
    #       environment = {
    #         URL = "https://127.0.0.1:2015/version";
    #       };
    #       environmentFiles = [
    #         /run/credentials/live.password
    #       ];
    #       # extraOptions = [
    #       #  "--network=testing"
    #       # ];
    #       login = {
    #         registry = "ghcr.io";
    #         username = "tcurdt";
    #         passwordFile = "/run/credentials/registry.github";
    #       };
    #     };

    #   };
    # }

    ../modules/db-influx.nix

    {
      services.telegraf = {
        enable = true;
        environmentFiles = [ "/secrets/telegraf.env" ];
        extraConfig = {
          global_tags = {
            dc = "contabo";
          };
          agent = {
            interval = "30s";
            hostname = "app";
          };
          inputs = {
            internal = {
              namepass = [ "internal_agent" ];
            };
            mem = [{}];
            cpu = [{
              # taginclude = { cpu = [ "cpu-total" ]; };
              # fieldpass = [ "cpu-total" ];
            }];
            disk = [{ mount_points = [ "/" ]; }];

            # linux_cpu = {};
            # swap = [{}]; # covered in mem
            # kernel = [{}];
            # system = [{}];
            # sysstat = [{}];
            # processes = [{}];
            # procstat = [{}];
            # interrupts = [{}];
            # conntrack = [{}];
            # net = [{}];
            # netstat = [{}];
            # diskio = [{}];

            prometheus = [{
              metric_version = 2;
              urls = [
                "http://127.0.0.1:2019/metrics" # caddy
              ];
              fieldpass = [ "caddy_*" "process_*" ];
            }];

            # postgresql = [{
            #   interval =
            #   address = "host=localhost user=postgres sslmode=disable";
            #   ignored_databases = [
            #     "postgres"
            #     "template0"
            #     "template1"
            #   ];
            # }];

            redis = [{
              servers = [ "tcp://127.0.0.1:6379" ];
              # fieldinclude = [ "keyspace_*" "used_*" "tracking_*" "io_threaed_*" ];
            }];

            # x509_cert = [{
            #   interval =
            #   sources = [
            #     tcp://api.vafer.org:443
            #     tcp://ntfy.vafer.org:443
            #   ];
            # }];

            docker = [{
              endpoint = "unix:///var/run/docker.sock";
              perdevice = false;
              perdevice_include = ["cpu"];
              docker_label_include = [];
              docker_label_exclude = [];
            }];
          };

          outputs = {

            influxdb_v2 = [{
              urls = [ "http://127.0.0.1:8086" ];
              organization = "system";
              bucket = "metrics";
              token = "\${INFLUX_TELEGRAF_TOKEN}";
              insecure_skip_verify = true;
            }];

            health = [{
              service_address = "http://127.0.0.1:8888";
            }];
          };
        };
      };
    }
  ];
}
