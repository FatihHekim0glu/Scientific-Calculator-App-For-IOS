import XCTest
@testable import ScientificCalculatorAppForIOS

final class ASTTests: XCTestCase {
    
    // MARK: - Number Node Tests
    
    func test_ASTNode_Number_Description() {
        let node = ASTNode.number(42.0)
        XCTAssertEqual(node.description, "42")
    }
    
    func test_ASTNode_Number_Description_Decimal() {
        let node = ASTNode.number(3.14159)
        XCTAssertEqual(node.description, "3.14159")
    }
    
    func test_ASTNode_Number_Description_NegativeInteger() {
        let node = ASTNode.number(-5.0)
        XCTAssertEqual(node.description, "-5")
    }
    
    func test_ASTNode_Number_Description_Zero() {
        let node = ASTNode.number(0.0)
        XCTAssertEqual(node.description, "0")
    }
    
    func test_ASTNode_Number_Description_LargeNumber() {
        let node = ASTNode.number(1000000.0)
        XCTAssertEqual(node.description, "1000000")
    }
    
    // MARK: - Constant Node Tests
    
    func test_ASTNode_Constant_Pi_Description() {
        let node = ASTNode.constant(.pi)
        XCTAssertEqual(node.description, "π")
    }
    
    func test_ASTNode_Constant_E_Description() {
        let node = ASTNode.constant(.e)
        XCTAssertEqual(node.description, "e")
    }
    
    // MARK: - Variable Node Tests
    
    func test_ASTNode_Variable_Description() {
        let node = ASTNode.variable("A")
        XCTAssertEqual(node.description, "A")
    }
    
    func test_ASTNode_Variable_Ans_Description() {
        let node = ASTNode.variable("Ans")
        XCTAssertEqual(node.description, "Ans")
    }
    
    func test_ASTNode_Variable_AllVariables_Description() {
        let variables = ["A", "B", "C", "D", "E", "F"]
        for variable in variables {
            let node = ASTNode.variable(variable)
            XCTAssertEqual(node.description, variable)
        }
    }
    
    // MARK: - Binary Operation Node Tests
    
    func test_ASTNode_BinaryOp_Add_Description() {
        let node = ASTNode.binaryOp(.add, .number(2.0), .number(3.0))
        XCTAssertEqual(node.description, "(2 + 3)")
    }
    
    func test_ASTNode_BinaryOp_Subtract_Description() {
        let node = ASTNode.binaryOp(.subtract, .number(5.0), .number(3.0))
        XCTAssertEqual(node.description, "(5 − 3)")
    }
    
    func test_ASTNode_BinaryOp_Multiply_Description() {
        let node = ASTNode.binaryOp(.multiply, .number(4.0), .number(5.0))
        XCTAssertEqual(node.description, "(4 × 5)")
    }
    
    func test_ASTNode_BinaryOp_Divide_Description() {
        let node = ASTNode.binaryOp(.divide, .number(10.0), .number(2.0))
        XCTAssertEqual(node.description, "(10 ÷ 2)")
    }
    
    func test_ASTNode_BinaryOp_Power_Description() {
        let node = ASTNode.binaryOp(.power, .number(2.0), .number(8.0))
        XCTAssertEqual(node.description, "(2 ^ 8)")
    }
    
    func test_ASTNode_BinaryOp_Nested_Description() {
        let inner = ASTNode.binaryOp(.add, .number(1.0), .number(2.0))
        let outer = ASTNode.binaryOp(.multiply, inner, .number(3.0))
        XCTAssertEqual(outer.description, "((1 + 2) × 3)")
    }
    
    func test_ASTNode_BinaryOp_WithConstant_Description() {
        let node = ASTNode.binaryOp(.multiply, .number(2.0), .constant(.pi))
        XCTAssertEqual(node.description, "(2 × π)")
    }
    
    func test_ASTNode_BinaryOp_WithVariable_Description() {
        let node = ASTNode.binaryOp(.add, .variable("A"), .variable("B"))
        XCTAssertEqual(node.description, "(A + B)")
    }
    
    // MARK: - Unary Operation Node Tests
    
    func test_ASTNode_UnaryOp_Negate_Description() {
        let node = ASTNode.unaryOp(.negate, .number(5.0))
        XCTAssertEqual(node.description, "(-5)")
    }
    
    func test_ASTNode_UnaryOp_Factorial_Description() {
        let node = ASTNode.unaryOp(.factorial, .number(5.0))
        XCTAssertEqual(node.description, "(5!)")
    }
    
    func test_ASTNode_UnaryOp_DoubleNegate_Description() {
        let inner = ASTNode.unaryOp(.negate, .number(3.0))
        let outer = ASTNode.unaryOp(.negate, inner)
        XCTAssertEqual(outer.description, "(-(-3))")
    }
    
