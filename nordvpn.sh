#!/bin/bash

ARCH=$(uname -m)
ARCH_PACKAGE=""
NORDVPN_VERSION="3.0.0-4"
PACKAGE_NAME="nordvpn"

print_usage(){
    echo "You must choose between:"
    echo "install or remove/purge"
}

install_dependencies(){
    if [ -x "$(command -v dnf)" ]; then
        sudo dnf install gpg wget openvpn alien
    elif [ -x "$(command -v zypper)" ]; then
        wget http://download.opensuse.org/repositories/home:/woelfel/openSUSE_Tumbleweed/noarch/alien-8.95-1.3.noarch.rpm
        sudo zypper in gpp wget openvpn
        if [ !-x "$(command -v alient)"]; then
		    sudo zypper in ./alien*.rpm
        fi
    fi
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
    rm alien*
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
    sudo cp -R /usr/lib/systemd/ /etc/systemd/
    sudo cp -R nordvpn/usr /
    sudo cp -R nordvpn/var /
    sudo sh nordvpn/install/doinst.sh configure
}

reload_systemd(){
   sudo systemctl daemon-reload
   sudo systemctl --now enable nordvpnsd.service
   systemctl --now --user enable nordvpnud.service
   echo "Enabled services with --now flag"
   echo "******************************"
}

uninstall_nordvpn(){
    sudo sh nordvpn/install/predelete.sh remove
    sed -i '/rm -f \/etc\/init.d\/nordvpn/d' nordvpn/install/delete.sh
    sudo sh nordvpn/install/delete.sh purge
    sudo rm /usr/bin/nordvpn
    sudo find /etc/systemd -name "nordvpn*" -exec rm {} \;
    echo "NordVPN has been removed!"
}

if [ -z $1 ]; then
    print_usage
    exit 1
fi


case $1 in
    install)
        extract_arch_package
        retrieve_nordvpn_deb
        handle_deb_file
	install_dependencies
        install_nordvpn
        reload_systemd
        ;;
    remove|purge)
        uninstall_nordvpn
        ;;
    *)
        print_usage
        ;;
esac

clean_up_folder
