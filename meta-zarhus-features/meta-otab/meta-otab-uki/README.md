# meta-otab-uki

Add this layer if you are booting UKI file directly.

If you want to test image on QEMU then after decompressing wic file you
need to increase it's size so there is space for overlayfs partition to be
created e.g. to increase image size by 512 MB you can use dd:

```sh
dd if=/dev/zero of=zarhus.img bs=1 count=0 seek=$(($(stat -c "%s" zarhus.img)+1024*1024*512))
```
