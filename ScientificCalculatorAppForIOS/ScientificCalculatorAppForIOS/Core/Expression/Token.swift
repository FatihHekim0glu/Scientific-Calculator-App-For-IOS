import Foundation

// MARK: - Mathematical Constants

/// Mathematical constants available in expressions
enum MathConstant: String, CaseIterable {
    case pi = "π"
    case e = "e"
    
    var value: Double {
        switch self {
        case .pi: return Double.pi
        case .e: return M_E
        }
    }
}

// MARK: - Operators

/// Binary operators for two-operand operations
enum BinaryOperator: String, CaseIterable {
    // Basic arithmetic
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
    case power = "^"
    case permutation = "P"
    case combination = "C"
    case modulo = "mod"
    case nthRoot = "√"
    case logBase = "log_"
    
    // Phase 3: Bitwise operators
    case bitwiseAnd = "and"
    case bitwiseOr = "or"
    case bitwiseXor = "xor"
    case bitwiseXnor = "xnor"
    case leftShift = "<<"
    case rightShift = ">>"
    
    // Phase 3: Vector/Matrix operators
    case dotProduct = "·"
    case crossProduct = "×v"
    
    var precedence: Int {
        switch self {
        // Bitwise OR, XOR, XNOR have lowest precedence
        case .bitwiseOr, .bitwiseXor, .bitwiseXnor: return 0
        // Bitwise AND
        case .bitwiseAnd: return 0
        // Addition and subtraction
        case .add, .subtract: return 1
        // Multiplication, division, modulo, dot/cross products, shifts
        case .multiply, .divide, .modulo: return 2
        case .dotProduct, .crossProduct: return 2
        case .leftShift, .rightShift: return 2
        // Exponentiation
        case .power: return 3
        // Higher precedence operators
        case .permutation, .combination, .nthRoot, .logBase: return 4
        }
    }
    
    var isRightAssociative: Bool {
        self == .power
    }
    
