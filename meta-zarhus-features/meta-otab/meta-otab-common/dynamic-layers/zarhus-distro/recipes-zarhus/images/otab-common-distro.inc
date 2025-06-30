DEPLOY_PARTITIONS = "p2"
do_deploy_partitions() {
    part_dir="${WORKDIR}/build-wic"
    for partition in "$part_dir"/*.direct.p*; do
        partition_basename="$(basename "$partition")"
        ext="${partition_basename##*.}"
        for deploy_ext in ${DEPLOY_PARTITIONS}; do
            if [ "$deploy_ext" = "$ext" ]; then
                bbdebug 1 "gzipping $partition"
                gzip --force --keep -9 "$partition"
                partition_image_basename="${IMAGE_BASENAME}-${MACHINE}.direct.$ext"
                mv "${partition}.gz" "${DEPLOY_DIR_IMAGE}/${partition_image_basename}.gz"
                break
            fi
        done
    done
}
addtask deploy_partitions after do_image_wic before do_build
