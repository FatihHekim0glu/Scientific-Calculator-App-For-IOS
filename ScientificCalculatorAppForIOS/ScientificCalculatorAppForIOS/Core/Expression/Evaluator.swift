import Foundation

// MARK: - Calculator Result

/// Result of evaluating an expression - supports multiple return types
enum CalculatorResult: Equatable {
    case real(Double)
    case complex(ComplexNumber)
    case matrix(Matrix)
    case vector(Vector)
    case baseN(BaseNNumber)
    
    /// Attempts to convert to Double (for compatibility)
    var doubleValue: Double? {
        switch self {
        case .real(let value):
            return value
        case .complex(let c) where c.isReal:
            return c.real
        case .baseN(let n):
            return n.doubleValue
        default:
            return nil
        }
    }
    
    /// Returns the result as a ComplexNumber if applicable
    var complexValue: ComplexNumber? {
        switch self {
        case .real(let value):
            return ComplexNumber(value)
        case .complex(let c):
            return c
        default:
            return nil
        }
    }
    
    /// Returns the result as a Matrix if applicable
    var matrixValue: Matrix? {
        if case .matrix(let m) = self {
            return m
        }
        return nil
    }
    
    /// Returns the result as a Vector if applicable
    var vectorValue: Vector? {
        if case .vector(let v) = self {
            return v
        }
        return nil
    }
    
    /// Returns the result as a BaseNNumber if applicable
    var baseNValue: BaseNNumber? {
        if case .baseN(let n) = self {
            return n
        }
        return nil
    }
    
    /// Returns true if this is a real number result
    var isReal: Bool {
        if case .real = self { return true }
        if case .complex(let c) = self { return c.isReal }
        return false
    }
    
    /// Display string for the result
    var description: String {
        switch self {
        case .real(let value):
            return formatNumber(value)
        case .complex(let c):
            return c.description
        case .matrix(let m):
            return m.description
        case .vector(let v):
            return v.description
        case .baseN(let n):
            return n.toString()
        }
    }
    
    /// Formats a number for display
    private func formatNumber(_ value: Double) -> String {
        if value.isNaN {
            return "NaN"
        }
        if value.isInfinite {
            return value > 0 ? "∞" : "-∞"
        }
        if value == floor(value) && abs(value) < 1e15 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.10g", value)
    }
}

// MARK: - Evaluation Context

/// Context for expression evaluation containing variables and settings
struct EvaluationContext {
    // MARK: - Basic Settings
    
    var angleMode: AngleMode = .degrees
    var variables: [String: Double] = [:]
    var lastAnswer: Double = 0
    var previousAnswer: Double = 0
    
    // Secondary results from coordinate conversions
    var lastPolarTheta: Double = 0
    var lastRectY: Double = 0
    
    // MARK: - Phase 3 Additions
    
    /// Current calculator mode
    var calculatorMode: CalculatorMode = .calculate
    
    /// Last answer as complex number (for complex mode)
    var complexLastAnswer: ComplexNumber?
    
    /// Stored matrices (MatA, MatB, MatC, MatD)
    var matrices: [MatrixRef: Matrix] = [:]
    
    /// Stored vectors (VctA, VctB, VctC, VctD)
    var vectors: [VectorRef: Vector] = [:]
    
    /// Current number base for Base-N mode
    var currentBase: NumberBase = .decimal
    
    // MARK: - Variable Access
    
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
    
    /// Stores a complex answer
    mutating func storeComplexAnswer(_ value: ComplexNumber) {
        complexLastAnswer = value
        if value.isReal {
            storeAnswer(value.real)
        }
    }
    
    // MARK: - Matrix Access
    
    /// Gets a matrix by reference
    func getMatrix(_ ref: MatrixRef) throws -> Matrix {
        guard let matrix = matrices[ref] else {
            throw CalculatorError.undefinedVariable(ref.rawValue)
        }
        return matrix
    }
    
    /// Sets a matrix by reference
    mutating func setMatrix(_ ref: MatrixRef, _ matrix: Matrix) {
        matrices[ref] = matrix
    }
    
    // MARK: - Vector Access
    
