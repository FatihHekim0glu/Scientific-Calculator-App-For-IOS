import Foundation
import SwiftUI

// MARK: - EquationType

/// Types of equations that can be solved
enum EquationType: String, CaseIterable {
    case simultaneous = "Simultaneous"
    case polynomial = "Polynomial"
    case numerical = "Solve for x"
    
    var description: String {
        switch self {
        case .simultaneous: return "System of linear equations"
        case .polynomial: return "Polynomial equation"
        case .numerical: return "Numerical root finding"
        }
    }
    
    var icon: String {
        switch self {
        case .simultaneous: return "square.grid.2x2"
        case .polynomial: return "x.squareroot"
        case .numerical: return "function"
        }
    }
}

// MARK: - SimultaneousConfig

/// Configuration for simultaneous equations
struct SimultaneousConfig {
    /// Number of unknowns (2, 3, or 4)
    var unknowns: Int = 2 {
        didSet {
            if unknowns != oldValue {
                adjustForUnknowns()
            }
        }
    }
    
    /// Coefficient matrix (n×n)
    var coefficients: [[Double]]
    
    /// Right-hand side constants
    var constants: [Double]
    
    init(unknowns: Int = 2) {
        self.unknowns = max(2, min(4, unknowns))
        self.coefficients = Array(repeating: Array(repeating: 0, count: self.unknowns), count: self.unknowns)
        self.constants = Array(repeating: 0, count: self.unknowns)
    }
    
    /// Adjusts arrays when unknowns count changes
    private mutating func adjustForUnknowns() {
        let n = max(2, min(4, unknowns))
        coefficients = Array(repeating: Array(repeating: 0, count: n), count: n)
        constants = Array(repeating: 0, count: n)
    }
    
    /// Sets coefficient at position
    mutating func setCoefficient(row: Int, col: Int, value: Double) {
        guard row >= 0 && row < unknowns && col >= 0 && col < unknowns else { return }
        coefficients[row][col] = value
    }
    
    /// Gets coefficient at position
    func getCoefficient(row: Int, col: Int) -> Double {
        guard row >= 0 && row < unknowns && col >= 0 && col < unknowns else { return 0 }
        return coefficients[row][col]
    }
    
    /// Sets constant at position
    mutating func setConstant(row: Int, value: Double) {
        guard row >= 0 && row < unknowns else { return }
        constants[row] = value
    }
    
    /// Gets constant at position
    func getConstant(row: Int) -> Double {
        guard row >= 0 && row < unknowns else { return 0 }
        return constants[row]
    }
    
    /// Resets all values to zero
    mutating func reset() {
        coefficients = Array(repeating: Array(repeating: 0, count: unknowns), count: unknowns)
        constants = Array(repeating: 0, count: unknowns)
    }
    
    /// Variable labels for display (x, y, z, w)
    var variableLabels: [String] {
        Array(["x", "y", "z", "w"].prefix(unknowns))
    }
}

// MARK: - PolynomialConfig

/// Configuration for polynomial equations
struct PolynomialConfig {
    /// Degree of polynomial (2, 3, or 4)
    var degree: Int = 2 {
        didSet {
            if degree != oldValue {
                adjustForDegree()
            }
        }
    }
    
    /// Coefficients [aₙ, ..., a₁, a₀] (highest to lowest power)
    var coefficients: [Double]
    
    init(degree: Int = 2) {
        self.degree = max(2, min(4, degree))
        self.coefficients = Array(repeating: 0, count: self.degree + 1)
        self.coefficients[0] = 1
    }
    
    /// Adjusts array when degree changes
    private mutating func adjustForDegree() {
        let d = max(2, min(4, degree))
        coefficients = Array(repeating: 0, count: d + 1)
        coefficients[0] = 1
    }
    
    /// Sets coefficient for x^power term
    mutating func setCoefficient(power: Int, value: Double) {
        let index = degree - power
        guard index >= 0 && index < coefficients.count else { return }
        coefficients[index] = value
    }
    
    /// Gets coefficient for x^power term
    func getCoefficient(power: Int) -> Double {
        let index = degree - power
        guard index >= 0 && index < coefficients.count else { return 0 }
        return coefficients[index]
    }
    
    /// Resets all values (leading coefficient to 1, rest to 0)
    mutating func reset() {
        coefficients = Array(repeating: 0, count: degree + 1)
        coefficients[0] = 1
    }
    
