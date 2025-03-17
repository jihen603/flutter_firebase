import 'dart:ui';
import 'package:encrypt/encrypt.dart' as encrypt;
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
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late AESHelper aesHelper;

  String humidity = "Loading...";
  String temperature = "Loading...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 🔐 Clé et IV en Base64 (assurez-vous que c'est la même que sur ESP8266)
    const keyBase64 = "EjRWeJCrze8SNFZ4kKvN7w=="; // Clé en Base64
    const ivBase64 = "ESIzRFV2iKo79hM="; // IV en Base64
    aesHelper = AESHelper(keyBase64, ivBase64);
    _fetchSensorData();
  }

  // 🔍 Récupération et déchiffrement des données Firebase
  void _fetchSensorData() {
    _database.child("DHT").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final encryptedHumidity = data['humidity'] as String? ?? '';
        final encryptedTemperature = data['temperature'] as String? ?? '';

        setState(() {
          humidity = encryptedHumidity.isNotEmpty
              ? aesHelper.decryptAES(encryptedHumidity)
              : "No Data";
          temperature = encryptedTemperature.isNotEmpty
              ? aesHelper.decryptAES(encryptedTemperature)
              : "No Data";
          isLoading = false;
        });
      } else {
        setState(() {
          humidity = 'No Data';
          temperature = 'No Data';
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(tSplashTopImage, fit: BoxFit.cover),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Welcome to MyApp",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text("Get Started", style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await AuthService().signout(context: context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text("Sign Out", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                  children: [
                    Text("Température: $temperature °C",
                        style: const TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 10),
                    Text("Humidité: $humidity %",
                        style: const TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


