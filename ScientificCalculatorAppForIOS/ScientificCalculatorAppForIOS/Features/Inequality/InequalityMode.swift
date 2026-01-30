import Foundation
import SwiftUI

// MARK: - InequalityMode

/// Manages inequality solver mode state
@Observable
class InequalityMode {
    
    // MARK: - Configuration
    
    /// Degree of polynomial (2, 3, or 4)
    var degree: Int = 2 {
        didSet {
            if degree != oldValue {
                coefficients = Array(repeating: 0, count: degree + 1)
                coefficients[0] = 1
                solution = nil
            }
        }
    }
    
    /// Polynomial coefficients [aₙ, ..., a₁, a₀]
    var coefficients: [Double] = [1, 0, 0]
    
    /// Comparison operator
    var comparison: ComparisonOperator = .lessThan
    
    // MARK: - Results
    
    /// Last solution
    private(set) var solution: InequalitySolution?
    
    /// Error message
    private(set) var errorMessage: String?
    
    // MARK: - Coefficient Access
    
    /// Sets coefficient for x^power
    func setCoefficient(power: Int, value: Double) {
        let index = degree - power
        if index >= 0 && index < coefficients.count {
            coefficients[index] = value
        }
    }
    
    /// Gets coefficient for x^power
    func getCoefficient(power: Int) -> Double {
        let index = degree - power
        if index >= 0 && index < coefficients.count {
            return coefficients[index]
        }
        return 0
    }
    
    // MARK: - Display Helpers
    
    /// Coefficient labels for display (a, b, c, d, e)
    var coefficientLabels: [String] {
        switch degree {
        case 2: return ["a", "b", "c"]
        case 3: return ["a", "b", "c", "d"]
        case 4: return ["a", "b", "c", "d", "e"]
        default: return []
        }
    }
    
    /// Power labels for display (x², x, constant)
    var powerLabels: [String] {
        switch degree {
        case 2: return ["x²", "x", ""]
        case 3: return ["x³", "x²", "x", ""]
        case 4: return ["x⁴", "x³", "x²", "x", ""]
        default: return []
        }
    }
    
    /// Equation string for display
    var equationString: String {
        var terms: [String] = []
        
        for (i, coeff) in coefficients.enumerated() {
            let power = degree - i
            if abs(coeff) < 1e-15 { continue }
            
            var term = ""
            if coeff < 0 {
                term = "- "
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
        
        return terms.joined(separator: " ") + " \(comparison.rawValue) 0"
    }
    
    private func superscript(_ n: Int) -> String {
        let superscripts = "⁰¹²³⁴⁵⁶⁷⁸⁹"
        return String(n).map { char in
            guard let digit = Int(String(char)), digit < 10 else {
                return char
            }
            let index = superscripts.index(superscripts.startIndex, offsetBy: digit)
            return superscripts[index]
        }.reduce("") { String($0) + String($1) }
    }
    
    // MARK: - Solving
    
    /// Solves the inequality
    func solve() {
        errorMessage = nil
        
        do {
            solution = try InequalitySolver.solve(
                coefficients: coefficients,
                comparison: comparison
            )
        } catch let error as CalculatorError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Reset
    
    /// Resets to default state
    func reset() {
        degree = 2
        coefficients = [1, 0, 0]
        comparison = .lessThan
        solution = nil
        errorMessage = nil
    }
    
    // MARK: - Formatted Results
    
    /// Solution in interval notation
    var solutionNotation: String? {
        solution?.notation
    }
    
    /// Critical points formatted
    var criticalPointsString: String? {
        guard let sol = solution, !sol.criticalPoints.isEmpty else { return nil }
        return "Roots: " + sol.criticalPoints
            .map { String(format: "%.6g", $0) }
            .joined(separator: ", ")
    }
    
    /// Detailed solution description
    var detailedSolution: String? {
        guard let sol = solution else { return nil }
        
        var lines: [String] = []
        
        // Add the equation being solved
        lines.append("Solving: \(equationString)")
        lines.append("")
        
        // Add critical points
        if !sol.criticalPoints.isEmpty {
            lines.append("Critical points (roots):")
            for (i, point) in sol.criticalPoints.enumerated() {
                lines.append("  x\(i + 1) = \(String(format: "%.10g", point))")
            }
            lines.append("")
        }
        
        // Add solution
        lines.append("Solution:")
        lines.append("  \(sol.notation)")
        
        return lines.joined(separator: "\n")
    }
    
    /// Whether the current configuration is valid for solving
    var isValidConfiguration: Bool {
        // Check that leading coefficient is not zero
        guard !coefficients.isEmpty else { return false }
        return abs(coefficients[0]) > 1e-15
    }
    
    /// Validation message if configuration is invalid
    var validationMessage: String? {
        if coefficients.isEmpty {
            return "No coefficients provided"
        }
        if abs(coefficients[0]) < 1e-15 {
            return "Leading coefficient cannot be zero"
        }
        return nil
    }
}
