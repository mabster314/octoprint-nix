{ config, lib, pkgs, ... }:
let
  user = "max";
  password="printer";
  hostname = "octoprint";
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
    hostName = hostname;
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

  services.openssh.enable = true;

  services.octoprint = {
    enable = true;
    port = 5000;
    openFirewall = true;
    extraConfig = {
      api.key = "DE291084FAF04AF9A04EFC4320C52A0D";
    };
  };

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      password = password;
      extraGroups = [ "wheel" "video" ];
    };
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";
}
