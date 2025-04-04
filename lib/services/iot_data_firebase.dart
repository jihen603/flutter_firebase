import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'aes_helper.dart';

class IotDataFirebase {
  final DatabaseReference _sensorsRef = FirebaseDatabase.instance.ref();

  Stream<Map<String, dynamic>> get realTimeDecryptedData {
    return _sensorsRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;

      // Debug: affiche les données brutes
      debugPrint('Données brutes Firebase: ${data.toString()}');

      return {
        'temperature': _parseData(data['DHT']['temperature']),
        'humidity': _parseData(data['DHT']['humidity']),
        'gas': _parseData(data['MQ5']['gas']),
        'soil_moisture': _parseData(data['MH-Sensor']['soil_moisture']),
        'vibration': _parseVibration(data['SW420']['vibration']),
      };
    });
  }

  double _parseData(dynamic encryptedValue) {
    try {
      if (encryptedValue == null) return 0.0;
      final decrypted = AESHelper.decryptFirebaseData(encryptedValue.toString());
      return double.tryParse(decrypted) ?? 0.0;
    } catch (e) {
      debugPrint('Erreur décryptage valeur: $e');
      return 0.0;
    }
  }

  bool _parseVibration(dynamic encryptedValue) {
    try {
      if (encryptedValue == null) return false;
      final decrypted = AESHelper.decryptFirebaseData(encryptedValue.toString());
      return decrypted == '1';
    } catch (e) {
      debugPrint('Erreur décryptage vibration: $e');
      return false;
    }
  }
}