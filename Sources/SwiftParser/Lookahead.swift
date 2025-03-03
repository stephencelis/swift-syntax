//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

@_spi(RawSyntax) import SwiftSyntax

extension Parser {
  /// Token lookahead for the parser.
  ///
  /// Parser lookahead functions nearly identically to parsing, except the
  /// resulting functions do not construct syntax trees and may skip an
  /// arbitrary number of tokens ahead in the input stream. Instances of
  /// ``Lookahead`` are distinct from their parent ``Parser`` instances, so
  /// any tokens they consume will not be reflected in the parent parser.
  struct Lookahead {
    var lexemes: Lexer.LexemeSequence
    var currentToken: Lexer.Lexeme
    /// Number of tokens this ``Lookahead`` has consumed from where it was started,
    /// i.e. how far it looked ahead.
    var tokensConsumed: Int = 0

    private init(
      lexemes: Lexer.LexemeSequence,
      currentToken: Lexer.Lexeme
    ) {
      self.lexemes = lexemes
      self.currentToken = currentToken
    }

    fileprivate init(cloning other: Parser) {
      self.init(lexemes: other.lexemes, currentToken: other.currentToken)
    }

    /// Initiates a lookahead session from the current point in this
    /// lookahead session.
    func lookahead() -> Lookahead {
      return Lookahead(lexemes: self.lexemes, currentToken: self.currentToken)
    }
  }

  /// Initiates a lookahead session from the current point in this parse.
  func lookahead() -> Lookahead {
    return Lookahead(cloning: self)
  }

  func withLookahead<T>(_ body: (_: inout Lookahead) -> T) -> T {
    var lookahead = lookahead()
    return body(&lookahead)
  }
}

extension Parser.Lookahead: TokenConsumer {
  /// Consumes the current token, and asserts that it matches `spec`.
  ///
  /// If the token kind did not match, this function will abort. It is useful
  /// to insert structural invariants during parsing.
  ///
  /// - Parameter kind: The kind of token to consume.
  /// - Returns: A token of the given kind.
  mutating func eat(_ spec: TokenSpec) -> Token {
    return self.consume(if: spec)!
  }

  #if SWIFTPARSER_ENABLE_ALTERNATE_TOKEN_INTROSPECTION
  var shouldRecordAlternativeTokenChoices: Bool { false }

  mutating func recordAlternativeTokenChoice(for lexeme: Lexer.Lexeme, choices: [TokenSpec]) {}
  #endif
}

extension Parser.Lookahead {
  func peek() -> Lexer.Lexeme {
    return self.lexemes.peek()
  }
}

extension Parser.Lookahead {
  mutating func missingToken(_ kind: RawTokenKind, text: SyntaxText?) {
    // do nothing
  }

  mutating func consumeAnyToken() {
    tokensConsumed += 1
    self.currentToken = self.lexemes.advance()
  }

  mutating func consumeAnyToken(remapping: RawTokenKind) {
    self.consumeAnyToken()
  }

  /// Consume tokens of lower precedence than `spec` until reaching a token that
  /// matches that `spec`. The token that matches `spec` is also consumed.
  mutating func consume(to spec: TokenSpec) {
    if self.consume(if: spec) != nil {
      return
    }
    var lookahead = self.lookahead()
    if lookahead.canRecoverTo(spec) != nil {
      for _ in 0..<lookahead.tokensConsumed {
        self.consumeAnyToken()
      }
      self.consumeAnyToken()
    }
  }

  /// Consumes a given token, or splits the current token into a leading token
  /// matching the given token and a trailing token and consumes the leading
  /// token.
  ///
  ///     <TOKEN> ... -> consumePrefix(<TOK>) -> [ <TOK> ] <EN> ...
  mutating func consumePrefix(_ prefix: SyntaxText, as tokenKind: RawTokenKind) {
    let tokenText = self.currentToken.tokenText

    if tokenText == prefix {
      return self.consumeAnyToken()
    }
    precondition(tokenText.hasPrefix(prefix))

    self.currentToken = self.lexemes.resetForSplit(
      splitToken: self.currentToken,
      consumedPrefix: self.currentToken.leadingTriviaByteLength + prefix.count
    )
  }
}

// MARK: Skipping Tokens

