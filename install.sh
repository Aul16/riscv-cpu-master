SERVER=http://172.17.13.40/deploiement-debian
CONFIG=${SERVER}/configuration
PRGS=${SERVER}/prgs

# Installation des paquets nécessaires pour le TP d'architecture

DEBIAN_FRONTEND=noninteractive apt-get install --yes gcc-riscv-unknown-elf

# Installation de Vivado

## Installation des règles udev permettant aux étudiants d'utiliser la liaison série avec les carte FPGA.

UDEV="99-tty-udev-student.rules"
wget -q ${CONFIG}/${UDEV} -O- > /tmp/${UDEV}
mv /tmp/${UDEV} /etc/udev/rules.d/
chown root: /etc/udev/rules.d/${UDEV}
udevadm control -R 

## Installation des dépendances de Vivado

DEBIAN_FRONTEND=noninteractive apt-get install --yes libx32stdc++6-i386-cross libgtk2.0-dev dpkg-dev libtinfo5
libncurses5 gawk


## Téléchargement de Vivado

mkdir -p /opt/Xilinx
wget -q ${PRGS}/vivado-2019.1.tgz -O- > /opt/Xilinx/vivado.tgz
cd /opt/Xilinx
tar xzf ./vivado.tgz
chown -R root: /opt/Xilinx
rm vivado.tgz

## Installation de l'icône de Vivado
wget -q ${PRGS}/vivado.desktop -O- > /usr/share/applications/vivado.desktop

## Ajout du chemin vers les exécutables de Vivado dans /etc/profile.

wget -q ${CONFIG}/vivado.sh -O-> /etc/profile.d/vivado.sh
chown root: /etc/profile.d/vivado.sh
chmod 644 /etc/profile.d/vivado.sh

## Ajout de règle udev supplémentaires
cd /opt/Xilinx/Vivado/2019.1/data/xicom/cable_drivers/lin64/install_script/install_drivers
./install_drivers