    /// Gets a vector by reference
    func getVector(_ ref: VectorRef) throws -> Vector {
        guard let vector = vectors[ref] else {
            throw CalculatorError.undefinedVariable(ref.rawValue)
        }
        return vector
    }
    
    /// Sets a vector by reference
    mutating func setVector(_ ref: VectorRef, _ vector: Vector) {
        vectors[ref] = vector
    }
}

// MARK: - Evaluator

/// Evaluates an AST and returns a CalculatorResult
struct Evaluator {
    private var context: EvaluationContext
    
    init(context: EvaluationContext = EvaluationContext()) {
        self.context = context
    }
    
    /// Returns the current evaluation context
    var currentContext: EvaluationContext {
        context
    }
    
    /// Updates the context
    mutating func updateContext(_ newContext: EvaluationContext) {
        self.context = newContext
    }
    
    // MARK: - Main Evaluation
    
    /// Evaluates an AST node and returns a CalculatorResult
    mutating func evaluate(_ node: ASTNode) throws -> CalculatorResult {
        switch node {
        case .number(let value):
            if context.calculatorMode == .baseN {
                return .baseN(try BaseNNumber(value, base: context.currentBase))
            }
            return .real(value)
            
        case .constant(let mathConstant):
            return .real(mathConstant.value)
            
        case .scientificConstant(let constant):
            return .real(constant.value)
            
        case .variable(let name):
            return .real(try context.getVariable(name))
            
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
            
        // MARK: Phase 3 Cases
            
        case .complexNumber(let real, let imaginary):
            return .complex(ComplexNumber(real: real, imaginary: imaginary))
            
        case .imaginaryUnit:
            return .complex(ComplexNumber.i)
            
        case .matrixRef(let ref):
            return .matrix(try context.getMatrix(ref))
            
        case .vectorRef(let ref):
            return .vector(try context.getVector(ref))
            
        case .matrixLiteral(let rows):
            let evaluatedRows = try rows.map { row in
                try row.map { node -> Double in
                    let result = try evaluate(node)
                    guard let value = result.doubleValue else {
                        throw CalculatorError.mathError("Matrix elements must be real numbers")
                    }
                    return value
                }
            }
            return .matrix(try Matrix(evaluatedRows))
            
        case .vectorLiteral(let components):
            let evaluatedComponents = try components.map { node -> Double in
                let result = try evaluate(node)
                guard let value = result.doubleValue else {
                    throw CalculatorError.mathError("Vector components must be real numbers")
                }
                return value
            }
            return .vector(try Vector(evaluatedComponents))
            
        case .baseNNumber(let value, let base):
            return .baseN(BaseNNumber(value, base: base))
        }
    }
    
    /// Evaluates and returns a Double result (legacy compatibility)
    mutating func evaluateToDouble(_ node: ASTNode) throws -> Double {
        let result = try evaluate(node)
        guard let value = result.doubleValue else {
            throw CalculatorError.mathError("Expected numeric result")
        }
        return value
    }
    
    // MARK: - Binary Operations
    
