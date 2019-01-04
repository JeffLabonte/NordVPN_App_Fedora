#!/bin/bash

ARCH=$(uname -m)
ARCH_PACKAGE=""
NORDVPN_VERSION="2.1.0-5"
PACKAGE_NAME="nordvpn"

print_usage(){
    echo "You must choose between:"
    echo "install or remove/purge"
}

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

clean_up_folder(){
    rm -rf nordvpn *{tgz,deb}*
}

retrieve_nordvpn_deb(){
    echo ""
    PACKAGE_NAME="nordvpn_${NORDVPN_VERSION}_${ARCH_PACKAGE}.deb"
    wget https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/$PACKAGE_NAME

}

handle_deb_file(){
    sudo alien -t --script $PACKAGE_NAME
    PACKAGE_NAME=$(echo $PACKAGE_NAME | sed 's/-[0-9]_amd64.deb/.tgz/g' | sed 's/_/-/g')
    mkdir $(pwd)/nordvpn
    mv $PACKAGE_NAME nordvpn/
    tar -xvf nordvpn/$PACKAGE_NAME -C nordvpn/
}

install_nordvpn(){
    sudo cp -R nordvpn/etc/systemd /etc
    sudo cp -R nordvpn/usr /
    sudo cp -R nordvpn/var /
    sudo sh nordvpn/install/doinst.sh configure
}

uninstall_nordvpn(){
    sudo sh nordvpn/install/predelete.sh remove
    sed -i '/rm -f \/etc\/init.d\/nordvpn/d' nordvpn/install/delete.sh
    sudo sh nordvpn/install/delete.sh purge
    sudo rm /usr/bin/nordvpn
    echo "NordVPN has been removed!"
}

if [ -z $1 ]; then
    print_usage
    exit 1
fi

install_dependencies
extract_arch_package
retrieve_nordvpn_deb
handle_deb_file

case $1 in
    install)
        install_nordvpn
        ;;
    remove|purge)
        uninstall_nordvpn
        ;;
    *)
        print_usage
        ;;
esac

clean_up_folder
