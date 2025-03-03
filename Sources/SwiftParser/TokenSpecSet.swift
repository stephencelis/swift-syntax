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

/// A set of `TokenSpecs`. We expect to consume one of the sets specs in the
/// parser.
protocol TokenSpecSet: CaseIterable {
  var spec: TokenSpec { get }

  /// Creates an instance if `lexeme` satisfy the condition of this subset.
  init?(lexeme: Lexer.Lexeme)
}

// MARK: - Subsets

enum CanBeStatementStart: TokenSpecSet {
  case _forget  // NOTE: support for deprecated _forget
  case `break`
  case `continue`
  case `defer`
  case `do`
  case `fallthrough`
  case `for`
  case discard
  case `guard`
  case `if`
  case `repeat`
  case `return`
  case `switch`
  case `throw`
  case `while`
  case yield

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(._forget): self = ._forget
    case TokenSpec(.break): self = .break
    case TokenSpec(.continue): self = .continue
    case TokenSpec(.defer): self = .defer
    case TokenSpec(.do): self = .do
    case TokenSpec(.fallthrough): self = .fallthrough
    case TokenSpec(.for): self = .for
    case TokenSpec(.discard): self = .discard
    case TokenSpec(.guard): self = .guard
    case TokenSpec(.if): self = .if
    case TokenSpec(.repeat): self = .repeat
    case TokenSpec(.return): self = .return
    case TokenSpec(.switch): self = .switch
    case TokenSpec(.throw): self = .throw
    case TokenSpec(.while): self = .while
    case TokenSpec(.yield): self = .yield
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case ._forget: return TokenSpec(._forget, recoveryPrecedence: .stmtKeyword)
    case .break: return .keyword(.break)
    case .continue: return .keyword(.continue)
    case .defer: return .keyword(.defer)
    case .do: return .keyword(.do)
    case .fallthrough: return .keyword(.fallthrough)
    case .for: return .keyword(.for)
    case .discard: return TokenSpec(.discard, recoveryPrecedence: .stmtKeyword)
    case .guard: return .keyword(.guard)
    case .if: return .keyword(.if)
    case .repeat: return .keyword(.repeat)
    case .return: return .keyword(.return)
    case .switch: return .keyword(.switch)
    case .throw: return .keyword(.throw)
    case .while: return .keyword(.while)
    case .yield: return .keyword(.yield)
    }
  }
}

enum CompilationCondition: TokenSpecSet {
  case swift
  case compiler
  case canImport

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(.swift): self = .swift
    case TokenSpec(.compiler): self = .compiler
    case TokenSpec(.canImport): self = .canImport
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .swift: return .keyword(.swift)
    case .compiler: return .keyword(.compiler)
    case .canImport: return .keyword(.canImport)
    }
  }

}

