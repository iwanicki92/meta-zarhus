import logging
import os
import shutil

from wic import WicError
from wic.plugins.source.rootfs import RootfsPlugin
from wic.misc import get_bitbake_var, exec_native_cmd

logger = logging.getLogger('wic')

class RootfsSedPlugin(RootfsPlugin):
    """
    Apply sed on /etc/fstab before partition is prepared. Plugin accepts couple
    sourceparams:
    * sed_filter_var=<VAR>, where <VAR> is name of bitbake variable containing
        sed filter string. <VAR> should also be added to WICVARS. Without this
        param rootfs-sed will act identically to rootfs plugin.
    * sed_filter_separator=<SEP> used if you want to pass multiple filters
        applied via "sed -e '<FILTER1>' [-e '<FILTER2>']...".
        Before applying each filter is stripped of leading and trailing
        whitespaces so you can safely pass multiple filters with
        spaces/newlines in them e.g. with
        --sourceparams="sed_filter_separator=@,sed_filter_var=SED" you can then
        set SED variable to:
        SED=" \\
            s/rw/ro/g @ \\
            s|/boot|/mnt| \\
        "
    """

    name = 'rootfs-sed'

    @classmethod
    def do_prepare_partition(cls, part, source_params, creator, cr_workdir,
                             oe_builddir, bootimg_dir, kernel_dir, krootfs_dir,
                             native_sysroot):
        args = [part, source_params, creator, cr_workdir,
                             oe_builddir, bootimg_dir, kernel_dir, krootfs_dir,
                             native_sysroot]
        if not 'sed_filter_var' in source_params:
            return super().do_prepare_partition(*args)
        else:
            fstab_sed_var = source_params['sed_filter_var']
        if part.rootfs_dir is None:
            if not 'ROOTFS_DIR' in krootfs_dir:
                raise WicError("Couldn't find --rootfs-dir, exiting")

            rootfs_dir = krootfs_dir['ROOTFS_DIR']
        else:
            if part.rootfs_dir in krootfs_dir:
                rootfs_dir = krootfs_dir[part.rootfs_dir]
            elif part.rootfs_dir:
                rootfs_dir = part.rootfs_dir
            else:
                raise WicError("Couldn't find --rootfs-dir=%s connection or "
                               "it is not a valid path, exiting" % part.rootfs_dir)

        fstab_sed = get_bitbake_var(fstab_sed_var)
        if not fstab_sed:
            raise WicError(f"Couldn't find {fstab_sed_var}, exiting")
        sed_sep = source_params.get("sed_filter_separator")

        fstab_path = os.path.join(rootfs_dir, "etc/fstab")
        has_fstab = os.path.exists(fstab_path)
        if not part.updated_fstab_path and not has_fstab:
            raise WicError("Can't find fstab in rootfs")
        if not part.updated_fstab_path:
            part.updated_fstab_path = os.path.join(cr_workdir, "fstab")
            shutil.copy(fstab_path, part.updated_fstab_path)
        fstab_path = part.updated_fstab_path

        if sed_sep:
            sed_filter = " ".join([
                f"-e '{filter.strip()}'"
                for filter in fstab_sed.split(sed_sep)
                ])
        else:
            sed_filter = f"'{fstab_sed}'"
        sed_cmd = f"sed -i {sed_filter} {fstab_path}"
        logger.debug(f"sed command used: {sed_cmd}")
        exec_native_cmd(sed_cmd, native_sysroot, None)
        if os.getenv('SOURCE_DATE_EPOCH'):
            fstab_time = int(os.getenv('SOURCE_DATE_EPOCH'))
            os.utime(part.updated_fstab_path, (fstab_time, fstab_time))
        part.update_fstab_in_rootfs = True
        # ignore no_fstab_update for this partition when using this plugin
        part.no_fstab_update = False

        return super().do_prepare_partition(*args)
