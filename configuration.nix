{ config, lib, pkgs, ... }:
let
  username = "max";
  pubkeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChvjHy0zchvYYpZ5qja4BA9c53A26iVlbQ2oNFiOLyQYmMztJXGfSXATXzI6tVQm0zS8B7c+0+6DzTILlL514oNJ5Qyf5FLhQqts/4bd/o9f0NMDcH2QV++zosHvc+xFZmYAnq/iScR01BkIi5QrashZEd3hIlRNKec73ZPtdV62OUG/SaBs4KVvl2ZleT9qAQ1r3FfvNDUKbDGmj912yoTyHfdz+3snH+nbpV8sF6nkznQZvnPrQNqlo0LMctwdXENiZLipybpwzZgUjO14+ItSD/+zMeBa5Y6TMNynheSNSWbPi1SttBcq3Zkx5mhXg46eNpEqZ920QVWEZFR3Fd cardno:0006 05312024"
  ];
  hostname = "octoprint";
  nfsHost = "192.168.0.32:/mnt/atlantic/octoprint";
  wlan_ssid = "Warriors DC";
  wlan_psk = "***REMOVED***";
  ip = { address = "192.168.0.174"; prefixLength = 24; };
  gateway = "192.168.0.1";
  dns = [ "1.1.1.1" "8.8.8.8" ];
  timezone = "America/New_York";
in {
  networking = {
    hostName = "${hostname}";
    useDHCP = false;
    defaultGateway = "${gateway}";
    nameservers = dns;
    interfaces.wlan0.ipv4.addresses = [
      ip
    ];
     wireless = {
      enable = true;
      networks."${wlan_ssid}".psk = "${wlan_psk}";
      interfaces = [ "wlan0" ];
    };
  };

  time.timeZone = "${timezone}";

  environment.systemPackages = with pkgs; [
    vim
    git
    udiskie
    kitty
    tmux
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # State directory for octoprint
  fileSystems."/var/lib/octoprint" = {
    device = "${nfsHost}";
    fsType = "nfs";
  };

  # Nginx configuration for octoprint
  services.nginx = {
    enable = true;
    virtualHosts."octoprint.local" = {
      forceSSL = true;
      sslCertificate = "/var/lib/octoprint/.ssl/cert.pem";
      sslCertificateKey = "/var/lib/octoprint/.ssl/key.pem";
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:5000/";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Scheme $scheme;
            proxy_http_version 1.1;

            client_max_body_size 0;
          '';
        };
        "/webcam/" = {
          proxyPass = "http://127.0.0.1:8080/";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 443 ];

  services.octoprint = {
    enable = true;
    host = "127.0.0.1";
    port = 5000;
    openFirewall = false;
    # Make sure user and statedir are correct
    user = "octoprint";
    stateDir = "/var/lib/octoprint";
    extraConfig = {
      # Set server commands for nixos paths
      server.commands = {
        serverRestartCommand = "/run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl restart octoprint.service";
        systemRestartCommand= "/run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl reboot";
        systemShutdownCommand = "/run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl poweroff";
      };
    };
  };

  # Make sure octoprint starts after state dir is mounted
  systemd.services = {
    octoprint = {
      after = [ "var-lib-octoprint.mount" ];
    };
    nginx = {
      after = [ "var-lib-octoprint.mount" ];
    };
  };

  users = {
    mutableUsers = false;
    users."${username}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" ];
      openssh.authorizedKeys.keys = pubkeys;
    };
  };

  security.sudo = {
    enable = true;
    extraRules= [
      {
        # Let user ${username} use all commands NOPASSWD.
        users = [ "${username}" ];
        commands = [
          {
            command = "ALL" ;
            options = [ "NOPASSWD" "SETENV" ];
          }
        ];
      }
      {
        # Let user octoprint use some systemctl commands NOPASSWD
        users = [ "octoprint" ];
        commands = [
          {
            command = "${pkgs.systemd}/bin/systemctl reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/systemctl poweroff";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/systemctl restart octoprint.service";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  system.stateVersion = "23.11";
}