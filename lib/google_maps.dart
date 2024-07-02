import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:senslinq/sensor_provider.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({Key? key}) : super(key: key);

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late BitmapDescriptor customGreyMarker;
  late BitmapDescriptor customGreenMarker;
  late BitmapDescriptor customRedMarker;
  bool markersLoaded = false;
  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
  }

  void _loadCustomMarkers() async {
    customGreyMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(72, 72)),
      'assets/grey-marker.png',
    );
    customGreenMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(72, 72)),
      'assets/green-marker.png',
    );
    customRedMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(72, 72)),
      'assets/red-marker.png',
    );

    setState(() {
      markersLoaded = true;
      dataLoaded = true;
    });
  }

  InfoWindow _buildInfoWindow(Map<String, dynamic> sensorData) {
    return InfoWindow(
      title: sensorData['locationAlias'] ?? 'Unknown',
      snippet: 'Concentration: ${sensorData['Concentration'] ?? 'Unknown'}\n'
      // 'Status: ${sensorData['Status'] ?? 'Unknown'}\nGas level: ${sensorData['GasLevel'] ?? 'Unknown'}\nConcentration: ${sensorData['Concentration'] ?? 'Unknown'}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: !dataLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Consumer<SensorProvider>(
              builder: (context, sensorProvider, child) {
                if (sensorProvider.onlineSensorLocations.isEmpty &&
                    sensorProvider.offlineSensorLocations.isEmpty) {
                  return const Center(child: Text('No sensor data available.'));
                }

                Set<Marker> markers = {};
                // Add online sensor markers
                markers.addAll(sensorProvider.onlineSensorLocations.map((sensor) {
                  final gasLevel = sensor['gasLevel'];
                  return Marker(
                    markerId: MarkerId(sensor['location'].toString()),
                    position: sensor['location'],
                    icon: gasLevel == 'mild' || gasLevel == 'heavy'
                        ? customRedMarker
                        : customGreenMarker,
                    infoWindow: _buildInfoWindow(sensor),
                  );
                }));

                // Add offline sensor markers
                markers.addAll(sensorProvider.offlineSensorLocations.map((sensor) {
                  final gasLevel = sensor['gasLevel'];
                  return Marker(
                    markerId: MarkerId(sensor['location'].toString()),
                    position: sensor['location'],
                    icon: gasLevel == 'mild' || gasLevel == 'heavy'
                        ? customRedMarker
                        : customGreyMarker,
                    infoWindow: _buildInfoWindow(sensor),
                  );
                }));

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(255, 158, 158, 158),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _initialCameraPosition(sensorProvider),
                        zoom: 11,
                      ),
                      markers: markers,
                    ),
                  ),
                );
              },
            ),
    );
  }

  LatLng _initialCameraPosition(SensorProvider sensorProvider) {
    if (sensorProvider.onlineSensorLocations.isNotEmpty) {
      double totalLat = 0;
      double totalLng = 0;
      for (var sensor in sensorProvider.onlineSensorLocations) {
        totalLat += sensor['location'].latitude;
        totalLng += sensor['location'].longitude;
      }
      double avgLat = totalLat / sensorProvider.onlineSensorLocations.length;
      double avgLng = totalLng / sensorProvider.onlineSensorLocations.length;

      return LatLng(avgLat, avgLng);
    } else {
      // Default to GooglePlex if no sensors
      return const LatLng(37.4223, -122.0848);
    }
  }
}