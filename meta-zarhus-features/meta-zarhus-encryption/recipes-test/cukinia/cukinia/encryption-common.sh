#!/bin/bash

return_code() {
    return "${1:$?}"
}

test_partition() {
    part_device="$1"
    part_name="$2"

    section "Test ${part_name}" "cyan"
    if as "Check if ${part_device} is encrypted" cukinia_cmd cryptsetup status "${part_device}";
    then
        encrypted_device=$(cryptsetup status "${part_device}" | sed -n "s|.*device:.*\(/dev/.*\)|\1|p")
        as "Check if we can get '${part_name}' LUKS device information dump" \
            cukinia_cmd cryptsetup luksDump "${encrypted_device}" --dump-json-metadata
    fi
}
