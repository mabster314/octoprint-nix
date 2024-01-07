# octoprint-nix
This is my NixOS flake to build SD card images for octoprint on the raspberry pi 4.
Octoprint state files are stored on an NFS folder, with specific tweaks for NixOS and an nginx reverse proxy to provide SSL.

To build the image, run `nix build .#packages.aarch64-linux.octoprint`.

Flash an SD card with `zstdcat result/sd-image/nixos-sd-image-*.img.zst | sudo dd of=<sd card root> conv=fsync status=progress bs=4M`.

## Dependencies
- [nixos-generators](https://github.com/nix-community/nixos-generators)
- [sops-nix](https://github.com/Mic92/sops-nix)
- [nixos-hardware](https://github.com/NixOS/nixos-hardware)

## Features
- Octoprint:
    - state directory mounted from an NFS share
    - correctly map octoprint commands to NixOS store
    - `sudoers` rules for octoprint systemd functions
    - firewall closed
- Nginx reverse proxy to add SSL to octoprint
- `sops-nix` based secret distribution
    - used for wireless configuration and x509 certificates
    - you must provide a sops-encrypted `secrets.yaml` file containing:
        ```
        wireless.env: |
            ssid=<Network SSID>
            psk=<psk>
        x509_cert: |
            -----BEGIN CERTIFICATE-----
            key here...
            -----END CERTIFICATE-----
        x509_key: |
            -----BEGIN PRIVATE KEY-----
            key here...
            -----END PRIVATE KEY-----
        ```
- Deploy script to copy machine host keys from my computer to the SD card
