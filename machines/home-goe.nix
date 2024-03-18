{ nixpkgs, hostName, hostPlatform, impermanence, ... } @ inputs: let

  pkgs = nixpkgs.legacyPackages.${hostPlatform};

in nixpkgs.lib.nixosSystem {

  specialArgs = { inherit inputs; };

  modules = [

    # inputs.nixos-generators.nixosModules.all-formats

    # inputs.release-go.nixosModules.default

    ../hardware/home.nix
    ../modules/server.nix
    ../modules/users.nix

    # ../modules/telegraf.nix
    ../modules/db-influx.nix
    ../modules/homeassistant.nix

    ../modules/zerotierone.nix
    # ../modules/tailscale.nix

    {
      nixpkgs.hostPlatform = hostPlatform;
      networking.hostName = hostName;
      networking.domain = "home";
      system.stateVersion = "23.11";
      # system.stateVersion = "24.05";
    }

    ../users/root.nix
    ../users/tcurdt.nix

    # {
    #   users.users.root.password = "secret";
    # }

    {
      networking.firewall.allowedTCPPorts = [ 80 443 ];
      services.caddy = {
        enable = true;

        # curl -k --resolve ntfy.vafer.org:443:127.0.0.1 https://ntfy.vafer.org

        virtualHosts."homeassistant.home" = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:2020
            tls internal
          '';
        };

      };
    }

  ];
}