enum ContextualDeclKeyword: TokenSpecSet {
  case __consuming
  case _compilerInitialized
  case _const
  case _local
  case actor
  case async
  case convenience
  case distributed
  case dynamic
  case final
  case indirect
  case infix
  case isolated
  case lazy
  case mutating
  case nonisolated
  case nonmutating
  case package
  case open
  case optional
  case override
  case postfix
  case prefix
  case required
  case unowned
  case weak

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(.__consuming): self = .__consuming
    case TokenSpec(._compilerInitialized): self = ._compilerInitialized
    case TokenSpec(._const): self = ._const
    case TokenSpec(._local): self = ._local
    case TokenSpec(.actor): self = .actor
    case TokenSpec(.async): self = .async
    case TokenSpec(.convenience): self = .convenience
    case TokenSpec(.distributed): self = .distributed
    case TokenSpec(.dynamic): self = .dynamic
    case TokenSpec(.final): self = .final
    case TokenSpec(.indirect): self = .indirect
    case TokenSpec(.infix): self = .infix
    case TokenSpec(.isolated): self = .isolated
    case TokenSpec(.lazy): self = .lazy
    case TokenSpec(.mutating): self = .mutating
    case TokenSpec(.nonisolated): self = .nonisolated
    case TokenSpec(.nonmutating): self = .nonmutating
    case TokenSpec(.package): self = .package
    case TokenSpec(.open): self = .open
    case TokenSpec(.optional): self = .optional
    case TokenSpec(.override): self = .override
    case TokenSpec(.postfix): self = .postfix
    case TokenSpec(.prefix): self = .prefix
    case TokenSpec(.required): self = .required
    case TokenSpec(.unowned): self = .unowned
    case TokenSpec(.weak): self = .weak
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .__consuming: return .keyword(.__consuming)
    case ._compilerInitialized: return .keyword(._compilerInitialized)
    case ._const: return .keyword(._const)
    case ._local: return .keyword(._local)
    case .actor: return .keyword(.actor)
    case .async: return .keyword(.async)
    case .convenience: return .keyword(.convenience)
    case .distributed: return .keyword(.distributed)
    case .dynamic: return .keyword(.dynamic)
    case .final: return .keyword(.final)
    case .indirect: return .keyword(.indirect)
    case .infix: return .keyword(.infix)
    case .isolated: return .keyword(.isolated)
    case .lazy: return .keyword(.lazy)
    case .mutating: return .keyword(.mutating)
    case .nonisolated: return .keyword(.nonisolated)
    case .nonmutating: return .keyword(.nonmutating)
    case .package: return .keyword(.package)
    case .open: return .keyword(.open)
    case .optional: return .keyword(.optional)
    case .override: return .keyword(.override)
    case .postfix: return .keyword(.postfix)
    case .prefix: return .keyword(.prefix)
    case .required: return .keyword(.required)
    case .unowned: return .keyword(.unowned)
    case .weak: return .keyword(.weak)
    }
  }
}

enum DeclarationKeyword: TokenSpecSet {
  case actor
  case `associatedtype`
  case `case`
  case `class`
  case `deinit`
  case `enum`
  case `extension`
  case `func`
  case `import`
  case `init`
  case `let`
  case macro
  case `operator`
  case `precedencegroup`
  case `protocol`
  case `struct`
  case `subscript`
  case `typealias`
  case `var`
  case `inout`
  case pound

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(.actor): self = .actor
    case TokenSpec(.macro): self = .macro
    case TokenSpec(.associatedtype): self = .associatedtype
    case TokenSpec(.case): self = .case
    case TokenSpec(.class): self = .class
    case TokenSpec(.deinit): self = .deinit
    case TokenSpec(.enum): self = .enum
    case TokenSpec(.extension): self = .extension
    case TokenSpec(.func): self = .func
    case TokenSpec(.import): self = .import
    case TokenSpec(.`init`): self = .`init`
    case TokenSpec(.let): self = .let
    case TokenSpec(.operator): self = .operator
    case TokenSpec(.precedencegroup): self = .precedencegroup
    case TokenSpec(.protocol): self = .protocol
    case TokenSpec(.struct): self = .struct
    case TokenSpec(.subscript): self = .subscript
    case TokenSpec(.typealias): self = .typealias
    case TokenSpec(.var): self = .var
    case TokenSpec(.inout): self = .inout
    case TokenSpec(.pound): self = .pound
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .actor: return TokenSpec(.actor, recoveryPrecedence: .declKeyword)
    case .associatedtype: return .keyword(.associatedtype)
    case .case: return TokenSpec(.case, recoveryPrecedence: .declKeyword)
    case .class: return .keyword(.class)
    case .deinit: return .keyword(.deinit)
    case .enum: return .keyword(.enum)
    case .extension: return .keyword(.extension)
    case .func: return .keyword(.func)
    case .import: return .keyword(.import)
    case .`init`: return .keyword(.`init`)
    case .let: return .keyword(.let)
    case .macro: return TokenSpec(.macro, recoveryPrecedence: .declKeyword)
    case .operator: return .keyword(.operator)
    case .precedencegroup: return .keyword(.precedencegroup)
    case .protocol: return .keyword(.protocol)
    case .struct: return .keyword(.struct)
    case .subscript: return .keyword(.subscript)
    case .typealias: return .keyword(.typealias)
    case .var: return .keyword(.var)
    case .inout: return TokenSpec(.inout, recoveryPrecedence: .declKeyword)
    case .pound: return TokenSpec(.pound, recoveryPrecedence: .openingPoundIf)
    }
  }
}

