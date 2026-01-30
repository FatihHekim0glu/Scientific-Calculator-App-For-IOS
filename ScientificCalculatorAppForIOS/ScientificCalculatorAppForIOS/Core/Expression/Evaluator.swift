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
    var previousAnswer: Double = 0
    
    // Secondary results from coordinate conversions
    var lastPolarTheta: Double = 0
    var lastRectY: Double = 0
    
    /// Sets a variable value
    mutating func setVariable(_ name: String, value: Double) {
        variables[name] = value
    }
    
    /// Gets a variable value, throwing if undefined
    func getVariable(_ name: String) throws -> Double {
        if name == "Ans" {
            return lastAnswer
        }
        if name == "PreAns" {
            return previousAnswer
        }
        guard let value = variables[name] else {
            throw CalculatorError.undefinedVariable(name)
        }
        return value
    }
    
    /// Stores a new answer, shifting the previous
    mutating func storeAnswer(_ value: Double) {
        previousAnswer = lastAnswer
        lastAnswer = value
    }
}

// MARK: - Evaluator

/// Evaluates an AST and returns a numeric result
struct Evaluator {
    private var context: EvaluationContext
    
    init(context: EvaluationContext = EvaluationContext()) {
        self.context = context
    }
    
    /// Returns the current evaluation context
    var currentContext: EvaluationContext {
        context
    }
    
    /// Evaluates an AST node and returns the result
    mutating func evaluate(_ node: ASTNode) throws -> Double {
        switch node {
        case .number(let value):
            return value
            
        case .constant(let mathConstant):
            return mathConstant.value
            
        case .scientificConstant(let constant):
            return constant.value
            
        case .variable(let name):
            return try context.getVariable(name)
            
        case .binaryOp(let op, let left, let right):
            return try evaluateBinaryOp(op, left: left, right: right)
            
        case .unaryOp(let op, let operand):
            return try evaluateUnaryOp(op, operand: operand)
            
        case .function(let function, let argument):
            return try evaluateFunction(function, argument: argument)
            
        case .function2(let function, let arg1, let arg2):
            return try evaluateFunction2(function, arg1: arg1, arg2: arg2)
            
        case .function0(let function):
            return try evaluateFunction0(function)
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
            
        case .permutation:
            return try Combinatorics.permutation(n: leftValue, r: rightValue)
            
        case .combination:
            return try Combinatorics.combination(n: leftValue, r: rightValue)
            
        case .modulo:
            return try Combinatorics.mod(leftValue, rightValue)
            
        case .nthRoot:
            return try NumberFunctions.nthRoot(index: leftValue, radicand: rightValue)
            
        case .logBase:
            return try NumberFunctions.logBase(leftValue, of: rightValue)
        }
    }
    
    // MARK: - Unary Operations
    
    private mutating func evaluateUnaryOp(_ op: UnaryOperator, operand: ASTNode) throws -> Double {
        let value = try evaluate(operand)
        
        switch op {
        case .negate:
            return -value
            
        case .factorial:
            return try Combinatorics.factorial(value)
            
        case .reciprocal:
            return try NumberFunctions.reciprocal(value)
            
        case .square:
            return try NumberFunctions.square(value)
            
        case .cube:
            return try NumberFunctions.cube(value)
            
        case .percent:
            return NumberFunctions.percent(value)
        }
    }
    
    // MARK: - Single-Argument Function Evaluation
    
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
            
        // Basic functions
        case .abs:
            return Swift.abs(value)
            
        case .exp:
            let result = Foundation.exp(value)
            guard result.isFinite else {
                throw CalculatorError.overflow
            }
            return result
            
        // Number functions (Phase 2)
        case .intPart:
            return NumberFunctions.integerPart(value)
            
        case .fracPart:
            return NumberFunctions.fractionalPart(value)
            
        case .floor:
            return NumberFunctions.floor(value)
            
        case .ceil:
            return NumberFunctions.ceil(value)
            
        case .round:
            return NumberFunctions.roundToDisplayPrecision(value)
            
        // Power functions (Phase 2)
        case .tenPow:
            return try NumberFunctions.tenPow(value)
            
        // Angle conversions (Phase 2)
        case .degToRad:
            return AngleConversions.degreesToRadians(value)
            
        case .radToDeg:
            return AngleConversions.radiansToDegrees(value)
            
        case .degToGrad:
            return AngleConversions.degreesToGradians(value)
            
        case .gradToDeg:
            return AngleConversions.gradiansToDegrees(value)
            
        case .dmsToDecimal:
            return AngleConversions.parseDMSEncoded(value).decimalDegrees
            
        case .decimalToDms:
            return AngleConversions.encodeDMS(AngleConversions.decimalToDMS(value))
            
        // Two-argument functions called with single argument - throw error
        case .randomInt, .pol, .rec, .gcd, .lcm:
            throw CalculatorError.syntaxError("\(function.rawValue) requires two arguments")
            
        // Zero-argument function called with argument - throw error
        case .random:
            throw CalculatorError.syntaxError("random() takes no arguments")
        }
    }
    
    // MARK: - Two-Argument Function Evaluation
    
    private mutating func evaluateFunction2(_ function: MathFunction, arg1: ASTNode, arg2: ASTNode) throws -> Double {
        let value1 = try evaluate(arg1)
        let value2 = try evaluate(arg2)
        
        switch function {
        case .randomInt:
            return try NumberFunctions.randomInt(min: value1, max: value2)
            
        case .pol:
            let result = CoordinateConversions.rectangularToPolar(x: value1, y: value2, angleMode: context.angleMode)
            context.lastPolarTheta = result.theta
            return result.r
            
        case .rec:
            let result = CoordinateConversions.polarToRectangular(r: value1, theta: value2, angleMode: context.angleMode)
            context.lastRectY = result.y
            return result.x
            
        case .gcd:
            return try Combinatorics.gcd(value1, value2)
            
        case .lcm:
            return try Combinatorics.lcm(value1, value2)
            
        default:
            throw CalculatorError.syntaxError("\(function.rawValue) is not a two-argument function")
        }
    }
    
    // MARK: - Zero-Argument Function Evaluation
    
    private func evaluateFunction0(_ function: MathFunction) throws -> Double {
        switch function {
        case .random:
            return NumberFunctions.random()
            
        default:
            throw CalculatorError.syntaxError("\(function.rawValue) is not a zero-argument function")
        }
    }
}