    private mutating func evaluateBinaryOp(_ op: BinaryOperator, left: ASTNode, right: ASTNode) throws -> CalculatorResult {
        let leftResult = try evaluate(left)
        let rightResult = try evaluate(right)
        
        // Dispatch based on operand types
        switch (leftResult, rightResult) {
        case (.complex(let lc), .complex(let rc)):
            return try evaluateComplexBinaryOp(op, lhs: lc, rhs: rc)
            
        case (.complex(let lc), .real(let rv)):
            return try evaluateComplexBinaryOp(op, lhs: lc, rhs: ComplexNumber(rv))
            
        case (.real(let lv), .complex(let rc)):
            return try evaluateComplexBinaryOp(op, lhs: ComplexNumber(lv), rhs: rc)
            
        case (.matrix(let lm), .matrix(let rm)):
            return try evaluateMatrixBinaryOp(op, lhs: lm, rhs: rm)
            
        case (.matrix(let m), .real(let s)):
            return try evaluateMatrixScalarOp(op, matrix: m, scalar: s)
            
        case (.real(let s), .matrix(let m)):
            return try evaluateScalarMatrixOp(op, scalar: s, matrix: m)
            
        case (.vector(let lv), .vector(let rv)):
            return try evaluateVectorBinaryOp(op, lhs: lv, rhs: rv)
            
        case (.vector(let v), .real(let s)):
            return try evaluateVectorScalarOp(op, vector: v, scalar: s)
            
        case (.real(let s), .vector(let v)):
            return try evaluateScalarVectorOp(op, scalar: s, vector: v)
            
        case (.baseN(let ln), .baseN(let rn)):
            return try evaluateBaseNBinaryOp(op, lhs: ln, rhs: rn)
            
        case (.baseN(let n), .real(let v)):
            let rn = try BaseNNumber(v, base: n.base)
            return try evaluateBaseNBinaryOp(op, lhs: n, rhs: rn)
            
        case (.real(let v), .baseN(let n)):
            let ln = try BaseNNumber(v, base: n.base)
            return try evaluateBaseNBinaryOp(op, lhs: ln, rhs: n)
            
        case (.real(let lv), .real(let rv)):
            return try evaluateRealBinaryOp(op, lhs: lv, rhs: rv)
            
        default:
            throw CalculatorError.mathError("Incompatible types for operator \(op.rawValue)")
        }
    }
    
    // MARK: - Real Binary Operations
    
    private func evaluateRealBinaryOp(_ op: BinaryOperator, lhs: Double, rhs: Double) throws -> CalculatorResult {
        switch op {
        case .add:
            return .real(lhs + rhs)
            
        case .subtract:
            return .real(lhs - rhs)
            
        case .multiply:
            return .real(lhs * rhs)
            
        case .divide:
            guard abs(rhs) >= 1e-15 else {
                throw CalculatorError.divisionByZero
            }
            return .real(lhs / rhs)
            
        case .power:
            if lhs < 0 && floor(rhs) != rhs {
                // Negative base with non-integer exponent produces complex result
                let c = ComplexNumber(lhs)
                return .complex(c.power(rhs))
            }
            let result = pow(lhs, rhs)
            guard result.isFinite else {
                throw CalculatorError.overflow
            }
            return .real(result)
            
        case .permutation:
            return .real(try Combinatorics.permutation(n: lhs, r: rhs))
            
        case .combination:
            return .real(try Combinatorics.combination(n: lhs, r: rhs))
            
        case .modulo:
            return .real(try Combinatorics.mod(lhs, rhs))
            
        case .nthRoot:
            return .real(try NumberFunctions.nthRoot(index: lhs, radicand: rhs))
            
        case .logBase:
            return .real(try NumberFunctions.logBase(lhs, of: rhs))
            
        case .bitwiseAnd, .bitwiseOr, .bitwiseXor, .bitwiseXnor, .leftShift, .rightShift:
            // Bitwise ops on reals: convert to BaseN
            let ln = try BaseNNumber(lhs, base: context.currentBase)
            let rn = try BaseNNumber(rhs, base: context.currentBase)
            return try evaluateBaseNBinaryOp(op, lhs: ln, rhs: rn)
            
        case .dotProduct, .crossProduct:
            throw CalculatorError.mathError("Vector operators require vector operands")
        }
    }
    
    // MARK: - Complex Binary Operations
    
    private func evaluateComplexBinaryOp(_ op: BinaryOperator, lhs: ComplexNumber, rhs: ComplexNumber) throws -> CalculatorResult {
        switch op {
        case .add:
            return .complex(lhs + rhs)
            
        case .subtract:
            return .complex(lhs - rhs)
            
        case .multiply:
            return .complex(lhs * rhs)
            
        case .divide:
            return .complex(try lhs / rhs)
            
        case .power:
            if rhs.isReal && rhs.real == floor(rhs.real) {
                return .complex(lhs.power(Int(rhs.real)))
            }
            return .complex(lhs.power(rhs.real))
            
        default:
            throw CalculatorError.mathError("Operator \(op.rawValue) not supported for complex numbers")
        }
    }
    
    // MARK: - Matrix Binary Operations
    
