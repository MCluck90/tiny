import 'package:tiny_lang/scanner.dart';
import 'package:tiny_lang/parser.dart';
import 'package:tiny_lang/ast.dart';

void main() {
  Scanner scanner = new Scanner(
    'BEGIN'
    'x := 2;'
    'END'
  );

  Parser parser = new Parser(scanner);
  AST ast = parser.parse();
  print(ast);
}
