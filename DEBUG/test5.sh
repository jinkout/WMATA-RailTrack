#!/bin/bash

# WMATA Railtrack Installer
# This script downloads the WMATA RailTrack Python application,
# configures it with the user's API key, and sets it up as a systemd service.

# Creating the WMATA RailTrack directory
WMATADIR="/home/$(whoami)/WMATA_RailTrack"
mkdir -p "$WMATADIR"

# Storing info in shorter variables
TRACKERURL="https://raw.githubusercontent.com/jinkout/WMATA-RailTrack/main/Python/wmata_railtrack_PUB.py"
T_NAME="wmata_railtrack_PUB.py"
SVC_NAME="wmata_service.service"
SEAFOAM='\e[38;5;122m'
ORANGE='\033[38;5;202m'
PINK='\e[38;5;211m'
LUIGI='\e[38;5;183m'
RESETCOLOR='\033[0m'

# Check for API key argument
if [[ -z "$1" ]]; then
    # If not provided, prompt for the API key
    API=""
    while [[ -z "$API" ]]; do
        read -p "Please enter your API key for the WMATA Train Positions API: " API
    done
else
    API="$1"
fi

printf "\n"
printf "********************************************************************"
printf "\n"
printf "\n"

# Download the Python script
printf "${PINK}Downloading the WMATA Railtrack script...${RESETCOLOR}\n"
wget -O "$WMATADIR/$T_NAME" "$TRACKERURL"

# Check if the download was successful
if [[ $? -ne 0 ]]; then
    printf "${ORANGE}Failed to download the script. Please check your internet connection.${RESETCOLOR}\n"
    exit 1
fi

# Replace the placeholder API key in the downloaded script with the user input
sed -i "s|API = 'YOUR_API_KEY'|API = '$API'|g" "$WMATADIR/$T_NAME"

# Make the Python script executable
chmod +x "$WMATADIR/$T_NAME"

# Create the systemd service file
printf "${PINK}Creating the wmata_service.service service...${RESETCOLOR}\n"

cat <<EOL | sudo tee /etc/systemd/system/$SVC_NAME > /dev/null
[Unit]
Description=WMATA Railtrack

[Service]
ExecStart=/usr/bin/python3 $WMATADIR/$T_NAME
WorkingDirectory=$WMATADIR
StandardOutput=inherit
StandardError=inherit
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the service
printf "${PINK}Reloading the service...${RESETCOLOR}\n"
sudo systemctl daemon-reload
sudo systemctl enable $SVC_NAME

# Create a text file for instructions to load on boot
INSTRUCTIONS='
echo "***************************************************"
printf "\n"
printf "\e[38;5;211mWMATA RailTracker has been started.\033[0m"
printf "\n"
printf "\e[38;5;122mTo restart the tracker, run:\033[0m"
printf "python3 /home/$(whoami)/WMATA_RailTrack/wmata_railtrack_PUB.py"
printf "\n"
printf "\e[38;5;122mYou can also check the status with:\033[0m"
printf "sudo systemctl status wmata_service.service"
printf "\n"
echo "***************************************************"
'

# Check if the instructions already exist in .bashrc
printf "${PINK}Checking for startup instructions in .bashrc...${RESETCOLOR}\n"
if ! grep -q "WMATA RailTrack Instructions" ~/.bashrc; then
    printf "\n"
    printf "${PINK}Adding startup instructions to .bashrc...${RESETCOLOR}\n"
    echo "$INSTRUCTIONS" >> ~/.bashrc
    printf "\n\n"
else
    printf "\n"
    printf "${LUIGI}Startup instructions already exist in .bashrc!$RESETCOLOR\n"
    printf "\n"
    printf "********************************************************************"
    printf "\n\n"
fi

# Final message
printf "\n"
printf "${SEAFOAM}The WMATA RailTracker installation was successful!$RESETCOLOR\n"
printf "${SEAFOAM}Please review the script output for errors in configuration.$RESETCOLOR\n"
printf "\n"
echo "***************************************************"
printf "\n\n"

# Countdown before starting the service
countdown=30
printf "Press 's' to skip the countdown or Ctrl + C to abort startup.\n"
for ((i=countdown; i>0; i--)); do
    echo -ne "Starting in $ORANGE$i$RESETCOLOR seconds...\r"
    sleep 1 &
    read -t 1 -n 1 key  # Wait for 1 second for a single key press
    if [[ $key == "s" ]]; then
        printf "\nCountdown skipped!\n"
        break
    fi
    kill $!  # Kill the sleep command if user presses a key
done

# Start the service immediately
printf "\n${PINK}Starting the service...$RESETCOLOR\n"
if sudo systemctl start $SVC_NAME; then
    printf "\n${SEAFOAM}Service started successfully!$RESETCOLOR\n"
else
    printf "\n${ORANGE}Failed to start the service. Please check the logs for more information.${RESETCOLOR}\n"
fi
