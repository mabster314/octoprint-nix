#!/usr/bin/env bash

set -euo pipefail

mkdir -p mnt
mount /dev/disk/by-label/NIXOS_SD mnt
mkdir -p mnt/etc/ssh
cp /run/secrets/octoprint/*_key mnt/etc/ssh
sync
umount mnt
rmdir mnt
