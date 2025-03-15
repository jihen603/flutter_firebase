import 'dart:ui'; // Import nécessaire pour BackdropFilter
import 'package:flutter/material.dart';
import 'package:untitled123/src/constants/image_strings.dart';
import 'package:untitled123/src/constants/text_strings.dart';
import '../login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0; // Initialisation de l’opacité à 0

  @override
  void initState() {
    super.initState();
    // Démarrer l'animation après 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1; // Augmente l’opacité à 1 pour lancer l’animation
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Assure que l'image et les effets remplissent l'écran
        children: [
          // Image de fond couvrant tout l'écran
          Image.asset(
            tSplashTopImage,
            fit: BoxFit.cover,
          ),

          // Effet flou sur toute l'image
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Flou plus intense
              child: Container(
                color: Colors.black.withOpacity(0.2), // Ajoute une légère obscurité
              ),
            ),
          ),

          // Contenu centré
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nom de l'application
                Text(
                  tAppName,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Tagline
                Text(
                  tAppTagLine,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30), // Espacement entre le texte et les boutons

                // Animation des boutons (fade-in)
                AnimatedOpacity(
                  duration: const Duration(seconds: 1), // Durée de l’animation
                  opacity: _opacity, // Animation basée sur l'opacité
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centre les boutons horizontalement
                    children: [
                      // Bouton Operator
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          side: const BorderSide(color: Colors.white), // Bordure blanche
                        ),
                        child: const Text(
                          "Administrator",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 20), // Espacement entre les boutons

                      // Bouton User
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Colors.white, // Couleur du bouton
                        ),
                        child: const Text(
                          "Operator",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}