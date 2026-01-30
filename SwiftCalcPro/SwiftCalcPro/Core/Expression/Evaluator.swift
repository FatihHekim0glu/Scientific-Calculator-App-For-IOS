import Foundation

// MARK: - Angle Mode

/// Angle units for trigonometric calculations
enum AngleMode {
    case degrees
    case radians
    case gradians
    
    /// Converts a value from this angle mode to radians
    func toRadians(_ value: Double) -> Double {
        switch self {
        case .degrees:
            return value * .pi / 180.0
        case .radians:
            return value
        case .gradians:
            return value * .pi / 200.0
        }
    }
    
    /// Converts a value from radians to this angle mode
    func fromRadians(_ value: Double) -> Double {
        switch self {
        case .degrees:
            return value * 180.0 / .pi
        case .radians:
            return value
        case .gradians:
            return value * 200.0 / .pi
        }
    }
}

// MARK: - Evaluation Context

/// Context for expression evaluation containing variables and settings
struct EvaluationContext {
    var angleMode: AngleMode = .degrees
    var variables: [String: Double] = [:]
    var lastAnswer: Double = 0
    
    /// Sets a variable value
    mutating func setVariable(_ name: String, value: Double) {
        variables[name] = value
    }
    
    /// Gets a variable value, throwing if undefined
    func getVariable(_ name: String) throws -> Double {
        if name == "Ans" {
            return lastAnswer
        }
        guard let value = variables[name] else {
            throw CalculatorError.undefinedVariable(name)
        }
        return value
    }
}

// MARK: - Evaluator

/// Evaluates an AST and returns a numeric result
struct Evaluator {
    private var context: EvaluationContext
    
    init(context: EvaluationContext = EvaluationContext()) {
        self.context = context
    }
    
    /// Evaluates an AST node and returns the result
    mutating func evaluate(_ node: ASTNode) throws -> Double {
        switch node {
        case .number(let value):
            return value
            
        case .constant(let mathConstant):
            return mathConstant.value
            
        case .variable(let name):
            return try context.getVariable(name)
            
        case .binaryOp(let op, let left, let right):
            return try evaluateBinaryOp(op, left: left, right: right)
            
        case .unaryOp(let op, let operand):
            return try evaluateUnaryOp(op, operand: operand)
            
        case .function(let function, let argument):
            return try evaluateFunction(function, argument: argument)
        }
    }
    
    // MARK: - Binary Operations
    
    private mutating func evaluateBinaryOp(_ op: BinaryOperator, left: ASTNode, right: ASTNode) throws -> Double {
        let leftValue = try evaluate(left)
        let rightValue = try evaluate(right)
        
        switch op {
        case .add:
            return leftValue + rightValue
            
        case .subtract:
            return leftValue - rightValue
            
        case .multiply:
            return leftValue * rightValue
            
        case .divide:
            guard abs(rightValue) >= 1e-15 else {
                throw CalculatorError.divisionByZero
            }
            return leftValue / rightValue
            
        case .power:
            let result = pow(leftValue, rightValue)
            guard result.isFinite else {
                throw CalculatorError.overflow
            }
            return result
        }
    }
    
    // MARK: - Unary Operations
    
    private mutating func evaluateUnaryOp(_ op: UnaryOperator, operand: ASTNode) throws -> Double {
        let value = try evaluate(operand)
        
        switch op {
        case .negate:
            return -value
            
        case .factorial:
            return try factorial(value)
        }
    }
    
    // MARK: - Function Evaluation
    
    private mutating func evaluateFunction(_ function: MathFunction, argument: ASTNode) throws -> Double {
        let value = try evaluate(argument)
        
        switch function {
        // Trigonometric functions
        case .sin:
            return sin(context.angleMode.toRadians(value))
            
        case .cos:
            return cos(context.angleMode.toRadians(value))
            
        case .tan:
            let radians = context.angleMode.toRadians(value)
            let cosValue = cos(radians)
            guard abs(cosValue) >= 1e-15 else {
                throw CalculatorError.domainError("Tangent undefined at this angle")
            }
            return sin(radians) / cosValue
            
        // Inverse trigonometric functions
        case .asin:
            guard value >= -1 && value <= 1 else {
                throw CalculatorError.domainError("asin requires input in [-1, 1]")
            }
            return context.angleMode.fromRadians(Foundation.asin(value))
            
        case .acos:
            guard value >= -1 && value <= 1 else {
                throw CalculatorError.domainError("acos requires input in [-1, 1]")
            }
            return context.angleMode.fromRadians(Foundation.acos(value))
            
        case .atan:
            return context.angleMode.fromRadians(Foundation.atan(value))
            
        // Hyperbolic functions
        case .sinh:
            return Foundation.sinh(value)
            
        case .cosh:
            return Foundation.cosh(value)
            
        case .tanh:
            return Foundation.tanh(value)
            
        // Inverse hyperbolic functions
        case .asinh:
            return Foundation.asinh(value)
            
        case .acosh:
            guard value >= 1 else {
                throw CalculatorError.domainError("acosh requires input >= 1")
            }
            return Foundation.acosh(value)
            
        case .atanh:
            guard value > -1 && value < 1 else {
                throw CalculatorError.domainError("atanh requires input in (-1, 1)")
            }
            return Foundation.atanh(value)
            
        // Logarithmic functions
        case .log:
            guard value > 0 else {
                throw CalculatorError.domainError("log requires positive input")
            }
            return log10(value)
            
        case .ln:
            guard value > 0 else {
                throw CalculatorError.domainError("ln requires positive input")
            }
            return Foundation.log(value)
            
        // Root functions
        case .sqrt:
            guard value >= 0 else {
                throw CalculatorError.domainError("sqrt requires non-negative input")
            }
            return Foundation.sqrt(value)
            
        case .cbrt:
            return Foundation.cbrt(value)
            
        // Other functions
        case .abs:
            return Swift.abs(value)
            
        case .exp:
            let result = Foundation.exp(value)
            guard result.isFinite else {
                throw CalculatorError.overflow
            }
            return result
        }
    }
    
    // MARK: - Factorial
    
    /// Computes the factorial of a non-negative integer
    private func factorial(_ n: Double) throws -> Double {
        guard n >= 0 else {
            throw CalculatorError.domainError("Factorial requires non-negative input")
        }
        guard n == floor(n) else {
            throw CalculatorError.domainError("Factorial requires integer input")
        }
        guard n <= 170 else {
            throw CalculatorError.overflow
        }
        
        if n <= 1 { return 1 }
        
        var result: Double = 1
        for i in 2...Int(n) {
            result *= Double(i)
        }
        return result
    }
}
