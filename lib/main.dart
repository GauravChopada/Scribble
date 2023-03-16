import 'package:flutter/material.dart';
import 'package:scribble/providers/game_provider.dart';
import 'package:scribble/providers/room_provider.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: '.env');
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => roomProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Scribble',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: homeScreen(),
        // initialRoute: "/homeScreen",
        routes: {
          homeScreen.Routename: (ctx) => homeScreen(),
        });
  }
}
