import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:voyager_net/spacecraft.dart';

class Server {
  /// Endpoint the server is targeting
  static Uri endpoint = Uri.parse("http://navigation.indoorsgroup.ca:34568");

  static Future<Spacecraft> fetchUpdate() async {
    final stopwatch = Stopwatch();
    stopwatch.start();
    final updateResponse = await http.get(
      endpoint.replace(path: "/get"),
    );
    stopwatch.stop();
    print("get fetch took ${stopwatch.elapsedMilliseconds} ms");

    // Error checking
    if (updateResponse.statusCode != 200) {
      throw Exception("Error: Update could not be retrieved from the server.");
    }

    return compute(_parseUpdateResponse, updateResponse);
  }

  static Spacecraft _parseUpdateResponse(Response updateResponse) {
    // Decode encoded responses
    Map<String, dynamic> decodedResponses = jsonDecode(updateResponse.body);
    String mapDataResponseBody = decodedResponses['mapDataResponse'];
    Uint8List mapImageBytes = base64Decode(decodedResponses['mapImageResponse']);

    // Decode the JSON response to get the map image size
    Map<String, dynamic> updateJson = jsonDecode(mapDataResponseBody);
    return Spacecraft(
        Offset(updateJson["position"]["x"].toDouble(), updateJson["position"]["y"].toDouble()),
        updateJson["rotation"].toDouble(),
        updateJson["velocity"].toDouble()
    );
  }

