#!/bin/bash
#skipped 13 already got enough bad luck

# WMATA Railtrack Installer
# This script downloads the WMATA RailTrack Python application,
# configures it with the user's API key, and sets it up as a systemd service.

# Creating the WMATA RailTrack directory
WMATADIR="/home/$(whoami)/WMATA_RailTrack"
mkdir -p "$WMATADIR"

# Storing info in shorter variables
TRACKERURL="https://raw.githubusercontent.com/jinkout/WMATA-RailTrack/main/Python/wmata_railtrack_PUB_Color.py"
T_NAME="$WMATADIR/wmata_railtrack_PUB.py"  # Updated path
SVC_NAME="wmata_service.service"
SEAFOAM='\e[38;5;122m'
ORANGE='\033[38;5;202m'
PINK='\e[38;5;211m'
LUIGI='\e[38;5;183m'
RESETCOLOR='\033[0m'

# Printing a warning to users
printf "\n"
echo -e "${ORANGE}***** ${RESETCOLOR}${SEAFOAM}This installation will make the RailTracker start immediately.${RESETCOLOR}${ORANGE} *****${RESETCOLOR}"
printf "\n"

# Prompt for the user's API key
echo -e "${PINK}Starting WMATA Railtrack installation...$RESETCOLOR"
read -p "Please enter your API key for the WMATA Train Positions API: " API
printf "********************************************************************"
printf "\n"
printf "\n"

# Download the Python script
echo -e "${PINK}Downloading the WMATA Railtrack script...$RESETCOLOR"
curl -o "$T_NAME" "$TRACKERURL"  # Updated to save directly to the intended location
printf "********************************************************************"
printf "\n"
printf "\n"

# Check if the download was successful
if [[ $? -ne 0 ]]; then
    echo -e "${ORANGE}Failed to download the script. Please check your internet connection.${RESETCOLOR}"
    exit 1
fi

# Replace the placeholder API key in the downloaded script with whatever the user inputted previously
sed -i "s|API = 'YOUR_API_KEY'|API = '$API'|g" "$T_NAME"

# Make the Python script executable
chmod +x "$T_NAME"

# Create the systemd service file
echo -e "${PINK}Creating the wmata_service.service service...$RESETCOLOR"
cat <<EOL | sudo tee /etc/systemd/system/$SVC_NAME > /dev/null 2>&1
[Unit]
Description=WMATA Railtrack

[Service]
ExecStart=/usr/bin/python3 $T_NAME
WorkingDirectory=$WMATADIR
StandardOutput=inherit
StandardError=inherit
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Enable wmata_service.service to run
echo -e "${PINK}Reloading the service...$RESETCOLOR"
sudo systemctl daemon-reload
sudo systemctl enable "$SVC_NAME"
sudo systemctl start "$SVC_NAME"
sudo systemctl restart "$SVC_NAME"
printf "\n\n"

# Create a text file for instructions to load on boot
INSTRUCTIONS='
echo "***************************************************"
# WMATA RailTrack Instructions
printf "\n"
echo -e "\e[38;5;211mWMATA RailTracker has been started.\033[0m"
printf "\n"
echo -e "\e[38;5;122mTo restart the tracker, run:\033[0m"
echo -e "python3 /home/$(whoami)/WMATA_RailTrack/wmata_railtrack_PUB.py"
printf "\n"
echo -e "\e[38;5;122mYou can also check the status with:\033[0m"
echo -e "sudo systemctl status wmata_service.service"
printf "\n"
echo "***************************************************"
'

# Check if the instructions already exist in .bashrc
echo -e "${PINK}Checking for startup instructions in .bashrc...$RESETCOLOR"
if ! grep -q "WMATA RailTrack Instructions" ~/.bashrc; then
    printf "\n"
    echo -e "${PINK}Adding startup instructions to .bashrc...$RESETCOLOR"
    echo "$INSTRUCTIONS" >> ~/.bashrc
    printf "\n\n"
else
    printf "\n"
    echo -e "${LUIGI}Startup instructions already exist in .bashrc!$RESETCOLOR"
    printf "********************************************************************"
    printf "\n"
    printf "\n"
fi

# Final message
printf "\n"
echo -e "${SEAFOAM}The WMATA RailTracker installation was successful!$RESETCOLOR"
echo -e "${SEAFOAM}Please review the script output for errors in configuration.$RESETCOLOR"
echo "***************************************************"
printf "\n"
printf "\n"

# Countdown before starting the Python script so there's time to read everything
countdown=30
echo -e "Press $SEAFOAM's'$RESETCOLOR to skip the countdown or ${LUIGI}Ctrl + C$RESETCOLOR to abort startup."
for ((i=countdown; i>0; i--)); do
    echo -ne "Starting in $ORANGE$i$RESETCOLOR seconds...\r"
    sleep 1 &
    read -t 1 -n 1 key  # Wait for 1 second for a single key press
    if [[ $key == "s" ]]; then
        printf "\nCountdown skipped!"
        break
    fi
    kill $!  # Kill the sleep command if user presses a key
done

# Start the service immediately
echo -e "\n${PINK}Starting the service...$RESETCOLOR"
printf "\n"
sleep 2
python3 -u "$T_NAME"
