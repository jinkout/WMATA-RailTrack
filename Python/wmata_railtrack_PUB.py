    #                               xxxxxxxxxxxxxxx
    # ------------------          x                 x
    # |                 |        x   xxx       xxx    x
    # |   yippee!!!!!   |        x   x x       x x    x
    # |                  \       x   xxx       xxx    x
    # |                   \      x   xxx       xxx    x
    #  _____________________     x                    x
    #                            x      xxxx         x
    #                             x                 x
    #                                xx x x x xx x  x x xx 
    #                                 x                    x
    #                                 x                    x
    #                                 x   x                x
    #                                 x   x                x
    #                                 x   x   xxxx xx x    x
    #                                 x   x   x   x   x    x
    #                                 x   xx  xxxx    x    x
    #                                  xxx  xx         xx  x


# Importing necessary libraries.
import requests
import time

# List of all station names as they align with circuits.
# For more details, refer to the pdf found in the repo at https://github.com/jinkout/WMATA-RailTrack/blob/main/Information%20for%20Humans/Metro%20Station%20Information.pdf
STATIONNAMES = [
    "Metro Center", "Farragut N", "Dupont Circle", "Woodley Park-Zoo/Adams Morgan",
    "Cleveland Park", "Van Ness-UDC", "Tenleytown-AU", "Friendship Heights",
    "Bethesda", "Medical Center", "Grosvenor-Strathmore", "North Bethesda",
    "Twinbrook", "Rockville", "Shady Grove", "Gallery Pl-Chinatown",
    "Judiciary Square", "Union Station", "Rhode Island Ave-Brentwood", "Brookland-CUA",
    "Fort Totten", "Takoma", "Silver Spring", "Forest Glen",
    "Wheaton", "Glenmont", "NoMa-Gallaudet U", "Metro Center",
    "Metro Center", "Metro Center", "McPherson Square", "McPherson Square",
    "McPherson Square", "Farragut West", "Farragut West", "Farragut West",
    "Foggy Bottom-GWU", "Foggy Bottom-GWU", "Foggy Bottom-GWU", "Rosslyn",
    "Rosslyn", "Rosslyn", "Arlington Cemetery", "Pentagon",
    "Pentagon", "Pentagon City", "Pentagon City", "Crystal City",
    "Crystal City", "Ronald Reagan Washington National Airport", "Ronald Reagan Washington National Airport",
    "Potomac Yard", "Potomac Yard", "Braddock Road", "Braddock Road",
    "King St-Old Town", "King St-Old Town", "Eisenhower Avenue", "Huntington",
    "Federal Triangle", "Federal Triangle", "Federal Triangle", "Smithsonian",
    "Smithsonian", "Smithsonian", "L'Enfant Plaza", "L'Enfant Plaza",
    "L'Enfant Plaza", "Federal Center SW", "Federal Center SW", "Federal Center SW",
    "Capitol South", "Capitol South", "Capitol South", "Eastern Market",
    "Eastern Market", "Eastern Market", "Potomac Ave", "Potomac Ave",
    "Potomac Ave", "Stadium-Armory", "Stadium-Armory", "Stadium-Armory",
    "Minnesota Ave", "Deanwood", "Cheverly", "Landover",
    "New Carrollton", "Mt Vernon Sq 7th St-Convention Center", "Mt Vernon Sq 7th St-Convention Center",
    "Shaw-Howard U", "Shaw-Howard U", "U Street/African-Amer Civil War Memorial/Cardozo",
    "Columbia Heights", "Georgia Ave-Petworth", "Fort Totten", "West Hyattsville",
    "Hyattsville Crossing", "College Park-U of Md", "Greenbelt", "Gallery Pl-Chinatown",
    "Gallery Pl-Chinatown", "Archives-Navy Memorial-Penn Quarter", "Archives-Navy Memorial-Penn Quarter",
    "L'Enfant Plaza", "L'Enfant Plaza", "Waterfront", "Navy Yard-Ballpark",
    "Anacostia", "Congress Heights", "Southern Avenue", "Naylor Road",
    "Suitland", "Branch Ave", "Benning Road", "Benning Road",
    "Capitol Heights", "Capitol Heights", "Addison Road-Seat Pleasant", "Addison Road-Seat Pleasant",
    "Morgan Boulevard", "Morgan Boulevard", "Downtown Largo", "Downtown Largo",
    "Van Dorn Street", "Franconia-Springfield", "Court House", "Court House",
    "Clarendon", "Clarendon", "Virginia Square-GMU", "Virginia Square-GMU",
    "Ballston-MU", "Ballston-MU", "East Falls Church", "East Falls Church",
    "West Falls Church", "Dunn Loring-Merrifield", "Vienna/Fairfax-GMU", "McLean",
    "Tysons", "Greensboro", "Spring Hill", "Wiehle-Reston East",
    "Reston Town Center", "Herndon", "Innovation Center", "Washington Dulles International Airport",
    "Loudoun Gateway", "Ashburn"
]