    private func evaluateMatrixBinaryOp(_ op: BinaryOperator, lhs: Matrix, rhs: Matrix) throws -> CalculatorResult {
        switch op {
        case .add:
            return .matrix(try lhs + rhs)
            
        case .subtract:
            return .matrix(try lhs - rhs)
            
        case .multiply:
            return .matrix(try lhs * rhs)
            
        default:
            throw CalculatorError.mathError("Operator \(op.rawValue) not supported for matrices")
        }
    }
    
    private func evaluateMatrixScalarOp(_ op: BinaryOperator, matrix: Matrix, scalar: Double) throws -> CalculatorResult {
        switch op {
        case .multiply:
            return .matrix(matrix * scalar)
            
        case .divide:
            return .matrix(try matrix / scalar)
            
        case .power:
            guard scalar == floor(scalar) && scalar >= 0 else {
                throw CalculatorError.mathError("Matrix power must be a non-negative integer")
            }
            return .matrix(try matrix.power(Int(scalar)))
            
        default:
            throw CalculatorError.mathError("Operator \(op.rawValue) not supported for matrix-scalar operation")
        }
    }
    
    private func evaluateScalarMatrixOp(_ op: BinaryOperator, scalar: Double, matrix: Matrix) throws -> CalculatorResult {
        switch op {
        case .multiply:
            return .matrix(scalar * matrix)
            
        default:
            throw CalculatorError.mathError("Operator \(op.rawValue) not supported for scalar-matrix operation")
        }
    }
    
    // MARK: - Vector Binary Operations
    
    private func evaluateVectorBinaryOp(_ op: BinaryOperator, lhs: Vector, rhs: Vector) throws -> CalculatorResult {
        switch op {
        case .add:
            return .vector(try lhs + rhs)
            
        case .subtract:
            return .vector(try lhs - rhs)
            
        case .dotProduct:
            return .real(try Vector.dot(lhs, rhs))
            
        case .crossProduct:
            return .vector(try Vector.cross(lhs, rhs))
            
        case .multiply:
            // Component-wise multiplication (Hadamard product) or interpret as dot product
            return .real(try Vector.dot(lhs, rhs))
            
        default:
            throw CalculatorError.mathError("Operator \(op.rawValue) not supported for vectors")
        }
    }
    
    private func evaluateVectorScalarOp(_ op: BinaryOperator, vector: Vector, scalar: Double) throws -> CalculatorResult {
        switch op {
        case .multiply:
            return .vector(vector * scalar)
            
        case .divide:
            return .vector(try vector / scalar)
            
        default:
            throw CalculatorError.mathError("Operator \(op.rawValue) not supported for vector-scalar operation")
        }
    }
    
    private func evaluateScalarVectorOp(_ op: BinaryOperator, scalar: Double, vector: Vector) throws -> CalculatorResult {
        switch op {
        case .multiply:
            return .vector(scalar * vector)
            
        default:
            throw CalculatorError.mathError("Operator \(op.rawValue) not supported for scalar-vector operation")
        }
    }
    
    // MARK: - Base-N Binary Operations
    
    private func evaluateBaseNBinaryOp(_ op: BinaryOperator, lhs: BaseNNumber, rhs: BaseNNumber) throws -> CalculatorResult {
        switch op {
        case .add:
            return .baseN(lhs + rhs)
            
        case .subtract:
            return .baseN(lhs - rhs)
            
        case .multiply:
            return .baseN(lhs * rhs)
            
        case .divide:
            return .baseN(try lhs / rhs)
            
        case .modulo:
            return .baseN(try lhs % rhs)
            
        case .bitwiseAnd:
            return .baseN(lhs & rhs)
            
        case .bitwiseOr:
            return .baseN(lhs | rhs)
            
        case .bitwiseXor:
            return .baseN(lhs ^ rhs)
            
        case .bitwiseXnor:
            return .baseN(BaseNNumber.xnor(lhs, rhs))
            
        case .leftShift:
            guard rhs.value >= 0 else {
                throw CalculatorError.domainError("Shift amount must be non-negative")
            }
            return .baseN(lhs << Int(rhs.value))
            
        case .rightShift:
            guard rhs.value >= 0 else {
                throw CalculatorError.domainError("Shift amount must be non-negative")
            }
            return .baseN(lhs >> Int(rhs.value))
            
        default:
            throw CalculatorError.mathError("Operator \(op.rawValue) not supported in Base-N mode")
        }
    }
    
