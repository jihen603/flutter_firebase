import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

class AESHelper {
  // 1. Clé et IV sous forme d'octets (plus fiable que UTF-8)
  static final _key = encrypt.Key(Uint8List.fromList([
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38,
    0x39, 0x30, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46 // '1234567890ABCDEF' en hex
  ]));

  static final _iv = encrypt.IV(Uint8List.fromList([
    0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48,
    0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50 // 'ABCDEFGHIJKLMNOP' en hex
  ]));

  // 2. Encrypter initialisé une seule fois
  static final _encrypter = encrypt.Encrypter(
    encrypt.AES(
      _key,
      mode: encrypt.AESMode.cbc,
      padding: 'PKCS7',
    ),
  );

  /// 3. Décryptage avec logs détaillés
  static String decryptFirebaseData(String encryptedData) {
    try {
      debugPrint('↩️ Donnée entrante: $encryptedData');

      // Nettoyage et padding Base64
      final cleanedData = encryptedData
          .trim()
          .replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), ''); // Supprime les caractères spéciaux

      final paddedData = cleanedData.padRight(
          cleanedData.length + (4 - cleanedData.length % 4) % 4,
          '='
      );

      debugPrint('🛠️ Après nettoyage: $paddedData');

      // Décodage et décryptage
      final encryptedBytes = base64.decode(paddedData);
      final result = _encrypter.decrypt(
        encrypt.Encrypted(encryptedBytes),
        iv: _iv,
      );

      debugPrint('✅ Décryptage réussi: $result');
      return result;
    } catch (e, stack) {
      debugPrint('''
⚠️ ERREUR CRITIQUE
Donnée: $encryptedData
Erreur: ${e.toString()}
Stack: ${stack.toString()}
''');
      return '0.0';
    }
  }
}