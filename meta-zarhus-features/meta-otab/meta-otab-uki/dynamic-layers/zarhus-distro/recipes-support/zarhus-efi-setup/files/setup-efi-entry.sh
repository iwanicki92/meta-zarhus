#!/bin/sh
set -e

current_bootnum="$(efibootmgr | head -1 | awk '{print $2}')"
# Delete the entry that was used to boot this session
efibootmgr -b "$current_bootnum" -B

# Delete all EFI boot entries labeled "ZarhusOS"
efibootmgr | grep "ZarhusOS" | awk '{print $1}' | sed 's/Boot//;s/\*//' | while read -r bootnum; do
    efibootmgr -b "$bootnum" -B
done

# Create the stable ZarhusOS entry on the disk
DISK=$(lsblk -no PKNAME "$(findmnt -nr -o SOURCE /boot)")

efibootmgr --disk "/dev/$DISK" \
           --part 1 \
           --create \
           --label "ZarhusOS A" \
           --loader '\EFI\BOOT\bootx64.efi' \
           --index 0 \
           --bootnum "$current_bootnum"

efibootmgr --disk "/dev/$DISK" \
           --part 3 \
           --create \
           --label "ZarhusOS B" \
           --loader '\EFI\BOOT\bootx64.efi' \
           --index 1
