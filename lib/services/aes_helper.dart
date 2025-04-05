import 'package:encrypt/encrypt.dart';

final key = Key.fromUtf8('0123456789abcdef');
final iv = IV.fromUtf8('abcdef9876543210');
final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

String decryptAES(String encryptedBase64) {
  try {
    return encrypter.decrypt64(encryptedBase64, iv: iv);
  } catch (e) {
    return 'Erreur de déchiffrement';
  }
}

