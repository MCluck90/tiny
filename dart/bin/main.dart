import 'package:tiny_lang/scanner.dart';
import 'package:tiny_lang/parser.dart';
import 'package:tiny_lang/ast.dart';

void main() {
  Scanner scanner = new Scanner(
    'BEGIN'
    'x := 2;'
    'READ (y);'
    'READ (y, z);'
    'WRITE (x);'
    'WRITE (1);'
    'WRITE (x, 1, y + z);'
    'x := x + y - z;'
    'y := (x + y) - (z - (x - y));'
    'END'
  );

  Parser parser = new Parser(scanner);
  AST ast = parser.parse();
  print(ast);
}