enum DeclarationModifier: TokenSpecSet {
  case __consuming
  case __setter_access
  case _const
  case _local
  case async
  case borrowing
  case `class`
  case consuming
  case convenience
  case distributed
  case dynamic
  case `fileprivate`
  case final
  case indirect
  case infix
  case `internal`
  case isolated
  case lazy
  case mutating
  case nonisolated
  case nonmutating
  case open
  case optional
  case override
  case package
  case postfix
  case prefix
  case `private`
  case `public`
  case reasync
  case required
  case `rethrows`
  case `static`
  case unowned
  case weak

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(.__consuming): self = .__consuming
    case TokenSpec(.__setter_access): self = .__setter_access
    case TokenSpec(._const): self = ._const
    case TokenSpec(._local): self = ._local
    case TokenSpec(.async): self = .async
    case TokenSpec(.borrowing): self = .borrowing
    case TokenSpec(.class): self = .class
    case TokenSpec(.consuming): self = .consuming
    case TokenSpec(.convenience): self = .convenience
    case TokenSpec(.distributed): self = .distributed
    case TokenSpec(.dynamic): self = .dynamic
    case TokenSpec(.fileprivate): self = .fileprivate
    case TokenSpec(.final): self = .final
    case TokenSpec(.indirect): self = .indirect
    case TokenSpec(.infix): self = .infix
    case TokenSpec(.internal): self = .internal
    case TokenSpec(.isolated): self = .isolated
    case TokenSpec(.lazy): self = .lazy
    case TokenSpec(.mutating): self = .mutating
    case TokenSpec(.nonisolated): self = .nonisolated
    case TokenSpec(.nonmutating): self = .nonmutating
    case TokenSpec(.open): self = .open
    case TokenSpec(.optional): self = .optional
    case TokenSpec(.override): self = .override
    case TokenSpec(.package): self = .package
    case TokenSpec(.postfix): self = .postfix
    case TokenSpec(.prefix): self = .prefix
    case TokenSpec(.private): self = .private
    case TokenSpec(.public): self = .public
    case TokenSpec(.reasync): self = .reasync
    case TokenSpec(.required): self = .required
    case TokenSpec(.rethrows): self = .rethrows
    case TokenSpec(.static): self = .static
    case TokenSpec(.unowned): self = .unowned
    case TokenSpec(.weak): self = .weak
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .__consuming: return .keyword(.__consuming)
    case .__setter_access: return .keyword(.__setter_access)
    case ._const: return TokenSpec(._const, recoveryPrecedence: .declKeyword)
    case ._local: return .keyword(._local)
    case .async: return TokenSpec(.async, recoveryPrecedence: .declKeyword)
    case .borrowing: return TokenSpec(.borrowing, recoveryPrecedence: .declKeyword)
    case .class: return .keyword(.class)
    case .consuming: return TokenSpec(.consuming, recoveryPrecedence: .declKeyword)
    case .convenience: return .keyword(.convenience)
    case .distributed: return .keyword(.distributed)
    case .dynamic: return .keyword(.dynamic)
    case .fileprivate: return .keyword(.fileprivate)
    case .final: return .keyword(.final)
    case .indirect: return .keyword(.indirect)
    case .infix: return .keyword(.infix)
    case .internal: return .keyword(.internal)
    case .isolated: return TokenSpec(.isolated, recoveryPrecedence: .declKeyword)
    case .lazy: return .keyword(.lazy)
    case .mutating: return .keyword(.mutating)
    case .nonisolated: return .keyword(.nonisolated)
    case .nonmutating: return .keyword(.nonmutating)
    case .open: return .keyword(.open)
    case .optional: return .keyword(.optional)
    case .override: return .keyword(.override)
    case .package: return .keyword(.package)
    case .postfix: return .keyword(.postfix)
    case .prefix: return .keyword(.prefix)
    case .private: return .keyword(.private)
    case .public: return .keyword(.public)
    case .reasync: return TokenSpec(.reasync, recoveryPrecedence: .declKeyword)
    case .required: return .keyword(.required)
    case .rethrows: return TokenSpec(.rethrows, recoveryPrecedence: .declKeyword)
    case .static: return .keyword(.static)
    case .unowned: return TokenSpec(.unowned, recoveryPrecedence: .declKeyword)
    case .weak: return TokenSpec(.weak, recoveryPrecedence: .declKeyword)
    }
  }
}

