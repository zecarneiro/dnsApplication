#!/bin/sh
# Autor: José M. C. Noronha
# Data: 17/03/2018

# print message Init
echo "Install..."

# Global defintion
HOME_FOLDER=$( echo $HOME )
sudoersPath="/etc/sudoers"
localizationShortcut="$HOME_FOLDER/.local/share/applications"
commandToInstallResolvConf="sudo apt install resolvconf -y"
copyApp="sudo cp -r dns_application /opt"
setChmod="sudo chmod +x /opt/dns_application/dns_change.sh"

# Create Shortcut Folder
./createFolder.sh "$HOME_FOLDER" .local share applications

# Create Desktop File
echo "
[Desktop Entry]
Encoding=UTF-8
Name=DNS Change
Comment=DNS Change
Exec=sudo /opt/dns_application/dns_change.sh
Terminal=true
Type=Application
Icon=/opt/dns_application/dnschanger.png
StartupNotify=true
Name[pt_PT]=Mudar DNS" > "$localizationShortcut/dnsChange.desktop"
chmod +x "$localizationShortcut/dnsChange.desktop"


echo "# Change DNS" | sudo tee -a $sudoersPath
echo "ALL ALL=(ALL) NOPASSWD:/opt/dns_application/dns_change.sh" | sudo tee -a $sudoersPath > /dev/null

$commandToInstallResolvConf
$copyApp
$setChmod

# print message finish
echo "Done."