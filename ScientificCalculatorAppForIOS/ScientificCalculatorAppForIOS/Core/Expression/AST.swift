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
    
    // MARK: - Phase 3: Complex Numbers
    
    /// Complex number literal (a + bi)
    case complexNumber(real: Double, imaginary: Double)
    
    /// Imaginary unit 'i'
    case imaginaryUnit
    
    // MARK: - Phase 3: Matrix
    
    /// Reference to a stored matrix (MatA, MatB, MatC, MatD)
    case matrixRef(MatrixRef)
    
    /// Matrix literal for inline matrix definitions
    case matrixLiteral([[ASTNode]])
    
    // MARK: - Phase 3: Vector
    
    /// Reference to a stored vector (VctA, VctB, VctC, VctD)
    case vectorRef(VectorRef)
    
    /// Vector literal for inline vector definitions
    case vectorLiteral([ASTNode])
    
    // MARK: - Phase 3: Base-N
    
    /// Base-N number literal with explicit base
    case baseNNumber(value: Int32, base: NumberBase)
    
    // MARK: - Phase 4: Statistics & Distributions
    
    /// N-argument function call for variadic functions (statistics, distributions)
    case functionN(MathFunction, [ASTNode])
    
    /// List literal for passing multiple values to functions
    case listLiteral([ASTNode])
    
    /// Statistical variable reference (Σx, x̄, σx, etc.)
    case statVariable(StatVariableType)
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
            // Phase 3: Complex operators
            case .conjugate:
                return "Conj(\(operand.description))"
            case .realPart:
                return "Re(\(operand.description))"
            case .imagPart:
                return "Im(\(operand.description))"
            case .argument:
                return "Arg(\(operand.description))"
            // Phase 3: Matrix operators
            case .transpose:
                return "(\(operand.description))ᵀ"
            case .determinant:
                return "det(\(operand.description))"
            case .matrixInverse:
                return "(\(operand.description))⁻¹"
            // Phase 3: Vector operators
            case .vectorMagnitude:
                return "‖\(operand.description)‖"
            case .normalize:
                return "norm(\(operand.description))"
            // Phase 3: Bitwise operators
            case .bitwiseNot:
                return "Not(\(operand.description))"
            case .bitwiseNeg:
                return "Neg(\(operand.description))"
            }
            
        case .function(let function, let argument):
            return "\(function.rawValue)(\(argument.description))"
            
        case .function2(let function, let arg1, let arg2):
            return "\(function.rawValue)(\(arg1.description), \(arg2.description))"
            
        case .function0(let function):
            return "\(function.rawValue)()"
            
        // MARK: Phase 3 Cases
            
        case .complexNumber(let real, let imaginary):
            if imaginary >= 0 {
                return "\(formatNumber(real)) + \(formatNumber(imaginary))i"
            } else {
                return "\(formatNumber(real)) - \(formatNumber(abs(imaginary)))i"
            }
            
        case .imaginaryUnit:
            return "i"
            
        case .matrixRef(let ref):
            return ref.rawValue
            
        case .vectorRef(let ref):
            return ref.rawValue
            
        case .matrixLiteral(let rows):
            let rowStrings = rows.map { row in
                "[" + row.map { $0.description }.joined(separator: ", ") + "]"
            }
            return "[" + rowStrings.joined(separator: "; ") + "]"
            
        case .vectorLiteral(let components):
            return "(" + components.map { $0.description }.joined(separator: ", ") + ")"
            
        case .baseNNumber(let value, let base):
            return formatBaseNNumber(value, base: base)
            
        // MARK: Phase 4 Cases
            
        case .functionN(let function, let arguments):
            let argsStr = arguments.map { $0.description }.joined(separator: ", ")
            return "\(function.rawValue)(\(argsStr))"
            
        case .listLiteral(let elements):
            let elemStr = elements.map { $0.description }.joined(separator: ", ")
            return "{\(elemStr)}"
            
        case .statVariable(let statVar):
            return statVar.rawValue
        }
    }
    
    /// Formats a number for display, removing unnecessary decimal places.
    private func formatNumber(_ value: Double) -> String {
        if value == floor(value) && abs(value) < 1e15 {
            return String(format: "%.0f", value)
        }
        return String(value)
    }
    
    /// Formats a Base-N number for display.
    private func formatBaseNNumber(_ value: Int32, base: NumberBase) -> String {
        let unsigned = UInt32(bitPattern: value)
        switch base {
        case .binary:
            return String(unsigned, radix: 2)
        case .octal:
            return String(unsigned, radix: 8)
        case .decimal:
            return String(value)
        case .hexadecimal:
            return String(unsigned, radix: 16).uppercased()
        }
    }
}

