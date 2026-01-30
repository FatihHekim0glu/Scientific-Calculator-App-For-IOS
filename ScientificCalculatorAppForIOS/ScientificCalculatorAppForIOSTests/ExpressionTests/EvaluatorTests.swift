import XCTest
@testable import ScientificCalculatorAppForIOS

final class EvaluatorTests: XCTestCase {
    
    // MARK: - Helper Methods
    
    private func evaluate(_ node: ASTNode, context: EvaluationContext = EvaluationContext()) throws -> Double {
        var evaluator = Evaluator(context: context)
        return try evaluator.evaluate(node)
    }
    
    private func evaluateExpression(_ input: String, context: EvaluationContext = EvaluationContext()) throws -> Double {
        var lexer = Lexer(input: input)
        let tokens = try lexer.tokenize()
        var parser = Parser(tokens: tokens)
        let ast = try parser.parse()
        var evaluator = Evaluator(context: context)
        return try evaluator.evaluate(ast)
    }
    
    // MARK: - Number Evaluation
    
    func test_Evaluator_Number_ReturnsValue() throws {
        let result = try evaluate(.number(42.0))
        XCTAssertEqual(result, 42.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_NegativeNumber_ReturnsValue() throws {
        let result = try evaluate(.number(-3.14))
        XCTAssertEqual(result, -3.14, accuracy: 1e-15)
    }
    
    func test_Evaluator_Zero_ReturnsZero() throws {
        let result = try evaluate(.number(0.0))
        XCTAssertEqual(result, 0.0, accuracy: 1e-15)
    }
    
    // MARK: - Arithmetic Operations
    
    func test_Evaluator_Addition_ReturnsSum() throws {
        let result = try evaluate(.binaryOp(.add, .number(2.0), .number(3.0)))
        XCTAssertEqual(result, 5.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Subtraction_ReturnsDifference() throws {
        let result = try evaluate(.binaryOp(.subtract, .number(10.0), .number(4.0)))
        XCTAssertEqual(result, 6.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Multiplication_ReturnsProduct() throws {
        let result = try evaluate(.binaryOp(.multiply, .number(6.0), .number(7.0)))
        XCTAssertEqual(result, 42.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Division_ReturnsQuotient() throws {
        let result = try evaluate(.binaryOp(.divide, .number(20.0), .number(4.0)))
        XCTAssertEqual(result, 5.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_DivisionByZero_ThrowsError() {
        XCTAssertThrowsError(try evaluate(.binaryOp(.divide, .number(1.0), .number(0.0)))) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_Evaluator_Power_ReturnsResult() throws {
        let result = try evaluate(.binaryOp(.power, .number(2.0), .number(8.0)))
        XCTAssertEqual(result, 256.0, accuracy: 1e-10)
    }
    
    func test_Evaluator_NegativePower_ReturnsResult() throws {
        let result = try evaluate(.binaryOp(.power, .number(2.0), .number(-1.0)))
        XCTAssertEqual(result, 0.5, accuracy: 1e-15)
    }
    
    func test_Evaluator_FractionalPower_ReturnsResult() throws {
        let result = try evaluate(.binaryOp(.power, .number(4.0), .number(0.5)))
        XCTAssertEqual(result, 2.0, accuracy: 1e-15)
    }
    
    // MARK: - Unary Operations
    
    func test_Evaluator_UnaryMinus_ReturnsNegated() throws {
        let result = try evaluate(.unaryOp(.negate, .number(5.0)))
        XCTAssertEqual(result, -5.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_UnaryMinus_DoubleNegation_ReturnsPositive() throws {
        let result = try evaluate(.unaryOp(.negate, .unaryOp(.negate, .number(5.0))))
        XCTAssertEqual(result, 5.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Factorial_ReturnsResult() throws {
        let result = try evaluate(.unaryOp(.factorial, .number(5.0)))
        XCTAssertEqual(result, 120.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Factorial_Zero_ReturnsOne() throws {
        let result = try evaluate(.unaryOp(.factorial, .number(0.0)))
        XCTAssertEqual(result, 1.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Factorial_One_ReturnsOne() throws {
        let result = try evaluate(.unaryOp(.factorial, .number(1.0)))
        XCTAssertEqual(result, 1.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Factorial_Negative_ThrowsError() {
        XCTAssertThrowsError(try evaluate(.unaryOp(.factorial, .number(-1.0)))) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Evaluator_Factorial_NonInteger_ThrowsError() {
        XCTAssertThrowsError(try evaluate(.unaryOp(.factorial, .number(3.5)))) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Evaluator_Factorial_Large_ThrowsOverflow() {
        XCTAssertThrowsError(try evaluate(.unaryOp(.factorial, .number(171.0)))) { error in
            XCTAssertEqual(error as? CalculatorError, .overflow)
        }
    }
    
    // MARK: - Constants
    
    func test_Evaluator_Pi_ReturnsCorrectValue() throws {
        let result = try evaluate(.constant(.pi))
        XCTAssertEqual(result, Double.pi, accuracy: 1e-15)
    }
    
    func test_Evaluator_E_ReturnsCorrectValue() throws {
        let result = try evaluate(.constant(.e))
        XCTAssertEqual(result, M_E, accuracy: 1e-15)
    }
    
    // MARK: - Trigonometric Functions (Degrees)
    
    func test_Evaluator_Sin_Degrees_ReturnsCorrectValue() throws {
        var context = EvaluationContext()
        context.angleMode = .degrees
        
        let result = try evaluate(.function(.sin, .number(30.0)), context: context)
        XCTAssertEqual(result, 0.5, accuracy: 1e-10)
    }
    
    func test_Evaluator_Sin_Degrees_90_ReturnsOne() throws {
        var context = EvaluationContext()
        context.angleMode = .degrees
        
        let result = try evaluate(.function(.sin, .number(90.0)), context: context)
        XCTAssertEqual(result, 1.0, accuracy: 1e-10)
    }
    
    func test_Evaluator_Sin_Radians_ReturnsCorrectValue() throws {
        var context = EvaluationContext()
        context.angleMode = .radians
        
        let result = try evaluate(.function(.sin, .number(Double.pi / 6)), context: context)
        XCTAssertEqual(result, 0.5, accuracy: 1e-10)
    }
    
    func test_Evaluator_Cos_ReturnsCorrectValue() throws {
        var context = EvaluationContext()
        context.angleMode = .degrees
        
        let result = try evaluate(.function(.cos, .number(60.0)), context: context)
        XCTAssertEqual(result, 0.5, accuracy: 1e-10)
    }
    
    func test_Evaluator_Cos_Zero_ReturnsOne() throws {
        var context = EvaluationContext()
        context.angleMode = .degrees
        
        let result = try evaluate(.function(.cos, .number(0.0)), context: context)
        XCTAssertEqual(result, 1.0, accuracy: 1e-10)
    }
    
    func test_Evaluator_Tan_ReturnsCorrectValue() throws {
        var context = EvaluationContext()
        context.angleMode = .degrees
        
        let result = try evaluate(.function(.tan, .number(45.0)), context: context)
        XCTAssertEqual(result, 1.0, accuracy: 1e-10)
    }
    
    // MARK: - Inverse Trigonometric Functions
    
    func test_Evaluator_Asin_ReturnsCorrectValue() throws {
        var context = EvaluationContext()
        context.angleMode = .degrees
        
        let result = try evaluate(.function(.asin, .number(0.5)), context: context)
        XCTAssertEqual(result, 30.0, accuracy: 1e-10)
    }
    
    func test_Evaluator_Asin_OutOfDomain_ThrowsError() {
        XCTAssertThrowsError(try evaluate(.function(.asin, .number(1.5)))) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Evaluator_Acos_ReturnsCorrectValue() throws {
        var context = EvaluationContext()
        context.angleMode = .degrees
        
        let result = try evaluate(.function(.acos, .number(0.5)), context: context)
        XCTAssertEqual(result, 60.0, accuracy: 1e-10)
    }
    
    func test_Evaluator_Acos_OutOfDomain_ThrowsError() {
        XCTAssertThrowsError(try evaluate(.function(.acos, .number(-1.5)))) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Evaluator_Atan_ReturnsCorrectValue() throws {
        var context = EvaluationContext()
        context.angleMode = .degrees
        
        let result = try evaluate(.function(.atan, .number(1.0)), context: context)
        XCTAssertEqual(result, 45.0, accuracy: 1e-10)
    }
    
    // MARK: - Hyperbolic Functions
    
    func test_Evaluator_Sinh_ReturnsCorrectValue() throws {
        let result = try evaluate(.function(.sinh, .number(0.0)))
        XCTAssertEqual(result, 0.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Cosh_ReturnsCorrectValue() throws {
        let result = try evaluate(.function(.cosh, .number(0.0)))
        XCTAssertEqual(result, 1.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Tanh_ReturnsCorrectValue() throws {
        let result = try evaluate(.function(.tanh, .number(0.0)))
        XCTAssertEqual(result, 0.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Asinh_ReturnsCorrectValue() throws {
        let result = try evaluate(.function(.asinh, .number(0.0)))
        XCTAssertEqual(result, 0.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Acosh_ReturnsCorrectValue() throws {
        let result = try evaluate(.function(.acosh, .number(1.0)))
        XCTAssertEqual(result, 0.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Acosh_OutOfDomain_ThrowsError() {
        XCTAssertThrowsError(try evaluate(.function(.acosh, .number(0.5)))) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Evaluator_Atanh_ReturnsCorrectValue() throws {
        let result = try evaluate(.function(.atanh, .number(0.0)))
        XCTAssertEqual(result, 0.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Atanh_OutOfDomain_ThrowsError() {
        XCTAssertThrowsError(try evaluate(.function(.atanh, .number(1.0)))) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    // MARK: - Logarithmic Functions
    
    func test_Evaluator_Log_ReturnsCorrectValue() throws {
        let result = try evaluate(.function(.log, .number(100.0)))
        XCTAssertEqual(result, 2.0, accuracy: 1e-10)
    }
    
    func test_Evaluator_Log_Zero_ThrowsError() {
        XCTAssertThrowsError(try evaluate(.function(.log, .number(0.0)))) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Evaluator_Log_Negative_ThrowsError() {
        XCTAssertThrowsError(try evaluate(.function(.log, .number(-1.0)))) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Evaluator_Ln_ReturnsCorrectValue() throws {
        let result = try evaluate(.function(.ln, .constant(.e)))
        XCTAssertEqual(result, 1.0, accuracy: 1e-10)
    }
    
    func test_Evaluator_Ln_One_ReturnsZero() throws {
        let result = try evaluate(.function(.ln, .number(1.0)))
        XCTAssertEqual(result, 0.0, accuracy: 1e-15)
    }
    
    // MARK: - Root Functions
    
    func test_Evaluator_Sqrt_ReturnsCorrectValue() throws {
        let result = try evaluate(.function(.sqrt, .number(16.0)))
        XCTAssertEqual(result, 4.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Sqrt_Negative_ThrowsError() {
        XCTAssertThrowsError(try evaluate(.function(.sqrt, .number(-1.0)))) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Evaluator_Cbrt_ReturnsCorrectValue() throws {
        let result = try evaluate(.function(.cbrt, .number(27.0)))
        XCTAssertEqual(result, 3.0, accuracy: 1e-10)
    }
    
    func test_Evaluator_Cbrt_Negative_ReturnsNegative() throws {
        let result = try evaluate(.function(.cbrt, .number(-8.0)))
        XCTAssertEqual(result, -2.0, accuracy: 1e-10)
    }
    
    // MARK: - Other Functions
    
    func test_Evaluator_Abs_Positive_ReturnsValue() throws {
        let result = try evaluate(.function(.abs, .number(5.0)))
        XCTAssertEqual(result, 5.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Abs_Negative_ReturnsPositive() throws {
        let result = try evaluate(.function(.abs, .number(-5.0)))
        XCTAssertEqual(result, 5.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Abs_Zero_ReturnsZero() throws {
        let result = try evaluate(.function(.abs, .number(0.0)))
        XCTAssertEqual(result, 0.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Exp_ReturnsCorrectValue() throws {
        let result = try evaluate(.function(.exp, .number(1.0)))
        XCTAssertEqual(result, M_E, accuracy: 1e-10)
    }
    
    func test_Evaluator_Exp_Zero_ReturnsOne() throws {
        let result = try evaluate(.function(.exp, .number(0.0)))
        XCTAssertEqual(result, 1.0, accuracy: 1e-15)
    }
    
    // MARK: - Variables
    
    func test_Evaluator_Variable_Defined_ReturnsValue() throws {
        var context = EvaluationContext()
        context.variables["A"] = 10.0
        
        let result = try evaluate(.variable("A"), context: context)
        XCTAssertEqual(result, 10.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_Variable_Undefined_ThrowsError() {
        let context = EvaluationContext()
        
        XCTAssertThrowsError(try evaluate(.variable("X"), context: context)) { error in
            guard case CalculatorError.undefinedVariable(let name) = error else {
                XCTFail("Expected undefined variable error")
                return
            }
            XCTAssertEqual(name, "X")
        }
    }
    
    func test_Evaluator_Ans_ReturnsLastAnswer() throws {
        var context = EvaluationContext()
        context.lastAnswer = 42.0
        
        let result = try evaluate(.variable("Ans"), context: context)
        XCTAssertEqual(result, 42.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_MultipleVariables_ReturnsCorrectValues() throws {
        var context = EvaluationContext()
        context.variables["A"] = 5.0
        context.variables["B"] = 3.0
        
        let result = try evaluate(.binaryOp(.add, .variable("A"), .variable("B")), context: context)
        XCTAssertEqual(result, 8.0, accuracy: 1e-15)
    }
    
    // MARK: - Complex Expressions
    
    func test_Evaluator_ComplexExpression_ReturnsCorrectResult() throws {
        let expr = ASTNode.binaryOp(
            .add,
            .binaryOp(.multiply, .number(2.0), .number(3.0)),
            .binaryOp(.power, .number(2.0), .number(3.0))
        )
        
        let result = try evaluate(expr)
        XCTAssertEqual(result, 14.0, accuracy: 1e-15)
    }
    
    func test_Evaluator_NestedFunctions_ReturnsCorrectResult() throws {
        var context = EvaluationContext()
        context.angleMode = .radians
        
        let result = try evaluate(.function(.sin, .function(.asin, .number(0.5))), context: context)
        XCTAssertEqual(result, 0.5, accuracy: 1e-10)
    }
    
    // MARK: - Angle Mode Tests
    
    func test_Evaluator_Gradians_Sin_ReturnsCorrectValue() throws {
        var context = EvaluationContext()
        context.angleMode = .gradians
        
        let result = try evaluate(.function(.sin, .number(100.0)), context: context)
        XCTAssertEqual(result, 1.0, accuracy: 1e-10)
    }
    
    // MARK: - Integration Tests
    
    func test_Integration_Tokenize_Parse_Evaluate_SimpleExpression() throws {
        let result = try evaluateExpression("2+3×4")
        XCTAssertEqual(result, 14.0, accuracy: 1e-15)
    }
    
    func test_Integration_Tokenize_Parse_Evaluate_ComplexExpression() throws {
        let result = try evaluateExpression("(2+3)×4^2")
        XCTAssertEqual(result, 80.0, accuracy: 1e-15)
    }
    
    func test_Integration_Tokenize_Parse_Evaluate_WithFunctions() throws {
        var context = EvaluationContext()
        context.angleMode = .degrees
        
        let result = try evaluateExpression("sin(30)+cos(60)", context: context)
        XCTAssertEqual(result, 1.0, accuracy: 1e-10)
    }
    
    func test_Integration_Tokenize_Parse_Evaluate_WithVariables() throws {
        var context = EvaluationContext()
        context.variables["A"] = 10.0
        context.variables["B"] = 5.0
        
        let result = try evaluateExpression("A×B+2", context: context)
        XCTAssertEqual(result, 52.0, accuracy: 1e-15)
    }
    
    func test_Integration_Tokenize_Parse_Evaluate_WithConstants() throws {
        let result = try evaluateExpression("2×π")
        XCTAssertEqual(result, 2 * Double.pi, accuracy: 1e-10)
    }
    
    func test_Integration_Tokenize_Parse_Evaluate_WithFactorial() throws {
        let result = try evaluateExpression("5!+3!")
        XCTAssertEqual(result, 126.0, accuracy: 1e-15)
    }
    
    func test_Integration_Tokenize_Parse_Evaluate_WithNegation() throws {
        let result = try evaluateExpression("-5+10")
        XCTAssertEqual(result, 5.0, accuracy: 1e-15)
    }
    
    func test_Integration_Tokenize_Parse_Evaluate_PowerAssociativity() throws {
        let result = try evaluateExpression("2^3^2")
        XCTAssertEqual(result, 512.0, accuracy: 1e-10)
    }
    
    func test_Integration_Tokenize_Parse_Evaluate_NestedParentheses() throws {
        let result = try evaluateExpression("((2+3)×(4−1))")
        XCTAssertEqual(result, 15.0, accuracy: 1e-15)
    }
    
    func test_Integration_Tokenize_Parse_Evaluate_SqrtAndPower() throws {
        let result = try evaluateExpression("sqrt(16)+2^3")
        XCTAssertEqual(result, 12.0, accuracy: 1e-15)
    }
    
    func test_Integration_Tokenize_Parse_Evaluate_LogAndExp() throws {
        let result = try evaluateExpression("log(100)+ln(e)")
        XCTAssertEqual(result, 3.0, accuracy: 1e-10)
    }
}

// MARK: - AngleMode Tests

final class AngleModeTests: XCTestCase {
    
    func test_AngleMode_Degrees_ToRadians() {
        let mode = AngleMode.degrees
        let radians = mode.toRadians(180.0)
        XCTAssertEqual(radians, Double.pi, accuracy: 1e-15)
    }
    
    func test_AngleMode_Radians_ToRadians() {
        let mode = AngleMode.radians
        let radians = mode.toRadians(Double.pi)
        XCTAssertEqual(radians, Double.pi, accuracy: 1e-15)
    }
    
    func test_AngleMode_Gradians_ToRadians() {
        let mode = AngleMode.gradians
        let radians = mode.toRadians(200.0)
        XCTAssertEqual(radians, Double.pi, accuracy: 1e-15)
    }
    
    func test_AngleMode_Degrees_FromRadians() {
        let mode = AngleMode.degrees
        let degrees = mode.fromRadians(Double.pi)
        XCTAssertEqual(degrees, 180.0, accuracy: 1e-10)
    }
    
    func test_AngleMode_Radians_FromRadians() {
        let mode = AngleMode.radians
        let radians = mode.fromRadians(Double.pi)
        XCTAssertEqual(radians, Double.pi, accuracy: 1e-15)
    }
    
    func test_AngleMode_Gradians_FromRadians() {
        let mode = AngleMode.gradians
        let gradians = mode.fromRadians(Double.pi)
        XCTAssertEqual(gradians, 200.0, accuracy: 1e-10)
    }
}

// MARK: - EvaluationContext Tests

final class EvaluationContextTests: XCTestCase {
    
    func test_EvaluationContext_DefaultAngleMode() {
        let context = EvaluationContext()
        XCTAssertEqual(context.angleMode, .degrees)
    }
    
    func test_EvaluationContext_DefaultVariables() {
        let context = EvaluationContext()
        XCTAssertTrue(context.variables.isEmpty)
    }
    
    func test_EvaluationContext_DefaultLastAnswer() {
        let context = EvaluationContext()
        XCTAssertEqual(context.lastAnswer, 0.0, accuracy: 1e-15)
    }
    
    func test_EvaluationContext_SetVariable() {
        var context = EvaluationContext()
        context.setVariable("A", value: 42.0)
        XCTAssertEqual(context.variables["A"], 42.0)
    }
    
    func test_EvaluationContext_GetVariable_Defined() throws {
        var context = EvaluationContext()
        context.variables["B"] = 3.14
        let value = try context.getVariable("B")
        XCTAssertEqual(value, 3.14, accuracy: 1e-15)
    }
    
    func test_EvaluationContext_GetVariable_Undefined_ThrowsError() {
        let context = EvaluationContext()
        XCTAssertThrowsError(try context.getVariable("Z")) { error in
            guard case CalculatorError.undefinedVariable(let name) = error else {
                XCTFail("Expected undefined variable error")
                return
            }
            XCTAssertEqual(name, "Z")
        }
    }
}