    /// Coefficient labels for display
    var coefficientLabels: [String] {
        switch degree {
        case 2: return ["a", "b", "c"]
        case 3: return ["a", "b", "c", "d"]
        case 4: return ["a", "b", "c", "d", "e"]
        default: return []
        }
    }
    
    /// Polynomial equation string for display
    var equationString: String {
        var terms: [String] = []
        
        for (i, coeff) in coefficients.enumerated() {
            let power = degree - i
            if abs(coeff) < 1e-15 { continue }
            
            var term = ""
            if coeff < 0 {
                term = terms.isEmpty ? "-" : "- "
            } else if !terms.isEmpty {
                term = "+ "
            }
            
            let absCoeff = abs(coeff)
            if power == 0 {
                term += String(format: "%.4g", absCoeff)
            } else if absCoeff != 1 {
                term += String(format: "%.4g", absCoeff)
            }
            
            if power > 0 {
                term += "x"
                if power > 1 {
                    term += superscript(power)
                }
            }
            
            terms.append(term)
        }
        
        if terms.isEmpty { terms = ["0"] }
        
        return terms.joined(separator: " ") + " = 0"
    }
    
    private func superscript(_ n: Int) -> String {
        let superscripts = "⁰¹²³⁴⁵⁶⁷⁸⁹"
        return String(n).map { char in
            if let digit = Int(String(char)), digit < 10 {
                let index = superscripts.index(superscripts.startIndex, offsetBy: digit)
                return superscripts[index]
            }
            return char
        }.reduce("") { String($0) + String($1) }
    }
}

// MARK: - NumericalConfig

/// Configuration for numerical solver
struct NumericalConfig {
    /// The equation expression (as string, to be parsed)
    var expression: String = ""
    
    /// Initial guess for root finding
    var initialGuess: Double = 0
    
    /// Variable name (default "x")
    var variable: String = "x"
    
    /// Maximum iterations
    var maxIterations: Int = 100
    
    /// Tolerance for convergence
    var tolerance: Double = 1e-12
    
    /// Resets to default values
    mutating func reset() {
        expression = ""
        initialGuess = 0
        variable = "x"
        maxIterations = 100
        tolerance = 1e-12
    }
    