/// Union of the following token kind subsets:
///  - `DeclarationModifier`
///  - `DeclarationKeyword`
enum DeclarationStart: TokenSpecSet {
  case declarationModifier(DeclarationModifier)
  case declarationKeyword(DeclarationKeyword)

  init?(lexeme: Lexer.Lexeme) {
    if let subset = DeclarationModifier(lexeme: lexeme) {
      self = .declarationModifier(subset)
    } else if let subset = DeclarationKeyword(lexeme: lexeme) {
      self = .declarationKeyword(subset)
    } else {
      return nil
    }
  }

  static var allCases: [DeclarationStart] {
    return DeclarationModifier.allCases.map(Self.declarationModifier) + DeclarationKeyword.allCases.map(Self.declarationKeyword)
  }

  var spec: TokenSpec {
    switch self {
    case .declarationModifier(let underlyingKind): return underlyingKind.spec
    case .declarationKeyword(let underlyingKind): return underlyingKind.spec
    }
  }
}

enum Operator: TokenSpecSet {
  case binaryOperator
  case postfixOperator
  case prefixOperator

  init?(lexeme: Lexer.Lexeme) {
    switch lexeme.rawTokenKind {
    case .binaryOperator: self = .binaryOperator
    case .postfixOperator: self = .postfixOperator
    case .prefixOperator: self = .prefixOperator
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .binaryOperator: return .binaryOperator
    case .postfixOperator: return .postfixOperator
    case .prefixOperator: return .prefixOperator
    }
  }
}

/// Tokens that can be used in operator declarations
enum OperatorLike: TokenSpecSet {
  case `operator`(Operator)
  case exclamationMark
  case infixQuestionMark
  case postfixQuestionMark
  case equal
  case arrow

  init?(lexeme: Lexer.Lexeme) {
    if let op = Operator(lexeme: lexeme) {
      self = .operator(op)
      return
    }
    switch lexeme.rawTokenKind {
    case .exclamationMark: self = .exclamationMark
    case .infixQuestionMark: self = .infixQuestionMark
    case .postfixQuestionMark: self = .postfixQuestionMark
    case .equal: self = .equal
    case .arrow: self = .arrow
    default: return nil
    }
  }

  static var allCases: [OperatorLike] {
    return Operator.allCases.map(Self.operator) + [
      .exclamationMark,
      .infixQuestionMark,
      .postfixQuestionMark,
      .equal,
      .arrow,
    ]
  }

  var spec: TokenSpec {
    switch self {
    case .operator(let op): return op.spec
    case .exclamationMark: return TokenSpec(.exclamationMark, remapping: .postfixOperator)
    case .infixQuestionMark: return TokenSpec(.infixQuestionMark, remapping: .binaryOperator)
    case .postfixQuestionMark: return TokenSpec(.postfixQuestionMark, remapping: .postfixOperator)
    case .equal: return TokenSpec(.equal, remapping: .binaryOperator)
    case .arrow: return TokenSpec(.arrow, remapping: .binaryOperator)
    }
  }
}