// MARK: - ASTNode Type Checking

extension ASTNode {
    /// Returns true if this node evaluates to a complex number
    var isComplexExpression: Bool {
        switch self {
        case .complexNumber, .imaginaryUnit:
            return true
        case .binaryOp(_, let left, let right):
            return left.isComplexExpression || right.isComplexExpression
        case .unaryOp(let op, let operand):
            if op.isComplexOperator {
                return true
            }
            return operand.isComplexExpression
        case .function(let fn, _):
            return fn.isComplexFunction
        default:
            return false
        }
    }
    
    /// Returns true if this node evaluates to a matrix
    var isMatrixExpression: Bool {
        switch self {
        case .matrixRef, .matrixLiteral:
            return true
        case .binaryOp(let op, let left, let right):
            if case .multiply = op {
                return left.isMatrixExpression && right.isMatrixExpression
            }
            if case .add = op {
                return left.isMatrixExpression && right.isMatrixExpression
            }
            if case .subtract = op {
                return left.isMatrixExpression && right.isMatrixExpression
            }
            return false
        case .unaryOp(let op, _):
            return op.isMatrixOperator
        case .function(let fn, _):
            return fn == .identity
        default:
            return false
        }
    }
    
    /// Returns true if this node evaluates to a vector
    var isVectorExpression: Bool {
        switch self {
        case .vectorRef, .vectorLiteral:
            return true
        case .binaryOp(let op, let left, let right):
            if case .crossProduct = op {
                return true
            }
            if case .add = op {
                return left.isVectorExpression && right.isVectorExpression
            }
            if case .subtract = op {
                return left.isVectorExpression && right.isVectorExpression
            }
            return false
        case .unaryOp(let op, _):
            return op == .normalize
        default:
            return false
        }
    }
    
    /// Returns true if this node evaluates to a Base-N number
    var isBaseNExpression: Bool {
        switch self {
        case .baseNNumber:
            return true
        case .binaryOp(let op, _, _):
            return op.isBitwiseOperator
        case .unaryOp(let op, _):
            return op.isBitwiseOperator
        default:
            return false
        }
    }
    
    /// Returns true if this is a Phase 3 node type
    var isPhase3Node: Bool {
        switch self {
        case .complexNumber, .imaginaryUnit, .matrixRef, .matrixLiteral,
             .vectorRef, .vectorLiteral, .baseNNumber:
            return true
        case .binaryOp(let op, _, _):
            return op.isBitwiseOperator || op.isVectorOperator
        case .unaryOp(let op, _):
            return op.isBitwiseOperator || op.isComplexOperator ||
                   op.isMatrixOperator || op.isVectorOperator
        case .function(let fn, _), .function2(let fn, _, _):
            return fn.isComplexFunction || fn.isMatrixFunction || fn.isVectorFunction
        default:
            return false
        }
    }
    
    /// Returns true if this is a Phase 4 node type (statistics/distributions)
    var isPhase4Node: Bool {
        switch self {
        case .functionN(let fn, _):
            return fn.isPhase4Function
        case .listLiteral:
            return true
        case .statVariable:
            return true
        case .function(let fn, _), .function2(let fn, _, _):
            return fn.isPhase4Function
        default:
            return false
        }
    }
    