    func test_ASTNode_UnaryOp_FactorialOfExpression_Description() {
        let expr = ASTNode.binaryOp(.add, .number(2.0), .number(3.0))
        let node = ASTNode.unaryOp(.factorial, expr)
        XCTAssertEqual(node.description, "((2 + 3)!)")
    }
    
    // MARK: - Function Node Tests
    
    func test_ASTNode_Function_Sin_Description() {
        let node = ASTNode.function(.sin, .number(30.0))
        XCTAssertEqual(node.description, "sin(30)")
    }
    
    func test_ASTNode_Function_Cos_Description() {
        let node = ASTNode.function(.cos, .number(60.0))
        XCTAssertEqual(node.description, "cos(60)")
    }
    
    func test_ASTNode_Function_Tan_Description() {
        let node = ASTNode.function(.tan, .number(45.0))
        XCTAssertEqual(node.description, "tan(45)")
    }
    
    func test_ASTNode_Function_Asin_Description() {
        let node = ASTNode.function(.asin, .number(0.5))
        XCTAssertEqual(node.description, "asin(0.5)")
    }
    
    func test_ASTNode_Function_Acos_Description() {
        let node = ASTNode.function(.acos, .number(0.5))
        XCTAssertEqual(node.description, "acos(0.5)")
    }
    
    func test_ASTNode_Function_Atan_Description() {
        let node = ASTNode.function(.atan, .number(1.0))
        XCTAssertEqual(node.description, "atan(1)")
    }
    
    func test_ASTNode_Function_Sinh_Description() {
        let node = ASTNode.function(.sinh, .number(1.0))
        XCTAssertEqual(node.description, "sinh(1)")
    }
    
    func test_ASTNode_Function_Cosh_Description() {
        let node = ASTNode.function(.cosh, .number(1.0))
        XCTAssertEqual(node.description, "cosh(1)")
    }
    
    func test_ASTNode_Function_Tanh_Description() {
        let node = ASTNode.function(.tanh, .number(1.0))
        XCTAssertEqual(node.description, "tanh(1)")
    }
    
    func test_ASTNode_Function_Log_Description() {
        let node = ASTNode.function(.log, .number(100.0))
        XCTAssertEqual(node.description, "log(100)")
    }
    
    func test_ASTNode_Function_Ln_Description() {
        let node = ASTNode.function(.ln, .constant(.e))
        XCTAssertEqual(node.description, "ln(e)")
    }
    
    func test_ASTNode_Function_Sqrt_Description() {
        let node = ASTNode.function(.sqrt, .number(16.0))
        XCTAssertEqual(node.description, "sqrt(16)")
    }
    
    func test_ASTNode_Function_Cbrt_Description() {
        let node = ASTNode.function(.cbrt, .number(27.0))
        XCTAssertEqual(node.description, "cbrt(27)")
    }
    
    func test_ASTNode_Function_Abs_Description() {
        let node = ASTNode.function(.abs, .unaryOp(.negate, .number(5.0)))
        XCTAssertEqual(node.description, "abs((-5))")
    }
    
    func test_ASTNode_Function_Exp_Description() {
        let node = ASTNode.function(.exp, .number(1.0))
        XCTAssertEqual(node.description, "exp(1)")
    }
    
    func test_ASTNode_Function_WithExpression_Description() {
        let expr = ASTNode.binaryOp(.add, .number(30.0), .number(15.0))
        let node = ASTNode.function(.sin, expr)
        XCTAssertEqual(node.description, "sin((30 + 15))")
    }
    
    func test_ASTNode_Function_Nested_Description() {
        let inner = ASTNode.function(.cos, .number(0.0))
        let outer = ASTNode.function(.sin, inner)
        XCTAssertEqual(outer.description, "sin(cos(0))")
    }
    
    // MARK: - Equality Tests
    
    func test_ASTNode_Equality_Number() {
        let node1 = ASTNode.number(42.0)
        let node2 = ASTNode.number(42.0)
        XCTAssertEqual(node1, node2)
    }
    
    func test_ASTNode_Equality_Constant() {
        let node1 = ASTNode.constant(.pi)
        let node2 = ASTNode.constant(.pi)
        XCTAssertEqual(node1, node2)
    }
    
    func test_ASTNode_Equality_Variable() {
        let node1 = ASTNode.variable("A")
        let node2 = ASTNode.variable("A")
        XCTAssertEqual(node1, node2)
    }
    
    func test_ASTNode_Equality_BinaryOp() {
        let node1 = ASTNode.binaryOp(.add, .number(2.0), .number(3.0))
        let node2 = ASTNode.binaryOp(.add, .number(2.0), .number(3.0))
        XCTAssertEqual(node1, node2)
    }
    
