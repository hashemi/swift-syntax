import XCTest
@_spi(RawSyntax) import SwiftSyntax
@_spi(Testing) @_spi(RawSyntax) import SwiftParser
import _SwiftSyntaxTestSupport

public class DiagnosticTests: XCTestCase {
  public func testMissingTokenDiags() throws {
    let source = """
    (first second Int)
    """
    let signature = withParser(source: source) { Syntax(raw: $0.parseFunctionSignature().raw) }

    XCTAssertSingleDiagnostic(in: signature, line: 1, column: 15, id: MissingTokenError.diagnosticID, message: "Expected ':' in function parameter")
  }

  public func testUnexpectedDiags() throws {
    let source = """
    (first second third fourth: Int)
    """
    let signature = withParser(source: source) { Syntax(raw: $0.parseFunctionSignature().raw) }

    XCTAssertSingleDiagnostic(in: signature, line: 1, column: 15, message: "Unexpected text 'third fourth' found in function parameter")
  }

  public func testCStyleForLoop() throws {
    let source = """
    for let x = 0; x < 10; x += 1, y += 1 {
    }
    """
    let loop = withParser(source: source) {
      Syntax(raw: $0.parseForEachStatement().raw).as(ForInStmtSyntax.self)!
    }

    XCTAssertSingleDiagnostic(
      in: loop,
      line: 1, column: 1,
      message: "C-style for statement has been removed in Swift 3",
      highlight: "let x = 0; x < 10; x += 1, y += 1 "
    )
  }

  public func testMissingClosingParen() throws {
    let source = """
    (first second: Int
    """
    let signature = withParser(source: source) {
      Syntax(raw: $0.parseFunctionSignature().raw).as(FunctionSignatureSyntax.self)!
    }

    XCTAssertSingleDiagnostic(in: signature, line: 1, column: 19, message: "Expected ')' to end parameter clause")
  }

  public func testMissingOpeningParen() throws {
    let source = """
    first second: Int)
    """
    let signature = withParser(source: source) {
      Syntax(raw: $0.parseFunctionSignature().raw).as(FunctionSignatureSyntax.self)!
    }

    XCTAssertSingleDiagnostic(in: signature, line: 1, column: 1, message: "Expected '(' to start parameter clause")
  }

  public func testThrowsInWrongLocation() throws {
    let source = """
    () -> throws Int
    """

    let signature = withParser(source: source) {
      Syntax(raw: $0.parseFunctionSignature().raw).as(FunctionSignatureSyntax.self)!
    }

    XCTAssertSingleDiagnostic(
      in: signature,
      line: 1, column: 7,
      message: "'throws' may only occur before '->'",
      expectedFixedSource: "() throws -> Int"
    )
  }

  public func testNoParamsForFunction() throws {
    let source = """
    class MyClass {
      func withoutParameters

      func withParameters() {}
    }
    """

    let classDecl = withParser(source: source) {
      Syntax(raw: $0.parseDeclaration().raw).as(ClassDeclSyntax.self)!
    }

    XCTAssertSingleDiagnostic(in: classDecl, line: 2, column: 25, message: "Expected argument list in function declaration")
  }

  func testMissingColonInTernary() throws {
    let source = """
      foo ? 1
      """

    let node = withParser(source: source) {
      Syntax(raw: $0.parseExpression().raw)
    }

    XCTAssertSingleDiagnostic(in: node, line: 1, column: 8, message: "Expected ':' after '? ...' in ternary expression")
  }
}
