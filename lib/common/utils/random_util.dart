import 'dart:math';

class RandomUtil {
  static const charsDict =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

      
  static String generateRandomString(int length) {
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => charsDict.codeUnitAt(random.nextInt(charsDict.length)),
    ));
  }
}
