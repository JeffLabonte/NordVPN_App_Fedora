#!/bin/bash

ARCH=$(uname -m)
ARCH_PACKAGE=""
NORDVPN_VERSION="2.1.0-5"
PACKAGE_NAME="nordvpn"

install_dependencies(){
    sudo dnf install gpg wget openvpn alien
}

extract_arch_package(){
    case $ARCH in 
        "x86_64")
            ARCH_PACKAGE="amd64"
            ;;
        "i386")
            ARCH_PACKGE="i386"
            ;;
    esac
}

retrieve_nordvpn_deb(){
    echo ""
    PACKAGE_NAME="nordvpn_${NORDVPN_VERSION}_${ARCH_PACKAGE}.deb"
    wget https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/$PACKAGE_NAME

}

install_nordvpn(){
    echo ""
}

extract_arch_package
retrieve_nordvpn_deb

case $1 in
    install)
        install_nordvpn
        ;;
esac
