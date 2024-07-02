import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senslinq/globals.dart' as globals;
import 'package:senslinq/sensor_provider.dart';
import 'package:senslinq/language_provider.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);

    try {
      await sensorProvider.fetchEventData(globals.Globals.globalToken);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $error')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final sensorProvider = Provider.of<SensorProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          languageProvider.getTranslatedValue('events'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _fetchData,
          ),
          const SizedBox(width: 10), 
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(54, 185, 140, 1)),
              ),
            )
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: sensorProvider.fetchEventData(globals.Globals.globalToken),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color.fromRGBO(54, 185, 140, 1)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final eventData = snapshot.data;
                  if (eventData == null || eventData.isEmpty) {
                    return const Center(child: Text('No events found.'));
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: eventData.length,
                      itemBuilder: (context, index) {
                        var event = eventData[index];

                        String datetime = event['eventTime'] ?? 'Unknown Date';
                        String description = event['eventDescription'] ??
                            'No description available';
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 1),
                          color: const Color.fromARGB(255, 223, 253, 243),
                          child: ListTile(
                            // contentPadding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 8.0),
                            title: Text(
                              datetime,
                              style: const TextStyle(
                                fontFamily: AutofillHints.addressCity,
                                fontSize: 12.1,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              
                              description,
                              style: const TextStyle(
                                fontSize: 13.5,
                                
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            onTap: () {},
                          ),
                        );
                      },
                    );
                  }
                }
              },
            ),
    );
  }
}