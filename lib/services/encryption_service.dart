import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

class EncryptionService {
  static final key = encrypt.Key.fromUtf8('0123456789abcdef');  // 16 octets (doit être identique à Python)
  static final iv = encrypt.IV.fromUtf8('abcdef9876543210');   // 16 octets

  static String decryptData(String encryptedData) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    // Décoder les données base64 avant déchiffrement
    final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    return decrypted;
  }
}