    func test_ASTNode_Equality_UnaryOp() {
        let node1 = ASTNode.unaryOp(.negate, .number(5.0))
        let node2 = ASTNode.unaryOp(.negate, .number(5.0))
        XCTAssertEqual(node1, node2)
    }
    
    func test_ASTNode_Equality_Function() {
        let node1 = ASTNode.function(.sin, .number(30.0))
        let node2 = ASTNode.function(.sin, .number(30.0))
        XCTAssertEqual(node1, node2)
    }
    
    func test_ASTNode_Equality_ComplexExpression() {
        let node1 = ASTNode.binaryOp(
            .add,
            .function(.sin, .number(30.0)),
            .binaryOp(.multiply, .number(2.0), .constant(.pi))
        )
        let node2 = ASTNode.binaryOp(
            .add,
            .function(.sin, .number(30.0)),
            .binaryOp(.multiply, .number(2.0), .constant(.pi))
        )
        XCTAssertEqual(node1, node2)
    }
    
    // MARK: - Inequality Tests
    
    func test_ASTNode_Inequality_DifferentNumbers() {
        let node1 = ASTNode.number(42.0)
        let node2 = ASTNode.number(43.0)
        XCTAssertNotEqual(node1, node2)
    }
    
    func test_ASTNode_Inequality_DifferentConstants() {
        let node1 = ASTNode.constant(.pi)
        let node2 = ASTNode.constant(.e)
        XCTAssertNotEqual(node1, node2)
    }
    
    func test_ASTNode_Inequality_DifferentVariables() {
        let node1 = ASTNode.variable("A")
        let node2 = ASTNode.variable("B")
        XCTAssertNotEqual(node1, node2)
    }
    
    func test_ASTNode_Inequality_DifferentOperators() {
        let node1 = ASTNode.binaryOp(.add, .number(2.0), .number(3.0))
        let node2 = ASTNode.binaryOp(.subtract, .number(2.0), .number(3.0))
        XCTAssertNotEqual(node1, node2)
    }
    
    func test_ASTNode_Inequality_DifferentOperands() {
        let node1 = ASTNode.binaryOp(.add, .number(2.0), .number(3.0))
        let node2 = ASTNode.binaryOp(.add, .number(2.0), .number(4.0))
        XCTAssertNotEqual(node1, node2)
    }
    
    func test_ASTNode_Inequality_DifferentUnaryOperators() {
        let node1 = ASTNode.unaryOp(.negate, .number(5.0))
        let node2 = ASTNode.unaryOp(.factorial, .number(5.0))
        XCTAssertNotEqual(node1, node2)
    }
    
    func test_ASTNode_Inequality_DifferentFunctions() {
        let node1 = ASTNode.function(.sin, .number(30.0))
        let node2 = ASTNode.function(.cos, .number(30.0))
        XCTAssertNotEqual(node1, node2)
    }
    
    func test_ASTNode_Inequality_DifferentTypes() {
        let node1 = ASTNode.number(3.14159)
        let node2 = ASTNode.constant(.pi)
        XCTAssertNotEqual(node1, node2)
    }
    
    func test_ASTNode_Inequality_NumberVsVariable() {
        let node1 = ASTNode.number(1.0)
        let node2 = ASTNode.variable("A")
        XCTAssertNotEqual(node1, node2)
    }
    
    // MARK: - Complex Tree Structure Tests
    
    func test_ASTNode_DeepNesting_Equality() {
        let deepNode1 = ASTNode.binaryOp(
            .add,
            .binaryOp(
                .multiply,
                .number(2.0),
                .binaryOp(.power, .number(3.0), .number(4.0))
            ),
            .function(.sqrt, .number(16.0))
        )
        
        let deepNode2 = ASTNode.binaryOp(
            .add,
            .binaryOp(
                .multiply,
                .number(2.0),
                .binaryOp(.power, .number(3.0), .number(4.0))
            ),
            .function(.sqrt, .number(16.0))
        )
        
        XCTAssertEqual(deepNode1, deepNode2)
    }
    
    func test_ASTNode_DeepNesting_Description() {
        let node = ASTNode.binaryOp(
            .add,
            .binaryOp(
                .multiply,
                .number(2.0),
                .binaryOp(.power, .number(3.0), .number(4.0))
            ),
            .function(.sqrt, .number(16.0))
        )
        
        XCTAssertEqual(node.description, "((2 × (3 ^ 4)) + sqrt(16))")
    }
    
    func test_ASTNode_AllNodeTypes_InSingleExpression() {
        let node = ASTNode.binaryOp(
            .add,
            .binaryOp(
                .multiply,
                .constant(.pi),
                .variable("A")
            ),
            .function(
                .sin,
                .unaryOp(.negate, .number(30.0))
            )
        )
        
        XCTAssertEqual(node.description, "((π × A) + sin((-30)))")
    }
}
