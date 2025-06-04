BOOT_A_UUID = "${BOOT_UUID}"
ROOT_A_UUID = "${ROOT_UUID}"
BOOT_B_UUID = "${@generate_uuid_from_sha(d, 'boot_b')}"
ROOT_B_UUID = "${@generate_uuid_from_sha(d, 'root_b')}"
