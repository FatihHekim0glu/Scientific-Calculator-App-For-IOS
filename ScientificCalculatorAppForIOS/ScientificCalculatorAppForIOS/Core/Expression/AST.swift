import Foundation

// MARK: - Abstract Syntax Tree Node

/// Represents a node in the abstract syntax tree for mathematical expressions.
indirect enum ASTNode: Equatable {
    /// A numeric literal value.
    case number(Double)
    
    /// A mathematical constant (π, e).
    case constant(MathConstant)
    
    /// A scientific constant (c, h, G, etc.).
    case scientificConstant(ScientificConstant)
    
    /// A variable reference (A-F, Ans, PreAns).
    case variable(String)
    
    /// A binary operation with left and right operands.
    case binaryOp(BinaryOperator, ASTNode, ASTNode)
    
    /// A unary operation with a single operand.
    case unaryOp(UnaryOperator, ASTNode)
    
    /// A single-argument function call.
    case function(MathFunction, ASTNode)
    
    /// A two-argument function call (gcd, lcm, pol, rec, randomInt).
    case function2(MathFunction, ASTNode, ASTNode)
    
    /// A zero-argument function call (random).
    case function0(MathFunction)
}

// MARK: - ASTNode Description

extension ASTNode: CustomStringConvertible {
    /// Returns a human-readable representation of the AST node.
    var description: String {
        switch self {
        case .number(let value):
            return formatNumber(value)
            
        case .constant(let mathConstant):
            return mathConstant.rawValue
            
        case .scientificConstant(let constant):
            return constant.displaySymbol
            
        case .variable(let name):
            return name
            
        case .binaryOp(let op, let left, let right):
            return "(\(left.description) \(op.rawValue) \(right.description))"
            
        case .unaryOp(let op, let operand):
            switch op {
            case .negate:
                return "(-\(operand.description))"
            case .factorial:
                return "(\(operand.description)!)"
            case .percent:
                return "(\(operand.description)%)"
            case .square:
                return "(\(operand.description))²"
            case .cube:
                return "(\(operand.description))³"
            case .reciprocal:
                return "(\(operand.description))⁻¹"
            }
            
        case .function(let function, let argument):
            return "\(function.rawValue)(\(argument.description))"
            
        case .function2(let function, let arg1, let arg2):
            return "\(function.rawValue)(\(arg1.description), \(arg2.description))"
            
        case .function0(let function):
            return "\(function.rawValue)()"
        }
    }
    
    /// Formats a number for display, removing unnecessary decimal places.
    private func formatNumber(_ value: Double) -> String {
        if value == floor(value) && abs(value) < 1e15 {
            return String(format: "%.0f", value)
        }
        return String(value)
    }
}
