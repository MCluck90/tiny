import 'package:tiny_lang/scanner.dart';
import 'package:tiny_lang/ast.dart';

// Produces an AST from a stream of tokens
class Parser {
  Scanner scanner;

  Parser(this.scanner);

  AST parse() {
    AST ast = new AST();
    return ast;
  }
}
