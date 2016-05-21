import 'package:tiny_lang/scanner.dart';
import 'package:tiny_lang/ast.dart';

// Produces an AST from a stream of tokens
class Parser {
  Scanner scanner;

  void _syntaxError(String expected) {
    throw new UnsupportedError('Expected $expected, instead got ${scanner.token.value}');
  }

  Parser(this.scanner);

  AST parse() {
    // BEGIN <statement>* END
    if (scanner.token.type != TokenType.begin) {
      _syntaxError('BEGIN');
    }
    scanner.next();

    // Begin generating the AST
    AST ast = new AST();

    // As long as there are statements to process, do so
    while (statement(true)) {
      ast.statements.add(statement());
    }

    if (scanner.token.type != TokenType.end) {
      _syntaxError('END');
    }
    return ast;
  }

  statement([bool check = false]) {
    // A statement can be a variable assignment, a "read", or a "write"
    // Always ends with a semicolon
    bool isAssignment = scanner.token.type == TokenType.id;
    bool isRead = scanner.token.type == TokenType.read;
    bool isWrite = scanner.token.type == TokenType.write;
    if (check) {
      return isAssignment || isRead || isWrite;
    }

    if (!isAssignment && !isRead && !isWrite) {
      _syntaxError('a statement');
    }

    ASTNode node;
    if (isAssignment) {
      // ID := <expression>
      String identifier = scanner.token.value;
      if (scanner.next().type != TokenType.assignment) {
        _syntaxError(':=');
      }
      scanner.next();
      node = new Assignment(identifier, expression());
    } else if (isRead) {
      // READ ( <id>, [, <id>]* )
      node = new Read();
      Read readNode = node as Read;
      if (scanner.next().type != TokenType.open) {
        _syntaxError('(');
      }
      if (scanner.next().type != TokenType.id) {
        _syntaxError('an identifier');
      }
      readNode.identifiers.add(scanner.token.value);

      // Handle a series of identifiers
      while (scanner.next().type == TokenType.comma) {
        if (scanner.next().type != TokenType.id) {
          _syntaxError('an identifier');
        }
        readNode.identifiers.add(scanner.token.value);
      }

      if (scanner.token.type != TokenType.close) {
        _syntaxError(')');
      }
      scanner.next();
    } else if (isWrite) {
      // WRITE ( <expression [, <expression>]* )
      node = new Write();
      Write writeNode = node as Write;
      if (scanner.next().type != TokenType.open) {
        _syntaxError('(');
      }
      scanner.next();
      writeNode.expressions.add(expression());
      while (scanner.token.type == TokenType.comma) {
        scanner.next();
        writeNode.expressions.add(expression());
      }
      if (scanner.token.type != TokenType.close) {
        _syntaxError(')');
      }
      scanner.next();
    } else {
      throw new Exception('How? This should never, ever happen.');
    }

    if (scanner.token.type != TokenType.semicolon) {
      _syntaxError(';');
    }
    scanner.next();
    return node;
  }

  ASTNode expression() {
    bool isParens = scanner.token.type == TokenType.open;
    bool isInt = scanner.token.type == TokenType.int;
    bool isIdentifier = scanner.token.type == TokenType.id;
    if (!isParens && !isInt && !isIdentifier) {
      _syntaxError('a (, an integer, or an identifier');
    }

    ASTNode node = factor();

    // Closing parentheses and commas should be handled elsewhere
    if (scanner.token.isOperator && scanner.token.type != TokenType.close && scanner.token.type != TokenType.comma) {
      Expression expression = new Expression(node, null, scanner.token.value);
      scanner.next();
      expression.right = this.expression();
      node = expression;
    }
    return node;
  }

  factor() {
    ASTNode node;
    if (scanner.token.type == TokenType.open) {
      scanner.next();
      node = new InnerExpression(expression());
      if (scanner.token.type != TokenType.close) {
        _syntaxError(')');
      }
    } else if (scanner.token.type == TokenType.int) {
      node = new Integer(scanner.token.value);
    } else if (scanner.token.type == TokenType.id) {
      node = new Identifier(scanner.token.value);
    } else {
      _syntaxError('(, an integer, or an identifier');
    }

    scanner.next();
    return node;
  }
}
