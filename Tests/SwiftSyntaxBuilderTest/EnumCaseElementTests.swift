import XCTest
import SwiftSyntax
import SwiftSyntaxBuilder

final class EnumCaseElementTests: XCTestCase {
  func testEnumInit() {
    let leadingTrivia = Trivia.unexpectedText("␣")
    let buildable = EnumDecl(
      identifier: "Greeting",
      inheritanceClause: TypeInheritanceClause {
        InheritedType(typeName: "String")
        InheritedType(typeName: "Codable")
        InheritedType(typeName: "Equatable")
      }
    ) {
      EnumCaseDecl {
        EnumCaseElement(
          identifier: "goodMorning",
          rawValue: StringLiteralExpr("Good Morning"))
        EnumCaseElement(
          identifier: "helloWorld",
          rawValue: StringLiteralExpr("Hello World"))
        EnumCaseElement(identifier: "hi")
      }
    }
    let syntax = buildable.buildSyntax(format: Format(), leadingTrivia: leadingTrivia)

    XCTAssertEqual(syntax.description,
      """
      ␣enum Greeting: String, Codable, Equatable {
          case goodMorning = "Good Morning", helloWorld = "Hello World", hi
      }
      """)
  }
}
