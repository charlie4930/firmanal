#!/bin/bash

if [ -e ../configure.sh ]; then
    source ../configure.sh
elif [ -e ./configure.sh ]; then
    source ./configure.sh
else
    echo "Error: Could not find 'configure.sh'!"
    exit 1
fi

if check_number $1; then
    echo "Usage: $0 <image ID>"
    echo "This script deletes a whole project"
    exit 1
fi
IID=${1}

# Check that no qemu is running:
echo "checking the process table for a running qemu instance ..."
PID=`ps -ef | grep qemu | grep "${IID}" | grep -v grep | awk '{print $2}'`
if ! [ -z $PID ]; then
    echo "killing process ${PID}"
    sudo kill -9 ${PID}
fi

PID1=`ps -ef | grep "${IID}\/run.sh" | grep -v grep | awk '{print $2}'`
if ! [ -z $PID1 ]; then
    echo "killing process ${PID1}"
    sudo kill ${PID1}
fi

# Check that nothing is mounted:
echo "In case the filesystem is mounted, umount it now ..."
sudo ${VM_SCRIPT_DIR}/umount.sh ${IID}

# Check network config
echo "In case the network is configured, reconfigure it now ..."
for i in 0 .. 4; do
    sudo ifconfig tap${IID}_${i} down
    sudo tunctl -d tap${IID}_${i}
done

# Cleanup database:
echo "Remove the database entries ..."
psql -d firmware -U firmadyne -h 127.0.0.1 -t -q -c "DELETE from image WHERE id=${IID};"

# Cleanup filesystem:
echo "Clean up the file system ..."
if [ -f "/tmp/qemu.${IID}*" ]; then
    sudo rm /tmp/qemu.${IID}*
fi

if [ -f ${FIRMWARE_DIR}/${IID}.tar.gz ]; then
    sudo rm ${FIRMWARE_DIR}/${IID}.tar.gz
fi

if [ -f ${FIRMWARE_DIR}/${IID}.kernel ]; then
    sudo rm ${FIRMWARE_DIR}/${IID}.kernel
fi

if [ -d ${VM_DIR}/${IID}/ ]; then
    sudo rm -r ${VM_DIR}/${IID}/
fi

echo "Done. Removed project ID ${IID}."
