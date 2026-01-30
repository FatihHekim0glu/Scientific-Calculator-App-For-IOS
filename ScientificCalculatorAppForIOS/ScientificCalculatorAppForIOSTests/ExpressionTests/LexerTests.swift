import XCTest
@testable import ScientificCalculatorAppForIOS

final class LexerTests: XCTestCase {
    
    // MARK: - Number Tokenization
    
    func test_Lexer_SimpleNumber_ReturnsNumberToken() throws {
        var lexer = Lexer(input: "42")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 2)
        if case .number(let value) = tokens[0].type {
            XCTAssertEqual(value, 42.0, accuracy: 1e-15)
        } else {
            XCTFail("Expected number token")
        }
        XCTAssertEqual(tokens[1].type, .end)
    }
    
    func test_Lexer_DecimalNumber_ReturnsNumberToken() throws {
        var lexer = Lexer(input: "3.14159")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 2)
        if case .number(let value) = tokens[0].type {
            XCTAssertEqual(value, 3.14159, accuracy: 1e-10)
        } else {
            XCTFail("Expected number token")
        }
    }
    
    func test_Lexer_ScientificNotation_ReturnsNumberToken() throws {
        var lexer = Lexer(input: "2.5e-3")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 2)
        if case .number(let value) = tokens[0].type {
            XCTAssertEqual(value, 0.0025, accuracy: 1e-15)
        } else {
            XCTFail("Expected number token")
        }
    }
    
    func test_Lexer_ScientificNotationPositiveExponent_ReturnsNumberToken() throws {
        var lexer = Lexer(input: "1.5e+10")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 2)
        if case .number(let value) = tokens[0].type {
            XCTAssertEqual(value, 1.5e10, accuracy: 1e5)
        } else {
            XCTFail("Expected number token")
        }
    }
    
    func test_Lexer_Zero_ReturnsNumberToken() throws {
        var lexer = Lexer(input: "0")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 2)
        if case .number(let value) = tokens[0].type {
            XCTAssertEqual(value, 0.0, accuracy: 1e-15)
        } else {
            XCTFail("Expected number token")
        }
    }
    
    // MARK: - Binary Operators
    
    func test_Lexer_Addition_ReturnsAddOperator() throws {
        var lexer = Lexer(input: "1+2")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 4)
        XCTAssertEqual(tokens[1].type, .binaryOperator(.add))
    }
    
    func test_Lexer_Subtraction_ReturnsSubtractOperator() throws {
        var lexer = Lexer(input: "5−3")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 4)
        XCTAssertEqual(tokens[1].type, .binaryOperator(.subtract))
    }
    
    func test_Lexer_Multiplication_ReturnsMultiplyOperator() throws {
        var lexer = Lexer(input: "4×5")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 4)
        XCTAssertEqual(tokens[1].type, .binaryOperator(.multiply))
    }
    
    func test_Lexer_MultiplicationAsterisk_ReturnsMultiplyOperator() throws {
        var lexer = Lexer(input: "4*5")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 4)
        XCTAssertEqual(tokens[1].type, .binaryOperator(.multiply))
    }
    
    func test_Lexer_Division_ReturnsDivideOperator() throws {
        var lexer = Lexer(input: "10÷2")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 4)
        XCTAssertEqual(tokens[1].type, .binaryOperator(.divide))
    }
    
    func test_Lexer_DivisionSlash_ReturnsDivideOperator() throws {
        var lexer = Lexer(input: "10/2")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 4)
        XCTAssertEqual(tokens[1].type, .binaryOperator(.divide))
    }
    
    func test_Lexer_Power_ReturnsPowerOperator() throws {
        var lexer = Lexer(input: "2^8")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 4)
        XCTAssertEqual(tokens[1].type, .binaryOperator(.power))
    }
    
    // MARK: - Unary Operators
    
    func test_Lexer_Factorial_ReturnsFactorialOperator() throws {
        var lexer = Lexer(input: "5!")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 3)
        XCTAssertEqual(tokens[1].type, .unaryOperator(.factorial))
    }
    
    func test_Lexer_UnaryMinus_AtStart_ReturnsNegateOperator() throws {
        var lexer = Lexer(input: "-5")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 3)
        XCTAssertEqual(tokens[0].type, .unaryOperator(.negate))
    }
    
    func test_Lexer_UnaryMinus_AfterOperator_ReturnsNegateOperator() throws {
        var lexer = Lexer(input: "3+-5")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 5)
        XCTAssertEqual(tokens[2].type, .unaryOperator(.negate))
    }
    
    func test_Lexer_UnaryMinus_AfterLeftParen_ReturnsNegateOperator() throws {
        var lexer = Lexer(input: "(-5)")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 5)
        XCTAssertEqual(tokens[1].type, .unaryOperator(.negate))
    }
    
    func test_Lexer_UnaryMinus_AfterNumber_ReturnsSubtractOperator() throws {
        var lexer = Lexer(input: "5-3")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 4)
        XCTAssertEqual(tokens[1].type, .binaryOperator(.subtract))
    }
    
    // MARK: - Constants
    
    func test_Lexer_Pi_ReturnsConstant() throws {
        var lexer = Lexer(input: "π")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens[0].type, .constant(.pi))
    }
    
    func test_Lexer_PiWord_ReturnsConstant() throws {
        var lexer = Lexer(input: "pi")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens[0].type, .constant(.pi))
    }
    
    func test_Lexer_E_ReturnsConstant() throws {
        var lexer = Lexer(input: "e")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens[0].type, .constant(.e))
    }
    
    // MARK: - Parentheses
    
    func test_Lexer_Parentheses_ReturnsParenTokens() throws {
        var lexer = Lexer(input: "(1+2)")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 6)
        XCTAssertEqual(tokens[0].type, .leftParen)
        XCTAssertEqual(tokens[4].type, .rightParen)
    }
    
    func test_Lexer_NestedParentheses_ReturnsCorrectTokens() throws {
        var lexer = Lexer(input: "((1))")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 6)
        XCTAssertEqual(tokens[0].type, .leftParen)
        XCTAssertEqual(tokens[1].type, .leftParen)
        XCTAssertEqual(tokens[3].type, .rightParen)
        XCTAssertEqual(tokens[4].type, .rightParen)
    }
    
    // MARK: - Functions
    
    func test_Lexer_SinFunction_ReturnsFunctionToken() throws {
        var lexer = Lexer(input: "sin(30)")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens[0].type, .function(.sin))
    }
    
    func test_Lexer_AllTrigFunctions_ReturnCorrectTokens() throws {
        let functions = ["sin", "cos", "tan", "asin", "acos", "atan"]
        let expected: [MathFunction] = [.sin, .cos, .tan, .asin, .acos, .atan]
        
        for (funcName, expectedFunc) in zip(functions, expected) {
            var lexer = Lexer(input: "\(funcName)(0)")
            let tokens = try lexer.tokenize()
            XCTAssertEqual(tokens[0].type, .function(expectedFunc), "Failed for \(funcName)")
        }
    }
    
    func test_Lexer_HyperbolicFunctions_ReturnCorrectTokens() throws {
        let functions = ["sinh", "cosh", "tanh", "asinh", "acosh", "atanh"]
        let expected: [MathFunction] = [.sinh, .cosh, .tanh, .asinh, .acosh, .atanh]
        
        for (funcName, expectedFunc) in zip(functions, expected) {
            var lexer = Lexer(input: "\(funcName)(0)")
            let tokens = try lexer.tokenize()
            XCTAssertEqual(tokens[0].type, .function(expectedFunc), "Failed for \(funcName)")
        }
    }
    
    func test_Lexer_LogFunction_ReturnsFunctionToken() throws {
        var lexer = Lexer(input: "log(10)")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens[0].type, .function(.log))
    }
    
    func test_Lexer_LnFunction_ReturnsFunctionToken() throws {
        var lexer = Lexer(input: "ln(e)")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens[0].type, .function(.ln))
    }
    
    func test_Lexer_SqrtFunction_ReturnsFunctionToken() throws {
        var lexer = Lexer(input: "sqrt(4)")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens[0].type, .function(.sqrt))
    }
    
    func test_Lexer_CbrtFunction_ReturnsFunctionToken() throws {
        var lexer = Lexer(input: "cbrt(8)")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens[0].type, .function(.cbrt))
    }
    
    func test_Lexer_AbsFunction_ReturnsFunctionToken() throws {
        var lexer = Lexer(input: "abs(-5)")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens[0].type, .function(.abs))
    }
    
    func test_Lexer_ExpFunction_ReturnsFunctionToken() throws {
        var lexer = Lexer(input: "exp(1)")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens[0].type, .function(.exp))
    }
    
    func test_Lexer_FunctionCaseInsensitive_ReturnsFunctionToken() throws {
        var lexer = Lexer(input: "SIN(30)")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens[0].type, .function(.sin))
    }
    
    // MARK: - Variables
    
    func test_Lexer_Variables_ReturnsVariableTokens() throws {
        let variables = ["A", "B", "C", "D", "E", "F"]
        
        for variable in variables {
            var lexer = Lexer(input: variable)
            let tokens = try lexer.tokenize()
            XCTAssertEqual(tokens[0].type, .variable(variable), "Failed for variable \(variable)")
        }
    }
    
    func test_Lexer_Ans_ReturnsVariableToken() throws {
        var lexer = Lexer(input: "Ans")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens[0].type, .variable("Ans"))
    }
    
    // MARK: - Whitespace
    
    func test_Lexer_WhitespaceIgnored() throws {
        var lexer = Lexer(input: "  1  +  2  ")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 4)
        if case .number(let value) = tokens[0].type {
            XCTAssertEqual(value, 1.0, accuracy: 1e-15)
        }
        XCTAssertEqual(tokens[1].type, .binaryOperator(.add))
        if case .number(let value) = tokens[2].type {
            XCTAssertEqual(value, 2.0, accuracy: 1e-15)
        }
    }
    
    func test_Lexer_TabsAndNewlinesIgnored() throws {
        var lexer = Lexer(input: "1\t+\n2")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 4)
    }
    
    // MARK: - Complex Expressions
    
    func test_Lexer_ComplexExpression_ReturnsCorrectTokens() throws {
        var lexer = Lexer(input: "sin(30)+cos(60)×2")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens[0].type, .function(.sin))
        XCTAssertEqual(tokens[1].type, .leftParen)
        XCTAssertEqual(tokens[3].type, .rightParen)
        XCTAssertEqual(tokens[4].type, .binaryOperator(.add))
        XCTAssertEqual(tokens[5].type, .function(.cos))
        XCTAssertEqual(tokens[9].type, .binaryOperator(.multiply))
    }
    
    func test_Lexer_ExpressionWithPiAndE_ReturnsCorrectTokens() throws {
        var lexer = Lexer(input: "π×e")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 4)
        XCTAssertEqual(tokens[0].type, .constant(.pi))
        XCTAssertEqual(tokens[1].type, .binaryOperator(.multiply))
        XCTAssertEqual(tokens[2].type, .constant(.e))
    }
    
    func test_Lexer_ExpressionWithFactorial_ReturnsCorrectTokens() throws {
        var lexer = Lexer(input: "5!+3!")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 6)
        XCTAssertEqual(tokens[1].type, .unaryOperator(.factorial))
        XCTAssertEqual(tokens[4].type, .unaryOperator(.factorial))
    }
    
    // MARK: - Token Positions
    
    func test_Lexer_TokenPositions_AreCorrect() throws {
        var lexer = Lexer(input: "1+2")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens[0].position, 0)
        XCTAssertEqual(tokens[1].position, 1)
        XCTAssertEqual(tokens[2].position, 2)
    }
    
    // MARK: - Error Cases
    
    func test_Lexer_InvalidCharacter_ThrowsSyntaxError() {
        var lexer = Lexer(input: "1@2")
        
        XCTAssertThrowsError(try lexer.tokenize()) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntax error")
                return
            }
        }
    }
    
    func test_Lexer_MalformedNumber_ThrowsSyntaxError() {
        var lexer = Lexer(input: "1.2.3")
        
        XCTAssertThrowsError(try lexer.tokenize()) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntax error")
                return
            }
        }
    }
    
    func test_Lexer_EmptyInput_ReturnsEndToken() throws {
        var lexer = Lexer(input: "")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].type, .end)
    }
    
    func test_Lexer_OnlyWhitespace_ReturnsEndToken() throws {
        var lexer = Lexer(input: "   ")
        let tokens = try lexer.tokenize()
        
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].type, .end)
    }
}
