import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:voyager_net/spacecraft.dart';

class Server {
  /// Endpoint the server is targeting
  //static Uri endpoint = Uri.parse("http://voyagernet.amot.dev:5000");
  //static Uri endpoint = Uri.parse("http://192.168.199.89:5000");
  static Uri endpoint = Uri.parse("http://127.0.0.1:5000");

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
    Map<String, dynamic> updateJson = jsonDecode(updateResponse.body);
    return Spacecraft(
        Offset(updateJson["position"]["x"].toDouble(), updateJson["position"]["y"].toDouble()),
        updateJson["rotation"].toDouble(),
        updateJson["orbital_velocity"].toDouble()
    );
  }

  static Future<void> setRotation(double rotation) async {
    final response = await http.post(
      endpoint.replace(path: "/set_rotation"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"rotation": rotation}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error: Could not set rotation.");
    }

    print("Rotation set to $rotation");
  }

  static Future<void> setThrust(int thrustPercent) async {
    final response = await http.post(
      endpoint.replace(path: "/set_thrust"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"thrust_percent": thrustPercent}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error: Could not set thrust.");
    }

    print("Thrust set to $thrustPercent%");
  }
}
