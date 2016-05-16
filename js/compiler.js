'use strict';

// Converts an AST into JavaScript
let Compiler = {
  identifiers: {},
  code: [],

  // Takes in an AST and spits out JavaScript
  compile(ast) {
    ast.statements.forEach(statement => {
      if (!this[statement.type]) {
        throw new Error(`Unknown statement type: ${statement.type}`);
      }
      this[statement.type](statement);
    });

    // Returns all of the generated code separated by line breaks
    return this.code.join('\n');
  },

  assignment(node) {
    // Produces a variable assignment
    let command = `${node.left} = ${this.expression(node.right)};`;

    // Only add a "var" if the variable hasn't been declared
    if (!this.identifiers[node.left]) {
      command = `var ${command}`;
      this.identifiers[node.left] = true;
    }
    this.code.push(command);
  },

  expression(node) {
    // Process different kinds of expressions
    switch (node.type) {
      // Literals and identifiers can be returned directly
      case 'literal':
      case 'identifier':
        return node.value;
        break;

      // Inner expressions are surrounded by parentheses
      // Makes it easier to process them by giving them a different type
      case 'inner-expression':
        return `(${this.expression(node.value)})`;
        break;

      // An expression is made up of a left side, a right side, and an operator
      case 'expression':
        let left = this.expression(node.left);
        let right = this.expression(node.right);
        return `${left} ${node.operator} ${right}`;
        break;

      // This should be impossible
      default:
        throw new Error(`Unhandled expression type: ${node.type}`);
    }
  },

  write(node) {
    // Write out the result of one or more expressions
    let command = 'console.log(';
    node.expressions.forEach((expression, i) => {
      // Separate expressions
      if (i > 0) {
        command += ', ';
      }
      command += this.expression(expression);
    });
    command += ');';
    this.code.push(command);
  },

  read(node) {
    // Prompt the user for input
    // This uses the "prompt" command which is available in all browsers
    // or can be filled in in Node.js with the prompt-sync module
    node.identifiers.forEach(identifier => {
      identifier = identifier.value;
      let command = `${identifier} = prompt("${identifier} = ? ");`;

      // Only add the "var" keyword if we haven't seen that identifier yet
      if (!this.identifiers[identifier]) {
        command = `var ${command}`;
        this.identifiers[identifier] = true;
      }
      this.code.push(command);
    });
  }
};

// Only export the compile function
module.exports = Compiler.compile.bind(Compiler);
