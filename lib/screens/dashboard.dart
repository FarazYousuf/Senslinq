import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senslinq/screens/login.dart';
// import 'package:senslinq/screens/sensor_details.dart';
import 'package:senslinq/screens/alert_details.dart';
import 'package:senslinq/screens/event_screen.dart';
import 'package:senslinq/auth_provider.dart';
import 'package:senslinq/google_maps.dart';
import 'package:senslinq/sensor_provider.dart';
import 'package:senslinq/alert_provider.dart';
import 'package:senslinq/globals.dart' as globals;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:senslinq/language_provider.dart';
import 'package:senslinq/constants/app_translation.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AppLanguage selectedLanguage = AppLanguage.English;

  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    //_startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;

    if (token != null) {
      try {
        print('Fetching sensor data with token: $token');
        await Provider.of<SensorProvider>(context, listen: false)
            .fetchSensorData(token);
        print('Fetching alert data with token: $token');
        await Provider.of<AlertProvider>(context, listen: false)
            .fetchAlertData(token);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch data: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token is null')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _fetchData();
    });
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('English'),
                onTap: () {
                  Provider.of<LanguageProvider>(context, listen: false)
                      .changeLanguage(AppLanguage.English);
                  setState(() {
                    selectedLanguage = AppLanguage.English;
                  });
                  Navigator.pop(context);
                },
                trailing: selectedLanguage == AppLanguage.English
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
              ListTile(
                title: const Text('Arabic'),
                onTap: () {
                  Provider.of<LanguageProvider>(context, listen: false)
                      .changeLanguage(AppLanguage.Arabic);
                  setState(() {
                    selectedLanguage = AppLanguage.Arabic;
                  });
                  Navigator.pop(context);
                },
                trailing: selectedLanguage == AppLanguage.Arabic
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isCurrentLanguageArabic();
    final sensorProvider = Provider.of<SensorProvider>(context);
    final alertProvider = Provider.of<AlertProvider>(context);

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SvgPicture.asset(
                'assets/logo.svg',
                height: 38,
                width: 38,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 9),
              const Spacer(),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _fetchData,
            ),
            const SizedBox(width: 10), // Adjust this spacing if necessary
          ],
        ),
        drawer: Drawer(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          width: MediaQuery.of(context).size.width * 0.6,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 120,
                child: DrawerHeader(
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 0.0, bottom: 0.0, left: 17),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/logo.svg', // Path to your SVG file
                              height: 39,
                              width: 39,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                // title: const Text('Dashboard'),
                title: Text(languageProvider.getTranslatedValue('dashboard')),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                // title: const Text('Events'),
                title: Text(languageProvider.getTranslatedValue('events')),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                // title: const Text('Settings'),
                title: Text(languageProvider.getTranslatedValue('settings')),
                onTap: () {
                  // Navigate to settings page
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                // title: Text('Language'),
                title: Text(languageProvider.getTranslatedValue('language')),
                onTap: () {
                  Navigator.pop(context);
                  _showLanguageDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                // title: const Text('Logout'),
                title: Text(languageProvider.getTranslatedValue('logOut')),
                onTap: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(54, 185, 140, 1)),
                ),
              )
            : Column(
                children: [
                  _buildSensorOverviewCard(sensorProvider),
                  _buildAlertOverviewCard(alertProvider),
                  Expanded(
                    child: Container(
                      color: Colors.white, // Set background color here
                      child: const GoogleMapPage(),
                    ),
                  ),
                ],
              ));
  }

  Widget _buildSensorOverviewCard(SensorProvider sensorProvider) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final totalText = languageProvider.getTranslatedValue('total');
    final sensorsText = languageProvider.getTranslatedValue('sensors');

    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const SensorDetailsScreen()),
        // );
      },
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: const SweepGradient(
            colors: [
              Color.fromARGB(255, 212, 212, 212),
              Color.fromARGB(255, 255, 255, 255),
            ],
            center: Alignment.centerLeft,
            startAngle: 0.0,
            endAngle: 3.25 * 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 1),
              blurRadius: 7,
              spreadRadius: 1.2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    // 'Total Sensors',
                    '$totalText $sensorsText',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  Text(
                    '${sensorProvider.totalSensors}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle,
                              color: Colors.green, size: 12),
                          const SizedBox(width: 4),
                          // const Text('Online'),
                          Text(
                            //  'Online',
                            languageProvider.getTranslatedValue('online'),
                          ),
                          const SizedBox(width: 13),
                          Text(
                            '${sensorProvider.onlineSensors}',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle, color: Colors.red, size: 12),
                          const SizedBox(width: 4),
                          // const Text('Offline'),
                          Text(
                            languageProvider.getTranslatedValue('offline'),
                          ),
                          const SizedBox(width: 13),
                          Text(
                            '${sensorProvider.offlineSensors}',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertOverviewCard(AlertProvider alertProvider) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AlertDetailsScreen(token: globals.Globals.globalToken),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: const SweepGradient(
            colors: [
              Color.fromRGBO(170, 226, 207, 1),
              Color.fromARGB(255, 255, 255, 255),
            ],
            center: Alignment.centerLeft,
            startAngle: 0.0,
            endAngle: 3.25 * 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 1),
              blurRadius: 7,
              spreadRadius: 1.2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    // 'Total Alerts',
                    languageProvider.getTranslatedValue('totalAlerts'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${alertProvider.totalAlerts}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle,
                              color: Colors.orange, size: 12),
                          const SizedBox(width: 4),
                          // const Text('Active'),
                          Text(
                            languageProvider.getTranslatedValue('active'),
                          ),
                          const SizedBox(width: 13),
                          Text(
                            '${alertProvider.activeAlerts}',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle,
                              color: Colors.blue, size: 12),
                          const SizedBox(width: 4),
                          // const Text('Attended'),
                          Text(
                            languageProvider.getTranslatedValue('attended'),
                          ),
                          const SizedBox(width: 13),
                          Text(
                            '${alertProvider.AttendedAlerts}',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
