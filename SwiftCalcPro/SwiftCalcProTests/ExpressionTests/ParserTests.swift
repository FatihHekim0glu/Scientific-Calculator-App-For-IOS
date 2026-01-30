import XCTest
@testable import ScientificCalculatorAppForIOS

final class ParserTests: XCTestCase {
    
    // MARK: - Helper Methods
    
    private func parse(_ input: String) throws -> ASTNode {
        var lexer = Lexer(input: input)
        let tokens = try lexer.tokenize()
        var parser = Parser(tokens: tokens)
        return try parser.parse()
    }
    
    private func parseTokens(_ tokens: [Token]) throws -> ASTNode {
        var parser = Parser(tokens: tokens)
        return try parser.parse()
    }
    
    // MARK: - Single Number
    
    func test_Parser_SingleNumber_ReturnsNumberNode() throws {
        let tokens = [
            Token(type: .number(42.0), position: 0),
            Token(type: .end, position: 2)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .number(42.0))
    }
    
    func test_Parser_DecimalNumber_ReturnsNumberNode() throws {
        let tokens = [
            Token(type: .number(3.14159), position: 0),
            Token(type: .end, position: 7)
        ]
        
        let result = try parseTokens(tokens)
        
        if case .number(let value) = result {
            XCTAssertEqual(value, 3.14159, accuracy: 1e-10)
        } else {
            XCTFail("Expected number node")
        }
    }
    
    // MARK: - Binary Operations
    
    func test_Parser_SimpleAddition_ReturnsBinaryOpNode() throws {
        let tokens = [
            Token(type: .number(2.0), position: 0),
            Token(type: .binaryOperator(.add), position: 1),
            Token(type: .number(3.0), position: 2),
            Token(type: .end, position: 3)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .binaryOp(.add, .number(2.0), .number(3.0)))
    }
    
    func test_Parser_Subtraction_ReturnsBinaryOpNode() throws {
        let tokens = [
            Token(type: .number(5.0), position: 0),
            Token(type: .binaryOperator(.subtract), position: 1),
            Token(type: .number(3.0), position: 2),
            Token(type: .end, position: 3)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .binaryOp(.subtract, .number(5.0), .number(3.0)))
    }
    
    func test_Parser_Multiplication_ReturnsBinaryOpNode() throws {
        let tokens = [
            Token(type: .number(4.0), position: 0),
            Token(type: .binaryOperator(.multiply), position: 1),
            Token(type: .number(5.0), position: 2),
            Token(type: .end, position: 3)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .binaryOp(.multiply, .number(4.0), .number(5.0)))
    }
    
    func test_Parser_Division_ReturnsBinaryOpNode() throws {
        let tokens = [
            Token(type: .number(10.0), position: 0),
            Token(type: .binaryOperator(.divide), position: 1),
            Token(type: .number(2.0), position: 2),
            Token(type: .end, position: 3)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .binaryOp(.divide, .number(10.0), .number(2.0)))
    }
    
    func test_Parser_Power_ReturnsBinaryOpNode() throws {
        let tokens = [
            Token(type: .number(2.0), position: 0),
            Token(type: .binaryOperator(.power), position: 1),
            Token(type: .number(8.0), position: 2),
            Token(type: .end, position: 3)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .binaryOp(.power, .number(2.0), .number(8.0)))
    }
    
    // MARK: - Operator Precedence
    
    func test_Parser_OperatorPrecedence_MultiplyBeforeAdd() throws {
        let tokens = [
            Token(type: .number(2.0), position: 0),
            Token(type: .binaryOperator(.add), position: 1),
            Token(type: .number(3.0), position: 2),
            Token(type: .binaryOperator(.multiply), position: 3),
            Token(type: .number(4.0), position: 4),
            Token(type: .end, position: 5)
        ]
        
        let result = try parseTokens(tokens)
        
        let expected = ASTNode.binaryOp(
            .add,
            .number(2.0),
            .binaryOp(.multiply, .number(3.0), .number(4.0))
        )
        XCTAssertEqual(result, expected)
    }
    
