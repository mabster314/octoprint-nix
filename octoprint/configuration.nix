{ config, lib, pkgs, ... }:
let
  username = "max";
in {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      raspberryPi.firmwareConfig = ''
        gpu_mem=192
      '';
    };
  };

  networking = {
    hostName = "octoprint";
    useDHCP = false;
    defaultGateway = "192.168.0.1";
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    interfaces.wlan0.ipv4.addresses = [ {
      address = "192.168.0.174";
      prefixLength = 24;
    } ];
     wireless = {
      enable = true;
      networks."Warriors DC".psk = "***REMOVED***";
      interfaces = [ "wlan0" ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    libraspberrypi
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
    device = "192.168.0.32:/mnt/atlantic/octoprint";
    fsType = "nfs";
  };

  # Make sure octoprint starts after state dir is mounted
  systemd.services.octoprint = {
    after = [ "var-lib-octoprint.mount" ];
  };

  services.octoprint = {
    enable = true;
    port = 5000;
    openFirewall = true;
    stateDir = "/var/lib/octoprint";
  };

  users = {
    mutableUsers = false;
    users."${username}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" ];
      openssh.authorizedKeys.keys = [
        # Max's smartcard
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChvjHy0zchvYYpZ5qja4BA9c53A26iVlbQ2oNFiOLyQYmMztJXGfSXATXzI6tVQm0zS8B7c+0+6DzTILlL514oNJ5Qyf5FLhQqts/4bd/o9f0NMDcH2QV++zosHvc+xFZmYAnq/iScR01BkIi5QrashZEd3hIlRNKec73ZPtdV62OUG/SaBs4KVvl2ZleT9qAQ1r3FfvNDUKbDGmj912yoTyHfdz+3snH+nbpV8sF6nkznQZvnPrQNqlo0LMctwdXENiZLipybpwzZgUjO14+ItSD/+zMeBa5Y6TMNynheSNSWbPi1SttBcq3Zkx5mhXg46eNpEqZ920QVWEZFR3Fd cardno:0006 05312024"
      ];
    };
  };

  security.sudo.extraRules= [
    {  users = [ "${username}" ];
      commands = [
         { command = "ALL" ;
           options= [ "NOPASSWD" "SETENV" ]; 
        }
      ];
    }
  ];

  system.stateVersion = "23.11";
}