    // MARK: - Unary Operations
    
    private mutating func evaluateUnaryOp(_ op: UnaryOperator, operand: ASTNode) throws -> CalculatorResult {
        let result = try evaluate(operand)
        
        switch result {
        case .real(let value):
            return try evaluateRealUnaryOp(op, operand: value)
            
        case .complex(let c):
            return try evaluateComplexUnaryOp(op, operand: c)
            
        case .matrix(let m):
            return try evaluateMatrixUnaryOp(op, operand: m)
            
        case .vector(let v):
            return try evaluateVectorUnaryOp(op, operand: v)
            
        case .baseN(let n):
            return try evaluateBaseNUnaryOp(op, operand: n)
        }
    }
    
    // MARK: - Real Unary Operations
    
    private func evaluateRealUnaryOp(_ op: UnaryOperator, operand: Double) throws -> CalculatorResult {
        switch op {
        case .negate:
            return .real(-operand)
            
        case .factorial:
            return .real(try Combinatorics.factorial(operand))
            
        case .reciprocal:
            return .real(try NumberFunctions.reciprocal(operand))
            
        case .square:
            return .real(try NumberFunctions.square(operand))
            
        case .cube:
            return .real(try NumberFunctions.cube(operand))
            
        case .percent:
            return .real(NumberFunctions.percent(operand))
            
        case .bitwiseNot:
            let n = try BaseNNumber(operand, base: context.currentBase)
            return .baseN(~n)
            
        case .bitwiseNeg:
            let n = try BaseNNumber(operand, base: context.currentBase)
            return .baseN(-n)
            
        case .conjugate, .realPart, .imagPart, .argument:
            // Promote to complex
            let c = ComplexNumber(operand)
            return try evaluateComplexUnaryOp(op, operand: c)
            
        case .transpose, .determinant, .matrixInverse:
            throw CalculatorError.mathError("Matrix operator requires matrix operand")
            
        case .vectorMagnitude, .normalize:
            throw CalculatorError.mathError("Vector operator requires vector operand")
        }
    }
    
    // MARK: - Complex Unary Operations
    
    private func evaluateComplexUnaryOp(_ op: UnaryOperator, operand: ComplexNumber) throws -> CalculatorResult {
        switch op {
        case .negate:
            return .complex(-operand)
            
        case .conjugate:
            return .complex(operand.conjugate())
            
        case .realPart:
            return .real(operand.real)
            
        case .imagPart:
            return .real(operand.imaginary)
            
        case .argument:
            return .real(context.angleMode.fromRadians(operand.argument))
            
        case .reciprocal:
            return .complex(try operand.reciprocal())
            
        case .square:
            return .complex(operand.power(2))
            
        case .cube:
            return .complex(operand.power(3))
            
        default:
            throw CalculatorError.mathError("Operator \(op.rawValue) not supported for complex numbers")
        }
    }
    
    // MARK: - Matrix Unary Operations
    
    private func evaluateMatrixUnaryOp(_ op: UnaryOperator, operand: Matrix) throws -> CalculatorResult {
        switch op {
        case .negate:
            return .matrix(-operand)
            
        case .transpose:
            return .matrix(operand.transpose)
            
        case .determinant:
            return .real(try operand.determinant())
            
        case .matrixInverse, .reciprocal:
            return .matrix(try operand.inverse())
            
        default:
            throw CalculatorError.mathError("Operator \(op.rawValue) not supported for matrices")
        }
    }
    
    // MARK: - Vector Unary Operations
    
    private func evaluateVectorUnaryOp(_ op: UnaryOperator, operand: Vector) throws -> CalculatorResult {
        switch op {
        case .negate:
            return .vector(-operand)
            
        case .vectorMagnitude:
            return .real(operand.magnitude)
            
        case .normalize:
            return .vector(try operand.normalized())
            
        default:
            throw CalculatorError.mathError("Operator \(op.rawValue) not supported for vectors")
        }
    }
    