    func test_Parser_OperatorPrecedence_PowerBeforeMultiply() throws {
        let tokens = [
            Token(type: .number(2.0), position: 0),
            Token(type: .binaryOperator(.multiply), position: 1),
            Token(type: .number(3.0), position: 2),
            Token(type: .binaryOperator(.power), position: 3),
            Token(type: .number(2.0), position: 4),
            Token(type: .end, position: 5)
        ]
        
        let result = try parseTokens(tokens)
        
        let expected = ASTNode.binaryOp(
            .multiply,
            .number(2.0),
            .binaryOp(.power, .number(3.0), .number(2.0))
        )
        XCTAssertEqual(result, expected)
    }
    
    func test_Parser_OperatorPrecedence_ComplexExpression() throws {
        let tokens = [
            Token(type: .number(1.0), position: 0),
            Token(type: .binaryOperator(.add), position: 1),
            Token(type: .number(2.0), position: 2),
            Token(type: .binaryOperator(.multiply), position: 3),
            Token(type: .number(3.0), position: 4),
            Token(type: .binaryOperator(.power), position: 5),
            Token(type: .number(4.0), position: 6),
            Token(type: .end, position: 7)
        ]
        
        let result = try parseTokens(tokens)
        
        let expected = ASTNode.binaryOp(
            .add,
            .number(1.0),
            .binaryOp(
                .multiply,
                .number(2.0),
                .binaryOp(.power, .number(3.0), .number(4.0))
            )
        )
        XCTAssertEqual(result, expected)
    }
    
    // MARK: - Parentheses
    
    func test_Parser_Parentheses_OverridePrecedence() throws {
        let tokens = [
            Token(type: .leftParen, position: 0),
            Token(type: .number(2.0), position: 1),
            Token(type: .binaryOperator(.add), position: 2),
            Token(type: .number(3.0), position: 3),
            Token(type: .rightParen, position: 4),
            Token(type: .binaryOperator(.multiply), position: 5),
            Token(type: .number(4.0), position: 6),
            Token(type: .end, position: 7)
        ]
        
        let result = try parseTokens(tokens)
        
        let expected = ASTNode.binaryOp(
            .multiply,
            .binaryOp(.add, .number(2.0), .number(3.0)),
            .number(4.0)
        )
        XCTAssertEqual(result, expected)
    }
    
    func test_Parser_NestedParentheses_ParsesCorrectly() throws {
        let tokens = [
            Token(type: .leftParen, position: 0),
            Token(type: .leftParen, position: 1),
            Token(type: .number(1.0), position: 2),
            Token(type: .binaryOperator(.add), position: 3),
            Token(type: .number(2.0), position: 4),
            Token(type: .rightParen, position: 5),
            Token(type: .binaryOperator(.multiply), position: 6),
            Token(type: .number(3.0), position: 7),
            Token(type: .rightParen, position: 8),
            Token(type: .end, position: 9)
        ]
        
        let result = try parseTokens(tokens)
        
        let expected = ASTNode.binaryOp(
            .multiply,
            .binaryOp(.add, .number(1.0), .number(2.0)),
            .number(3.0)
        )
        XCTAssertEqual(result, expected)
    }
    
    // MARK: - Unary Operators
    
    func test_Parser_UnaryMinus_ReturnsUnaryOpNode() throws {
        let tokens = [
            Token(type: .unaryOperator(.negate), position: 0),
            Token(type: .number(5.0), position: 1),
            Token(type: .end, position: 2)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .unaryOp(.negate, .number(5.0)))
    }
    
    func test_Parser_Factorial_ReturnsUnaryOpNode() throws {
        let tokens = [
            Token(type: .number(5.0), position: 0),
            Token(type: .unaryOperator(.factorial), position: 1),
            Token(type: .end, position: 2)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .unaryOp(.factorial, .number(5.0)))
    }
    
    func test_Parser_DoubleFactorial_ParsesCorrectly() throws {
        let tokens = [
            Token(type: .number(3.0), position: 0),
            Token(type: .unaryOperator(.factorial), position: 1),
            Token(type: .unaryOperator(.factorial), position: 2),
            Token(type: .end, position: 3)
        ]
        
        let result = try parseTokens(tokens)
        
        let expected = ASTNode.unaryOp(.factorial, .unaryOp(.factorial, .number(3.0)))
        XCTAssertEqual(result, expected)
    }
    
    // MARK: - Functions
    
    func test_Parser_Function_Sin_ReturnsFunctionNode() throws {
        let tokens = [
            Token(type: .function(.sin), position: 0),
            Token(type: .leftParen, position: 3),
            Token(type: .number(30.0), position: 4),
            Token(type: .rightParen, position: 6),
            Token(type: .end, position: 7)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .function(.sin, .number(30.0)))
    }
    