enum SwitchCaseStart: TokenSpecSet {
  case `case`
  case `default`

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(.case): self = .case
    case TokenSpec(.default): self = .default
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .case: return .keyword(.case)
    case .default: return .keyword(.default)
    }
  }
}

enum TypeAttribute: TokenSpecSet {
  case _local
  case _noMetadata
  case _opaqueReturnTypeOf
  case async
  case autoclosure
  case convention
  case differentiable
  case escaping
  case noDerivative
  case noescape
  case Sendable
  case unchecked

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(._local): self = ._local
    case TokenSpec(._noMetadata): self = ._noMetadata
    case TokenSpec(._opaqueReturnTypeOf): self = ._opaqueReturnTypeOf
    case TokenSpec(.async): self = .async
    case TokenSpec(.autoclosure): self = .autoclosure
    case TokenSpec(.convention): self = .convention
    case TokenSpec(.differentiable): self = .differentiable
    case TokenSpec(.escaping): self = .escaping
    case TokenSpec(.noDerivative): self = .noDerivative
    case TokenSpec(.noescape): self = .noescape
    case TokenSpec(.Sendable): self = .Sendable
    case TokenSpec(.unchecked): self = .unchecked
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case ._local: return .keyword(._local)
    case ._noMetadata: return .keyword(._noMetadata)
    case ._opaqueReturnTypeOf: return .keyword(._opaqueReturnTypeOf)
    case .async: return .keyword(.async)
    case .autoclosure: return .keyword(.autoclosure)
    case .convention: return .keyword(.convention)
    case .differentiable: return .keyword(.differentiable)
    case .escaping: return .keyword(.escaping)
    case .noDerivative: return .keyword(.noDerivative)
    case .noescape: return .keyword(.noescape)
    case .Sendable: return .keyword(.Sendable)
    case .unchecked: return .keyword(.unchecked)
    }
  }
}

@_spi(Diagnostics)
public enum TypeSpecifier: TokenSpecSet {
  case `inout`
  case owned
  case shared
  case borrowing
  case consuming

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(.inout): self = .inout
    case TokenSpec(.__owned): self = .owned
    case TokenSpec(.__shared): self = .shared
    case TokenSpec(.consuming): self = .consuming
    case TokenSpec(.borrowing): self = .borrowing
    default: return nil
    }
  }

  @_spi(Diagnostics)
  public init?(token: TokenSyntax) {
    switch token {
    case TokenSpec(.inout): self = .inout
    case TokenSpec(.__owned): self = .owned
    case TokenSpec(.__shared): self = .shared
    case TokenSpec(.consuming): self = .shared
    case TokenSpec(.borrowing): self = .shared
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .inout: return .keyword(.inout)
    case .owned: return .keyword(.__owned)
    case .shared: return .keyword(.__shared)
    case .borrowing: return .keyword(.borrowing)
    case .consuming: return .keyword(.consuming)
    }
  }
}

// MARK: Expression start

enum ExpressionModifierKeyword: TokenSpecSet {
  case await
  case _move
  case _borrow
  case `try`
  case consume
  case copy

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(.await): self = .await
    case TokenSpec(._move): self = ._move
    case TokenSpec(._borrow): self = ._borrow
    case TokenSpec(.try): self = .try
    case TokenSpec(.consume): self = .consume
    case TokenSpec(.copy): self = .copy
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .await: return .keyword(.await)
    case ._move: return .keyword(._move)
    case ._borrow: return .keyword(._borrow)
    case .consume: return .keyword(.consume)
    case .copy: return .keyword(.copy)
    case .try: return .keyword(.try)
    }
  }
}

enum IfOrSwitch: TokenSpecSet {
  case `if`
  case `switch`

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(.if): self = .if
    case TokenSpec(.switch): self = .switch
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .if: return .keyword(.if)
    case .switch: return .keyword(.switch)
    }
  }
}

