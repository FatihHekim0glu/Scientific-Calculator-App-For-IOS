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
    
    var precedence: Int {
        switch self {
        case .add, .subtract: return 1
        case .multiply, .divide, .modulo: return 2
        case .power: return 3
        case .permutation, .combination, .nthRoot, .logBase: return 4
        }
    }
    
    var isRightAssociative: Bool {
        self == .power
    }
}

/// Unary operators for single-operand operations
enum UnaryOperator: String, CaseIterable {
    case negate = "negate"
    case factorial = "!"
    case reciprocal = "⁻¹"
    case square = "²"
    case cube = "³"
    case percent = "%"
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
    
    /// Returns true if this function takes two arguments
    var isTwoArgument: Bool {
        switch self {
        case .randomInt, .pol, .rec, .gcd, .lcm:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this function takes no arguments
    var isZeroArgument: Bool {
        self == .random
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
}

// MARK: - Token

/// A lexical token with type and position information
struct Token: Equatable {
    let type: TokenType
    let position: Int
}
