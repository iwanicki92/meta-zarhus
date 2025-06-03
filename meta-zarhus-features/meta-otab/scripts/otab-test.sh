#!/bin/bash
#
# SPDX-FileCopyrightText: 2020 3mdeb Embedded Systems Consulting <contact@3mdeb.com>
#
# SPDX-License-Identifier: MIT

function errorExit {
    local _msg="$1"
    echo "$_msg"
    exit 1
}

function errorCheck {
    local _ec="$?"
    local _msg="$1"

    if [ "$_ec" -ne 0  ]; then
        errorExit "$_msg (error code: $_ec)"
    fi
}

function printHelp {
cat <<EOF
Usage: ./$(basename "$0") <IP_ADDRESS> <SWU_FILE>
EOF
exit 1
}

function sshCmd {
    local _cmd="$1"
    ssh $SSH_OPTS "$_cmd" 2> /dev/null
    # errorCheck "Error while executing command: $_cmd on target"
}

function scpPut {
    local _local_path="$1"
    local _remote_path="$2"
    echo -e "\nSending file $_local_path to target device..."
    scp $SCP_OPTS $_local_path $SSH_USER@$SSH_IP:$_remote_path 2> /dev/null
    errorCheck "Error while sending $_local_path to target"
    echo "done"
}

getRootLabel() {
    local _root_label=""
    local _cmdline=$(sshCmd "cat /proc/cmdline")
    for arg in $_cmdline; do
    	# Set optarg to option parameter, and '' if no parameter was
    	# given
        optarg=$(expr "x$arg" : 'x[^=]*=\(.*\)' || echo '')
    	case $arg in
            root=*)
                _root_label=$optarg ;;
        esac
    done
    echo "$_root_label" | cut -d '=' -f 2
}

getRootDevice() {
    local _cmd="mount | grep ' on /media/rfs/ro' | cut -d ' ' -f 1"
    local _root_device=$(sshCmd "$_cmd")
    echo "$_root_device"
}

waitForDevice() {
    local _max_timeout=60
    local _start=$SECONDS
    local _timeout_at=$(( $SECONDS + $_max_timeout ))

    until sshCmd "uptime" > /dev/null; do
      if (( $SECONDS > $_timeout_at )); then
        errorExit "System is still not back; giving up"
      fi
      sleep 5
    done
    echo "System successfully rebooted after $(( $SECONDS - $_start )) s"
}

[ $# -ne 2 ] && printHelp

IP_ADDR="$1"
SWU_FILE_LOCAL=$(readlink -f "$2")
SWU_FILE_REMOTE=/tmp/$(basename $SWU_FILE_LOCAL)

SSH_PORT=22
SSH_USER="root"
SSH_IP="$IP_ADDR"

SSH_OPTS="-o UserKnownHostsFile=/dev/null \
          -o StrictHostKeyChecking=no \
          -p $SSH_PORT \
          $SSH_USER@$SSH_IP"

SCP_OPTS="-o UserKnownHostsFile=/dev/null \
          -o StrictHostKeyChecking=no \
          -P $SSH_PORT"

runTest() {
    cat <<EOF
Test case 1
  - step 1.1: check current root LABEL from kernel commandline
  - step 1.2: check which device is mounted as root filesystem
  - step 1.3: perform update
  - step 1.4: wait for device to reboot
  - step 1.5: check current root LABEL from kernel commandline
    - should change: rootfsa <--> rootfsb
  - step 1.6: check which device is mounted as root filesystem
    - should change: /dev/xxxx2 <--> /dev/xxxx3
  - step 1.7: reboot
  - step 1.8: wait for device to reboot
  - step 1.9: check current root LABEL from kernel commandline
    - should be the same as before reboot (the updated system is the default
      one)
  - step 1.10: check which device is mounted as root filesystem
    - should be the same as before reboot (the updated system is the default
      one)

EOF

    echo "step 1.1: check current root LABEL from kernel commandline"
    LABEL_BEFORE="$(getRootLabel)"
    echo "Label before: $LABEL_BEFORE"
    echo

    echo "step 1.2: check which device is mounted as root filesystem"
    DEVICE_BEFORE="$(getRootDevice)"
    echo "Device before: $DEVICE_BEFORE"
    echo

    echo "step 1.3: perform update"
    scpPut "$SWU_FILE_LOCAL" "$SWU_FILE_REMOTE"
    sshCmd "otab update $SWU_FILE_REMOTE" > /dev/null
    echo

    echo "step 1.4: wait for device to reboot"
    waitForDevice
    echo

    echo "step 1.5: check current root LABEL from kernel commandline"
    LABEL_AFTER_1="$(getRootLabel)"
    echo "Label after_1: $LABEL_AFTER_1"
    echo

    echo "step 1.6: check which device is mounted as root filesystem"
    DEVICE_AFTER_1="$(getRootDevice)"
    echo "Device after_1: $DEVICE_AFTER_1"
    echo

    echo "step 1.7: reboot"
    sshCmd "reboot"
    echo

    echo "step 1.8: wait for device to reboot"
    waitForDevice
    echo

    echo "step 1.9: check current root LABEL from kernel commandline"
    LABEL_AFTER_2="$(getRootLabel)"
    echo "Label after_2: $LABEL_AFTER_2"
    echo

    echo "step 1.10: check which device is mounted as root filesystem"
    DEVICE_AFTER_2="$(getRootDevice)"
    echo "Device after_2: $DEVICE_AFTER_2"
    echo

    echo "Test summary:"
    if [ "$LABEL_BEFORE" != "$LABEL_AFTER_1" ]; then
        echo "1.5: PASS"
    else
        echo "1.5: FAIL"
    fi

    if [ "$DEVICE_BEFORE" != "$DEVICE_AFTER_1" ]; then
        echo "1.6: PASS"
    else
        echo "1.6: FAIL"
    fi

    if [ "$LABEL_AFTER_1" = "$LABEL_AFTER_2" ]; then
        echo "1.9: PASS"
    else
        echo "1.9: FAIL"
    fi

    if [ "$DEVICE_AFTER_1" = "$DEVICE_AFTER_2" ]; then
        echo "1.10: PASS"
    else
        echo "1.10: FAIL"
    fi
}

runTest