  // /// Fetches building bounds for a specific floor.
  // static Future<BuildingBounds> fetchBuildingBoundsForFloor(int floor) async {
  //   // GET [building-bounds] is JSON with ARGS {"floor"}
  //   //  [
  //   //    {
  //   //      "name": "ASB 9000",
  //   //      "topLeftCorner": {
  //   //        "lat": 49.283,
  //   //        "lng": -123.121
  //   //      },
  //   //      "bottomLeftCorner": {
  //   //        "lat": 49.282,
  //   //        "lng": -123.121
  //   //      },
  //   //      "bottomRightCorner": {
  //   //        "lat": 49.282,
  //   //        "lng": -123.120
  //   //      },
  //   //      "name": "AQ 8000",
  //   //      "topLeftCorner": {
  //   //        "lat": 49.283,
  //   //        "lng": -123.121
  //   //      },
  //   //      "bottomLeftCorner": {
  //   //        "lat": 49.282,
  //   //        "lng": -123.121
  //   //      },
  //   //      "bottomRightCorner": {
  //   //        "lat": 49.282,
  //   //        "lng": -123.120
  //   //      },
  //   //  ]
  //   final stopwatch = Stopwatch();
  //   stopwatch.start();
  //   final buildingBoundsResponse = await http.get(
  //     endpoint.replace(path: "/building-bounds", queryParameters: {"floor": floor.toString()}),
  //   );
  //   stopwatch.stop();
  //   printDebug("building-bounds fetch took ${stopwatch.elapsedMilliseconds} ms");
  //
  //   // Error checking
  //   if (buildingBoundsResponse.statusCode != 200) {
  //     throw Exception("Error: Building bounds could not be retrieved from Navigation Server.");
  //   }
  //
  //   return compute(_parseBuildingBounds, buildingBoundsResponse);
  // }
  //
  // static BuildingBounds _parseBuildingBounds(Response buildingBoundsResponse) {
  //   // Parse the JSON response
  //   List<dynamic> jsonResponse = json.decode(buildingBoundsResponse.body);
  //
  //   // Convert the list of maps to a list of Buildings
  //   BuildingBounds buildingBounds = jsonResponse.map((item) {
  //     return Building(
  //       item["name"],
  //       LatLng(item["topLeftCorner"]["lat"].toDouble(), item["topLeftCorner"]["lng"].toDouble()),
  //       LatLng(item["bottomLeftCorner"]["lat"].toDouble(), item["bottomLeftCorner"]["lng"].toDouble()),
  //       LatLng(item["bottomRightCorner"]["lat"].toDouble(), item["bottomRightCorner"]["lng"].toDouble()),
  //     );
  //   }).toList();
  //
  //   return buildingBounds;
  // }
  //
  // /// Fetches nodes, given a partial or exact name, up to the given count.
  // /// For example, if exactMatch is true and count is 3, "ASB 9001" will return
  // /// a list containing only "ASB 9001" if it is unique. If it is not unique, it
  // /// will return multiple nodes with name "ASB 9001".
  // static Future<List<MapNode>> fetchNodesByName(int count, bool exactMatch, String name) async {
  //   // GET [nodes-by-name] is JSON with ARGS {"count", "exact", "name"}
  //   //  [
  //   //    {
  //   //      "id": 29
  //   //      "name": "ASB 8800",
  //   //      "x": 100,
  //   //      "y": 100,
  //   //      "floor": 0
  //   //    },
  //   //    {
  //   //      "id": 30
  //   //      "name": "ASB 8801",
  //   //      "x": 100,
  //   //      "y": 120,
  //   //      "floor": 0
  //   //    }
  //   //  ]
  //   final stopwatch = Stopwatch();
  //   stopwatch.start();
  //   final nodesByNameResponse = await http.get(
  //     endpoint.replace(path: "/nodes-by-name", queryParameters: {
  //       "count": count.toString(),
  //       "exact": exactMatch.toString(),
  //       "name": name
  //     }),
  //   );
  //   stopwatch.stop();
  //   printDebug("nodes-by-name fetch took ${stopwatch.elapsedMilliseconds} ms");
  //
  //   // Error checking
  //   if (nodesByNameResponse.statusCode != 200) {
  //     throw Exception("Error: Nodes could not be retrieved from Navigation Server.");
  //   }
  //
  //   return compute(_parseNodesByName, nodesByNameResponse);
  // }
  //
  // static List<MapNode> _parseNodesByName(Response nodesByNameResponse) {
  //   // Parse the JSON response
  //   List<dynamic> jsonResponse = json.decode(nodesByNameResponse.body);
  //
  //   // Convert the json response to a list of Nodes
  //   List<MapNode> nodes = jsonResponse.map((nodeData) {
  //     return MapNode(
  //       nodeData["ID"].toInt(),
  //       nodeData["name"],
  //       "",
  //       LatLng(nodeData["GPSLat"].toDouble(), nodeData["GPSLong"].toDouble()),
  //       nodeData["floor"].toInt(),
  //     );
  //   }).toList();
  //
  //   return nodes;
  // }
  //
  // static Future<HashMap<String, NavPath>> fetchPathsToDestination(MapNode origin, MapNode destination, bool bathroomFinder) async {
  //   // POST [paths-to-destination] is JSON
  //   //  {
  //   //    "start": "ASB 8800",
  //   //    "end": "ASB 8801", (can be empty string in case of bathroomFinder being true)
  //   //    "bathroomFinder": false,
  //   //    "settings": {
  //   //      "stairsPreference": "preferred",
  //   //      "rampsPreference": "allowed",
  //   //      "elevatorsPreference": "notAllowed",
  //   //      "genderPreference": "male" (other options are "female" and "diverse")
  //   //      "accessibleStallRequired": true
  //   //    },
  //   //  }
  //   // GET [paths-to-destination] is JSON
  //   //  [
  //   //    {
  //   //      "metric": {
  //   //        "name": "Distance",
  //   //        "value": 20 (total distance)
  //   //      },
  //   //      "path": [
  //   //        {
  //   //          "id": 29,
  //   //          "name": "ASB 8800",
  //   //          "feature": "",
  //   //          "x": 100,
  //   //          "y": 100,
  //   //          "floor": 0,
  //   //          "remaining": 20 (metric from this node)
  //   //        },
  //   //        {
  //   //          "id": 30,
  //   //          "name": "ASB 8801",
  //   //          "feature": "Stairs",
  //   //          "x": 100,
  //   //          "y": 120,
  //   //          "floor": 0,
  //   //          "remaining": 0
  //   //        }
  //   //      ]
  //   //    },
  //   //    {
  //   //      "metric": {
  //   //        "name": "Time",
  //   //        "value": 15 (total time)
  //   //      },
  //   //      "path": [
  //   //        {
  //   //          "id": 29,
  //   //          "name": "ASB 8800",
  //   //          "feature": "",
  //   //          "x": 100,
  //   //          "y": 100,
  //   //          "floor": 0,
  //   //          "remaining": 15 (metric from this node)
  //   //        },
  //   //        {
  //   //          "id": 30,
  //   //          "name": "ASB 8801",
  //   //          "feature": "Stairs",
  //   //          "x": 100,
  //   //          "y": 120,
  //   //          "floor": 0,
  //   //          "remaining": 0
  //   //        }
  //   //      ]
  //   //    },
  //   //  ]
  //
  //   if (!origin.hasLocationAndFloor() || (!destination.hasLocationAndFloor() && !bathroomFinder)) {
  //     throw Exception("Error: Map Node malformed.");
  //   }
  //
  //   // If origin is current location, we need to call a slightly different endpoint
  //   Response pathsToDestinationResponse;
  //   final stopwatch = Stopwatch();
  //   stopwatch.start();
  //   if (origin.isCurrentLocation() || origin.isSelectedLocation()) {
  //     pathsToDestinationResponse = await http.post(
  //       endpoint.replace(path: "/paths-to-destination-from-closest"),
  //       headers: <String, String>{
  //         "Content-Type": "application/json; charset=UTF-8",
  //       },
  //       body: jsonEncode(<String, dynamic>{
  //         "startLat": origin.location!.latitude,
  //         "startLng": origin.location!.longitude,
  //         "end": destination.name,
  //         "bathroomFinder": bathroomFinder,
  //         "userFloor": origin.logicalFloor,
  //         "endFloorPlan": 0,
  //         "settings": await SettingsContainer.jsonify(),
  //       }),
  //     );
  //   }
  //   else {
  //     pathsToDestinationResponse = await http.post(
  //       endpoint.replace(path: "/paths-to-destination"),
  //       headers: <String, String>{
  //         "Content-Type": "application/json; charset=UTF-8",
  //       },
  //       body: jsonEncode(<String, dynamic>{
  //         "start": origin.name,
  //         "end": destination.name,
  //         "bathroomFinder": bathroomFinder,
  //         "startFloorPlan": 0,
  //         "endFloorPlan": 0,
  //         "settings": await SettingsContainer.jsonify(),
  //       }),
  //     );
  //   }
  //   stopwatch.stop();
  //   printDebug("paths-to-destination fetch took ${stopwatch.elapsedMilliseconds} ms");
  //
  //   // Error checking
  //   if (pathsToDestinationResponse.statusCode != 200) {
  //     throw Exception("Error: Paths could not be retrieved from Navigation Server.");
  //   }
  //
  //   return compute(_parsePathsToDestination, pathsToDestinationResponse);
  // }
  //
  // static HashMap<String, NavPath> _parsePathsToDestination(Response pathsToDestinationResponse) {
  //   // Parse the JSON response
  //   final responseJson = jsonDecode(pathsToDestinationResponse.body);
  //
  //   // Convert the JSON response into a map of Metric name and NavPath
  //   HashMap<String, NavPath> navPaths = HashMap.fromIterable(
  //     responseJson,
  //     key: (pathJson) {
  //       // Extract the metric name to use as the key
  //       return pathJson["metric"]["name"] as String;
  //     },
  //     value: (pathJson) {
  //       // Parse the metric
  //       Metric metric = Metric(
  //         pathJson["metric"]["name"],
  //         pathJson["metric"]["value"].toDouble(),
  //       );
  //
  //       // Parse the path
  //       List<MapNode> path = (pathJson["path"] as List).map<MapNode>((nodeJson) {
  //         return MapNode(
  //           nodeJson["id"].toInt(),
  //           nodeJson["name"],
  //           nodeJson["feature"],
  //           LatLng(nodeJson["y"].toDouble(), nodeJson["x"].toDouble()),
  //           nodeJson["floor"].toInt(),
  //           nodeJson["remaining"].toDouble(),
  //         );
  //       }).toList();
  //
  //       // Create and return the NavPath object
  //       return NavPath(metric, path);
  //     },
  //   );
  //
  //   return navPaths;
  // }
}
