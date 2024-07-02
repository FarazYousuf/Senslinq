import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senslinq/language_provider.dart';
import 'package:senslinq/screens/dashboard.dart';
import 'package:senslinq/screens/login.dart';
import 'package:senslinq/sensor_provider.dart';
import 'package:senslinq/alert_provider.dart';
import 'auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child:  const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SensLinQ',
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: const Color.fromARGB(255, 244, 244, 246),
        ),
        home: auth.isAuth ? const DashboardScreen() : const LoginScreen(),
      ),
    );
  }
}