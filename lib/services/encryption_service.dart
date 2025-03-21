import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static final key = Key.fromUtf8("0123456789abcdef");
  static final iv = IV.fromUtf8("abcdef9876543210");

  static String decryptAES(String encryptedBase64) {
    try {
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final encryptedBytes = base64.decode(encryptedBase64);
      final decrypted = encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);
      return utf8.decode(decrypted);
    } catch (e) {
      print("Erreur de déchiffrement : $e");
      return "Erreur";
    }
  }
}