# List of all circuits as they align with station names.
# For more details, refer to the pdf found in the repo at https://github.com/jinkout/WMATA-RailTrack/blob/main/Information%20for%20Humans/Metro%20Station%20Information.pdf
CIRCUITIDS = [
    203, 190, 179, 363, 154, 142, 336, 126, 109, 95, 
    80, 62, 53, 32, 7, 467, 466, 485, 513, 527, 
    548, 571, 591, 611, 629, 625, 700, 1135, 1135, 
    1135, 1126, 1126, 1126, 1117, 1117, 1117, 1105, 
    1105, 1105, 1092, 1092, 1092, 1070, 1052, 1052, 
    1036, 1036, 1024, 1024, 1010, 1010, 3493, 3493, 
    976, 976, 969, 969, 955, 944, 1384, 1384, 1384, 
    1393, 1393, 1393, 1400, 1400, 1400, 1406, 1406, 
    1406, 1418, 1418, 1418, 1424, 1424, 1424, 1436, 
    1436, 1436, 1443, 1443, 1443, 1475, 1487, 1500, 
    1522, 1542, 1753, 1753, 1764, 1764, 1773, 1782, 
    1796, 1809, 1833, 1840, 1871, 1894, 2246, 2246, 
    2241, 2241, 2231, 2231, 2219, 2208, 2199, 2183, 
    2170, 2154, 2136, 2118, 2420, 2420, 2434, 2434, 
    2449, 2449, 2469, 2469, 2487, 2487, 2634, 2604, 
    2911, 2911, 2898, 2898, 2886, 2886, 2870, 2870, 
    2844, 2844, 2817, 2796, 2774, 3238, 3232, 3221, 
    3214, 3155, 3627, 3612, 3594, 3577, 3544, 3523, 
    661, 389, 378, 164, 356, 336, 326, 309, 
    294, 80, 260, 251, 232, 210, 667, 677, 
    686, 717, 731, 757, 785, 809, 828, 846, 
    868, 496, 1330, 1330, 1330, 1323, 1323, 1323, 
    1310, 1310, 1310, 1298, 1298, 1298, 1285, 1285, 
    1285, 1265, 1246, 1246, 1230, 1230, 1217, 1217, 
    1204, 1204, 3512, 3512, 1170, 1170, 1162, 1162, 
    1148, 1137, 1549, 1549, 1549, 1559, 1559, 1559, 
    1568, 1568, 1568, 1575, 1575, 1575, 1590, 1590, 
    1590, 1598, 1598, 1598, 1610, 1610, 1610, 1618, 
    1618, 1618, 1643, 1657, 1670, 1692, 1711, 1911, 
    1911, 1923, 1923, 1923, 1942, 1956, 1971, 1992, 
    2009, 2030, 2055, 1899, 1899, 2376, 2376, 2364, 
    2364, 2352, 2342, 2333, 2317, 2303, 2291, 2272, 
    2255, 2506, 2506, 2521, 2521, 2537, 2537, 2557, 
    2557, 2574, 2574, 2709, 2679, 3061, 3061, 3048, 
    3048, 3037, 3037, 3023, 3023, 3001, 3001, 2976, 
    2954, 2933, 3377, 3370, 3359, 3352, 3290, 3741, 
    3724, 3706, 3689, 3657, 3637
]

# Mapping station names and circuit ID arrays.
CIRCUITBYNAME = dict(zip(CIRCUITIDS,STATIONNAMES))

# Make sure to implement YOUR API key here!
API = 'YOUR_API_KEY'
URL = 'http://api.wmata.com/TrainPositions/TrainPositions?contentType=json'

# For continuous running. If you want to run it manually: remove the while True, remove the time.sleep(10) at the bottom, and make sure to outdent.
while True:
    response = requests.get(URL, headers={"api_key": API})

    # If the API responds with no errors, then...
    if response.status_code == 200:
        data = response.json()

        # For each train in the raw data returned by the API, get the Train ID, the Circuit ID, the Line Code, and its Direction.
        for train in data["TrainPositions"]:
            train_id = train.get("TrainId")
            circuitID = train.get("CircuitId")
            lineCode = train.get("LineCode")
            direction = train.get("DirectionNum")

            # Print information for all trains.
            print(f"Train ID: {train_id}")
            print(f"Line: {lineCode}")
            
            # Print station name if the circuit ID matches.
            if circuitID in CIRCUITBYNAME:
                stationName = CIRCUITBYNAME[circuitID]
                print(f"Station: {stationName}")
            # If there's no match, the train is deemed not at a station and will return "En route..."
            else:
                print("Station: En route...")
            
            print(f"Circuit ID: {circuitID}")
            
            # Print direction information 
            if direction == 1:
                print("Direction: Northbound/Eastbound")
            elif direction == 2:
                print("Direction: Southbound/Westbound")
            else:
                print("Directional data not found.")
            
            # In between runs of the program, print some asterisks to show it's the end of a set of results.
            print("-" * 20)

    # If there's an error code, print failure and return the code.
    else:
        print(f"Failed to retrieve data: {response.status_code}")
        # Some common error codes and their solutions.
        if response.status_code == 401:
            print("Verify your API key is correct, Line 117.")
            break
        elif response.status_code == 404:
            print("Verify your URL is correct, Line 118.")
            break
        elif response.status_code == 429:
            print("\n Whoa there, slow down! Too many requests! Add a time.sleep(x) or other method.")
            break
    print("*" * 5, "Updating Locations", "*" *5)
    time.sleep(10)