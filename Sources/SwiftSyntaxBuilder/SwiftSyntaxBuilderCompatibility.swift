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

// This file provides compatiblity aliases to keep dependents of SwiftSyntaxBuilder building.
// All users of the declarations in this file should transition away from them ASAP.

import SwiftSyntax

@available(*, deprecated, renamed: "ImportPathBuilder")
public typealias AccessPathBuilder = ImportPathBuilder

extension TupleExprSyntax {
  @available(*, deprecated, message: "Use an initializer with a elements argument")
  public init(
    leadingTrivia: Trivia? = nil,
    unexpectedBeforeLeftParen: UnexpectedNodesSyntax? = nil,
    leftParen: TokenSyntax = .leftParenToken(),
    unexpectedBetweenLeftParenAndElementList: UnexpectedNodesSyntax? = nil,
    unexpectedBetweenElementListAndRightParen: UnexpectedNodesSyntax? = nil,
    rightParen: TokenSyntax = .rightParenToken(),
    unexpectedAfterRightParen: UnexpectedNodesSyntax? = nil,
    @TupleExprElementListBuilder elementListBuilder: () throws -> TupleExprElementListSyntax,
    trailingTrivia: Trivia? = nil
  ) rethrows {
    try self.init(
      leadingTrivia: leadingTrivia,
      unexpectedBeforeLeftParen,
      leftParen: leftParen,
      unexpectedBetweenLeftParenAndElementList,
      elements: elementListBuilder(),
      unexpectedBetweenElementListAndRightParen,
      rightParen: rightParen,
      unexpectedAfterRightParen,
      trailingTrivia: trailingTrivia
    )
  }
}
