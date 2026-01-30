import Foundation

// MARK: - CalculatorError

/// Defines all error types for the scientific calculator
enum CalculatorError: Error, Equatable, LocalizedError {
    /// Syntax error in expression parsing
    case syntaxError(String)
    
    /// Mathematical error during calculation
    case mathError(String)
    
    /// Division by zero attempted
    case divisionByZero
    
    /// Invalid input provided
    case invalidInput(String)
    
    /// Variable not defined in context
    case undefinedVariable(String)
    
    /// Operation outside valid domain
    case domainError(String)
    
    /// Result exceeds representable range
    case overflow
    
    /// Result too small to represent
    case underflow
    
    /// Calculation exceeded time limit
    case timeout
    
    /// Matrix or vector dimensions incompatible
    case dimensionMismatch(String)
    
    /// Equation has no solution
    case noSolution
    
    /// Equation has infinite solutions
    case infiniteSolutions
    
    // MARK: - LocalizedError
    
    var errorDescription: String? {
        switch self {
        case .syntaxError(let message):
            return "Syntax Error: \(message)"
        case .mathError(let message):
            return "Math Error: \(message)"
        case .divisionByZero:
            return "Math Error: Division by zero"
        case .invalidInput(let message):
            return "Invalid Input: \(message)"
        case .undefinedVariable(let name):
            return "Undefined Variable: \(name)"
        case .domainError(let message):
            return "Domain Error: \(message)"
        case .overflow:
            return "Overflow Error: Result too large"
        case .underflow:
            return "Underflow Error: Result too small"
        case .timeout:
            return "Timeout Error: Calculation took too long"
        case .dimensionMismatch(let message):
            return "Dimension Error: \(message)"
        case .noSolution:
            return "No Solution"
        case .infiniteSolutions:
            return "Infinite Solutions"
        }
    }
}
