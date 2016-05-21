import 'package:tiny_lang/ast.dart';

class Compiler {
  Map<String, bool> identifiers;
  List<String> code;

  Compiler() {
    identifiers = new Map<String, bool>();
    code = new List<String>();
  }

  String compile(AST ast) {
    code.add(
      'import "dart:io";\n'
      'int prompt(String id) {\n'
      '  stdout.write("\$id = ?> ");\n'
      '  var value = int.parse(stdin.readLineSync().trim(), onError: (source) => null);\n'
      '  while (value == null) {\n'
      '    print("Please enter an integer.");\n'
      '    stdout.write("\$id = ?> ");\n'
      '    value = int.parse(stdin.readLineSync().trim(), onError: (source) => null);\n'
      '  }\n'
      '  return value;\n'
      '}\n'
      'void main() {'
    );
    for (ASTNode statement in ast.statements) {
      if (statement is Assignment) {
        assignment(statement);
      } else if (statement is Write) {
        write(statement);
      } else if (statement is Read) {
        read(statement);
      } else {
        throw new UnsupportedError('Unknown statement type: ${statement.type}');
      }
    }

    return code.join('\n  ') + '\n}';
  }

  void assignment(Assignment node) {
    String command = '${node.left} = ${expression(node.right)};';

    // Only add "int" if the identifiers hasn't been seen before
    if (!identifiers[node.left]) {
      command = 'int $command';
      identifiers[node.left] = true;
    }
    code.add(command);
  }

  String expression(ASTNode node) {
    if (node is Integer) {
      return node.value.toString();
    } else if (node is Identifier) {
      return node.value;
    } else if (node is InnerExpression) {
      return '(${expression(node.value)})';
    } else if (node is Expression) {
      String left = expression(node.left);
      String right = expression(node.right);
      return '$left ${node.operator} $right';
    } else {
      throw new UnsupportedError('Unhandled expression type: ${node.type}');
    }
  }

  void write(Write node) {
    String command = 'stdout.write("';
    for (int i = 0; i < node.expressions.length; i++) {
      ASTNode expression = node.expressions[i];
      if (i > 0) {
        command += ' ';
      }
      command += '\${${this.expression(expression)}}';
    }
    command += '");';
    code.add(command);
    code.add('print("");');
  }

  void read(Read node) {
    for (String identifier in node.identifiers) {
      String command = '$identifier = prompt("$identifier");';

      // Only add the "int" keyword if we haven't seen that identifier before
      if (!identifiers[identifier]) {
        command = 'int $command';
        identifiers[identifier] = true;
      }
      code.add(command);
    }
  }
}
