import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_tracker/models/task.dart';
import 'package:task_tracker/tasks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//setting the theme of the app

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 216, 170, 92),
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);

void main() async {
  // initializing hive

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // setting the orientation of the app to portrait

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      theme: theme,
      home: const TasksMainScreen(),
    );
  }
}
