import json
import copy
import csv

with open("./airports.json", "r") as airports_json:
    airports_list = json.load(airports_json)

    #watson entities
    airportCodes = []
    cities = []
    states = []
    airportNames = []
    # mapped object
    airportObjects = []

    for airport in airports_list:
        airportObject = {}

        airport = airport[:-2] if airport.endswith("\n") else airport
        components = airport.split("  ")
        code = components[0] #ORD
        codeEntity = "\"code\"," + "\"" + code + "\""
        if codeEntity not in airportCodes:
            airportCodes.append(codeEntity)
        airportObject["code"] = code

        second_components = components[1].split("-", 1)
        second_components = map(lambda x: x.strip(), second_components)
        if len(second_components) == 2:
            name = second_components[1] #O'Hare Chicago International
            nameEntity = "\"name\"," + "\"" + name + "\""
            if nameEntity not in airportNames:
                airportNames.append(nameEntity)
            airportObject["name"] = name

        address = second_components[0]
        comma_components = address.split(',')
        comma_components = map(lambda x: x.strip(), comma_components)

        city = comma_components[0] #Chicago
        cityEntity = "\"city\"," + "\"" + city + "\""
        if cityEntity not in cities:
            cities.append(cityEntity)
        airportObject["city"] = city

        if len(comma_components) == 2:
            state = comma_components[1] #IL
            stateEntity = "\"state\"," + "\"" + state + "\""
            if stateEntity not in states:
                states.append(stateEntity)
            airportObject["state"] = state

        airportObjects.append(airportObject)

with open("./codeEntities.csv", "w") as codeEntities:
    for codeEntity in airportCodes:
        codeEntities.write(codeEntity)
        codeEntities.write('\n')

with open("./nameEntities.csv", "w") as nameEntities:
    for nameEntity in airportNames:
        nameEntities.write(nameEntity)
        nameEntities.write('\n')

with open("./cityEntities.csv", "w") as cityEntities:
    for cityEntity in cities:
        cityEntities.write(cityEntity)
        cityEntities.write('\n')

with open("./stateEntities.csv", "w") as stateEntities:
    for stateEntity in states:
        stateEntities.write(stateEntity)
        stateEntities.write('\n')

with open('airport_objects.json', 'w') as outfile:
    json.dump(airportObjects, outfile)
