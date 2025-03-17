import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled123/services/database_service.dart';
import 'package:untitled123/src/features/authentification/screens/login_screen.dart';
import '../../../../../services/auth_service.dart';
import '../../../../constants/image_strings.dart';
import '../chiffrement/aes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String humidity = "Loading...";
  String temperature = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
  }

  void _fetchSensorData() {
    _database.child("DHT/humidity").onValue.listen((event) {
      final encryptedHumidity = event.snapshot.value?.toString() ?? '';
      print('Encrypted Humidity: $encryptedHumidity'); // Débogage
      if (encryptedHumidity.isNotEmpty) {
        try {
          setState(() {
            humidity = AESHelper.decryptAES(encryptedHumidity);
          });
        } catch (e) {
          print('Decryption error for humidity: $e');
        }
      } else {
        print('Humidity data is empty or null');
      }
    });

    _database.child("DHT/temperature").onValue.listen((event) {
      final encryptedTemperature = event.snapshot.value?.toString() ?? '';
      print('Encrypted Temperature: $encryptedTemperature'); // Débogage
      if (encryptedTemperature.isNotEmpty) {
        try {
          setState(() {
            temperature = AESHelper.decryptAES(encryptedTemperature);
          });
        } catch (e) {
          print('Decryption error for temperature: $e');
        }
      } else {
        print('Temperature data is empty or null');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond
          Image.asset(
            tSplashTopImage,
            fit: BoxFit.cover,
          ),

          // Effet flou
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          // Contenu au centre de l'écran
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Welcome to MyApp",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Bouton pour démarrer
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),

                const SizedBox(height: 20),

                // Bouton de déconnexion
                ElevatedButton(
                  onPressed: () async {
                    await AuthService().signout(context: context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                // Affichage des données récupérées en temps réel
                StreamBuilder(
                  stream: _databaseService.getRealTimeData('MQ5/value'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                      final data = snapshot.data!.snapshot.value;
                      return Text(
                        'MQ5 Value: $data',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      );
                    }
                    return const Text(
                      'No data available',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 🔹 Affichage des données DHT (Température & Humidité)
                Text(
                  "Température: $temperature °C",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  "Humidité: $humidity %",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

