import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:senslinq/globals.dart' as globals; 

class SensorProvider with ChangeNotifier {
  int totalSensors = 0;
  int onlineSensors = 0;
  int offlineSensors = 0;
  List<dynamic> Sensordata = [];
  Map<String, dynamic> sensorData = {};

  List<Map<String, dynamic>> onlineSensorLocations = [];
  List<Map<String, dynamic>> offlineSensorLocations = [];

  Future<void> fetchSensorData(String token) async {
    final url = Uri.parse(
        globals.Globals.apiUrl +'/api/v1/getsensorstatus');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        Sensordata = json.decode(response.body);

        onlineSensorLocations.clear();
        offlineSensorLocations.clear();
        onlineSensors = 0;
        offlineSensors = 0;

        totalSensors = Sensordata.length;

        for (var sensor in Sensordata) {
          LatLng location = LatLng(
            double.parse(sensor['locationCoordinates']['latitude']),
            double.parse(sensor['locationCoordinates']['longitude']),
          );
          String gasLevel = sensor['sensorData']['gasLevel'];
          String Lalias = sensor['locationAlias'];
          String Status = sensor['status'];
          String Concentration = sensor['sensorData']['concentration'];

          print(Status);

          sensorData = {
            'location': location,
            'Gaslevel': gasLevel,
            'locationAlias': Lalias,
            'Status': Status,
            'Concentration': Concentration,
          };

          if (sensor['status'] == 'online') {
            onlineSensorLocations.add(sensorData);
            onlineSensors++;
          } else if (sensor['status'] == 'offline') {
            offlineSensorLocations.add(sensorData);
            offlineSensors++;
          }
        }

        notifyListeners();
      } else {
        throw Exception('Failed to fetch sensor data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching sensor data: $error');
    }
  }

  // --------------------------Fetch Events Data------------------------------
  // -------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchEventData(String token) async {
    final url =
        Uri.parse(globals.Globals.apiUrl +'/api/v1/getevents');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> eventData = json.decode(response.body);
        return eventData.map((event) {
          return {
            'eventTime': event['eventTime'],
            'eventDescription': event['eventDescription'],
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch events data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching events data: $error');
    }
  }
}

