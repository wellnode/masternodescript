#!/bin/bash

PORT=50312
RPCPORT=50313
CONF_DIR=~/.wend
COINZIP='https://github.com/wellnode/WEND/releases/download/v1.0/wend-linux.zip'

cd ~
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

function configure_systemd {
  cat << EOF > /etc/systemd/system/wend.service
[Unit]
Description=Wellnode Service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart=/usr/local/bin/wendd
ExecStop=-/usr/local/bin/wend-cli stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  sleep 2
  systemctl enable wend.service
  systemctl start wend.service
}

echo ""
echo ""
DOSETUP="y"

if [ $DOSETUP = "y" ]  
then
  apt-get update
  apt install zip unzip git curl wget -y
  cd /usr/local/bin/
  wget $COINZIP
  unzip wend-linux.zip
  rm wend-qt wend-tx wend-linux.zip
  chmod +x wend*
  
  mkdir -p $CONF_DIR
  cd $CONF_DIR

fi

 IP=$(curl -s4 api.ipify.org)
 echo ""
 echo "Configure your masternodes now!"
 echo "Detecting IP address:$IP"
 echo ""
 echo "Enter masternode private key"
 read PRIVKEY
 
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> wend.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> wend.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> wend.conf_TEMP
  echo "rpcport=$RPCPORT" >> wend.conf_TEMP
  echo "listen=1" >> wend.conf_TEMP
  echo "server=1" >> wend.conf_TEMP
  echo "daemon=1" >> wend.conf_TEMP
  echo "maxconnections=250" >> wend.conf_TEMP
  echo "masternode=1" >> wend.conf_TEMP
  echo "" >> wend.conf_TEMP
  echo "port=$PORT" >> wend.conf_TEMP
  echo "externalip=$IP:$PORT" >> wend.conf_TEMP
  echo "masternodeaddr=$IP:$PORT" >> wend.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> wend.conf_TEMP
  mv wend.conf_TEMP wend.conf
  cd
  echo ""
  echo -e "Your ip is ${GREEN}$IP:$PORT${NC}"

	## Config Systemctl
	configure_systemd
  
echo ""
echo "Commands:"
echo -e "Start Wellnode Service: ${GREEN}systemctl start wend${NC}"
echo -e "Check Wellnode Status Service: ${GREEN}systemctl status wend${NC}"
echo -e "Stop Wellnode Service: ${GREEN}systemctl stop wend${NC}"
echo -e "Check Masternode Status: ${GREEN}wend-cli getmasternodestatus${NC}"

echo ""
echo -e "${GREEN}Wellnode Masternode Installation Done${NC}"
exec bash
exit
