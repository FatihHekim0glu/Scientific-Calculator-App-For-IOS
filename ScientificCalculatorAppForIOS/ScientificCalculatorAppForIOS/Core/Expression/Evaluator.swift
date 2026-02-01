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
    
    // MARK: - Phase 4 Additions
    
    /// Statistical data for statistics mode calculations
    var statisticalData: StatisticalData?
    
    /// Cached one-variable statistics result
    var cachedOneVarStats: OneVariableStatistics?
    
    /// Cached two-variable statistics result  
    var cachedTwoVarStats: TwoVariableStatistics?
    
    /// Selected regression type for statistics mode
    var selectedRegressionType: RegressionType = .linear
    
    /// Cached regression result
    var cachedRegressionResult: RegressionResult?
    
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
    
    // MARK: - Phase 4: Statistics Access
    
    /// Gets a statistical variable by name (Σx, x̄, σx, etc.)
    mutating func getStatVariable(_ name: String) throws -> Double {
        guard let data = statisticalData else {
            throw CalculatorError.invalidInput("No statistical data available")
        }
        
        // Ensure stats are calculated
        if cachedOneVarStats == nil {
            cachedOneVarStats = try Statistics.oneVariable(data: data)
        }
        
        guard let stats = cachedOneVarStats else {
            throw CalculatorError.invalidInput("Cannot calculate statistics")
        }
        
        switch name {
        case "n":
            return Double(stats.n)
        case "Σx", "sumX":
            return stats.sum
        case "Σx²", "sumX2":
            return stats.sumOfSquares
        case "x̄", "meanX":
            return stats.mean
        case "σx", "popStdDevX":
            return stats.populationStdDev
        case "sx", "sampleStdDevX":
            return stats.sampleStdDev
        case "minX":
            return stats.min
        case "maxX":
            return stats.max
        case "Med", "median":
            return stats.median
        case "Q₁", "Q1":
            return stats.q1
        case "Q₃", "Q3":
            return stats.q3
        default:
            return try getTwoVarStatVariable(name)
        }
    }
    
    /// Gets a 2-variable statistical variable
    private mutating func getTwoVarStatVariable(_ name: String) throws -> Double {
        guard let data = statisticalData, data.isTwoVariable else {
            throw CalculatorError.invalidInput("2-variable statistics requires Y data")
        }
        
        // Ensure 2-var stats are calculated
        if cachedTwoVarStats == nil {
            cachedTwoVarStats = try Statistics.twoVariable(data: data)
        }
        
        guard let twoVarStats = cachedTwoVarStats else {
            throw CalculatorError.invalidInput("Cannot calculate 2-variable statistics")
        }
        
        switch name {
        case "Σy", "sumY":
            return twoVarStats.yStats.sum
        case "Σy²", "sumY2":
            return twoVarStats.yStats.sumOfSquares
        case "ȳ", "meanY":
            return twoVarStats.yStats.mean
        case "σy", "popStdDevY":
            return twoVarStats.yStats.populationStdDev
        case "sy", "sampleStdDevY":
            return twoVarStats.yStats.sampleStdDev
        case "minY":
            return twoVarStats.yStats.min
        case "maxY":
            return twoVarStats.yStats.max
        case "Σxy", "sumXY":
            return twoVarStats.sumOfProducts
        case "r", "correlation":
            return twoVarStats.correlation
        case "r²", "rSquared":
            return twoVarStats.rSquared
        case "a", "regA":
            return try getRegressionCoefficient("a")
        case "b", "regB":
            return try getRegressionCoefficient("b")
        case "c", "regC":
            return try getRegressionCoefficient("c")
        default:
            throw CalculatorError.undefinedVariable(name)
        }
    }
    
    /// Gets a regression coefficient
    private mutating func getRegressionCoefficient(_ name: String) throws -> Double {
        guard let data = statisticalData, data.isTwoVariable,
              let xValues = Optional(data.xValues),
              let yValues = data.yValues else {
            throw CalculatorError.invalidInput("Regression requires 2-variable data")
        }
        
        // Ensure regression is calculated
        if cachedRegressionResult == nil {
            cachedRegressionResult = try Regression.regression(selectedRegressionType, xValues: xValues, yValues: yValues)
        }
        
        guard let regression = cachedRegressionResult else {
            throw CalculatorError.invalidInput("Cannot calculate regression")
        }
        
        switch name {
        case "a":
            return regression.a
        case "b":
            return regression.b
        case "c":
            guard let c = regression.c else {
                throw CalculatorError.invalidInput("Coefficient c only available for quadratic regression")
            }
            return c
        default:
            throw CalculatorError.undefinedVariable(name)
        }
    }
    
    /// Invalidates cached statistics when data changes
    mutating func invalidateStatisticsCache() {
        cachedOneVarStats = nil
        cachedTwoVarStats = nil
        cachedRegressionResult = nil
    }
    
    /// Sets statistical data and invalidates cache
    mutating func setStatisticalData(_ data: StatisticalData?) {
        statisticalData = data
        invalidateStatisticsCache()
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
            
        // MARK: Phase 4 Cases
            
        case .functionN(let function, let arguments):
            return try evaluateFunctionN(function, arguments: arguments)
            
        case .listLiteral:
            // Lists are handled by functions that accept them
            throw CalculatorError.syntaxError("List literals must be used as function arguments")
            
        case .statVariable(let statVar):
            return .real(try context.getStatVariable(statVar.rawValue))
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
        // Handle Phase 4 statistics functions with single argument
        if function.isStatisticsFunction {
            let argResult = try evaluate(argument)
            guard let value = argResult.doubleValue else {
                throw CalculatorError.mathError("Statistics functions require numeric arguments")
            }
            return try evaluateStatisticsFunction(function, values: [value])
        }
        
        // Handle Phase 4 regression functions
        if function.isRegressionFunction {
            let argResult = try evaluate(argument)
            guard let value = argResult.doubleValue else {
                throw CalculatorError.mathError("Regression functions require numeric arguments")
            }
            return try evaluateRegressionFunction(function, argument: value)
        }
        
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
            
        // Statistics functions require multiple arguments
        case .mean, .sum, .sumSquares, .popStdDev, .sampleStdDev, .variance,
             .minimum, .maximum, .median, .quartile1, .quartile3, .count,
             .covariance, .correlation:
            throw CalculatorError.syntaxError("\(function.rawValue) requires a list of values")
            
        // Distribution functions require multiple arguments
        case .normalPdf, .normalCdf, .invNorm, .binomialPdf, .binomialCdf,
             .poissonPdf, .poissonCdf:
            throw CalculatorError.syntaxError("\(function.rawValue) requires multiple arguments")
            
        // Regression functions require data context
        case .linRegA, .linRegB, .estimateY, .estimateX:
            throw CalculatorError.syntaxError("\(function.rawValue) requires regression data")
            
        // Calculus functions require special parsing
        case .integrate, .differentiate, .summation, .product:
            throw CalculatorError.syntaxError("\(function.rawValue) requires expression and bounds")
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
            return .complex(argument.complexSinh())
            
        case .cosh:
            return .complex(argument.complexCosh())
            
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
    
    // MARK: - Phase 4: Statistics Function Evaluation
    
    /// Evaluates statistical functions that operate on lists of values
    private func evaluateStatisticsFunction(_ function: MathFunction, values: [Double]) throws -> CalculatorResult {
        guard !values.isEmpty else {
            throw CalculatorError.invalidInput("Statistics functions require at least one value")
        }
        
        switch function {
        case .mean:
            return .real(Statistics.mean(values))
            
        case .sum:
            return .real(Statistics.sum(values))
            
        case .sumSquares:
            return .real(Statistics.sumOfSquares(values))
            
        case .popStdDev:
            guard values.count >= 1 else {
                throw CalculatorError.invalidInput("Standard deviation requires at least 1 value")
            }
            return .real(Statistics.populationStdDev(values))
            
        case .sampleStdDev:
            guard values.count >= 2 else {
                throw CalculatorError.invalidInput("Sample standard deviation requires at least 2 values")
            }
            return .real(Statistics.sampleStdDev(values))
            
        case .variance:
            guard values.count >= 1 else {
                throw CalculatorError.invalidInput("Variance requires at least 1 value")
            }
            let sd = Statistics.populationStdDev(values)
            return .real(sd * sd)
            
        case .minimum:
            guard let minVal = values.min() else {
                throw CalculatorError.invalidInput("Min requires at least one value")
            }
            return .real(minVal)
            
        case .maximum:
            guard let maxVal = values.max() else {
                throw CalculatorError.invalidInput("Max requires at least one value")
            }
            return .real(maxVal)
            
        case .median:
            return .real(Statistics.median(values))
            
        case .quartile1:
            return .real(try Statistics.quartile(values, q: 1))
            
        case .quartile3:
            return .real(try Statistics.quartile(values, q: 3))
            
        case .count:
            return .real(Double(values.count))
            
        default:
            throw CalculatorError.syntaxError("\(function.rawValue) is not a statistics function")
        }
    }
    
    /// Evaluates two-variable statistics functions (covariance, correlation)
    private func evaluateTwoVarStatisticsFunction(_ function: MathFunction, xValues: [Double], yValues: [Double]) throws -> CalculatorResult {
        guard xValues.count == yValues.count else {
            throw CalculatorError.invalidInput("X and Y arrays must have the same length")
        }
        
        guard xValues.count >= 2 else {
            throw CalculatorError.invalidInput("\(function.rawValue) requires at least 2 data points")
        }
        
        switch function {
        case .covariance:
            return .real(try Statistics.covariance(xValues, yValues, frequencies: nil, population: true))
            
        case .correlation:
            return .real(try Statistics.correlation(xValues, yValues, frequencies: nil))
            
        default:
            throw CalculatorError.syntaxError("\(function.rawValue) is not a two-variable statistics function")
        }
    }
    
    // MARK: - Phase 4: Distribution Function Evaluation
    
    /// Evaluates distribution functions with their specific argument counts
    private func evaluateDistributionFunction(_ function: MathFunction, args: [Double]) throws -> CalculatorResult {
        switch function {
        // Normal distribution functions: (x, μ, σ)
        case .normalPdf:
            guard args.count == 3 else {
                throw CalculatorError.invalidInput("normalPdf requires 3 arguments: x, μ, σ")
            }
            let dist = try NormalDistribution(mean: args[1], stdDev: args[2])
            return .real(dist.pdf(args[0]))
            
        case .normalCdf:
            guard args.count == 3 else {
                throw CalculatorError.invalidInput("normalCdf requires 3 arguments: x, μ, σ")
            }
            let dist = try NormalDistribution(mean: args[1], stdDev: args[2])
            return .real(dist.cdf(args[0]))
            
        case .invNorm:
            guard args.count == 3 else {
                throw CalculatorError.invalidInput("invNorm requires 3 arguments: p, μ, σ")
            }
            let dist = try NormalDistribution(mean: args[1], stdDev: args[2])
            return .real(try dist.inverseCdf(args[0]))
            
        // Binomial distribution functions: (k, n, p)
        case .binomialPdf:
            guard args.count == 3 else {
                throw CalculatorError.invalidInput("binomialPdf requires 3 arguments: k, n, p")
            }
            let k = Int(args[0])
            let n = Int(args[1])
            let p = args[2]
            let dist = try BinomialDistribution(trials: n, probability: p)
            return .real(try dist.pmf(k))
            
        case .binomialCdf:
            guard args.count == 3 else {
                throw CalculatorError.invalidInput("binomialCdf requires 3 arguments: k, n, p")
            }
            let k = Int(args[0])
            let n = Int(args[1])
            let p = args[2]
            let dist = try BinomialDistribution(trials: n, probability: p)
            return .real(try dist.cdf(k))
            
        // Poisson distribution functions: (k, λ)
        case .poissonPdf:
            guard args.count == 2 else {
                throw CalculatorError.invalidInput("poissonPdf requires 2 arguments: k, λ")
            }
            let k = Int(args[0])
            let lambda = args[1]
            let dist = try PoissonDistribution(lambda: lambda)
            return .real(try dist.pmf(k))
            
        case .poissonCdf:
            guard args.count == 2 else {
                throw CalculatorError.invalidInput("poissonCdf requires 2 arguments: k, λ")
            }
            let k = Int(args[0])
            let lambda = args[1]
            let dist = try PoissonDistribution(lambda: lambda)
            return .real(try dist.cdf(k))
            
        default:
            throw CalculatorError.syntaxError("\(function.rawValue) is not a distribution function")
        }
    }
    
    // MARK: - Phase 4: Regression Function Evaluation
    
    /// Evaluates regression estimation functions
    private mutating func evaluateRegressionFunction(_ function: MathFunction, argument: Double) throws -> CalculatorResult {
        guard let data = context.statisticalData,
              data.isTwoVariable,
              let yValues = data.yValues else {
            throw CalculatorError.invalidInput("Regression functions require 2-variable statistical data")
        }
        
        // Get or compute regression
        if context.cachedRegressionResult == nil {
            context.cachedRegressionResult = try Regression.regression(
                context.selectedRegressionType,
                xValues: data.xValues,
                yValues: yValues
            )
        }
        
        guard let regression = context.cachedRegressionResult else {
            throw CalculatorError.invalidInput("Cannot calculate regression")
        }
        
        switch function {
        case .estimateY:
            return .real(regression.estimateY(from: argument))
            
        case .estimateX:
            guard let x = regression.estimateX(from: argument) else {
                throw CalculatorError.mathError("Cannot estimate X for this regression type")
            }
            return .real(x)
            
        case .linRegA:
            return .real(regression.a)
            
        case .linRegB:
            return .real(regression.b)
            
        default:
            throw CalculatorError.syntaxError("\(function.rawValue) is not a regression function")
        }
    }
    
    // MARK: - Phase 4: N-Argument Function Evaluation
    
    /// Evaluates functions with variable number of arguments
    private mutating func evaluateFunctionN(_ function: MathFunction, arguments: [ASTNode]) throws -> CalculatorResult {
        // Check if it's a calculus function (Phase 6)
        if function.isCalculusFunction {
            return try evaluateCalculusFunctionN(function, arguments: arguments)
        }
        
        // Check if it's a distribution function
        if function.isDistributionFunction {
            let args = try arguments.map { node -> Double in
                let result = try evaluate(node)
                guard let value = result.doubleValue else {
                    throw CalculatorError.mathError("Distribution functions require numeric arguments")
                }
                return value
            }
            return try evaluateDistributionFunction(function, args: args)
        }
        
        // Check if it's a statistics function
        if function.isStatisticsFunction {
            let values = try arguments.map { node -> Double in
                let result = try evaluate(node)
                guard let value = result.doubleValue else {
                    throw CalculatorError.mathError("Statistics functions require numeric arguments")
                }
                return value
            }
            return try evaluateStatisticsFunction(function, values: values)
        }
        
        throw CalculatorError.syntaxError("\(function.rawValue) is not supported as a multi-argument function")
    }
    
    // MARK: - Phase 6: Calculus Function Evaluation
    
    /// Evaluates calculus functions from functionN syntax
    /// Syntax: integrate(expression, variable, lower, upper)
    ///         differentiate(expression, variable, point)
    ///         summation(expression, variable, start, end)
    ///         product(expression, variable, start, end)
    private mutating func evaluateCalculusFunctionN(_ function: MathFunction, arguments: [ASTNode]) throws -> CalculatorResult {
        guard arguments.count >= 3 else {
            throw CalculatorError.invalidInput("\(function.rawValue) requires at least 3 arguments")
        }
        
        // First argument is the expression (NOT evaluated - passed as AST)
        let expression = arguments[0]
        
        // Second argument is the variable name
        let variableName: String
        if case .variable(let name) = arguments[1] {
            variableName = name
        } else {
            throw CalculatorError.invalidInput("Second argument must be a variable name")
        }
        
        // Remaining arguments are numeric bounds
        var numericArgs: [Double] = []
        for i in 2..<arguments.count {
            let result = try evaluate(arguments[i])
            guard let value = result.doubleValue else {
                throw CalculatorError.mathError("Bounds must be numeric values")
            }
            numericArgs.append(value)
        }
        
        return try evaluateCalculusFunction(function, expression: expression, variable: variableName, args: numericArgs)
    }
    
    /// Evaluates calculus functions (integrate, differentiate, summation, product)
    private mutating func evaluateCalculusFunction(
        _ function: MathFunction,
        expression: ASTNode,
        variable: String,
        args: [Double]
    ) throws -> CalculatorResult {
        switch function {
        case .integrate:
            guard args.count >= 2 else {
                throw CalculatorError.invalidInput("integrate requires lower and upper bounds")
            }
            let a = args[0]
            let b = args[1]
            
            let result = try integrateExpression(expression, variable: variable, from: a, to: b)
            return .real(result)
            
        case .differentiate:
            guard args.count >= 1 else {
                throw CalculatorError.invalidInput("differentiate requires a point")
            }
            let point = args[0]
            
            let result = try differentiateExpression(expression, variable: variable, at: point)
            return .real(result)
            
        case .summation:
            guard args.count >= 2 else {
                throw CalculatorError.invalidInput("summation requires start and end")
            }
            let start = Int(args[0])
            let end = Int(args[1])
            
            let result = try summationExpression(expression, variable: variable, from: start, to: end)
            return .real(result)
            
        case .product:
            guard args.count >= 2 else {
                throw CalculatorError.invalidInput("product requires start and end")
            }
            let start = Int(args[0])
            let end = Int(args[1])
            
            let result = try productExpression(expression, variable: variable, from: start, to: end)
            return .real(result)
            
        default:
            throw CalculatorError.syntaxError("\(function.rawValue) is not a calculus function")
        }
    }
    
    // MARK: - Inline Calculus Implementations
    
    /// Integrates an expression using Simpson's rule
    private func integrateExpression(_ expression: ASTNode, variable: String, from a: Double, to b: Double) throws -> Double {
        let n = 1000
        let h = (b - a) / Double(n)
        var sum = 0.0
        
        for i in 0...n {
            let x = a + Double(i) * h
            var ctx = context
            ctx.variables[variable] = x
            var eval = Evaluator(context: ctx)
            let result = try eval.evaluate(expression)
            guard let value = result.doubleValue else {
                throw CalculatorError.mathError("Cannot integrate non-numeric expression")
            }
            
            let weight: Double
            if i == 0 || i == n {
                weight = 1
            } else if i % 2 == 1 {
                weight = 4
            } else {
                weight = 2
            }
            sum += weight * value
        }
        
        return sum * h / 3
    }
    
    /// Differentiates an expression using central difference
    private func differentiateExpression(_ expression: ASTNode, variable: String, at point: Double) throws -> Double {
        let h = 1e-8
        
        var ctxPlus = context
        ctxPlus.variables[variable] = point + h
        var evalPlus = Evaluator(context: ctxPlus)
        let resultPlus = try evalPlus.evaluate(expression)
        
        var ctxMinus = context
        ctxMinus.variables[variable] = point - h
        var evalMinus = Evaluator(context: ctxMinus)
        let resultMinus = try evalMinus.evaluate(expression)
        
        guard let fp = resultPlus.doubleValue, let fm = resultMinus.doubleValue else {
            throw CalculatorError.mathError("Cannot differentiate non-numeric expression")
        }
        
        return (fp - fm) / (2 * h)
    }
    
    /// Computes summation
    private func summationExpression(_ expression: ASTNode, variable: String, from start: Int, to end: Int) throws -> Double {
        guard start <= end else {
            throw CalculatorError.invalidInput("Start must be ≤ end for summation")
        }
        guard end - start < 10_000_000 else {
            throw CalculatorError.domainError("Summation range too large")
        }
        
        var sum = 0.0
        for i in start...end {
            var ctx = context
            ctx.variables[variable] = Double(i)
            var eval = Evaluator(context: ctx)
            let result = try eval.evaluate(expression)
            guard let value = result.doubleValue else {
                throw CalculatorError.mathError("Cannot sum non-numeric expression")
            }
            sum += value
        }
        return sum
    }
    
    /// Computes product
    private func productExpression(_ expression: ASTNode, variable: String, from start: Int, to end: Int) throws -> Double {
        guard start <= end else {
            throw CalculatorError.invalidInput("Start must be ≤ end for product")
        }
        guard end - start < 10_000_000 else {
            throw CalculatorError.domainError("Product range too large")
        }
        
        var result = 1.0
        for i in start...end {
            var ctx = context
            ctx.variables[variable] = Double(i)
            var eval = Evaluator(context: ctx)
            let evalResult = try eval.evaluate(expression)
            guard let value = evalResult.doubleValue else {
                throw CalculatorError.mathError("Cannot multiply non-numeric expression")
            }
            result *= value
            if result == 0 { break }
        }
        return result
    }
}

