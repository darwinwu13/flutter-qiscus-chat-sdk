import 'dart:math';

class QiscusUtility {
  Random _random = Random();
  List<String> _symbols = List();

  factory QiscusUtility() => QiscusUtility._internal();

  QiscusUtility._internal() {
    StringBuffer tmp = StringBuffer();
    for (int ch = '0'.codeUnitAt(0); ch <= '9'.codeUnitAt(0); ch++) {
      tmp.write(String.fromCharCode(ch));
    }
    for (int ch = 'a'.codeUnitAt(0); ch <= 'z'.codeUnitAt(0); ch++) {
      tmp.write(String.fromCharCode(ch));
    }
    _symbols = tmp.toString().split("");
  }

  static String getRandomString(int length) {
    final instance = QiscusUtility();
    Random _random = instance._random;
    List<String> _symbols = instance._symbols;

    StringBuffer buf = StringBuffer();
    for (int i = 0; i < length; i++) {
      buf.write(_symbols[_random.nextInt(_symbols.length)]);
    }
    return buf.toString();
  }
}
