import 'package:chico_chess_connect/pages/multiplayer/lobby.dart';
import 'package:chico_chess_connect/pages/auth/profile.dart';
import 'package:chico_chess_connect/utils/auth.dart';
import 'package:chico_chess_connect/pages/local/local_chessboard.dart';
import 'package:chico_chess_connect/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Auth(),
        '/chessboard': (context) => const LocalChessBoardScreen(),
        '/multiplayer': (context) => Lobby(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/chessboard');
              },
              child: const Text('Local Chess'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/multiplayer');
              },
              child: const Text('Multiplayer'),
            ),
          ],
        ),
      ),
    );
  }
}
