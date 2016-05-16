'use strict';

// We need the scanner to iterate through each token
let Scanner = require('./scanner.js');

// Tell the user what you were expecting then show the current tokens value
function syntaxError(expected) {
  throw new SyntaxError(`Expected ${expected}, instead got ${Scanner.token.value}`);
}

let Parser = {
  parse() {
    // BEGIN <statement>* END
    if (Scanner.token.type !== 'BEGIN') {
      syntaxError('BEGIN');
    }
    Scanner.next();

    // Begin generating the AST
    let ast = {
      type: 'program',
      statements: []
    };

    // As long as there are statements to process, do so
    while (this.statement(true)) {
      ast.statements.push(this.statement());
    }

    if (Scanner.token.type !== 'END') {
      syntaxError('END');
    }

    return ast;
  },

  statement(checkStatement) {
    // A statement can be a variable assignment,
    // a "read" statement, or a "write" statement followed by a semicolon
    let isAssignment = Scanner.token.type === 'ID';
    let isRead = Scanner.token.type === 'READ';
    let isWrite = Scanner.token.type === 'WRITE';
    if (checkStatement) {
      return isAssignment || isRead || isWrite;
    }

    if (!isAssignment && !isRead && !isWrite) {
      syntaxError('a statement');
    }

    let node = {};
    if (isAssignment) {
      // ID := <expression>
      let identifier = Scanner.token.value;
      if (Scanner.next().type !== 'ASSIGNMENT') {
        syntaxError(':=');
      }
      Scanner.next();
      node = {
        type: 'assignment',
        left: identifier,
        right: this.expression()
      };
    } else if (isRead) {
      // READ ( <id> [, <id>]* )
      node = {
        type: 'read',
        identifiers: []
      };
      if (Scanner.next().type !== 'OPEN') {
        syntaxError('(');
      }
      if (Scanner.next().type !== 'ID') {
        syntaxError('an identifier');
      }
      node.identifiers.push({
        type: 'identifier',
        value: Scanner.token.value
      });

      // Allow for a series of identifiers
      while (Scanner.next().type === 'COMMA') {
        if (Scanner.next().type !== 'ID') {
          syntaxError('an identifier');
        }
        node.identifiers.push({
          type: 'identifier',
          value: Scanner.token.value
        });
      }
      if (Scanner.token.type !== 'CLOSE') {
        syntaxError(')');
      }
      Scanner.next();
    } else if (isWrite) {
      // WRITE ( <expression [, <expression>]* )
      node = {
        type: 'write',
        expressions: []
      };
      if (Scanner.next().type !== 'OPEN') {
        syntaxError('(');
      }
      Scanner.next();
      node.expressions.push(this.expression());
      while (Scanner.token.type === 'COMMA') {
        Scanner.next();
        node.expressions.push(this.expression());
      }
      if (Scanner.token.type !== 'CLOSE') {
        syntaxError(')');
      }
      Scanner.next();
    } else {
      // This should never happen
      throw new Error(`Unhandled statement condition: ${Scanner.token.type}.
        If this happened to you, please tell me because that's amazing.`);
    }

    if (Scanner.token.type !== 'SEMICOLON') {
      syntaxError(';');
    }
    Scanner.next();
    return node;
  },

  expression() {
    // An expression can be an integer, an identifier,
    // any combination with an operator between them,
    // or any of the above wrapped in parentheses

    let isParens = Scanner.token.type === 'OPEN';
    let isInt = Scanner.token.type === 'INT';
    let isIdentifier = Scanner.token.type === 'ID';
    if (!isParens && !isInt && !isIdentifier) {
      syntaxError('a (, an integer, or an identifier');
    }

    let node = {
      type: 'expression',
      left: this.factor()
    };
    
    // Closing parentheses and commas should be handled in other parts of the syntax
    if (Scanner.token.operator && ['CLOSE', 'COMMA'].indexOf(Scanner.token.type) === -1) {
      node.operator = Scanner.token.operator;
      Scanner.next();
      node.right = this.expression();
    } else {
      // Just a literal, no operator
      node = node.left;
    }

    return node;
  },

  factor() {
    // An expression wrapped in parentheses, an identifier, or an integer
    let node;
    if (Scanner.token.type === 'OPEN') {
      Scanner.next();
      node = {
        type: 'inner-expression',
        value: this.expression()
      };
      if (Scanner.token.type !== 'CLOSE') {
        syntaxError(')');
      }
    } else if (Scanner.token.type === 'INT') {
      node = {
        type: 'literal',
        value: Scanner.token.value
      };
    } else if (Scanner.token.type === 'ID') {
      node = {
        type: 'identifier',
        value: Scanner.token.value
      };
    } else {
      syntaxError('(, an integer, or an identifier');
    }
    Scanner.next();
    return node;
  }
};

// Only export the parse function since that's all anyone needs
module.exports = Parser.parse.bind(Parser);
