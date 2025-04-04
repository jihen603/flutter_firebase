import 'package:firebase_database/firebase_database.dart';
import 'aes_helper.dart';

class IotDataFirebase {
  final DatabaseReference _sensorsRef = FirebaseDatabase.instance.ref();

  /// Stream des données IoT décryptées en temps réel
  Stream<Map<String, dynamic>> get realTimeDecryptedData {
    return _sensorsRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;

      return {
        'temperature': _parseDouble(data['DHT']['temperature']),
        'humidity': _parseDouble(data['DHT']['humidity']),
        'gas': _parseDouble(data['MQ5']['gas']),
        'soil_moisture': _parseDouble(data['MH-Sensor']['soil_moisture']),
        'vibration': _parseVibration(data['SW420']['vibration']),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    });
  }

  double _parseDouble(dynamic encryptedValue) {
    try {
      final decrypted = AESHelper.decryptFirebaseData(encryptedValue.toString());
      return double.tryParse(decrypted) ?? 0.0;
    } catch (e) {
      print('Erreur décryptage valeur: $e');
      return 0.0;
    }
  }

  bool _parseVibration(dynamic encryptedValue) {
    try {
      final decrypted = AESHelper.decryptFirebaseData(encryptedValue.toString());
      return decrypted == '1'; // '1' = true, '0' = false
    } catch (e) {
      print('Erreur décryptage vibration: $e');
      return false;
    }
  }

  /// Méthode pour tester la connexion
  Future<void> testConnection() async {
    try {
      final snapshot = await _sensorsRef.child('DHT/temperature').get();
      print('Test Firebase: ${snapshot.exists}');
    } catch (e) {
      print('Erreur connexion Firebase: $e');
    }
  }
}