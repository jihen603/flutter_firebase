import 'dart:typed_data';
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
  final DatabaseService _databaseService = DatabaseService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String humidity = "Loading...";
  String temperature = "Loading...";
  bool isLoading = true;  // Variable pour gérer l'affichage de l'indicateur de chargement

  // Clé et IV à utiliser pour AES (assurez-vous qu'ils sont corrects et en format Base64 ou hex)
  final key = encrypt.Key.fromUtf8('your-32-char-key-here-your-32'); // Exemple de clé 32 caractères
  final iv = encrypt.IV.fromUtf8('your-16-char-iv-here'); // Exemple de IV 16 caractères
  late AESHelper aesDecryption;

  @override
  void initState() {
    super.initState();
    aesDecryption = AESHelper(key, iv); // Initialisation de l'objet AESHelper
    _fetchSensorData();
  }

  // Fonction pour récupérer les données
  void _fetchSensorData() {
    _database.child("DHT").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final encryptedHumidity = data['humidity'] as String? ?? '';
        final encryptedTemperature = data['temperature'] as String? ?? '';

        if (encryptedHumidity.isNotEmpty && encryptedTemperature.isNotEmpty) {
          try {
            setState(() {
              humidity = aesDecryption.decryptAES(encryptedHumidity); // Décryptage avec AESHelper
              temperature = aesDecryption.decryptAES(encryptedTemperature);
              isLoading = false;  // Lorsque les données sont décryptées, on arrête le chargement
            });
          } catch (e) {
            print('Decryption error: $e');
            setState(() {
              humidity = 'Decryption Error';
              temperature = 'Decryption Error';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            humidity = 'Data Missing';
            temperature = 'Data Missing';
            isLoading = false;
          });
        }
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
                  onPressed: () {
                    // Action pour démarrer, par exemple, navigation vers un autre écran
                  },
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
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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

                // Affichage de l'indicateur de chargement si nécessaire
                isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                  children: [
                    // Affichage des données DHT (Température & Humidité)
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}


