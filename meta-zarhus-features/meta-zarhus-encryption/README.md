# Zarhus encryption layer

This layer adds rootfs encryption support.

## Dependencies

### initramfs

Encryption/decryption happens in initramfs so final image needs to include and
use it. By default, `initramfs-module-encrypt-decrypt` is only added to
`core-image-minimal-initramfs`, if you want to use different initramfs then you
need to add it to `INITRAMFS_SCRIPTS` in your initramfs recipe.

As we are encrypting `rootfs`, kernel and initramfs have to be on different
partition.

### kernel arguments

To make encryption work make sure that in arguments passed to kernel:

* `root=` uses `/dev/mapper/<mapped_name>`, `LABEL=` or `UUID=`
* There is `rd.luks.rootfs=` argument with path to encrypted partition e.g.
    `/dev/<device>`, `PARTLABEL=` or `PARTUUID=`

To encrypt/decrypt additional partitions add
`rd.luks.encrypt=<PARTITION>[,PARTITION]...` command line argument.

## Encryption/decryption details

Encryption/decryption flow:

1. Boot kernel & initramfs
2. Check if `rd.luks.rootfs=<X>` argument was passed, if it wasn't then continue
    with normal boot
3. Check if `<X>` device is encrypted
    - If it is, then
        * decrypt rootfs
        * decrypt all partitions in `rd.luks.encrypt`
        * continue with normal boot
    - If it isn't then continue to point 4
4. For all partitions in `rd.luks.encrypt` and for `rd.luks.rootfs`
    1. Shrink filesystem by 32 MB
    2. Shrink partition by 32 MB
    3. Encrypt partition in-place with temporary key
    4. Add recovery key (generate new one if it's first partition that's being
       encrypted)
    5. Enroll TPM2 device and wipe temporary key decryption method
    6. Decrypt partition
    7. Extend filesystem to use all available space left after encryption
5. Continue with normal boot

You can change PCRs used when enrolling TPM by changing `TPM_PCRS` variable in
`initramfs-framework` recipe. By default, it uses PCR7.

## Recovery

* During encryption process you will be shown recovery key. Make sure to save it
in safe space.
* You will be asked to enter recovery password in case of failed
decryption via TPM2.
* When entering password there is no visible confirmation that you've written
anything (e.g. no '*' for each character inputted).
* Pasting recovery password through serial connection might/might not work. In
  case it doesn't work you might have to paste it in couple smaller chunks or
  write it manually.
