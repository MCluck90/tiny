enum NodeType {
  program,
  assignment,
  read,
  write,
  identifier,
  literal,
  expression,
  innerExpression
}

abstract class ASTNode {
  NodeType type;

  String toString([int depth = 0]) {
    return '${"  " * depth}type: ${type.toString().replaceFirst("NodeType.", "")}';
  }
}

class AST extends ASTNode {
  List<ASTNode> statements;

  AST() {
    type = NodeType.program;
    statements = new List<ASTNode>();
  }

  String toString([int depth = 0]) {
    String tabs = '  ' * depth;
    String result = '$tabs${super.toString(depth)} [\n';
    for (int i = 0; i < statements.length; i++) {
      String linebreak = (i < statements.length - 1) ? '\n' : '';
      result += '${statements[i].toString(depth + 1)}$linebreak';
    }
    return '$result]';
  }
}

class Assignment extends ASTNode {
  String left;
  ASTNode right;

  Assignment(String _left, ASTNode _right) {
    type = NodeType.assignment;
    left = _left;
    right = _right;
  }

  String toString([int depth = 0]) {
    return '${super.toString(depth)}\n'
           '${"  " * depth}left: $left\n'
           '${"  " * depth}right:\n${right.toString(depth + 1)}\n';
  }
}

class Read extends ASTNode {
  List<String> identifiers;

  Read([List<String> ids]) {
    type = NodeType.read;
    identifiers = (ids != null) ? ids : new List<String>();
  }

  String toString([int depth = 0]) {
    String tabs = '  ' * depth;
    String result = '$tabs${super.toString()}\n'
                    '${tabs}identifiers: [';
    for (int i = 0; i < identifiers.length; i++) {
      String comma = (i < identifiers.length - 1) ? ', ' : '';
      result += '${identifiers[i]}$comma';
    }
    return '$result]\n';
  }
}

class Write extends ASTNode {
  List<ASTNode> expressions;

  Write([List<ASTNode> expr]) {
    type = NodeType.write;
    expressions = (expr != null) ? expr : new List<ASTNode>();
  }

  String toString([int depth = 0]) {
    String tabs = '  ' * depth;
    String result = '$tabs${super.toString()}\n'
                    '${tabs}expressions: [\n';
    for (int i = 0; i < expressions.length; i++) {
      result += '${expressions[i].toString(depth + 1)}\n\n';
    }
    return '$result$tabs]\n';
  }
}

class Integer extends ASTNode {
  int value;

  Integer(String val) {
    type = NodeType.literal;
    value = int.parse(val);
  }

  String toString([int depth = 0]) {
    String tabs = '  ' * depth;
    return '${tabs}${super.toString()}\n${tabs}value: $value';
  }
}

class Identifier extends ASTNode {
  String value;

  Identifier(String val) {
    type = NodeType.identifier;
    value = val;
  }

  String toString([int depth = 0]) {
    return '${super.toString(depth)}\n'
           '${"  " * depth}value: $value';
  }
}

class Expression extends ASTNode {
  ASTNode left;
  ASTNode right;
  String operator;

  Expression([this.left, this.right, this.operator]) {
    type = NodeType.expression;
  }

  String toString([int depth = 0]) {
    String tabs = '  ' * depth;
    return '${super.toString(depth)}\n'
           '${tabs}operator: $operator\n'
           '${tabs}left:\n${left.toString(depth + 1)}\n'
           '${tabs}right:\n${right.toString(depth + 1)}\n';
  }
}

class InnerExpression extends ASTNode {
  ASTNode value;

  InnerExpression([this.value]) {
    type = NodeType.innerExpression;
  }

  String toString([int depth = 0]) {
    String tabs = '  ' * depth;
    return '${super.toString(depth)}\n'
           '$tabs(\n'
           '${value.toString(depth + 1)}'
           '$tabs)';
  }
}
