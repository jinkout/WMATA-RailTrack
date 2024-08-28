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

# Printing a warning to users
printf "\n"
printf "${ORANGE}***** ${RESETCOLOR}${SEAFOAM}This installation will make the RailTracker start immediately.${RESETCOLOR}${ORANGE} *****${RESETCOLOR}\n"

# Prompt for the user's API key or take it as an argument
API="${1:-}"
if [[ -z "$API" ]]; then
    printf "${PINK}Starting WMATA Railtrack installation...${RESETCOLOR}\n"
    read -p "Please enter your API key for the WMATA Train Positions API: " API
fi
printf "\n********************************************************************\n\n"

# Download the Python script
printf "${PINK}Downloading the WMATA Railtrack script...${RESETCOLOR}\n"
if ! curl -o "$WMATADIR/$T_NAME" "$TRACKERURL"; then
    printf "${ORANGE}Failed to download the script. Please check your internet connection.${RESETCOLOR}\n"
    exit 1
fi
printf "\n********************************************************************\n\n"

# Replace the placeholder API key in the downloaded script with whatever the user inputted previously
sed -i "s|API = 'YOUR_API_KEY'|API = '$API'|g" "$WMATADIR/$T_NAME"

# Make the Python script executable
chmod +x "$WMATADIR/$T_NAME"

# Create the systemd service file
printf "${PINK}Creating the wmata_service.service service...$RESETCOLOR\n"

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
printf "${PINK}Reloading the service...$RESETCOLOR\n"
sudo systemctl daemon-reload
sudo systemctl enable "$SVC_NAME"
sudo systemctl start "$SVC_NAME"

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
printf "${PINK}Checking for startup instructions in .bashrc...$RESETCOLOR\n"
if ! grep -q "WMATA RailTrack Instructions" ~/.bashrc; then
    printf "${PINK}Adding startup instructions to .bashrc...$RESETCOLOR\n"
    echo "$INSTRUCTIONS" >> ~/.bashrc
else
    printf "${LUIGI}Startup instructions already exist in .bashrc!$RESETCOLOR\n"
    printf "********************************************************************\n\n"
fi

# Final message
printf "${SEAFOAM}The WMATA RailTracker installation was successful!$RESETCOLOR\n"
printf "${SEAFOAM}Please review the script output for errors in configuration.$RESETCOLOR\n"
printf "***************************************************\n\n"

# Countdown before starting the Python script
countdown=30
printf "Press $SEAFOAM's'$RESETCOLOR to skip the countdown or ${LUIGI}Ctrl + C$RESETCOLOR to abort startup."
for ((i=countdown; i>0; i--)); do
    echo -ne "Starting in $ORANGE$i$RESETCOLOR seconds...\r"
    sleep 1 &
    read -t 1 -n 1 key
    if [[ $key == "s" ]]; then
        printf "\nCountdown skipped!"
        break
    fi
    kill $!  # Kill the sleep command if user presses a key
done

# Start the service immediately
printf "\n${PINK}Starting the service...$RESETCOLOR\n"
sleep 2
python3 -u "$WMATADIR/$T_NAME" &
