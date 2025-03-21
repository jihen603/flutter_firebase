import 'package:flutter/material.dart';
import '../../../../../services/database_service.dart';
import '../../../../../services/encryption_service.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String decryptedData = "En attente des données...";

  @override
  void initState() {
    super.initState();
    FirebaseService().listenForEncryptedData((encrypted) {
      setState(() {
        decryptedData = EncryptionService.decryptAES(encrypted);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome Screen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Données Déchiffrées :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              decryptedData,
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
