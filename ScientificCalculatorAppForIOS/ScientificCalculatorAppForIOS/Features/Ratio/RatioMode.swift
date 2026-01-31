import Foundation
import SwiftUI

// MARK: - RatioPosition

/// Position of the unknown in the ratio A:B = C:D
enum RatioPosition: String, CaseIterable {
    case a = "X : B = C : D"
    case b = "A : X = C : D"
    case c = "A : B = X : D"
    case d = "A : B = C : X"
    
    /// Description of what we're solving for
    var description: String {
        switch self {
        case .a: return "Solve for first term"
        case .b: return "Solve for second term"
        case .c: return "Solve for third term"
        case .d: return "Solve for fourth term"
        }
    }
}

// MARK: - RatioSolver

/// Solves proportions A:B = C:D
struct RatioSolver {
    
    /// Solves for the unknown in A:B = C:D
    /// Using cross multiplication: A × D = B × C
    /// - Parameters:
    ///   - a: First term (nil if solving for this)
    ///   - b: Second term (nil if solving for this)
    ///   - c: Third term (nil if solving for this)
    ///   - d: Fourth term (nil if solving for this)
    /// - Returns: The solved value
    static func solve(a: Double?, b: Double?, c: Double?, d: Double?) throws -> Double {
        let unknowns = [a, b, c, d].filter { $0 == nil }.count
        guard unknowns == 1 else {
            throw CalculatorError.invalidInput("Exactly one value must be unknown")
        }
        
        // A:B = C:D means A/B = C/D, so A×D = B×C
        
        if a == nil {
            // Solve for A: A = (B × C) / D
            guard let b = b, let c = c, let d = d else { fatalError() }
            guard abs(d) > 1e-15 else {
                throw CalculatorError.divisionByZero
            }
            return (b * c) / d
        }
        
        if b == nil {
            // Solve for B: B = (A × D) / C
            guard let a = a, let c = c, let d = d else { fatalError() }
            guard abs(c) > 1e-15 else {
                throw CalculatorError.divisionByZero
            }
            return (a * d) / c
        }
        
        if c == nil {
            // Solve for C: C = (A × D) / B
            guard let a = a, let b = b, let d = d else { fatalError() }
            guard abs(b) > 1e-15 else {
                throw CalculatorError.divisionByZero
            }
            return (a * d) / b
        }
        
        if d == nil {
            // Solve for D: D = (B × C) / A
            guard let a = a, let b = b, let c = c else { fatalError() }
            guard abs(a) > 1e-15 else {
                throw CalculatorError.divisionByZero
            }
            return (b * c) / a
        }
        
        fatalError("Should not reach here")
    }
}

// MARK: - RatioMode

/// Manages ratio/proportion mode state
@Observable
class RatioMode {
    
    // MARK: - Input Values
    
    /// Value A (nil if solving for this)
    var valueA: Double? = 1
    
    /// Value B (nil if solving for this)
    var valueB: Double? = 2
    
    /// Value C (nil if solving for this)
    var valueC: Double? = 3
    
    /// Value D - this is what we're solving for by default
    var valueD: Double? = nil
    
    /// Which position is the unknown
    var unknownPosition: RatioPosition = .d
    
    // MARK: - Results
    
    /// Solved result
    private(set) var result: Double?
    
    /// Error message
    private(set) var errorMessage: String?
    
    // MARK: - Display Strings
    
    /// Input string for A
    var inputA: String = "1"
    
    /// Input string for B
    var inputB: String = "2"
    
    /// Input string for C
    var inputC: String = "3"
    
    /// Input string for D
    var inputD: String = ""
    
    // MARK: - Solving
    
    /// Parses inputs and solves the ratio
    func solve() {
        errorMessage = nil
        result = nil
        
        parseValues()
        
        do {
            result = try RatioSolver.solve(a: valueA, b: valueB, c: valueC, d: valueD)
            
            if let r = result {
                switch unknownPosition {
                case .a: inputA = formatResult(r)
                case .b: inputB = formatResult(r)
                case .c: inputC = formatResult(r)
                case .d: inputD = formatResult(r)
                }
            }
        } catch let error as CalculatorError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Parses input strings to values
    private func parseValues() {
        valueA = unknownPosition == .a ? nil : Double(inputA)
        valueB = unknownPosition == .b ? nil : Double(inputB)
        valueC = unknownPosition == .c ? nil : Double(inputC)
        valueD = unknownPosition == .d ? nil : Double(inputD)
    }
    
    /// Formats result for display
    private func formatResult(_ value: Double) -> String {
        if value == floor(value) && abs(value) < 1e10 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.10g", value)
    }
    
    // MARK: - Position Switching
    
    /// Sets which position is the unknown
    func setUnknown(_ position: RatioPosition) {
        unknownPosition = position
        
        switch position {
        case .a:
            inputA = ""
            if inputB.isEmpty { inputB = "2" }
            if inputC.isEmpty { inputC = "3" }
            if inputD.isEmpty { inputD = "6" }
        case .b:
            inputB = ""
            if inputA.isEmpty { inputA = "1" }
            if inputC.isEmpty { inputC = "3" }
            if inputD.isEmpty { inputD = "6" }
        case .c:
            inputC = ""
            if inputA.isEmpty { inputA = "1" }
            if inputB.isEmpty { inputB = "2" }
            if inputD.isEmpty { inputD = "6" }
        case .d:
            inputD = ""
            if inputA.isEmpty { inputA = "1" }
            if inputB.isEmpty { inputB = "2" }
            if inputC.isEmpty { inputC = "3" }
        }
        
        result = nil
        errorMessage = nil
    }
    
    // MARK: - Display
    
    /// Ratio display string: "A : B = C : D"
    var ratioDisplay: String {
        let aStr = unknownPosition == .a ? "X" : inputA
        let bStr = unknownPosition == .b ? "X" : inputB
        let cStr = unknownPosition == .c ? "X" : inputC
        let dStr = unknownPosition == .d ? "X" : inputD
        return "\(aStr) : \(bStr) = \(cStr) : \(dStr)"
    }
    
    /// Result display string
    var resultDisplay: String? {
        guard let r = result else { return nil }
        return "X = \(formatResult(r))"
    }
    
    // MARK: - Reset
    
    /// Resets to default state
    func reset() {
        inputA = "1"
        inputB = "2"
        inputC = "3"
        inputD = ""
        unknownPosition = .d
        result = nil
        errorMessage = nil
    }
}
