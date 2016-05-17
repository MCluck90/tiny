enum TokenType {
  begin,
  end,
  read,
  write,
  assignment,
  add,
  sub,
  open,
  close,
  comma,
  semicolon,
  int,
  id,
  unknown,
  eof
}

Map<String, TokenType> keywords = const {
  'BEGIN': TokenType.begin,
  'END': TokenType.end,
  'READ': TokenType.read,
  'WRITE': TokenType.write
};

Map<String, TokenType> operators = const {
  ':=': TokenType.assignment,
  '+': TokenType.add,
  '-': TokenType.sub,
  '(': TokenType.open,
  ')': TokenType.close,
  ',': TokenType.comma
};

class Token {
  TokenType type;
  String value;
  bool isOperator;

  Token(this.type, this.value, [this.isOperator = false]);

  String toString() => 'Token <${type.toString().substring(type.toString().indexOf('.') + 1)} : $value>';
}

// Regular expressions for various tokens
RegExp _whitespace = new RegExp(r"^\s+");
RegExp _integer = new RegExp(r"^[-|+]?[1-9][0-9]*");
RegExp _identifier = new RegExp(r"^[a-zA-Z_$][a-zA-Z0-9_$]*");
RegExp _notWhitespace = new RegExp(r"^[^\s]+");

// Converts input into a sequence of tokens
class Scanner {
  String input;
  Token token;

  Scanner(String _input) {
    input = _input;
    next();
  }

  // Parse out the next token
  // and assign it to the token property
  Token next() {
    // Don't bother reading if we've already reached the end of the file
    if (token?.type == TokenType.eof) {
      return token;
    }

    // Remove leading whitespace
    Match whitespace = _whitespace.firstMatch(input);
    if (whitespace != null) {
      input = input.substring(whitespace.end);
    }

    // Detect if we're at the end of the input
    if (input.length == 0) {
      return token = new Token(TokenType.eof, 'end of file');
    }

    // Parse out keywords
    for (String keyword in keywords.keys) {
      if (input.indexOf(keyword) == 0) {
        input = input.substring(keyword.length);
        return token = new Token(keywords[keyword], keyword);
      }
    }

    // Parse out integers
    Match integer = _integer.firstMatch(input);
    if (integer != null) {
      input = input.substring(integer.end);
      return token = new Token(TokenType.int, integer.group(0));
    }

    // Parse out identifiers
    Match identifier = _identifier.firstMatch(input);
    if (identifier != null) {
      input = input.substring(identifier.end);
      return token = new Token(TokenType.id, identifier.group(0));
    }

    // Parse out operators
    for (String operator in operators.keys) {
      if (input.indexOf(operator) == 0) {
        input = input.substring(operator.length);
        return token = new Token(operators[operator], operator, true);
      }
    }

    // Parse semi-colons for the end of statements
    if (input.indexOf(';') == 0) {
      input = input.substring(1);
      return token = new Token(TokenType.semicolon, ';');
    }

    // Unknown token
    Match unknown = _notWhitespace.firstMatch(input);
    input = input.substring(unknown.end);
    return token = new Token(TokenType.unknown, unknown.group(0));
  }
}
