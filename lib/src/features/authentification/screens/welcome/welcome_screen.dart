import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled123/services/auth_service.dart';
import 'package:untitled123/src/features/authentification/screens/login_screen.dart';
import '../../../../constants/image_strings.dart';

class AESHelper {
  static final key = encrypt.Key.fromUtf8('1234567890123456');
  static final iv = encrypt.IV.fromUtf8('1234567890123456');

  static final encrypter = encrypt.Encrypter(
    encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
  );

  static String decryptAES(String encryptedText) {
    try {
      final encryptedBytes = base64.decode(normalizeBase64(encryptedText));
      final decrypted = encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);
      return utf8.decode(decrypted).trim();
    } catch (e) {
      print("Erreur de déchiffrement : $e");
      return "Decryption Error";
    }
  }

  static String normalizeBase64(String base64String) {
    while (base64String.length % 4 != 0) {
      base64String += "=";
    }
    return base64String;
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String humidity = "Loading...";
  String temperature = "Loading...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _startRealTimeListener();
  }

  void _startRealTimeListener() {
    _database.child("DHT").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final encryptedHumidity = data['humidity']?.toString() ?? '';
        final encryptedTemperature = data['temperature']?.toString() ?? '';

        print("Données chiffrées Firebase (Humidité) : $encryptedHumidity");
        print("Données chiffrées Firebase (Température) : $encryptedTemperature");

        setState(() {
          humidity = encryptedHumidity.isNotEmpty ? AESHelper.decryptAES(encryptedHumidity) : "No Data";
          temperature = encryptedTemperature.isNotEmpty ? AESHelper.decryptAES(encryptedTemperature) : "No Data";
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(role: 'operator'),
                      ),
                    );
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
                    Text("Température: $temperature °C", style: const TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 10),
                    Text("Humidité: $humidity %", style: const TextStyle(color: Colors.white, fontSize: 18)),
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
