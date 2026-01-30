import XCTest
@testable import ScientificCalculatorAppForIOS

final class TokenTests: XCTestCase {
    
    // MARK: - MathConstant Tests
    
    func test_MathConstant_Pi_ReturnsCorrectValue() {
        let pi = MathConstant.pi
        XCTAssertEqual(pi.value, Double.pi, accuracy: 1e-15)
    }
    
    func test_MathConstant_E_ReturnsCorrectValue() {
        let e = MathConstant.e
        XCTAssertEqual(e.value, M_E, accuracy: 1e-15)
    }
    
    func test_MathConstant_Pi_RawValue() {
        XCTAssertEqual(MathConstant.pi.rawValue, "π")
    }
    
    func test_MathConstant_E_RawValue() {
        XCTAssertEqual(MathConstant.e.rawValue, "e")
    }
    
    func test_MathConstant_AllCases() {
        let allCases = MathConstant.allCases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.pi))
        XCTAssertTrue(allCases.contains(.e))
    }
    
    // MARK: - BinaryOperator Precedence Tests
    
    func test_BinaryOperator_Precedence_IsCorrect() {
        XCTAssertEqual(BinaryOperator.add.precedence, 1)
        XCTAssertEqual(BinaryOperator.subtract.precedence, 1)
        XCTAssertEqual(BinaryOperator.multiply.precedence, 2)
        XCTAssertEqual(BinaryOperator.divide.precedence, 2)
        XCTAssertEqual(BinaryOperator.power.precedence, 3)
    }
    
    func test_BinaryOperator_AddSubtract_SamePrecedence() {
        XCTAssertEqual(BinaryOperator.add.precedence, BinaryOperator.subtract.precedence)
    }
    
    func test_BinaryOperator_MultiplyDivide_SamePrecedence() {
        XCTAssertEqual(BinaryOperator.multiply.precedence, BinaryOperator.divide.precedence)
    }
    
    func test_BinaryOperator_MultiplyHigherThanAdd() {
        XCTAssertGreaterThan(BinaryOperator.multiply.precedence, BinaryOperator.add.precedence)
    }
    
    func test_BinaryOperator_PowerHigherThanMultiply() {
        XCTAssertGreaterThan(BinaryOperator.power.precedence, BinaryOperator.multiply.precedence)
    }
    
    // MARK: - BinaryOperator Associativity Tests
    
    func test_BinaryOperator_Power_IsRightAssociative() {
        XCTAssertTrue(BinaryOperator.power.isRightAssociative)
    }
    
    func test_BinaryOperator_Add_IsNotRightAssociative() {
        XCTAssertFalse(BinaryOperator.add.isRightAssociative)
    }
    
    func test_BinaryOperator_Subtract_IsNotRightAssociative() {
        XCTAssertFalse(BinaryOperator.subtract.isRightAssociative)
    }
    
    func test_BinaryOperator_Multiply_IsNotRightAssociative() {
        XCTAssertFalse(BinaryOperator.multiply.isRightAssociative)
    }
    
    func test_BinaryOperator_Divide_IsNotRightAssociative() {
        XCTAssertFalse(BinaryOperator.divide.isRightAssociative)
    }
    
    // MARK: - BinaryOperator Raw Values Tests
    
    func test_BinaryOperator_RawValues() {
        XCTAssertEqual(BinaryOperator.add.rawValue, "+")
        XCTAssertEqual(BinaryOperator.subtract.rawValue, "−")
        XCTAssertEqual(BinaryOperator.multiply.rawValue, "×")
        XCTAssertEqual(BinaryOperator.divide.rawValue, "÷")
        XCTAssertEqual(BinaryOperator.power.rawValue, "^")
    }
    
    func test_BinaryOperator_AllCases() {
        let allCases = BinaryOperator.allCases
        XCTAssertEqual(allCases.count, 5)
    }
    
    // MARK: - UnaryOperator Tests
    
    func test_UnaryOperator_RawValues() {
        XCTAssertEqual(UnaryOperator.negate.rawValue, "negate")
        XCTAssertEqual(UnaryOperator.factorial.rawValue, "!")
    }
    
    func test_UnaryOperator_AllCases() {
        let allCases = UnaryOperator.allCases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.negate))
        XCTAssertTrue(allCases.contains(.factorial))
    }
    
    // MARK: - MathFunction Tests
    
    func test_MathFunction_AllTrigFunctions() {
        let trigFunctions: [MathFunction] = [.sin, .cos, .tan, .asin, .acos, .atan]
        for function in trigFunctions {
            XCTAssertTrue(MathFunction.allCases.contains(function))
        }
    }
    
    func test_MathFunction_AllHyperbolicFunctions() {
        let hyperbolicFunctions: [MathFunction] = [.sinh, .cosh, .tanh, .asinh, .acosh, .atanh]
        for function in hyperbolicFunctions {
            XCTAssertTrue(MathFunction.allCases.contains(function))
        }
    }
    
    func test_MathFunction_LogarithmicFunctions() {
        XCTAssertTrue(MathFunction.allCases.contains(.log))
        XCTAssertTrue(MathFunction.allCases.contains(.ln))
    }
    
    func test_MathFunction_RootFunctions() {
        XCTAssertTrue(MathFunction.allCases.contains(.sqrt))
        XCTAssertTrue(MathFunction.allCases.contains(.cbrt))
    }
    
    func test_MathFunction_OtherFunctions() {
        XCTAssertTrue(MathFunction.allCases.contains(.abs))
        XCTAssertTrue(MathFunction.allCases.contains(.exp))
    }
    
    func test_MathFunction_AllCases_Count() {
        XCTAssertEqual(MathFunction.allCases.count, 18)
    }
    
    // MARK: - Token Equality Tests
    
    func test_Token_Equality() {
        let token1 = Token(type: .number(42.0), position: 0)
        let token2 = Token(type: .number(42.0), position: 0)
        XCTAssertEqual(token1, token2)
    }
    
    func test_Token_Inequality_DifferentType() {
        let token1 = Token(type: .number(42.0), position: 0)
        let token2 = Token(type: .number(43.0), position: 0)
        XCTAssertNotEqual(token1, token2)
    }
    
    func test_Token_Inequality_DifferentPosition() {
        let token1 = Token(type: .number(42.0), position: 0)
        let token2 = Token(type: .number(42.0), position: 1)
        XCTAssertNotEqual(token1, token2)
    }
    
    func test_Token_Equality_Operators() {
        let token1 = Token(type: .binaryOperator(.add), position: 5)
        let token2 = Token(type: .binaryOperator(.add), position: 5)
        XCTAssertEqual(token1, token2)
    }
    
    func test_Token_Equality_Functions() {
        let token1 = Token(type: .function(.sin), position: 0)
        let token2 = Token(type: .function(.sin), position: 0)
        XCTAssertEqual(token1, token2)
    }
    
    func test_Token_Equality_Constants() {
        let token1 = Token(type: .constant(.pi), position: 0)
        let token2 = Token(type: .constant(.pi), position: 0)
        XCTAssertEqual(token1, token2)
    }
    
    func test_Token_Equality_Variables() {
        let token1 = Token(type: .variable("A"), position: 0)
        let token2 = Token(type: .variable("A"), position: 0)
        XCTAssertEqual(token1, token2)
    }
    
    func test_Token_Equality_Parentheses() {
        let leftParen1 = Token(type: .leftParen, position: 0)
        let leftParen2 = Token(type: .leftParen, position: 0)
        XCTAssertEqual(leftParen1, leftParen2)
        
        let rightParen1 = Token(type: .rightParen, position: 1)
        let rightParen2 = Token(type: .rightParen, position: 1)
        XCTAssertEqual(rightParen1, rightParen2)
    }
    
    func test_Token_Equality_End() {
        let end1 = Token(type: .end, position: 10)
        let end2 = Token(type: .end, position: 10)
        XCTAssertEqual(end1, end2)
    }
    
    // MARK: - TokenType Tests
    
    func test_TokenType_Number() {
        let type = TokenType.number(3.14)
        if case .number(let value) = type {
            XCTAssertEqual(value, 3.14, accuracy: 1e-15)
        } else {
            XCTFail("Expected number token type")
        }
    }
    
    func test_TokenType_Constant() {
        let type = TokenType.constant(.pi)
        if case .constant(let constant) = type {
            XCTAssertEqual(constant, .pi)
        } else {
            XCTFail("Expected constant token type")
        }
    }
    
    func test_TokenType_Variable() {
        let type = TokenType.variable("Ans")
        if case .variable(let name) = type {
            XCTAssertEqual(name, "Ans")
        } else {
            XCTFail("Expected variable token type")
        }
    }
    
    func test_TokenType_BinaryOperator() {
        let type = TokenType.binaryOperator(.multiply)
        if case .binaryOperator(let op) = type {
            XCTAssertEqual(op, .multiply)
        } else {
            XCTFail("Expected binary operator token type")
        }
    }
    
    func test_TokenType_UnaryOperator() {
        let type = TokenType.unaryOperator(.factorial)
        if case .unaryOperator(let op) = type {
            XCTAssertEqual(op, .factorial)
        } else {
            XCTFail("Expected unary operator token type")
        }
    }
    
    func test_TokenType_Function() {
        let type = TokenType.function(.cos)
        if case .function(let function) = type {
            XCTAssertEqual(function, .cos)
        } else {
            XCTFail("Expected function token type")
        }
    }
}
