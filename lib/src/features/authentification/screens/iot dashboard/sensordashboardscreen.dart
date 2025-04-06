import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SensorDashboard extends StatefulWidget {
  @override
  _SensorDashboardState createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  final key = encrypt.Key.fromUtf8('1234567890ABCDEF'); // 16 chars
  final iv = encrypt.IV.fromUtf8('ABCDEFGHIJKLMNOP');  // 16 chars

  late encrypt.Encrypter encrypter;

  String humidity = '';
  String temperature = '';
  String gas = '';
  String soilMoisture = '';
  String vibration = '';

  @override
  void initState() {
    super.initState();
    encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    _listenToFirebase();
  }

  void _listenToFirebase() {
    _databaseReference.onValue.listen((event) {
      final data = event.snapshot.value as Map;

      setState(() {
        humidity = decryptAES(data['DHT/humidity']);
        temperature = decryptAES(data['DHT/temperature']);
        gas = decryptAES(data['MQ5/gas']);
        soilMoisture = decryptAES(data['MH-Sensor/soil_moisture']);
        vibration = decryptAES(data['SW420/vibration']);
      });
    });
  }

  String decryptAES(String base64Text) {
    try {
      final encrypted = encrypt.Encrypted.fromBase64(base64Text);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      print('Erreur de déchiffrement : $e');
      return 'Erreur';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Humidity: $humidity', style: TextStyle(fontSize: 18)),
            Text('Temperature: $temperature', style: TextStyle(fontSize: 18)),
            Text('Gas: $gas', style: TextStyle(fontSize: 18)),
            Text('Soil Moisture: $soilMoisture', style: TextStyle(fontSize: 18)),
            Text('Vibration: $vibration', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
