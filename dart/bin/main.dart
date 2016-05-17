import 'package:tiny_lang/scanner.dart';

void main() {
  Scanner scanner = new Scanner(
    'BEGIN'
    'x := 2;'
    'y := -4;'
    'READ (z, a, b);'
    'WRITE (x, y + z, a - b)'
    'END'
  );
  while (scanner.token.type != TokenType.eof) {
    print(scanner.token);
    scanner.next();
  }
}
