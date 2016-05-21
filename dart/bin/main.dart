import 'dart:io';

import 'package:tiny_lang/scanner.dart';
import 'package:tiny_lang/parser.dart';
import 'package:tiny_lang/ast.dart';

main(List<String> arguments) async {
  if (arguments.length < 1) {
    print('Usage: dart bin/main.dart path-to-file');
    return;
  }
  
  Scanner scanner = new Scanner(await (new File(arguments[0]).readAsString()));
  Parser parser = new Parser(scanner);
  AST ast = parser.parse();
  print(ast);
}