    func test_Parser_Function_WithParentheses() throws {
        let tokens = [
            Token(type: .function(.cos), position: 0),
            Token(type: .leftParen, position: 3),
            Token(type: .number(60.0), position: 4),
            Token(type: .rightParen, position: 6),
            Token(type: .end, position: 7)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .function(.cos, .number(60.0)))
    }
    
    func test_Parser_Function_WithExpression() throws {
        let tokens = [
            Token(type: .function(.sin), position: 0),
            Token(type: .leftParen, position: 3),
            Token(type: .number(30.0), position: 4),
            Token(type: .binaryOperator(.add), position: 6),
            Token(type: .number(15.0), position: 7),
            Token(type: .rightParen, position: 9),
            Token(type: .end, position: 10)
        ]
        
        let result = try parseTokens(tokens)
        
        let expected = ASTNode.function(.sin, .binaryOp(.add, .number(30.0), .number(15.0)))
        XCTAssertEqual(result, expected)
    }
    
    func test_Parser_NestedFunctions() throws {
        let tokens = [
            Token(type: .function(.sin), position: 0),
            Token(type: .leftParen, position: 3),
            Token(type: .function(.cos), position: 4),
            Token(type: .leftParen, position: 7),
            Token(type: .number(0.0), position: 8),
            Token(type: .rightParen, position: 9),
            Token(type: .rightParen, position: 10),
            Token(type: .end, position: 11)
        ]
        
        let result = try parseTokens(tokens)
        
        let expected = ASTNode.function(.sin, .function(.cos, .number(0.0)))
        XCTAssertEqual(result, expected)
    }
    
    // MARK: - Constants
    
    func test_Parser_Constant_Pi_ReturnsConstantNode() throws {
        let tokens = [
            Token(type: .constant(.pi), position: 0),
            Token(type: .end, position: 1)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .constant(.pi))
    }
    
    func test_Parser_Constant_E_ReturnsConstantNode() throws {
        let tokens = [
            Token(type: .constant(.e), position: 0),
            Token(type: .end, position: 1)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .constant(.e))
    }
    
    func test_Parser_ConstantInExpression() throws {
        let tokens = [
            Token(type: .number(2.0), position: 0),
            Token(type: .binaryOperator(.multiply), position: 1),
            Token(type: .constant(.pi), position: 2),
            Token(type: .end, position: 3)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .binaryOp(.multiply, .number(2.0), .constant(.pi)))
    }
    
    // MARK: - Variables
    
    func test_Parser_Variable_ReturnsVariableNode() throws {
        let tokens = [
            Token(type: .variable("A"), position: 0),
            Token(type: .end, position: 1)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .variable("A"))
    }
    
    func test_Parser_VariableInExpression() throws {
        let tokens = [
            Token(type: .variable("A"), position: 0),
            Token(type: .binaryOperator(.add), position: 1),
            Token(type: .variable("B"), position: 2),
            Token(type: .end, position: 3)
        ]
        
        let result = try parseTokens(tokens)
        
        XCTAssertEqual(result, .binaryOp(.add, .variable("A"), .variable("B")))
    }
    
    // MARK: - Right Associativity
    
    func test_Parser_RightAssociativity_Power() throws {
        let tokens = [
            Token(type: .number(2.0), position: 0),
            Token(type: .binaryOperator(.power), position: 1),
            Token(type: .number(3.0), position: 2),
            Token(type: .binaryOperator(.power), position: 3),
            Token(type: .number(4.0), position: 4),
            Token(type: .end, position: 5)
        ]
        
        let result = try parseTokens(tokens)
        
        let expected = ASTNode.binaryOp(
            .power,
            .number(2.0),
            .binaryOp(.power, .number(3.0), .number(4.0))
        )
        XCTAssertEqual(result, expected)
    }
    
    // MARK: - Left Associativity
    
    func test_Parser_LeftAssociativity_Addition() throws {
        let tokens = [
            Token(type: .number(1.0), position: 0),
            Token(type: .binaryOperator(.add), position: 1),
            Token(type: .number(2.0), position: 2),
            Token(type: .binaryOperator(.add), position: 3),
            Token(type: .number(3.0), position: 4),
            Token(type: .end, position: 5)
        ]
        
        let result = try parseTokens(tokens)
        
        let expected = ASTNode.binaryOp(
            .add,
            .binaryOp(.add, .number(1.0), .number(2.0)),
            .number(3.0)
        )
        XCTAssertEqual(result, expected)
    }
    