    /// Returns true if this node is a statistics expression
    var isStatisticsExpression: Bool {
        switch self {
        case .functionN(let fn, _):
            return fn.isStatisticsFunction
        case .statVariable:
            return true
        case .function(let fn, _):
            return fn.isStatisticsFunction || fn.isRegressionFunction
        default:
            return false
        }
    }
}

// MARK: - ASTNode Utility Methods

extension ASTNode {
    /// Returns the result type category for this node
    var resultType: ASTResultType {
        if isComplexExpression { return .complex }
        if isMatrixExpression { return .matrix }
        if isVectorExpression { return .vector }
        if isBaseNExpression { return .baseN }
        return .real
    }
    
    /// Returns true if this node contains any imaginary unit
    var containsImaginaryUnit: Bool {
        switch self {
        case .imaginaryUnit:
            return true
        case .complexNumber:
            return true
        case .binaryOp(_, let left, let right):
            return left.containsImaginaryUnit || right.containsImaginaryUnit
        case .unaryOp(_, let operand):
            return operand.containsImaginaryUnit
        case .function(_, let arg):
            return arg.containsImaginaryUnit
        case .function2(_, let arg1, let arg2):
            return arg1.containsImaginaryUnit || arg2.containsImaginaryUnit
        case .functionN(_, let args):
            return args.contains { $0.containsImaginaryUnit }
        case .listLiteral(let elements):
            return elements.contains { $0.containsImaginaryUnit }
        default:
            return false
        }
    }
    
    /// Returns all matrix references used in this node
    var matrixReferences: Set<MatrixRef> {
        switch self {
        case .matrixRef(let ref):
            return [ref]
        case .binaryOp(_, let left, let right):
            return left.matrixReferences.union(right.matrixReferences)
        case .unaryOp(_, let operand):
            return operand.matrixReferences
        case .function(_, let arg):
            return arg.matrixReferences
        case .function2(_, let arg1, let arg2):
            return arg1.matrixReferences.union(arg2.matrixReferences)
        case .matrixLiteral(let rows):
            return rows.flatMap { $0 }.reduce(into: Set<MatrixRef>()) {
                $0.formUnion($1.matrixReferences)
            }
        case .functionN(_, let args):
            return args.reduce(into: Set<MatrixRef>()) {
                $0.formUnion($1.matrixReferences)
            }
        case .listLiteral(let elements):
            return elements.reduce(into: Set<MatrixRef>()) {
                $0.formUnion($1.matrixReferences)
            }
        default:
            return []
        }
    }
    
    /// Returns all vector references used in this node
    var vectorReferences: Set<VectorRef> {
        switch self {
        case .vectorRef(let ref):
            return [ref]
        case .binaryOp(_, let left, let right):
            return left.vectorReferences.union(right.vectorReferences)
        case .unaryOp(_, let operand):
            return operand.vectorReferences
        case .function(_, let arg):
            return arg.vectorReferences
        case .function2(_, let arg1, let arg2):
            return arg1.vectorReferences.union(arg2.vectorReferences)
        case .vectorLiteral(let components):
            return components.reduce(into: Set<VectorRef>()) {
                $0.formUnion($1.vectorReferences)
            }
        case .functionN(_, let args):
            return args.reduce(into: Set<VectorRef>()) {
                $0.formUnion($1.vectorReferences)
            }
        case .listLiteral(let elements):
            return elements.reduce(into: Set<VectorRef>()) {
                $0.formUnion($1.vectorReferences)
            }
        default:
            return []
        }
    }
}

// MARK: - Result Type Enumeration

/// Categorizes the expected result type of an AST node
enum ASTResultType {
    case real
    case complex
    case matrix
    case vector
    case baseN
}
