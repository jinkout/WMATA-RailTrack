# 🚂 WMATA-RailTrack 🚂
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
1. __CircuitId:__ The circuit identifier the train is currently on.
2. __DirectionNum:__ The direction the train is moving, irrespective of the track the train is on.
4. __TrainId:__ Uniquely identifiable internal train identifier.
5. __LineCode:__ Two-letter color abbreviation for the line.

## Information for Humans:
For more human-readable information on the MetroRail circuit and station system, open the Information for Humans folder.
There, you will find a PDF that contains 2 tables with information on all stations:

| Station Code | Station Name | Line Color | CircuitID | Sequence Number |

The tables are split by which direction (1 or 2) that the trains are currently traveling because the circuit ID can be different for the same station based on direction.
