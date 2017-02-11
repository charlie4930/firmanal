#!/bin/bash

set -e

if [[ ${USER} == "root" ]]; then
	echo "Please run this script without root privilege."
	exit 1
fi

if [ -e ../configure.sh ]; then
        source ../configure.sh
elif [ -e ./configure.sh ]; then
        source ./configure.sh
else
        echo "Error: Could not find 'configure.sh'!"
        exit 1
fi


for pkg in "python2-cstruct" "python2-lzo" "python2-pyliblzma" "afl" "firmware-mod-kit" "flawfinder" "jefferson-git" "multipath-tools" "sasquatch" "snowman" "stuffit" "ubi_reader" "uml_utilities" "yaffshiv"
do
	cd "${SCRIPT_DIR}/pkgs/${pkg}"
	makepkg -srcif --needed --noconfirm
done