enum ExpressionPrefixOperator: TokenSpecSet {
  case backslash
  case prefixAmpersand
  case prefixOperator

  init?(lexeme: Lexer.Lexeme) {
    switch lexeme.rawTokenKind {
    case .backslash: self = .backslash
    case .prefixAmpersand: self = .prefixAmpersand
    case .prefixOperator: self = .prefixOperator
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .backslash: return .backslash
    case .prefixAmpersand: return .prefixAmpersand
    case .prefixOperator: return .prefixOperator
    }
  }
}

enum MatchingPatternStart: TokenSpecSet {
  case `is`
  case `let`
  case `var`
  case `inout`

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(.is): self = .is
    case TokenSpec(.let): self = .let
    case TokenSpec(.var): self = .var
    case TokenSpec(.inout): self = .inout
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .is: return .keyword(.is)
    case .let: return .keyword(.let)
    case .var: return .keyword(.var)
    case .inout: return .keyword(.inout)
    }
  }
}

enum ParameterModifier: TokenSpecSet {
  case _const
  case isolated

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(._const): self = ._const
    case TokenSpec(.isolated): self = .isolated
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case ._const: return .keyword(._const)
    case .isolated: return .keyword(.isolated)
    }
  }
}

enum PrimaryExpressionStart: TokenSpecSet {
  case `Any`
  case atSign  // For recovery
  case `Self`
  case dollarIdentifier
  case `false`
  case floatingLiteral
  case identifier
  case `init`
  case integerLiteral
  case leftBrace
  case leftParen
  case leftSquare
  case `nil`
  case period
  case pound
  case poundAvailableKeyword  // For recovery
  case poundUnavailableKeyword  // For recovery
  case regexSlash
  case extendedRegexDelimiter
  case `self`
  case `super`
  case `true`
  case wildcard
  case rawStringDelimiter
  case stringQuote
  case multilineStringQuote
  case singleQuote

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(.Any): self = .Any
    case TokenSpec(.atSign): self = .atSign
    case TokenSpec(.Self): self = .Self
    case TokenSpec(.dollarIdentifier): self = .dollarIdentifier
    case TokenSpec(.false): self = .false
    case TokenSpec(.floatingLiteral): self = .floatingLiteral
    case TokenSpec(.identifier): self = .identifier
    case TokenSpec(.`init`): self = .`init`
    case TokenSpec(.integerLiteral): self = .integerLiteral
    case TokenSpec(.leftBrace): self = .leftBrace
    case TokenSpec(.leftParen): self = .leftParen
    case TokenSpec(.leftSquare): self = .leftSquare
    case TokenSpec(.nil): self = .nil
    case TokenSpec(.period): self = .period
    case TokenSpec(.pound): self = .pound
    case TokenSpec(.poundAvailableKeyword): self = .poundAvailableKeyword
    case TokenSpec(.poundUnavailableKeyword): self = .poundUnavailableKeyword
    case TokenSpec(.regexSlash): self = .regexSlash
    case TokenSpec(.extendedRegexDelimiter): self = .extendedRegexDelimiter
    case TokenSpec(.self): self = .self
    case TokenSpec(.super): self = .super
    case TokenSpec(.true): self = .true
    case TokenSpec(.wildcard): self = .wildcard
    case TokenSpec(.rawStringDelimiter): self = .rawStringDelimiter
    case TokenSpec(.stringQuote): self = .stringQuote
    case TokenSpec(.multilineStringQuote): self = .multilineStringQuote
    case TokenSpec(.singleQuote): self = .singleQuote
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .Any: return .keyword(.Any)
    case .atSign: return .atSign
    case .Self: return .keyword(.Self)
    case .dollarIdentifier: return .dollarIdentifier
    case .false: return .keyword(.false)
    case .floatingLiteral: return .floatingLiteral
    case .identifier: return .identifier
    case .`init`: return .keyword(.`init`)
    case .integerLiteral: return .integerLiteral
    case .leftBrace: return .leftBrace
    case .leftParen: return .leftParen
    case .leftSquare: return .leftSquare
    case .nil: return .keyword(.nil)
    case .period: return .period
    case .pound: return .pound
    case .poundAvailableKeyword: return .poundAvailableKeyword
    case .poundUnavailableKeyword: return .poundUnavailableKeyword
    case .regexSlash: return .regexSlash
    case .extendedRegexDelimiter: return .extendedRegexDelimiter
    case .self: return .keyword(.self)
    case .super: return .keyword(.super)
    case .true: return .keyword(.true)
    case .wildcard: return .wildcard
    case .rawStringDelimiter: return .rawStringDelimiter
    case .stringQuote: return .stringQuote
    case .multilineStringQuote: return .multilineStringQuote
    case .singleQuote: return .singleQuote
    }
  }
}

