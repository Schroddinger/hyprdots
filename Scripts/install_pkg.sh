#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to install pkgs from input list |--/ /-|#
#|-/ /--| Prasanth Rangan                        |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

source global_fn.sh
if [ $? -ne 0 ] ; then
    echo "Error: unable to source global_fn.sh, please execute from $(dirname $(realpath $0))..."
    exit 1
fi

install_list="${1:-install_pkg.lst}"

basic_list="fakeroot make gcc pkgconfig cmake acpi patch bison flex which git sof-firmware"
for pk in $basic_list; do
    if ! pkg_installed ${pk}
        then
        echo "installing dependency ${pk}..."
        suso pacman -S ${pk}
    fi
done

if ! pkg_installed yay
    then
    echo "installing dependency yay..."
    ./install_yay.sh 2>&1
fi


while read pkg
do
    if pkg_installed ${pkg}
        then
        echo "skipping ${pkg}..."

    elif pkg_available ${pkg}
        then
        echo "queueing ${pkg} from arch repo..."
        pkg_arch=`echo $pkg_arch ${pkg}`

    elif aur_available ${pkg}
        then
        echo "queueing ${pkg} from aur..."
        pkg_aur=`echo $pkg_aur ${pkg}`

    else
        echo "error: unknown package ${pkg}..."
    fi
done < $install_list


if [ `echo $pkg_arch | wc -w` -gt 0 ]
then
    echo "installing $pkg_arch from arch repo..."
    sudo pacman ${use_default} -S $pkg_arch
fi

if [ `echo $pkg_aur | wc -w` -gt 0 ]
then
    echo "installing $pkg_aur from aur..."
    yay ${use_default} -S $pkg_aur
fi