    /// Returns true if this is a bitwise operator
    var isBitwiseOperator: Bool {
        switch self {
        case .bitwiseAnd, .bitwiseOr, .bitwiseXor, .bitwiseXnor, .leftShift, .rightShift:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this is a vector-specific operator
    var isVectorOperator: Bool {
        switch self {
        case .dotProduct, .crossProduct:
            return true
        default:
            return false
        }
    }
}

/// Unary operators for single-operand operations
enum UnaryOperator: String, CaseIterable {
    // Basic unary operators
    case negate = "negate"
    case factorial = "!"
    case reciprocal = "⁻¹"
    case square = "²"
    case cube = "³"
    case percent = "%"
    
    // Phase 3: Bitwise operators
    case bitwiseNot = "Not"
    case bitwiseNeg = "Neg"
    
    // Phase 3: Complex operators
    case conjugate = "Conj"
    case realPart = "Re"
    case imagPart = "Im"
    case argument = "Arg"
    
    // Phase 3: Matrix operators
    case transpose = "ᵀ"
    case determinant = "det"
    case matrixInverse = "⁻¹m"
    
    // Phase 3: Vector operators
    case vectorMagnitude = "‖‖"
    case normalize = "norm"
    
    /// Returns true if this is a bitwise unary operator
    var isBitwiseOperator: Bool {
        switch self {
        case .bitwiseNot, .bitwiseNeg:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this is a complex-specific operator
    var isComplexOperator: Bool {
        switch self {
        case .conjugate, .realPart, .imagPart, .argument:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this is a matrix-specific operator
    var isMatrixOperator: Bool {
        switch self {
        case .transpose, .determinant, .matrixInverse:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this is a vector-specific operator
    var isVectorOperator: Bool {
        switch self {
        case .vectorMagnitude, .normalize:
            return true
        default:
            return false
        }
    }
}

// MARK: - Functions

/// Mathematical functions available in expressions
enum MathFunction: String, CaseIterable {
    // Trigonometric
    case sin, cos, tan
    case asin, acos, atan
    
    // Hyperbolic
    case sinh, cosh, tanh
    case asinh, acosh, atanh
    
    // Logarithmic
    case log, ln
    
    // Roots
    case sqrt, cbrt
    
    // Basic
    case abs
    case exp
    
    // Number functions (Phase 2)
    case intPart
    case fracPart
    case floor, ceil
    case round
    
    // Random (Phase 2)
    case random
    case randomInt
    
    // Coordinate conversions (Phase 2)
    case pol
    case rec
    
    // Angle conversions (Phase 2)
    case degToRad, radToDeg
    case degToGrad, gradToDeg
    case dmsToDecimal
    case decimalToDms
    
    // Number theory (Phase 2)
    case gcd
    case lcm
    
    // Power functions (Phase 2)
    case tenPow
    
    // Phase 3: Complex functions
    case complexSqrt
    case complexExp
    case complexLn
    case complexSin
    case complexCos
    case complexTan
    
    // Phase 3: Matrix functions
    case identity
    case trace
    
    // Phase 3: Vector functions
    case vectorAngle
    case vectorProject
    
    // Phase 3: Base-N functions
    case baseConvert
    
    // MARK: - Phase 4: Statistics Functions
    
    /// Mean/average of values
    case mean
    /// Sum of values
    case sum
    /// Sum of squares
    case sumSquares
    /// Population standard deviation
    case popStdDev
    /// Sample standard deviation
    case sampleStdDev
    /// Variance
    case variance
    /// Minimum value
    case minimum
    /// Maximum value
    case maximum
    /// Median
    case median
    /// First quartile (Q1)
    case quartile1
    /// Third quartile (Q3)
    case quartile3
    /// Count of values
    case count
    /// Covariance
    case covariance
    /// Pearson correlation coefficient
    case correlation
    
    // MARK: - Phase 4: Distribution Functions
    
    /// Normal probability density function
    case normalPdf
    /// Normal cumulative distribution function
    case normalCdf
    /// Inverse normal CDF (quantile function)
    case invNorm
    /// Binomial probability mass function
    case binomialPdf
    /// Binomial cumulative distribution function
    case binomialCdf
    /// Poisson probability mass function
    case poissonPdf
    /// Poisson cumulative distribution function
    case poissonCdf
    
    // MARK: - Phase 4: Regression Functions
    
    /// Linear regression intercept (a)
    case linRegA
    /// Linear regression slope (b)
    case linRegB
    /// Estimated y value (ŷ)
    case estimateY
    /// Estimated x value (x̂)
    case estimateX
    
    // MARK: - Phase 6: Numerical Calculus Functions
    
    /// Definite integral ∫[a,b] f(x) dx
    case integrate
    /// Numerical derivative d/dx at a point
    case differentiate
    /// Summation Σ f(x) for x = start to end
    case summation
    /// Product Π f(x) for x = start to end
    case product
    
    /// Returns true if this function takes two arguments
    var isTwoArgument: Bool {
        switch self {
        case .randomInt, .pol, .rec, .gcd, .lcm, .vectorAngle, .vectorProject, .baseConvert,
             .covariance, .correlation, .poissonPdf, .poissonCdf:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this function takes three arguments
    var isThreeArgument: Bool {
        switch self {
        case .normalPdf, .normalCdf, .invNorm, .binomialPdf, .binomialCdf:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this is a variadic function (takes multiple arguments)
    var isVariadic: Bool {
        switch self {
        case .mean, .sum, .sumSquares, .popStdDev, .sampleStdDev, .variance,
             .minimum, .maximum, .median, .quartile1, .quartile3, .count:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this function takes no arguments
    var isZeroArgument: Bool {
        self == .random
    }
    
    /// Returns true if this is a complex-specific function
    var isComplexFunction: Bool {
        switch self {
        case .complexSqrt, .complexExp, .complexLn, .complexSin, .complexCos, .complexTan:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this is a matrix function
    var isMatrixFunction: Bool {
        switch self {
        case .identity, .trace:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this is a vector function
    var isVectorFunction: Bool {
        switch self {
        case .vectorAngle, .vectorProject:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Phase 4 Function Properties
    
    /// Returns true if this is a statistics function
    var isStatisticsFunction: Bool {
        switch self {
        case .mean, .sum, .sumSquares, .popStdDev, .sampleStdDev, .variance,
             .minimum, .maximum, .median, .quartile1, .quartile3, .count,
             .covariance, .correlation:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this is a distribution function
    var isDistributionFunction: Bool {
        switch self {
        case .normalPdf, .normalCdf, .invNorm,
             .binomialPdf, .binomialCdf,
             .poissonPdf, .poissonCdf:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this is a regression function
    var isRegressionFunction: Bool {
        switch self {
        case .linRegA, .linRegB, .estimateY, .estimateX:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this is a Phase 4 function
    var isPhase4Function: Bool {
        isStatisticsFunction || isDistributionFunction || isRegressionFunction
    }
    
    /// Number of arguments for distribution functions
    var distributionArgumentCount: Int {
        switch self {
        case .normalPdf, .normalCdf: return 3  // x, μ, σ
        case .invNorm: return 3                 // p, μ, σ
        case .binomialPdf, .binomialCdf: return 3  // k, n, p
        case .poissonPdf, .poissonCdf: return 2     // k, λ
        default: return 1
        }
    }
    
    // MARK: - Phase 6: Calculus Function Properties
    
    /// Returns true if this is a calculus function requiring special handling
    var isCalculusFunction: Bool {
        switch self {
        case .integrate, .differentiate, .summation, .product:
            return true
        default:
            return false
        }
    }
    
    /// Number of arguments for calculus functions
    /// integrate(f(x), x, a, b) = 4 (expression, variable, lower, upper)
    /// differentiate(f(x), x, a) = 3 (expression, variable, point)
    /// summation(f(x), x, a, b) = 4 (expression, variable, start, end)
    /// product(f(x), x, a, b) = 4 (expression, variable, start, end)
    var calculusArgumentCount: Int {
        switch self {
        case .integrate, .summation, .product: return 4
        case .differentiate: return 3
        default: return 1
        }
    }
    
    /// Returns true if this is a Phase 6 function
    var isPhase6Function: Bool {
        isCalculusFunction
    }
}

// MARK: - Phase 4: Statistical Functions Enum

/// Statistical functions that operate on lists of values
enum StatFunction: String, CaseIterable {
    case mean = "mean"
    case sum = "sum"
    case stdDev = "stdDev"
    case variance = "var"
    case min = "min"
    case max = "max"
    case median = "median"
    case count = "count"
    case range = "range"
    
    /// Whether this function accepts variable number of arguments
    var isVariadic: Bool { true }
    
    /// Minimum number of arguments required
    var minArguments: Int {
        switch self {
        case .count, .sum: return 1
        case .mean, .min, .max, .median, .range: return 1
        case .stdDev, .variance: return 2
        }
    }
}

// MARK: - Phase 6: Calculus Operators

/// Calculus operators with special syntax
enum CalcOperator: String, CaseIterable {
    case integral = "∫"
    case derivative = "d/dx"
    case sigma = "Σ"
    case pi = "Π"
    
    var displaySymbol: String {
        switch self {
        case .integral: return "∫"
        case .derivative: return "d/dx"
        case .sigma: return "Σ"
        case .pi: return "Π"
        }
    }
    
    var description: String {
        switch self {
        case .integral: return "Definite integral"
        case .derivative: return "Derivative at point"
        case .sigma: return "Summation"
        case .pi: return "Product"
        }
    }
}

// MARK: - Token Types

/// Represents the type of a lexical token
/// Note: ScientificConstant is defined in Core/Math/Constants.swift
enum TokenType: Equatable {
    case number(Double)
    case constant(MathConstant)
    case scientificConstant(ScientificConstant)
    case binaryOperator(BinaryOperator)
    case unaryOperator(UnaryOperator)
    case function(MathFunction)
    case leftParen
    case rightParen
    case comma
    case variable(String)
    case end
    
    // Phase 3 additions
    
    /// Imaginary unit 'i' for complex numbers
    case imaginaryUnit
    
    /// Reference to a stored matrix (MatA, MatB, etc.)
    case matrixRef(MatrixRef)
    
    /// Reference to a stored vector (VctA, VctB, etc.)
    case vectorRef(VectorRef)
    
    /// Base indicator for Base-N mode (BIN, OCT, DEC, HEX)
    case baseIndicator(NumberBase)
    
    /// Left bracket for matrix literals
    case leftBracket
    
    /// Right bracket for matrix literals
    case rightBracket
    
    /// Semicolon for matrix row separator
    case semicolon
    
    // Phase 4 additions
    
    /// Statistical variable (Σx, x̄, σx, etc.)
    case statVariable(StatVariableType)
    
    /// Statistical function (variadic, takes list of values)
    case statFunction(StatFunction)
    
    // Phase 6 additions
    
    /// Calculus operator (∫, d/dx, Σ, Π)
    case calculusOperator(CalcOperator)
}

// MARK: - Token

/// A lexical token with type and position information
struct Token: Equatable {
    let type: TokenType
    let position: Int
}

// MARK: - Token Type Extensions

extension TokenType {
    /// Returns true if this token type is a Phase 3 type
    var isPhase3Type: Bool {
        switch self {
        case .imaginaryUnit, .matrixRef, .vectorRef, .baseIndicator, .leftBracket, .rightBracket, .semicolon:
            return true
        case .binaryOperator(let op):
            return op.isBitwiseOperator || op.isVectorOperator
        case .unaryOperator(let op):
            return op.isBitwiseOperator || op.isComplexOperator || op.isMatrixOperator || op.isVectorOperator
        case .function(let fn):
            return fn.isComplexFunction || fn.isMatrixFunction || fn.isVectorFunction
        default:
            return false
        }
    }
    
    /// Returns true if this token type is a Phase 4 type
    var isPhase4Type: Bool {
        switch self {
        case .statVariable, .statFunction:
            return true
        case .function(let fn):
            return fn.isPhase4Function
        default:
            return false
        }
    }
    
    /// Returns true if this token type is a Phase 6 type
    var isPhase6Type: Bool {
        switch self {
        case .calculusOperator:
            return true
        case .function(let fn):
            return fn.isPhase6Function
        default:
            return false
        }
    }
    
    /// Returns true if this is a calculus-related token
    var isCalculusToken: Bool {
        switch self {
        case .calculusOperator:
            return true
        case .function(let fn):
            return fn.isCalculusFunction
        default:
            return false
        }
    }
    
    /// Returns true if this is a statistics-related token
    var isStatisticsToken: Bool {
        switch self {
        case .statVariable, .statFunction:
            return true
        case .function(let fn):
            return fn.isStatisticsFunction
        default:
            return false
        }
    }
    
    /// Returns true if this is a distribution-related token
    var isDistributionToken: Bool {
        switch self {
        case .function(let fn):
            return fn.isDistributionFunction
        default:
            return false
        }
    }
    
    /// Returns true if this token starts an expression
    var canStartExpression: Bool {
        switch self {
        case .number, .constant, .scientificConstant, .variable, .leftParen, .function,
             .imaginaryUnit, .matrixRef, .vectorRef, .leftBracket,
             .statVariable, .statFunction, .calculusOperator:
            return true
        case .unaryOperator(let op):
            return op == .negate
        default:
            return false
        }
    }
    
    /// Returns a display string for the token type
    var displayString: String {
        switch self {
        case .number(let value):
            return String(value)
        case .constant(let c):
            return c.rawValue
        case .scientificConstant(let c):
            return c.symbol
        case .binaryOperator(let op):
            return op.rawValue
        case .unaryOperator(let op):
            return op.rawValue
        case .function(let fn):
            return fn.rawValue
        case .leftParen:
            return "("
        case .rightParen:
            return ")"
        case .comma:
            return ","
        case .variable(let name):
            return name
        case .end:
            return "END"
        case .imaginaryUnit:
            return "i"
        case .matrixRef(let ref):
            return ref.rawValue
        case .vectorRef(let ref):
            return ref.rawValue
        case .baseIndicator(let base):
            return base.name
        case .leftBracket:
            return "["
        case .rightBracket:
            return "]"
        case .semicolon:
            return ";"
        case .statVariable(let sv):
            return sv.rawValue
        case .statFunction(let sf):
            return sf.rawValue
        case .calculusOperator(let op):
            return op.displaySymbol
        }
    }
}