    /// Whether the configuration has a valid expression
    var hasExpression: Bool {
        !expression.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

// MARK: - EquationMode

/// Manages equation solver mode state
@Observable
class EquationMode {
    
    // MARK: - Type Selection
    
    /// Currently selected equation type
    var equationType: EquationType = .polynomial
    
    // MARK: - Configurations
    
    /// Simultaneous equation configuration
    var simultaneousConfig = SimultaneousConfig()
    
    /// Polynomial equation configuration
    var polynomialConfig = PolynomialConfig()
    
    /// Numerical solver configuration
    var numericalConfig = NumericalConfig()
    
    // MARK: - Results
    
    /// Last simultaneous solution
    private(set) var simultaneousSolution: SystemSolution?
    
    /// Last polynomial roots
    private(set) var polynomialRoots: PolynomialRoots?
    
    /// Last numerical solution
    private(set) var numericalSolution: NumericalSolution?
    
    /// Last error message
    private(set) var errorMessage: String?
    
    /// Whether a solution is currently being computed
    private(set) var isComputing: Bool = false
    
    // MARK: - Solving
    
    /// Solves with current configuration
    func solve() {
        errorMessage = nil
        isComputing = true
        
        defer { isComputing = false }
        
        do {
            switch equationType {
            case .simultaneous:
                simultaneousSolution = try solveSimultaneous()
            case .polynomial:
                polynomialRoots = try solvePolynomial()
            case .numerical:
                numericalSolution = try solveNumerical()
            }
        } catch let error as CalculatorError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Solves simultaneous equations
    private func solveSimultaneous() throws -> SystemSolution {
        return try SimultaneousEquationSolver.solve(
            coefficients: simultaneousConfig.coefficients,
            constants: simultaneousConfig.constants
        )
    }
    
    /// Solves polynomial equation
    private func solvePolynomial() throws -> PolynomialRoots {
        return try PolynomialSolver.solve(
            coefficients: polynomialConfig.coefficients
        )
    }
    
    /// Solves equation numerically
    private func solveNumerical() throws -> NumericalSolution {
        guard numericalConfig.hasExpression else {
            throw CalculatorError.invalidInput("Please enter an expression")
        }
        
        var lexer = Lexer(input: numericalConfig.expression)
        let tokens = try lexer.tokenize()
        var parser = Parser(tokens: tokens)
        let ast = try parser.parse()
        
        let context = EvaluationContext()
        let config = NumericalSolverConfig(
            maxIterations: numericalConfig.maxIterations,
            tolerance: numericalConfig.tolerance
        )
        
        return try NumericalSolver.solveExpression(
            ast,
            variable: numericalConfig.variable,
            initialGuess: numericalConfig.initialGuess,
            context: context,
            config: config
        )
    }
    
    // MARK: - Reset
    
    /// Resets all configurations and results
    func reset() {
        simultaneousConfig = SimultaneousConfig()
        polynomialConfig = PolynomialConfig()
        numericalConfig = NumericalConfig()
        simultaneousSolution = nil
        polynomialRoots = nil
        numericalSolution = nil
        errorMessage = nil
    }
    
    /// Resets only current configuration
    func resetCurrent() {
        switch equationType {
        case .simultaneous:
            simultaneousConfig.reset()
            simultaneousSolution = nil
        case .polynomial:
            polynomialConfig.reset()
            polynomialRoots = nil
        case .numerical:
            numericalConfig.reset()
            numericalSolution = nil
        }
        errorMessage = nil
    }
    
    /// Clears current result without resetting input
    func clearResult() {
        switch equationType {
        case .simultaneous:
            simultaneousSolution = nil
        case .polynomial:
            polynomialRoots = nil
        case .numerical:
            numericalSolution = nil
        }
        errorMessage = nil
    }
    
    // MARK: - Result Checking
    
    /// Whether there is a result for the current equation type
    var hasResult: Bool {
        switch equationType {
        case .simultaneous:
            return simultaneousSolution != nil
        case .polynomial:
            return polynomialRoots != nil
        case .numerical:
            return numericalSolution != nil
        }
    }
    
    /// Whether there is an error
    var hasError: Bool {
        errorMessage != nil
    }
    
    // MARK: - Formatted Results
    
    /// Gets formatted result string
    var formattedResult: String? {
        switch equationType {
        case .simultaneous:
            return formatSimultaneousResult()
        case .polynomial:
            return formatPolynomialResult()
        case .numerical:
            return formatNumericalResult()
        }
    }
    
    private func formatSimultaneousResult() -> String? {
        guard let solution = simultaneousSolution else { return nil }
        
        switch solution {
        case .unique(let values):
            let vars = ["x", "y", "z", "w"]
            return values.enumerated()
                .map { "\(vars[$0.offset]) = \(formatValue($0.element))" }
                .joined(separator: "\n")
            
        case .noSolution:
            return "No Solution\nThe system is inconsistent"
            
        case .infiniteSolutions(let desc):
            return "Infinite Solutions\n\(desc)"
        }
    }
    
    private func formatPolynomialResult() -> String? {
        guard let roots = polynomialRoots else { return nil }
        
        var lines: [String] = []
        var rootIndex = 1
        
        for root in roots.realRoots {
            lines.append("x\(subscript(rootIndex)) = \(formatValue(root))")
            rootIndex += 1
        }
        
        for root in roots.complexRoots {
            lines.append("x\(subscript(rootIndex)) = \(root.description)")
            rootIndex += 1
        }
        
        if lines.isEmpty {
            return "No roots found"
        }
        
        return lines.joined(separator: "\n")
    }
    
    private func formatNumericalResult() -> String? {
        guard let solution = numericalSolution else { return nil }
        
        var result = "\(numericalConfig.variable) = \(formatValue(solution.root))"
        result += "\nIterations: \(solution.iterations)"
        result += "\nResidual: \(String(format: "%.2e", solution.residual))"
        result += "\nMethod: \(solution.method)"
        
        if !solution.converged {
            result += "\n⚠️ Did not fully converge"
        }
        
        return result
    }
    
    // MARK: - Formatting Helpers
    
    private func formatValue(_ value: Double) -> String {
        if value.isNaN {
            return "NaN"
        }
        if value.isInfinite {
            return value > 0 ? "∞" : "-∞"
        }
        if value == floor(value) && abs(value) < 1e10 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.10g", value)
    }
    
    private func subscript(_ n: Int) -> String {
        let subscripts = "₀₁₂₃₄₅₆₇₈₉"
        return String(n).map { char in
            if let digit = Int(String(char)), digit < 10 {
                let index = subscripts.index(subscripts.startIndex, offsetBy: digit)
                return subscripts[index]
            }
            return char
        }.reduce("") { String($0) + String($1) }
    }
}
