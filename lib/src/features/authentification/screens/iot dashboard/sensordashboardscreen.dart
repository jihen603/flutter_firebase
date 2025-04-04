import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SensorDashboard extends StatefulWidget {
  const SensorDashboard({Key? key}) : super(key: key);

  @override
  State<SensorDashboard> createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // AES Key et IV doivent être identiques à ceux dans l'ESP8266
  final key = encrypt.Key.fromUtf8("1234567890ABCDEF");
  final iv = encrypt.IV.fromUtf8("ABCDEFGHIJKLMNOP");

  String decryptAES(String base64Str) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final encryptedBytes = base64.decode(base64Str);
      final decrypted = encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);
      return utf8.decode(decrypted);
    } catch (e) {
      return "Erreur";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📊 Sensor Dashboard")),
      body: StreamBuilder(
        stream: _dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data is DatabaseEvent &&
              (snapshot.data! as DatabaseEvent).snapshot.value != null) {
            final data = (snapshot.data! as DatabaseEvent).snapshot.value as Map;

            final hum = decryptAES(data['DHT']?['humidity'] ?? "");
            final temp = decryptAES(data['DHT']?['temperature'] ?? "");
            final gas = decryptAES(data['MQ5']?['gas'] ?? "");
            final soil = decryptAES(data['MH-Sensor']?['soil_moisture'] ?? "");
            final vib = decryptAES(data['SW420']?['vibration'] ?? "");

            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                sensorCard("🌡️ Température", "$temp °C"),
                sensorCard("💧 Humidité", "$hum %"),
                sensorCard("🔥 Gaz", gas),
                sensorCard("🌱 Humidité du sol", soil),
                sensorCard("🪵 Vibration", vib == "1" ? "Détectée" : "Aucune"),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget sensorCard(String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
