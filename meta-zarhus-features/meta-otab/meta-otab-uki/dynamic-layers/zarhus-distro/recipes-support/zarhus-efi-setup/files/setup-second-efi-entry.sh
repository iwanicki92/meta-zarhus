#!/bin/bash
efibootmgr --disk "/dev/$DISK" \
           --part 2 \
           --create \
           --label "ZarhusOS B" \
           --loader '\EFI\BOOT\bootx64.efi'
