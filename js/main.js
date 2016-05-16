'use strict';

let fs = require('fs');
let path = require('path');
let Scanner = require('./scanner.js');
let parse = require('./parser.js');
let interpret = require('./interpreter.js');
let compile = require('./compiler.js');

// Load in the input
let input = fs.readFileSync(path.join(process.cwd(), process.argv[2])).toString();

// Initialize the scanner
Scanner.init(input);

// Parse out the AST
let ast = parse();

// Interpret the code directly
if (process.argv.indexOf('-i') > -1) {
  interpret(ast);
} else {
  // Otherwise, compile the code and print the result
  var output = compile(ast);
  console.log(output);
}
