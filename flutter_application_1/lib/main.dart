import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/habit_database.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/theme/theme_provider.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await HabitDatabase.initialize();
  await HabitDatabase().saveFirstLaunchDate();

  runApp( 
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => HabitDatabase()),

      ChangeNotifierProvider(create: (context) => ThemeProvider()),
    ],
    child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
