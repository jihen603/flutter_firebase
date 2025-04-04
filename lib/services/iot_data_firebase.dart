import 'package:firebase_database/firebase_database.dart';
import 'aes_helper.dart';

class IotDataFirebase {
  final DatabaseReference _sensorsRef = FirebaseDatabase.instance.ref();

  /// Stream des données IoT décryptées en temps réel
  Stream<Map<String, dynamic>> get realTimeDecryptedData {
    return _sensorsRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;

      return {
        'temperature': _decryptValue(data['DHT']['temperature']),
        'humidity': _decryptValue(data['DHT']['humidity']),
        'gas': _decryptValue(data['MQ5']['gas']),
        'vibration': _decryptVibration(data['SW420']['vibration']), // Utilisez une méthode spécifique
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    });
  }

  double _decryptValue(dynamic encryptedData) {
    try {
      final decrypted = AESHelper.decryptFirebaseData(encryptedData.toString());
      return double.tryParse(decrypted) ?? 0.0;
    } catch (e) {
      print('Erreur de décryptage: $e');
      return 0.0;
    }
  }

  bool _decryptVibration(dynamic encryptedData) {
    try {
      final decrypted = AESHelper.decryptFirebaseData(encryptedData.toString());
      return decrypted == '1'; // Retourne directement un booléen
    } catch (e) {
      print('Erreur de décryptage vibration: $e');
      return false;
    }
  }
}