    // MARK: - Base-N Unary Operations
    
    private func evaluateBaseNUnaryOp(_ op: UnaryOperator, operand: BaseNNumber) throws -> CalculatorResult {
        switch op {
        case .negate, .bitwiseNeg:
            return .baseN(-operand)
            
        case .bitwiseNot:
            return .baseN(~operand)
            
        default:
            throw CalculatorError.mathError("Operator \(op.rawValue) not supported in Base-N mode")
        }
    }
    
    // MARK: - Single-Argument Function Evaluation
    
    private mutating func evaluateFunction(_ function: MathFunction, argument: ASTNode) throws -> CalculatorResult {
        let argResult = try evaluate(argument)
        
        // Handle complex-specific functions
        if function.isComplexFunction {
            guard let c = argResult.complexValue else {
                throw CalculatorError.mathError("Complex function requires complex-compatible argument")
            }
            return try evaluateComplexFunction(function, argument: c)
        }
        
        // Handle matrix-specific functions
        if function.isMatrixFunction {
            return try evaluateMatrixFunction(function, argument: argResult)
        }
        
        // Handle standard functions with real values
        guard let value = argResult.doubleValue else {
            // Try complex evaluation for standard functions
            if let c = argResult.complexValue {
                return try evaluateStandardFunctionWithComplex(function, argument: c)
            }
            throw CalculatorError.mathError("Function \(function.rawValue) requires numeric argument")
        }
        
        return try evaluateStandardFunction(function, argument: value)
    }
    
    // MARK: - Standard Functions (Real)
    
    private func evaluateStandardFunction(_ function: MathFunction, argument value: Double) throws -> CalculatorResult {
        switch function {
        // Trigonometric functions
        case .sin:
            return .real(sin(context.angleMode.toRadians(value)))
            
        case .cos:
            return .real(cos(context.angleMode.toRadians(value)))
            
        case .tan:
            let radians = context.angleMode.toRadians(value)
            let cosValue = cos(radians)
            guard abs(cosValue) >= 1e-15 else {
                throw CalculatorError.domainError("Tangent undefined at this angle")
            }
            return .real(sin(radians) / cosValue)
            
        // Inverse trigonometric functions
        case .asin:
            guard value >= -1 && value <= 1 else {
                throw CalculatorError.domainError("asin requires input in [-1, 1]")
            }
            return .real(context.angleMode.fromRadians(Foundation.asin(value)))
            
        case .acos:
            guard value >= -1 && value <= 1 else {
                throw CalculatorError.domainError("acos requires input in [-1, 1]")
            }
            return .real(context.angleMode.fromRadians(Foundation.acos(value)))
            
        case .atan:
            return .real(context.angleMode.fromRadians(Foundation.atan(value)))
            
        // Hyperbolic functions
        case .sinh:
            return .real(Foundation.sinh(value))
            
        case .cosh:
            return .real(Foundation.cosh(value))
            
        case .tanh:
            return .real(Foundation.tanh(value))
            
        // Inverse hyperbolic functions
        case .asinh:
            return .real(Foundation.asinh(value))
            
        case .acosh:
            guard value >= 1 else {
                throw CalculatorError.domainError("acosh requires input >= 1")
            }
            return .real(Foundation.acosh(value))
            
        case .atanh:
            guard value > -1 && value < 1 else {
                throw CalculatorError.domainError("atanh requires input in (-1, 1)")
            }
            return .real(Foundation.atanh(value))
            
        // Logarithmic functions
        case .log:
            guard value > 0 else {
                throw CalculatorError.domainError("log requires positive input")
            }
            return .real(log10(value))
            
        case .ln:
            guard value > 0 else {
                throw CalculatorError.domainError("ln requires positive input")
            }
            return .real(Foundation.log(value))
            
        // Root functions
        case .sqrt:
            if value < 0 {
                // Return complex result for negative input
                let c = ComplexNumber(value)
                return .complex(c.squareRoot())
            }
            return .real(Foundation.sqrt(value))
            
        case .cbrt:
            return .real(Foundation.cbrt(value))
            
        // Basic functions
        case .abs:
            return .real(Swift.abs(value))
            
        case .exp:
            let result = Foundation.exp(value)
            guard result.isFinite else {
                throw CalculatorError.overflow
            }
            return .real(result)
            
        // Number functions (Phase 2)
        case .intPart:
            return .real(NumberFunctions.integerPart(value))
            
        case .fracPart:
            return .real(NumberFunctions.fractionalPart(value))
            
        case .floor:
            return .real(NumberFunctions.floor(value))
            
        case .ceil:
            return .real(NumberFunctions.ceil(value))
            
        case .round:
            return .real(NumberFunctions.roundToDisplayPrecision(value))
            
        // Power functions (Phase 2)
        case .tenPow:
            return .real(try NumberFunctions.tenPow(value))
            
        // Angle conversions (Phase 2)
        case .degToRad:
            return .real(AngleConversions.degreesToRadians(value))
            
        case .radToDeg:
            return .real(AngleConversions.radiansToDegrees(value))
            
        case .degToGrad:
            return .real(AngleConversions.degreesToGradians(value))
            
        case .gradToDeg:
            return .real(AngleConversions.gradiansToDegrees(value))
            
        case .dmsToDecimal:
            return .real(AngleConversions.parseDMSEncoded(value).decimalDegrees)
            
        case .decimalToDms:
            return .real(AngleConversions.encodeDMS(AngleConversions.decimalToDMS(value)))
            
        // Two-argument functions called with single argument - throw error
        case .randomInt, .pol, .rec, .gcd, .lcm, .vectorAngle, .vectorProject, .baseConvert:
            throw CalculatorError.syntaxError("\(function.rawValue) requires two arguments")
            
        // Zero-argument function called with argument - throw error
        case .random:
            throw CalculatorError.syntaxError("random() takes no arguments")
            
        // Complex and matrix functions handled elsewhere
        case .complexSqrt, .complexExp, .complexLn, .complexSin, .complexCos, .complexTan,
             .identity, .trace:
            throw CalculatorError.syntaxError("\(function.rawValue) requires special handling")
        }
    }
    
