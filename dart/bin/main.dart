import 'dart:io';

import 'package:tiny_lang/scanner.dart';
import 'package:tiny_lang/parser.dart';
import 'package:tiny_lang/ast.dart';
import 'package:tiny_lang/interpreter.dart';
import 'package:tiny_lang/compiler.dart';

main(List<String> arguments) async {
  if (arguments.length < 1) {
    print('Usage: dart bin/main.dart path-to-file [-i]');
    return;
  }

  Scanner scanner = new Scanner(await (new File(arguments[0]).readAsString()));
  Parser parser = new Parser(scanner);
  AST ast = parser.parse();

  if (arguments.contains("-i")) {
    // Interpret the result
    Interpreter interpreter = new Interpreter();
    interpreter.interpret(ast);
  } else {
    // Compile Dart code
    Compiler compiler = new Compiler();
    print(compiler.compile(ast));
  }
}
