'use strict';

let prompt = require('prompt-sync')();

// Interprets an AST
let Interpreter = {
  variables: {},
  interpret(ast) {
    // Run through each of the statements and evaluate them
    ast.statements.forEach((statement) => {
      if (!this[statement.type]) {
        throw new Error(`Unhandled statement type: ${statement.type}`);
      }
      this[statement.type](statement);
    });
  },

  assignment(node) {
    // Assign a value to a given variable
    let identifier = node.left;
    let value = this.evaluate(node.right);
    this.variables[identifier] = value;
  },

  evaluate(node) {
    // Evaluates an expression
    switch (node.type) {
      case 'literal':
        return node.value;
        break;

      case 'identifier':
        if (this.variables[node.value] === undefined) {
          throw new Error(`Unknown identifier: ${node.value}`);
        }
        return this.variables[node.value];
        break;

      // This makes it easier to interpret expressions contained in parentheses
      case 'inner-expression':
        return this.evaluate(node.value);
        break;

      case 'expression':
        let sum = this.evaluate(node.left);
        // Expressions are similar to a linked-list with "right"
        // being the "next" node.
        while (node && node.right) {
          let right = 0;
          if (node.right.type === 'inner-expression') {
            // If the right-hand side is in parentheses, run that first
            right = this.evaluate(node.right);
          } else if (node.right.type === 'expression') {
            // If the chain continues, get the value of the next operand
            right = this.evaluate(node.right.left);
          } else {
            // Otherwise, get the value of the last operand
            right = this.evaluate(node.right);
          }

          // Based on the current operator, increment the sum
          if (node.operator === '+') {
            sum += right;
          } else if (node.operator === '-') {
            sum -= right;
          } else {
            throw new Error(`Unknown operator: ${node.operator}`);
          }
          node = node.right;
        }
        return sum;
        break;

      default:
        throw new Error(`Unhandled evaluation: ${node.type}`);
    }
  },

  write(node) {
    // Output the result of 1 or more expressions
    console.log.apply(console, node.expressions.map(this.evaluate, this));
  },

  read(node) {
    // Prompt the user for input on one or more variables
    node.identifiers.forEach((identifier) => {
      let value = prompt(`${identifier.value} = ?>`).trim();
      while (!value.match(/^\d+$/)) {
        value = prompt(`Please enter an integer.\n${identifier.value} = ?`).trim();
      }
      this.variables[identifier.value] = parseInt(value);
    });
  }
};

// Only export the interpret function
module.exports = Interpreter.interpret.bind(Interpreter);