extension Parser.Lookahead {
  mutating func skipTypeAttribute() {
    // These are keywords that we accept as attribute names.
    guard self.at(.identifier) || self.at(.keyword(.in), .keyword(.inout)) else {
      return
    }

    // Determine which attribute it is.
    if let (attr, handle) = self.at(anyIn: TypeAttribute.self) {
      // Ok, it is a valid attribute, eat it, and then process it.
      self.eat(handle)
      if case .convention = attr {
        guard
          self.consume(if: .leftParen) != nil,
          self.consume(if: .identifier) != nil,
          self.consume(if: .rightParen) != nil
        else {
          return
        }
      }
      return
    }

    if let (_, handle) = self.at(anyIn: Parser.DeclarationAttributeWithSpecialSyntax.self) {
      // This is a valid decl attribute so they should have put it on the decl
      // instead of the type.
      //
      // Recover by eating @foo(...)
      self.eat(handle)
      if self.at(.leftParen) {
        var backtrack = self.lookahead()
        backtrack.skipSingle()
        // If we found '->', or 'throws' after paren, it's likely a parameter
        // of function type.
        guard backtrack.at(.arrow) || backtrack.at(.keyword(.throws), .keyword(.rethrows), .keyword(.throw)) else {
          self.skipSingle()
          return
        }
      }
      return
    }

    _ = self.canParseCustomAttribute()
    return
  }
}

extension Parser.Lookahead {
  mutating func consumeAttributeList() -> Bool {
    guard self.at(.atSign) else {
      return false
    }

    while let _ = self.consume(if: .atSign) {
      // Consume qualified names that may or may not involve generic arguments.
      repeat {
        self.consume(if: .identifier, .keyword(.rethrows))
        // We don't care whether this succeeds or fails to eat generic
        // parameters.
        _ = self.consumeGenericArguments()
      } while self.consume(if: .period) != nil

      if self.consume(if: .leftParen) != nil {
        while !self.at(.eof, .rightParen, .poundEndifKeyword) {
          self.skipSingle()
        }
        self.consume(if: .rightParen)
      }
    }
    return true
  }

  /// Tries consuming a `#if` directive that only contains attributes.
  /// Returns `true` if that was successful and `false` if
  ///  - we are not at a valid `#if` directive (e.g. `#endif` is missing)
  ///  - the directive contained non-attributes
  ///  - the directive did not contain any attributes
  mutating func consumeIfConfigOfAttributes() -> Bool {
    precondition(self.at(.poundIfKeyword))
    var didSeeAnyAttributes = false
    var poundIfLoopProgress = LoopProgressCondition()
    repeat {
      precondition(self.at(.poundIfKeyword, .poundElseKeyword, .poundElseifKeyword))
      self.consumeAnyToken()

      // <expression> after `#if` or `#elseif`
      self.skipUntilEndOfLine()

      var attributesLoopProgress = LoopProgressCondition()
      ATTRIBUTE_LOOP: while attributesLoopProgress.evaluate(self.currentToken) {
        switch self.currentToken.rawTokenKind {
        case .atSign:
          didSeeAnyAttributes = true
          _ = self.consumeAttributeList()
        case .poundIfKeyword:
          _ = self.consumeIfConfigOfAttributes()
        default:
          break ATTRIBUTE_LOOP
        }
      }
    } while self.at(.poundElseifKeyword, .poundElseKeyword) && poundIfLoopProgress.evaluate(self.currentToken)

    return didSeeAnyAttributes && self.currentToken.isAtStartOfLine && self.consume(if: .poundEndifKeyword) != nil
  }
}

// MARK: Lookahead

extension Parser.Lookahead {
  mutating func isStartOfGetSetAccessor() -> Bool {
    precondition(self.at(.leftBrace), "not checking a brace?")

    // The only case this can happen is if the accessor label is immediately after
    // a brace (possibly preceded by attributes).  "get" is implicit, so it can't
    // be checked for.  Conveniently however, get/set properties are not allowed
    // to have initializers, so we don't have an ambiguity, we just have to check
    // for observing accessors.
    //
    // If we have a 'didSet' or a 'willSet' label, disambiguate immediately as
    // an accessor block.
    let nextToken = self.peek()
    if TokenSpec(.didSet) ~= nextToken || TokenSpec(.willSet) ~= nextToken || TokenSpec(.`init`) ~= nextToken {
      return true
    }

    // If we don't have attributes, then it cannot be an accessor block.
    if nextToken.rawTokenKind != .atSign {
      return false
    }

    // Eat the "{".
    var lookahead = self.lookahead()
    lookahead.eat(.leftBrace)

    // Eat attributes, if present.
    while lookahead.consume(if: .atSign) != nil {
      guard lookahead.consume(if: .identifier) != nil else {
        return false
      }
      // Eat paren after attribute name; e.g. @foo(x)
      if lookahead.at(.leftParen) {
        lookahead.skipSingle()
      }
    }

    // Check if we have 'didSet'/'willSet' or 'init' after attributes.
    return lookahead.at(.keyword(.didSet), .keyword(.willSet), .keyword(.`init`))
  }
}

