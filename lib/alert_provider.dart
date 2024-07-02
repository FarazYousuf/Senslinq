import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:senslinq/globals.dart' as globals;

class AlertProvider with ChangeNotifier {
  int totalAlerts = 0;
  int activeAlerts = 0;
  int AttendedAlerts = 0;
  List<dynamic> alertdata = [];
  List<dynamic> sensordata = [];

  Future<void> fetchAlertData(String token) async {
    totalAlerts = 0;
    activeAlerts = 0;
    AttendedAlerts = 0;
    final url = Uri.parse(globals.Globals.apiUrl + '/api/v1/getsensorstatus');
    final url2 = Uri.parse(globals.Globals.apiUrl + '/api/v1/getalerts');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final sensorresponse = await http.get(url, headers: headers);
      if (sensorresponse.statusCode == 200) {
        sensordata = json.decode(sensorresponse.body);
        debugPrint('Fetched Alert Data: $sensordata');

        // totalAlerts = sensordata.length;
        for (var sensor in sensordata) {
          if (sensor['sensorData']['gasLevel'] == 'mild' ||
              sensor['sensorData']['gasLevel'] == 'heavy' ||
              sensor['sensorData']['gasLevel'] == 'test') {
            activeAlerts++;
          }
          if (sensor['attendingUsers'] != null &&
              sensor['attendingUsers'].isNotEmpty) {
            AttendedAlerts++;
          }
        }
      } else {
        print('Failed to fetch alert data: ${sensorresponse.body}');
        throw Exception('Invalid token or server error');
      }
      final alertresponse = await http.get(url2, headers: headers);
      if (alertresponse.statusCode == 200) {
        alertdata = json.decode(alertresponse.body);
        debugPrint('Fetched Alert Data: $alertdata');

        // totalAlerts = alertdata.length;
        for (var alert in alertdata) {
          if (alert['tag'] == 'alert') {
            totalAlerts++;
          } else {
            print('No alert found');
          }
        }

        notifyListeners();
      } else {
        print('Failed to fetch alert data: ${alertresponse.body}');
        throw Exception('Invalid token or server error');
      }
    } catch (error) {
      print('Error fetching alert data: $error');
      throw Exception('Error fetching alert data');
    }
  }
}
