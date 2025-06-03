# meta-otab

## About

This layers contains an implementation of Over-the-air (OTA) Dual Image (A/B)
OS update system for Yocto distributions. The implementation is based on the
[SWUpdate framework](https://sbabic.github.io/swupdate/swupdate.html).

## Dependencies

This layer depends on the following layers:
* [meta-swupdate](https://github.com/sbabic/meta-swupdate)
* [3mdeb/meta-readonly-rootfs-overlay](https://github.com/3mdeb/meta-readonly-rootfs-overlay)

## Content

* `meta-otab-common` - Common layer, should always be enabled.
* `meta-otab-grub` - Layer with support for the `GRUB` bootloader, currently
  `x86-64 UEFI` is supported
* `meta-otab-uboot` - Layer with support for the `U-Boot` bootlodaer,
  currently `arm` and `aarch64` platforms are supported.
* `scripts` - Set of useful scripts which can be used with the meta-otab based
  products.
* `meta-otab-encryption` - Allows for provisioning of encrypted update image.
* `meta-otab-signed` - Layer providing signed functionality for trusted source
  verification.
* `meta-otab-https` - Support for updating over HTTPS server. Allows for use of
  self-signed certificates if necessary.
* `meta-otab-rorootfs` - Adds support for readonly rootfs with the OTAB
  functionality. Currently, `Raspberry Pi 3 Model B+` is verified to work
  correctly.

### Scripts

#### generate-keys.sh

Script created to generate keys used with signed and encrypted update images
implemented by `meta-otab-encryption` and `meta-otab-signed`.

Script usage.

```shell
$ ./generate-keys.sh
Usage: generate-keys.sh [options]

    Options:
        TYPE       - type of keys to generate. Select one of these: sig, enc,
                     all
        PASSPHRASE - passphrase use to create keys for signing and encrypting the
                     image

    Example:
        ./generate-keys.sh enc <PASSPHRASE>
        ./generate-keys.sh sig <PASSPHRASE>
        ./generate-keys.sh all <PASSPHRASE>
```

Script allows for creation of new encryption and signing keys. If you've used
`./generate-keys.sh all` your output should look something like this:

```shell
Generated files (add them to 'recipes-otab/otab-keys/otab-keys-sig' in 'meta-customer-layer'):
    /home/user/workspace/meta-otab/scripts/sig.key.pem
    /home/user/workspace/meta-otab/scripts/sig.cert.pem


Generated encryption keys:

SWUPDATE_ENC_SALT = "B3BB24D5D6589924"
SWUPDATE_ENC_KEY = "1B61B9ACF6AFA0AE0B289F1AD4E4CFE2C8D124D0D8696F8BA1A1C4DB259BC325"
SWUPDATE_ENC_IV = "0C43778771BEE2F9029DEC9C64564950"

Add them to distro configuration file of 'meta-customer-layer'.
```

The `sig.key.pem` and `sig.cert.pem` are related to [meta-otab-signed](#content)
functionality and need to be placed in the
`meta-custom/meta-custom-distro/recipes-otab/otab-keys/otab-keys-sig/sig.cert.pem`
directory.

The `SWUPDATE_ENC_KEY` and `SWUPDATE_ENC_IV` are a part of
[meta-otab-encryption](#content). The variables need to be set in the
`meta-custom/meta-custom-distro/conf/layer.conf` directory.

#### delta-patches.sh

Script used to create [delta update
images](https://sbabic.github.io/swupdate/delta-update.html?highlight=delta).

Script usage.

```shell
$ ./meta-otab/scripts/delta-patches.sh help
Usage: DEBUG= TARGET= delta-patches.sh command
    Commands:
        help                        print this help
        create                      create delta patches based on the latest
                                    build version and versions available on the
                                    updates server
    Environment variables:
        DEBUG                       when specified, use debug rootfs image to
                                    create delta patches, by default the script
                                    will use prod image
        TARGET                      part of the rootfs image name, dependent on
                                    the project name, if TARGET is not
                                    specified, the script exits
    Examples:
        ./scripts/delta-patches.sh help
        DEBUG=yes TARGET=xyz ./scripts/delta-patches.sh create
        TARGET=xyz ./scripts/delta-patches.sh upload
```

Script should be used from project top directory (where all meta-layers are
stored). It use `versions.txt` file which is downloaded from the update server
and consist of list of available image rootfs versions. For now it support
downloading that list from Google Cloud Storage. This file should be available
at the following path.

`https://storage.googleapis.com/$_bucket/rootfs-image/versions.txt`

When this script is delivered to the client, change the value of the `_bucket`
variable, which indicates the bucket from which the rootfs images will be
downloaded.

Created swu files will be stored in `top_dir/artifacts/delta-patches/OPT`.
Where `OPT` will be `debug` or `prod` depending on the option selected.

#### https_py_container.sh

Script used with [update via HTTPS server](#update-server).

## Configuration

The build configuration can be adjusted through the set of variables. The
default values are defined in the `layer.conf` files in revelevant layers.

## Update Server

The platform can connect to a update server via HTTPS. It's possible to create
a basic server Docker image using the `scripts/https_py_container.sh`.
To do this you have to provide a certificate and private key file.
For hosting on a local network the `generate_certificate.sh`
generates a certificate tied to your host platform hostname and a encryption key.
It's vital when hosting the update server locally to parse the hostname and port
of the server to the `OTAB_SERVER_LINK` variable as well as putting your cert
at the `recipes-otab/ca-certificates/ca-certificates%/server.crt` path.

```shell
OTAB_SERVER_LINK = "https://hostname:port"
```

The script generates a Dockerfile at a specified `server_directory` that will
run a HTTPS server using python with your specified config.

```shell
$ ./https_py_container.sh --help
Usage: ./https_py_container.sh <port> <certificate> <key> [<server_directory>] [<volume_directory>] [<docker_image_name>]
```

To start the script use the `run_${docker_image_name}_image.sh` script that was
placed in your specified `server_directory`.

For example if we didn't specify `docker_image_name` it will be equal
to https_py_container

```shell
$ ./run_https_py_container_image.sh
a8679e6d77b52684355d127e7d8adf36a14b116dd07f483c27cd91671da8360c
```

The script will run the container and output the `CONTAINER ID` given to it.
After placing the .swu image file at the `volume_directory` the platform should
be able to poll the update.