    // MARK: - Complex Functions
    
    private func evaluateComplexFunction(_ function: MathFunction, argument: ComplexNumber) throws -> CalculatorResult {
        switch function {
        case .complexSqrt:
            return .complex(argument.squareRoot())
            
        case .complexExp:
            return .complex(argument.exp())
            
        case .complexLn:
            return .complex(try argument.ln())
            
        case .complexSin:
            return .complex(argument.sin())
            
        case .complexCos:
            return .complex(argument.cos())
            
        case .complexTan:
            return .complex(try argument.tan())
            
        default:
            throw CalculatorError.mathError("Function \(function.rawValue) is not a complex function")
        }
    }
    
    // MARK: - Standard Functions with Complex Arguments
    
    private func evaluateStandardFunctionWithComplex(_ function: MathFunction, argument: ComplexNumber) throws -> CalculatorResult {
        switch function {
        case .sin:
            return .complex(argument.sin())
            
        case .cos:
            return .complex(argument.cos())
            
        case .tan:
            return .complex(try argument.tan())
            
        case .sinh:
            return .complex(argument.sinh())
            
        case .cosh:
            return .complex(argument.cosh())
            
        case .tanh:
            return .complex(try argument.tanh())
            
        case .exp:
            return .complex(argument.exp())
            
        case .ln:
            return .complex(try argument.ln())
            
        case .sqrt:
            return .complex(argument.squareRoot())
            
        case .abs:
            return .real(argument.magnitude)
            
        default:
            throw CalculatorError.mathError("Function \(function.rawValue) not supported for complex numbers")
        }
    }
    
    // MARK: - Matrix Functions
    
    private mutating func evaluateMatrixFunction(_ function: MathFunction, argument: CalculatorResult) throws -> CalculatorResult {
        switch function {
        case .identity:
            guard let size = argument.doubleValue else {
                throw CalculatorError.mathError("Identity requires a numeric size")
            }
            guard size == floor(size) && size > 0 && size <= 4 else {
                throw CalculatorError.domainError("Identity size must be integer 1-4")
            }
            return .matrix(try Matrix.identity(size: Int(size)))
            
        case .trace:
            guard let matrix = argument.matrixValue else {
                throw CalculatorError.mathError("Trace requires a matrix argument")
            }
            return .real(try matrix.trace())
            
        default:
            throw CalculatorError.mathError("Function \(function.rawValue) is not a matrix function")
        }
    }
    
