import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senslinq/alert_provider.dart';
import 'package:senslinq/sensor_provider.dart';
import 'package:senslinq/language_provider.dart';

class AlertDetailsScreen extends StatefulWidget {
  final String token;

  const AlertDetailsScreen({Key? key, required this.token}) : super(key: key);

  @override
  _AlertDetailsScreenState createState() => _AlertDetailsScreenState();
}

class _AlertDetailsScreenState extends State<AlertDetailsScreen> {
  bool _isLoading = false;

  Future<void> _fetchAlertData() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<AlertProvider>(context, listen: false).fetchAlertData(widget.token);
    await Provider.of<SensorProvider>(context, listen: false).fetchSensorData(widget.token);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          languageProvider.getTranslatedValue('alertsLogs'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _fetchAlertData,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(54, 185, 140, 1),
              ),
            )
          : FutureBuilder(
              future: fetchAllData(context, widget.token),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color.fromRGBO(54, 185, 140, 1)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final sensorProvider = Provider.of<SensorProvider>(context);
                  final alertProvider = Provider.of<AlertProvider>(context);
                  final formattedAlertLogs = getFormattedAlertLogs(
                      alertProvider.alertdata, sensorProvider.Sensordata);

                  return ListView.builder(
                    itemCount: formattedAlertLogs.length,
                    itemBuilder: (context, index) {
                      final log = formattedAlertLogs[index].split(': ');

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                        // color: const Color.fromRGBO(190, 233, 218, 1),
                        color: const Color.fromARGB(255, 223, 253, 243),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log[0],
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                log[1],
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
    );
  }

  Future<void> fetchAllData(BuildContext context, String token) async {
    await Provider.of<AlertProvider>(context, listen: false).fetchAlertData(token);
    await Provider.of<SensorProvider>(context, listen: false).fetchSensorData(token);
  }

  List<String> getFormattedAlertLogs(
      List<dynamic> alerts, List<dynamic> sensors) {
    var formattedEvents = <String>[];

    if (alerts.isEmpty || sensors.isEmpty) return formattedEvents;

    for (var alert in alerts) {
      var sensor = sensors.firstWhere((s) => s['sensorId'] == alert['sensorId'],
          orElse: () => null);
      if (sensor != null) {
        String formattedTimestamp =
            DateTime.parse(alert['updatedAt']).toString().split('.')[0];
        String formattedEvent =
            "$formattedTimestamp: ${sensor['locationAlias'].toUpperCase()} ${sensor['type'].toUpperCase()} ${alert['sensorId']}";
        formattedEvents.add(formattedEvent);
      }
    }

    return formattedEvents;
  }
}