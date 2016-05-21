import 'dart:io';

import 'package:tiny_lang/ast.dart';

class Interpreter {
  Map<String, int> variables;

  Interpreter() {
    variables = new Map<String, int>();
  }

  void interpret(AST ast) {
    // Run through each of the statements and evaluate them
    for (ASTNode statement in ast.statements) {
      if (statement is Assignment) {
        assignment(statement);
      } else if (statement is Write) {
        write(statement);
      } else if (statement is Read) {
        read(statement);
      } else {
        throw new UnsupportedError('Unknown statement type: ${statement.type.toString()}');
      }
    }
  }

  void assignment(Assignment node) {
    // Assign a value to a given variable
    variables[node.left] = evaluate(node.right);
  }

  int evaluate(ASTNode node) {
    if (node is Integer) {
      return node.value;
    } else if (node is Identifier) {
      if (!variables.containsKey(node.value)) {
        throw new Exception('Unknown identifier: ${node.value}');
      }
      return variables[node.value];
    } else if (node is InnerExpression) {
      return this.evaluate(node.value);
    } else if (node is Expression) {
      Expression exp = node as Expression;
      int sum = this.evaluate(exp.left);

      // Expressions are similar to a linked-list with "right"
      // being the "next" node.
      while (exp != null && exp.right != null) {
        int right = 0;
        if (exp.right is InnerExpression) {
          // If the right-hand side is in parentheses, run that first
          right = this.evaluate(exp.right);
        } else if (exp.right is Expression) {
          // If the chain continues, get the value of the next operand
          right = this.evaluate((exp.right as Expression).left);
        } else {
          // Otherwise, get the value of the last operator
          right = this.evaluate(exp.right);
        }

        // Based on the current operator, increment the sum
        if (exp.operator == '+') {
          sum += right;
        } else if (exp.operator == '-') {
          sum -= right;
        } else {
          throw new UnsupportedError('Unknown operator: ${exp.operator}');
        }
        if (exp.right is Expression) {
          exp = exp.right;
        } else {
          exp = null;
        }
      }
      return sum;
    } else {
      throw new UnimplementedError('Unhandled evaluation: ${node.type}');
    }
  }

  void write(Write node) {
    for (ASTNode expression in node.expressions) {
      stdout.write('${evaluate(expression)} ');
    }
    print('');
  }

  void read(Read node) {
    for (String identifier in node.identifiers) {
      stdout.write('$identifier = ?> ');
      var value = int.parse(stdin.readLineSync().trim(), onError: (source) => null);
      while (value == null) {
        print('Please enter an integer.');
        stdout.write('$identifier = ?> ');
        value = int.parse(stdin.readLineSync().trim(), onError: (source) => null);
      }
      variables[identifier] = value;
    }
  }
}
