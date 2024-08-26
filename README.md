# WMATA-RailTrack
A train tracker for the Washington Metropolitan Area Transit Authority (WMATA) MetroRail.

## Introduction
This program uses the [WMATA TrainPositions API](https://developer.wmata.com/api-details#api=5763fa6ff91823096cac1057&operation=5763fb35f91823096cac1058) for all location data. It's designed to download and forget it using a loop to continuously run and update with new data from the API every 10 seconds.

##
    curl -O


## Necessary Libraries:

[__Requests:__](https://pypi.org/project/requests/) Allows Python to send HTTP/1.1 requests easily. Mandatory for functionality.
##
    pip3 install requests

[__Sty:__](https://pypi.org/project/sty/) Allows for string styling, in this case, coloring. Only needed for wmata_railtrack_PUB_Color.py
##
    pip3 install sty

## API Information:
The response elements used in this project are:
1. CircuitId: The circuit identifier the train is currently on.
2. DirectionNum: The direction the train is moving, irrespective of the track the train is on.
4. TrainId: Uniquely identifiable internal train identifier.
5. LineCode: Two-letter color abbreviation for the line.
