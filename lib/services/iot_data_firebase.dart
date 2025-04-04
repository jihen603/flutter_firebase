import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'aes_helper.dart';

class IotDataFirebase {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Stream<Map<String, dynamic>> get realTimeData {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;

      // Debug: Affiche la structure complète
      debugPrint('🔥 Données brutes Firebase: ${data.toString()}');

      return {
        'temperature': _parseValue(data['DHT']?['temperature']),
        'humidity': _parseValue(data['DHT']?['humidity']),
        'gas': _parseValue(data['MQ5']?['gas']),
        'soil_moisture': _parseValue(data['MH-Sensor']?['soil_moisture']),
        'vibration': _parseVibration(data['SW420']?['vibration']),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    });
  }

  double _parseValue(dynamic encryptedValue) {
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