// MARK: - Evaluator Extensions for Convenience

extension Evaluator {
    
    /// Evaluates an expression string and returns a CalculatorResult
    mutating func evaluateExpression(_ expression: String) throws -> CalculatorResult {
        var lexer = Lexer(input: expression)
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
    
    // MARK: - Phase 4: Statistics Convenience Methods
    
    /// Sets statistical data for evaluation context
    mutating func setStatisticalData(_ data: StatisticalData?) {
        context.setStatisticalData(data)
    }
    
    /// Sets the regression type for statistical calculations
    mutating func setRegressionType(_ type: RegressionType) {
        context.selectedRegressionType = type
        context.cachedRegressionResult = nil
    }
    
    /// Gets a statistical variable value by name
    mutating func getStatVariable(_ name: String) throws -> Double {
        return try context.getStatVariable(name)
    }
    
    /// Evaluates a statistics function with provided values
    mutating func evaluateStatistics(_ function: MathFunction, values: [Double]) throws -> CalculatorResult {
        return try evaluateStatisticsFunction(function, values: values)
    }
    
    /// Evaluates a distribution function with provided arguments
    mutating func evaluateDistribution(_ function: MathFunction, args: [Double]) throws -> CalculatorResult {
        return try evaluateDistributionFunction(function, args: args)
    }
    
    // MARK: - Phase 6: Calculus Convenience Methods
    
    /// Evaluates a definite integral ∫[a,b] f(x) dx
    mutating func evaluateIntegral(
        expression: ASTNode,
        variable: String,
        from a: Double,
        to b: Double
    ) throws -> Double {
        return try integrateExpression(expression, variable: variable, from: a, to: b)
    }
    
    /// Evaluates derivative f'(point)
    mutating func evaluateDerivative(
        expression: ASTNode,
        variable: String,
        at point: Double
    ) throws -> Double {
        return try differentiateExpression(expression, variable: variable, at: point)
    }
    
    /// Evaluates summation Σ f(x) for x = start to end
    mutating func evaluateSummation(
        expression: ASTNode,
        variable: String,
        from start: Int,
        to end: Int
    ) throws -> Double {
        return try summationExpression(expression, variable: variable, from: start, to: end)
    }
    
    /// Evaluates product Π f(x) for x = start to end
    mutating func evaluateProduct(
        expression: ASTNode,
        variable: String,
        from start: Int,
        to end: Int
    ) throws -> Double {
        return try productExpression(expression, variable: variable, from: start, to: end)
    }
    
    /// Evaluates a calculus function with the given arguments
    mutating func evaluateCalculus(
        _ function: MathFunction,
        expression: ASTNode,
        variable: String,
        bounds: [Double]
    ) throws -> CalculatorResult {
        return try evaluateCalculusFunction(function, expression: expression, variable: variable, args: bounds)
    }
}