// MARK: Skipping Tokens

extension Parser.Lookahead {
  mutating func skipUntil(_ t1: TokenSpec, _ t2: TokenSpec) {
    return skip(initialState: .skipUntil(t1, t2))
  }

  mutating func skipUntilEndOfLine() {
    while !self.at(.eof) && !self.currentToken.isAtStartOfLine {
      self.skipSingle()
    }
  }

  mutating func skipSingle() {
    return skip(initialState: .skipSingle)
  }

  // Note: We don't need to treat string quotes as bracketed tokens because:
  //  - If we skip over the opening quote, we also automatically skip over
  //    closing quote since it has the same token kind
  //  - It is very unlikely that we look for string segments, so we
  //    automatically skip over those as individual tokens
  //  - String interpolation contains parentheses, so it automatically skips
  //    until the closing parenthesis.
  private enum BracketedTokens: TokenSpecSet {
    case leftParen
    case leftBrace
    case leftSquare
    case poundIfKeyword
    case poundElseKeyword
    case poundElseifKeyword

    init?(lexeme: Lexer.Lexeme) {
      switch lexeme.rawTokenKind {
      case .leftParen: self = .leftParen
      case .leftBrace: self = .leftBrace
      case .leftSquare: self = .leftSquare
      case .poundIfKeyword: self = .poundIfKeyword
      case .poundElseKeyword: self = .poundElseKeyword
      case .poundElseifKeyword: self = .poundElseifKeyword
      default: return nil
      }
    }

    var spec: TokenSpec {
      switch self {
      case .leftParen: return .leftParen
      case .leftBrace: return .leftBrace
      case .leftSquare: return .leftSquare
      case .poundIfKeyword: return .poundIfKeyword
      case .poundElseKeyword: return .poundElseKeyword
      case .poundElseifKeyword: return .poundElseifKeyword
      }
    }
  }

  private enum SkippingState {
    /// Equivalent to a call to `skipSingle`. Skip a single token.
    /// If that token is bracketed, skip until the closing bracket
    case skipSingle
    /// Execute code after skipping bracketed tokens detected from `skipSingle`.
    case skipSinglePost(start: BracketedTokens)
    /// Skip until either `t1` or `t2`.
    case skipUntil(_ t1: TokenSpec, _ t2: TokenSpec)
  }

  /// A non-recursie function to skip tokens.
  private mutating func skip(initialState: SkippingState) {
    var stack: [SkippingState] = [initialState]

    while let state = stack.popLast() {
      switch state {
      case .skipSingle:
        let t = self.at(anyIn: BracketedTokens.self)
        switch t {
        case (.leftParen, let handle)?:
          self.eat(handle)
          stack += [.skipSinglePost(start: .leftParen), .skipUntil(.rightParen, .rightBrace)]
        case (.leftBrace, let handle)?:
          self.eat(handle)
          stack += [.skipSinglePost(start: .leftBrace), .skipUntil(.rightBrace, .rightBrace)]
        case (.leftSquare, let handle)?:
          self.eat(handle)
          stack += [.skipSinglePost(start: .leftSquare), .skipUntil(.rightSquare, .rightSquare)]
        case (.poundIfKeyword, let handle)?,
          (.poundElseKeyword, let handle)?,
          (.poundElseifKeyword, let handle)?:
          self.eat(handle)
          // skipUntil also implicitly stops at tok::pound_endif.
          stack += [.skipSinglePost(start: t!.0), .skipUntil(.poundElseKeyword, .poundElseifKeyword)]
        case nil:
          self.consumeAnyToken()
        }
      case .skipSinglePost(start: let start):
        switch start {
        case .leftParen:
          self.consume(if: .rightParen)
        case .leftBrace:
          self.consume(if: .rightBrace)
        case .leftSquare:
          self.consume(if: .rightSquare)
        case .poundIfKeyword, .poundElseKeyword, .poundElseifKeyword:
          if self.at(.poundElseKeyword, .poundElseifKeyword) {
            stack += [.skipSingle]
          } else {
            self.consume(if: .poundElseifKeyword)
          }
          return
        }
      case .skipUntil(let t1, let t2):
        if !self.at(.eof, t1, t2) && !self.at(.poundEndifKeyword, .poundElseKeyword, .poundElseifKeyword) {
          stack += [.skipUntil(t1, t2), .skipSingle]
        }
      }
    }
  }
}