    func test_Parser_LeftAssociativity_Subtraction() throws {
        let tokens = [
            Token(type: .number(10.0), position: 0),
            Token(type: .binaryOperator(.subtract), position: 1),
            Token(type: .number(3.0), position: 2),
            Token(type: .binaryOperator(.subtract), position: 3),
            Token(type: .number(2.0), position: 4),
            Token(type: .end, position: 5)
        ]
        
        let result = try parseTokens(tokens)
        
        let expected = ASTNode.binaryOp(
            .subtract,
            .binaryOp(.subtract, .number(10.0), .number(3.0)),
            .number(2.0)
        )
        XCTAssertEqual(result, expected)
    }
    
    // MARK: - Error Cases
    
    func test_Parser_MismatchedParentheses_ThrowsError() {
        let tokens = [
            Token(type: .leftParen, position: 0),
            Token(type: .number(1.0), position: 1),
            Token(type: .binaryOperator(.add), position: 2),
            Token(type: .number(2.0), position: 3),
            Token(type: .end, position: 4)
        ]
        
        XCTAssertThrowsError(try parseTokens(tokens)) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntax error")
                return
            }
        }
    }
    
    func test_Parser_MissingOperand_ThrowsError() {
        let tokens = [
            Token(type: .number(1.0), position: 0),
            Token(type: .binaryOperator(.add), position: 1),
            Token(type: .end, position: 2)
        ]
        
        XCTAssertThrowsError(try parseTokens(tokens)) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntax error")
                return
            }
        }
    }
    
    func test_Parser_EmptyInput_ThrowsError() {
        let tokens: [Token] = []
        
        XCTAssertThrowsError(try parseTokens(tokens)) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntax error")
                return
            }
        }
    }
    
    func test_Parser_OnlyEndToken_ThrowsError() {
        let tokens = [
            Token(type: .end, position: 0)
        ]
        
        XCTAssertThrowsError(try parseTokens(tokens)) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntax error")
                return
            }
        }
    }
    
    func test_Parser_UnexpectedOperator_ThrowsError() {
        let tokens = [
            Token(type: .binaryOperator(.multiply), position: 0),
            Token(type: .number(5.0), position: 1),
            Token(type: .end, position: 2)
        ]
        
        XCTAssertThrowsError(try parseTokens(tokens)) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntax error")
                return
            }
        }
    }
    
    func test_Parser_ExtraRightParen_ThrowsError() {
        let tokens = [
            Token(type: .number(1.0), position: 0),
            Token(type: .rightParen, position: 1),
            Token(type: .end, position: 2)
        ]
        
        XCTAssertThrowsError(try parseTokens(tokens)) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntax error")
                return
            }
        }
    }
    
    func test_Parser_ConsecutiveOperators_ThrowsError() {
        let tokens = [
            Token(type: .number(1.0), position: 0),
            Token(type: .binaryOperator(.add), position: 1),
            Token(type: .binaryOperator(.multiply), position: 2),
            Token(type: .number(2.0), position: 3),
            Token(type: .end, position: 4)
        ]
        
        XCTAssertThrowsError(try parseTokens(tokens)) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntax error")
                return
            }
        }
    }
    
    // MARK: - Complex Expressions
    
    func test_Parser_ComplexMathExpression() throws {
        let tokens = [
            Token(type: .function(.sin), position: 0),
            Token(type: .leftParen, position: 3),
            Token(type: .constant(.pi), position: 4),
            Token(type: .binaryOperator(.divide), position: 5),
            Token(type: .number(2.0), position: 6),
            Token(type: .rightParen, position: 7),
            Token(type: .binaryOperator(.add), position: 8),
            Token(type: .function(.cos), position: 9),
            Token(type: .leftParen, position: 12),
            Token(type: .number(0.0), position: 13),
            Token(type: .rightParen, position: 14),
            Token(type: .end, position: 15)
        ]
        
        let result = try parseTokens(tokens)
        
        let expected = ASTNode.binaryOp(
            .add,
            .function(.sin, .binaryOp(.divide, .constant(.pi), .number(2.0))),
            .function(.cos, .number(0.0))
        )
        XCTAssertEqual(result, expected)
    }
}
