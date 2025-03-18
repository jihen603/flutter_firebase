import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled123/services/auth_service.dart';
import 'package:untitled123/src/features/authentification/screens/login_screen.dart';
import '../../../../constants/image_strings.dart';

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

  // Clé de chiffrement AES (16 octets pour AES-128)
  final List<int> aesKey = [
    0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF,
    0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF
  ];

  // IV (Vecteur d'Initialisation) - 16 octets
  final List<int> aesIv = [
    0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88,
    0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 0x00
  ];

  late encrypt.Encrypter encrypter;
  late encrypt.IV iv;

  @override
  void initState() {
    super.initState();

    // Initialisation du chiffrement AES avec la clé et IV
    final key = encrypt.Key(Uint8List.fromList(aesKey));
    iv = encrypt.IV(Uint8List.fromList(aesIv));
    encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));

    _startRealTimeListener();
  }

  // Démarre l'écoute en temps réel des données Firebase
  void _startRealTimeListener() {
    _database.child("DHT").onValue.listen((event) {
      final data = event.snapshot.value as Map? ?? {};
      final encryptedHumidity = data['humidity'] as String? ?? '';
      final encryptedTemperature = data['temperature'] as String? ?? '';

      // Logs pour vérifier les valeurs chiffrées
      print(" Données chiffrées Firebase (Humidité) : $encryptedHumidity");
      print(" Données chiffrées Firebase (Température) : $encryptedTemperature");

      // Test du déchiffrement
      String decryptedHumidity = decryptAES(encryptedHumidity);
      String decryptedTemperature = decryptAES(encryptedTemperature);

      print(" Test déchiffrement Flutter (Humidité) : $decryptedHumidity");
      print(" Test déchiffrement Flutter (Température) : $decryptedTemperature");

      setState(() {
        humidity = encryptedHumidity.isNotEmpty ? decryptedHumidity : "No Data";
        temperature = encryptedTemperature.isNotEmpty ? decryptedTemperature : "No Data";
        isLoading = false;
      });
    });
  }

  // Fonction de déchiffrement AES avec padding PKCS7
  String decryptAES(String encryptedText) {
    try {
      final encryptedBytes = base64.decode(encryptedText); // Décodage Base64
      final decrypted = encrypter.decryptBytes(
          encrypt.Encrypted(encryptedBytes), iv: iv); // Déchiffrement
      return utf8.decode(decrypted); // Retourner la valeur déchiffrée
    } catch (e) {
      print("Erreur de déchiffrement : $e");
      return "Decryption Error"; // Message d'erreur en cas d'échec
    }
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
