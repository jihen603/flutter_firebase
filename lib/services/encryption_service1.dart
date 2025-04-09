import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static final key = encrypt.Key.fromUtf8('1234567890ABCDEF'); // même clé que ESP8266
  static final iv = encrypt.IV.fromUtf8('ABCDEFGHIJKLMNOP');   // même IV que ESP8266

  static String decryptData(String base64Data) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypt.Encrypted.fromBase64(base64Data);
    return encrypter.decrypt(encrypted, iv: iv);
  }
}
