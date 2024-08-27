#!/bin/bash


TRACKERURL="https://raw.githubusercontent.com/jinkout/WMATA-RailTrack/main/Python/wmata_railtrack_PUB.py"
T_NAME="wmata_railtrack_PUB.py"
SVC_NAME="wmata_service.service"
read -p "Please enter your API key for the WMATA Train Positions API: " API

curl -O $TRACKERURL


sed -i "s|API = 'YOUR_API_KEY'|API = '$API'|g" $T_NAME


chmod +x $T_NAME

cat <<EOL | sudo tee /etc/systemd/system/$SVC_NAME
[Unit]
Description=WMATA Railtrack

[Service]
ExecStart=/usr/bin/python3 /path/to/$SVC_NAME
WorkingDirectory=$(pwd)
StandardOutput=inherit
StandardError=inherit
Restart=always

[Install]
WantedBy=multi-user.target
EOL


sudo systemctl daemon-reload
sudo systemctl enable $SVC_NAME
sudo systemctl start $SVC_NAME

echo "The WMATA RailTracker is successfully installed and configured with your API key and will run on start."
