'use strict';

// All keywords in the language
const KEYWORDS = [
  'BEGIN',
  'END',
  'READ',
  'WRITE'
];

// All operators and their matching token types
const OPERATORS = {
  ':=': 'ASSIGNMENT',
  '+' : 'ADD',
  '-' : 'SUB',
  '(' : 'OPEN',
  ')' : 'CLOSE',
  ',' : 'COMMA'
};

let Scanner = {
  input: '',
  index: 0,
  token: {},

  // Initialize the scanner with the given input
  init(input) {
    this.input = input;
    this.index = 0;
    this.next();
  },

  // Retrieve the next token
  // Assign to the token property and return the same token
  next() {
    // Don't bother reading if we're at the end of the file
    if (this.token.type === 'EOF') {
      return this.token;
    }

    // Read from the latest index
    let input = this.input.slice(this.index);

    // Remove leading whitespace
    let whitespace = input.match(/^\s+/);
    if (whitespace) {
      whitespace = whitespace[0];
      input = input.slice(whitespace.length);
      this.index += whitespace.length;
    }

    // Detect if we're at the end of the file/input
    if (this.index >= this.input.length) {
      this.token = {
        type: 'EOF',
        value: 'end of file'
      };
      return this.token;
    }

    // Parse out keywords
    for (var i = 0, len = KEYWORDS.length; i < len; i++) {
      let keyword = KEYWORDS[i];
      if (input.indexOf(keyword) === 0) {
        this.index += keyword.length;
        this.token = {
          type: keyword,
          value: keyword
        };
        return this.token;
      }
    }

    // Parse out integers
    let integer = input.match(/^[-|+]?\d+/);
    if (integer) {
      integer = integer[0];

      // Verify that multi-digit numbers don't start with 0
      if (integer.length === 1 || integer[0] !== '0') {
        this.index += integer.length;
        this.token = {
          type: 'INT',
          value: parseInt(integer)
        };
        return this.token;
      }
    }

    // Parse out identifiers
    let identifier = input.match(/^[a-zA-Z_$][a-zA-Z0-9_$]*/);
    if (identifier) {
      identifier = identifier[0];
      this.index += identifier.length;
      this.token = {
        type: 'ID',
        value: identifier
      };
      return this.token;
    }

    // Parse out operators
    let operatorKeys = Object.keys(OPERATORS);
    for (var i = 0, len = operatorKeys.length; i < len; i++) {
      let operator = operatorKeys[i];
      if (input.indexOf(operator) === 0) {
        this.index += operator.length;
        this.token = {
          type: OPERATORS[operator],
          operator,
          value: operator
        };
        return this.token;
      }
    }

    // Parse semi-colons for the end of statements
    if (input.indexOf(';') === 0) {
      this.index += 1;
      this.token = {
        type: 'SEMICOLON',
        value: ';'
      };
      return this.token;
    }

    // Unknown token
    let unknown = input.match(/^[^\s]+/)[0];
    this.index += unknown.length;
    this.token = {
      type: 'UNKNOWN',
      value: unknown
    };
    return this.token;
  }
};

module.exports = Scanner;