    // MARK: - Two-Argument Function Evaluation
    
    private mutating func evaluateFunction2(_ function: MathFunction, arg1: ASTNode, arg2: ASTNode) throws -> CalculatorResult {
        // Handle vector functions specially
        if function.isVectorFunction {
            let result1 = try evaluate(arg1)
            let result2 = try evaluate(arg2)
            
            guard let v1 = result1.vectorValue, let v2 = result2.vectorValue else {
                throw CalculatorError.mathError("\(function.rawValue) requires vector arguments")
            }
            
            return try evaluateVectorFunction2(function, v1: v1, v2: v2)
        }
        
        // Standard two-argument functions need Double values
        let value1 = try evaluateToDouble(arg1)
        let value2 = try evaluateToDouble(arg2)
        
        switch function {
        case .randomInt:
            return .real(try NumberFunctions.randomInt(min: value1, max: value2))
            
        case .pol:
            let result = CoordinateConversions.rectangularToPolar(x: value1, y: value2, angleMode: context.angleMode)
            context.lastPolarTheta = result.theta
            return .real(result.r)
            
        case .rec:
            let result = CoordinateConversions.polarToRectangular(r: value1, theta: value2, angleMode: context.angleMode)
            context.lastRectY = result.y
            return .real(result.x)
            
        case .gcd:
            return .real(try Combinatorics.gcd(value1, value2))
            
        case .lcm:
            return .real(try Combinatorics.lcm(value1, value2))
            
        case .baseConvert:
            // Special base conversion: value1 is the number, value2 is the target base
            guard let targetBaseValue = Int(exactly: value2),
                  let targetBase = NumberBase(rawValue: targetBaseValue) else {
                throw CalculatorError.domainError("Invalid target base")
            }
            let n = try BaseNNumber(value1, base: context.currentBase)
            return .baseN(n.convert(to: targetBase))
            
        default:
            throw CalculatorError.syntaxError("\(function.rawValue) is not a two-argument function")
        }
    }
    
    // MARK: - Vector Two-Argument Functions
    
    private func evaluateVectorFunction2(_ function: MathFunction, v1: Vector, v2: Vector) throws -> CalculatorResult {
        switch function {
        case .vectorAngle:
            return .real(try Vector.angle(v1, v2, angleMode: context.angleMode))
            
        case .vectorProject:
            return .vector(try v1.project(onto: v2))
            
        default:
            throw CalculatorError.mathError("Function \(function.rawValue) is not a vector function")
        }
    }
    
    // MARK: - Zero-Argument Function Evaluation
    
    private func evaluateFunction0(_ function: MathFunction) throws -> CalculatorResult {
        switch function {
        case .random:
            return .real(NumberFunctions.random())
            
        default:
            throw CalculatorError.syntaxError("\(function.rawValue) is not a zero-argument function")
        }
    }
}

// MARK: - Evaluator Extensions for Convenience

extension Evaluator {
    
    /// Evaluates an expression string and returns a CalculatorResult
    mutating func evaluateExpression(_ expression: String) throws -> CalculatorResult {
        let lexer = Lexer(expression)
        let tokens = try lexer.tokenize()
        var parser = Parser(tokens: tokens)
        let ast = try parser.parse()
        return try evaluate(ast)
    }
    
    /// Checks if an AST would produce a complex result
    func wouldProduceComplex(_ node: ASTNode) -> Bool {
        node.isComplexExpression || node.containsImaginaryUnit
    }
    
    /// Checks if an AST would produce a matrix result
    func wouldProduceMatrix(_ node: ASTNode) -> Bool {
        node.isMatrixExpression
    }
    
    /// Checks if an AST would produce a vector result
    func wouldProduceVector(_ node: ASTNode) -> Bool {
        node.isVectorExpression
    }
}