/// Union of the following token kind subsets:
///  - `AwaitTry`
///  - `ExpressionPrefixOperator`
///  - `MatchingPatternStart`
///  - `PrimaryExpressionStart`
enum ExpressionStart: TokenSpecSet {
  case awaitTryMove(ExpressionModifierKeyword)
  case expressionPrefixOperator(ExpressionPrefixOperator)
  case primaryExpressionStart(PrimaryExpressionStart)
  case ifOrSwitch(IfOrSwitch)

  init?(lexeme: Lexer.Lexeme) {
    if let subset = ExpressionModifierKeyword(lexeme: lexeme) {
      self = .awaitTryMove(subset)
    } else if let subset = ExpressionPrefixOperator(lexeme: lexeme) {
      self = .expressionPrefixOperator(subset)
    } else if let subset = PrimaryExpressionStart(lexeme: lexeme) {
      self = .primaryExpressionStart(subset)
    } else if let subset = IfOrSwitch(lexeme: lexeme) {
      self = .ifOrSwitch(subset)
    } else {
      return nil
    }
  }

  static var allCases: [ExpressionStart] {
    return ExpressionModifierKeyword.allCases.map(Self.awaitTryMove)
      + ExpressionPrefixOperator.allCases.map(Self.expressionPrefixOperator)
      + PrimaryExpressionStart.allCases.map(Self.primaryExpressionStart)
      + IfOrSwitch.allCases.map(Self.ifOrSwitch)
  }

  var spec: TokenSpec {
    switch self {
    case .awaitTryMove(let underlyingKind): return underlyingKind.spec
    case .expressionPrefixOperator(let underlyingKind): return underlyingKind.spec
    case .primaryExpressionStart(let underlyingKind): return underlyingKind.spec
    case .ifOrSwitch(let underlyingKind): return underlyingKind.spec
    }
  }
}

enum EffectSpecifiers: TokenSpecSet {
  case async
  case await
  case reasync
  case `rethrows`
  case `throw`
  case `throws`
  case `try`

  init?(lexeme: Lexer.Lexeme) {
    switch PrepareForKeywordMatch(lexeme) {
    case TokenSpec(.async): self = .async
    case TokenSpec(.await, allowAtStartOfLine: false): self = .await
    case TokenSpec(.reasync): self = .reasync
    case TokenSpec(.rethrows): self = .rethrows
    case TokenSpec(.throw, allowAtStartOfLine: false): self = .throw
    case TokenSpec(.throws): self = .throws
    case TokenSpec(.try, allowAtStartOfLine: false): self = .try
    default: return nil
    }
  }

  var spec: TokenSpec {
    switch self {
    case .async: return .keyword(.async)
    case .await: return TokenSpec(.await, allowAtStartOfLine: false)
    case .reasync: return .keyword(.reasync)
    case .rethrows: return .keyword(.rethrows)
    case .throw: return TokenSpec(.throw, allowAtStartOfLine: false)
    case .throws: return .keyword(.throws)
    case .try: return TokenSpec(.try, allowAtStartOfLine: false)
    }
  }
}
