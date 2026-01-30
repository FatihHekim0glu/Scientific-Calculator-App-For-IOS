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
    
    /// Returns true if this function takes two arguments
    var isTwoArgument: Bool {
        switch self {
        case .randomInt, .pol, .rec, .gcd, .lcm, .vectorAngle, .vectorProject, .baseConvert:
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
    
    /// Returns true if this token starts an expression
    var canStartExpression: Bool {
        switch self {
        case .number, .constant, .scientificConstant, .variable, .leftParen, .function,
             .imaginaryUnit, .matrixRef, .vectorRef, .leftBracket:
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
        }
    }
}
