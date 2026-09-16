import 'package:flutter/material.dart';
import 'routes.dart';

class HealthApp extends StatelessWidget{
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Tracker',

      initialRoute: '/login',
      routes: appRoutes,
    );
  } 
}