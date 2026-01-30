import Foundation

// MARK: - ComparisonOperator

/// Comparison operators for inequalities
enum ComparisonOperator: String, CaseIterable {
    case lessThan = "<"
    case lessThanOrEqual = "≤"
    case greaterThan = ">"
    case greaterThanOrEqual = "≥"
    
    /// Whether this operator includes equality
    var includesEquality: Bool {
        self == .lessThanOrEqual || self == .greaterThanOrEqual
    }
    
    /// The opposite operator
    var opposite: ComparisonOperator {
        switch self {
        case .lessThan: return .greaterThan
        case .lessThanOrEqual: return .greaterThanOrEqual
        case .greaterThan: return .lessThan
        case .greaterThanOrEqual: return .lessThanOrEqual
        }
    }
}

// MARK: - Interval

/// Represents an interval on the real number line
struct Interval: Equatable, CustomStringConvertible {
    /// Lower bound (nil = -∞)
    let lower: Double?
    
    /// Upper bound (nil = +∞)
    let upper: Double?
    
    /// Whether lower bound is included
    let lowerInclusive: Bool
    
    /// Whether upper bound is included
    let upperInclusive: Bool
    
    // MARK: - Initialization
    
    /// Creates a bounded interval
    init(lower: Double?, upper: Double?, lowerInclusive: Bool = false, upperInclusive: Bool = false) {
        self.lower = lower
        self.upper = upper
        self.lowerInclusive = lowerInclusive
        self.upperInclusive = upperInclusive
    }
    
    /// Creates interval (-∞, upper)
    static func lessThan(_ value: Double) -> Interval {
        Interval(lower: nil, upper: value, lowerInclusive: false, upperInclusive: false)
    }
    
    /// Creates interval (-∞, upper]
    static func lessThanOrEqual(_ value: Double) -> Interval {
        Interval(lower: nil, upper: value, lowerInclusive: false, upperInclusive: true)
    }
    
    /// Creates interval (lower, +∞)
    static func greaterThan(_ value: Double) -> Interval {
        Interval(lower: value, upper: nil, lowerInclusive: false, upperInclusive: false)
    }
    
    /// Creates interval [lower, +∞)
    static func greaterThanOrEqual(_ value: Double) -> Interval {
        Interval(lower: value, upper: nil, lowerInclusive: true, upperInclusive: false)
    }
    
    /// Creates interval (lower, upper)
    static func open(_ lower: Double, _ upper: Double) -> Interval {
        Interval(lower: lower, upper: upper, lowerInclusive: false, upperInclusive: false)
    }
    
    /// Creates interval [lower, upper]
    static func closed(_ lower: Double, _ upper: Double) -> Interval {
        Interval(lower: lower, upper: upper, lowerInclusive: true, upperInclusive: true)
    }
    
    /// All real numbers (-∞, +∞)
    static let allReals = Interval(lower: nil, upper: nil, lowerInclusive: false, upperInclusive: false)
    
    /// Empty set
    static let empty = Interval(lower: 1, upper: 0, lowerInclusive: false, upperInclusive: false)
    
    // MARK: - Properties
    
    /// Whether this interval is empty
    var isEmpty: Bool {
        if let l = lower, let u = upper {
            if l > u { return true }
            if l == u && (!lowerInclusive || !upperInclusive) { return true }
        }
        return false
    }
    
    /// Whether this interval represents all real numbers
    var isAllReals: Bool {
        lower == nil && upper == nil
    }
    
    /// Whether a value is contained in this interval
    func contains(_ value: Double) -> Bool {
        if isEmpty { return false }
        
        if let l = lower {
            if value < l { return false }
            if value == l && !lowerInclusive { return false }
        }
        
        if let u = upper {
            if value > u { return false }
            if value == u && !upperInclusive { return false }
        }
        
        return true
    }
    
    // MARK: - String Representation
    
    /// Interval notation string: "(a, b]", "(-∞, 5)", etc.
    var description: String {
        if isEmpty { return "∅" }
        
        let leftBracket = lowerInclusive ? "[" : "("
        let rightBracket = upperInclusive ? "]" : ")"
        let lowerStr = lower.map { formatNumber($0) } ?? "-∞"
        let upperStr = upper.map { formatNumber($0) } ?? "∞"
        return "\(leftBracket)\(lowerStr), \(upperStr)\(rightBracket)"
    }
    
    private func formatNumber(_ value: Double) -> String {
        if value == value.rounded() && abs(value) < 1e10 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.4g", value)
    }
}

// MARK: - InequalitySolution

/// Result of solving a polynomial inequality
struct InequalitySolution: Equatable {
    /// The critical points (roots of the polynomial)
    let criticalPoints: [Double]
    
    /// Solution intervals
    let intervals: [Interval]
    
    /// Whether the solution set is empty
    var isEmpty: Bool { intervals.isEmpty }
    
    /// Whether the solution is all real numbers
    var isAllReals: Bool { intervals.count == 1 && intervals[0].isAllReals }
    
    /// Interval notation representation
    var notation: String {
        if isEmpty { return "∅" }
        if isAllReals { return "ℝ" }
        return intervals.map { $0.description }.joined(separator: " ∪ ")
    }
}

// MARK: - InequalitySolver

/// Solves polynomial inequalities
struct InequalitySolver {
    
    private static let epsilon: Double = 1e-12
    
    // MARK: - Main Solver
    
    /// Solves polynomial inequality: p(x) op 0
    /// - Parameters:
    ///   - coefficients: Polynomial coefficients [aₙ, ..., a₁, a₀]
    ///   - comparison: The comparison operator (<, ≤, >, ≥)
    /// - Returns: Solution with critical points and intervals
    static func solve(
        coefficients: [Double],
        comparison: ComparisonOperator
    ) throws -> InequalitySolution {
        guard !coefficients.isEmpty else {
            throw CalculatorError.invalidInput("Coefficient array cannot be empty")
        }
        
        // Remove leading zeros
        var normalizedCoeffs = coefficients
        while normalizedCoeffs.count > 1 && abs(normalizedCoeffs[0]) < epsilon {
            normalizedCoeffs.removeFirst()
        }
        
        // Constant polynomial
        if normalizedCoeffs.count == 1 {
            return solveConstant(normalizedCoeffs[0], comparison: comparison)
        }
        
        // Linear polynomial
        if normalizedCoeffs.count == 2 {
            return try solveLinear(
                a: normalizedCoeffs[0],
                b: normalizedCoeffs[1],
                comparison: comparison
            )
        }
        
        // Find roots of the polynomial
        let roots = try PolynomialSolver.solve(coefficients: normalizedCoeffs)
        
        // Only use real roots as critical points
        let criticalPoints = roots.realRoots.sorted()
        
        // Build solution intervals
        let intervals = buildIntervals(
            criticalPoints: criticalPoints,
            comparison: comparison,
            coefficients: normalizedCoeffs
        )
        
        return InequalitySolution(
            criticalPoints: criticalPoints,
            intervals: intervals
        )
    }
    
    /// Solves quadratic inequality: ax² + bx + c op 0
    static func solveQuadratic(
        a: Double, b: Double, c: Double,
        comparison: ComparisonOperator
    ) throws -> InequalitySolution {
        return try solve(coefficients: [a, b, c], comparison: comparison)
    }
    
    /// Solves cubic inequality: ax³ + bx² + cx + d op 0
    static func solveCubic(
        a: Double, b: Double, c: Double, d: Double,
        comparison: ComparisonOperator
    ) throws -> InequalitySolution {
        return try solve(coefficients: [a, b, c, d], comparison: comparison)
    }
    
    /// Solves quartic inequality: ax⁴ + bx³ + cx² + dx + e op 0
    static func solveQuartic(
        a: Double, b: Double, c: Double, d: Double, e: Double,
        comparison: ComparisonOperator
    ) throws -> InequalitySolution {
        return try solve(coefficients: [a, b, c, d, e], comparison: comparison)
    }
    
    // MARK: - Special Cases
    
    /// Solves constant inequality: c op 0
    private static func solveConstant(
        _ c: Double,
        comparison: ComparisonOperator
    ) -> InequalitySolution {
        let satisfies: Bool
        switch comparison {
        case .lessThan:
            satisfies = c < -epsilon
        case .lessThanOrEqual:
            satisfies = c < epsilon
        case .greaterThan:
            satisfies = c > epsilon
        case .greaterThanOrEqual:
            satisfies = c > -epsilon
        }
        
        if satisfies {
            return InequalitySolution(criticalPoints: [], intervals: [.allReals])
        } else {
            return InequalitySolution(criticalPoints: [], intervals: [])
        }
    }
    
    /// Solves linear inequality: ax + b op 0
    private static func solveLinear(
        a: Double, b: Double,
        comparison: ComparisonOperator
    ) throws -> InequalitySolution {
        guard abs(a) > epsilon else {
            return solveConstant(b, comparison: comparison)
        }
        
        let root = -b / a
        let includeRoot = comparison.includesEquality
        
        // For ax + b, positive when x > -b/a if a > 0, or x < -b/a if a < 0
        let positiveOnRight = a > 0
        
        switch comparison {
        case .lessThan, .lessThanOrEqual:
            // Want p(x) < 0 or ≤ 0
            if positiveOnRight {
                // Negative on left side
                let interval = Interval(
                    lower: nil,
                    upper: root,
                    lowerInclusive: false,
                    upperInclusive: includeRoot
                )
                return InequalitySolution(criticalPoints: [root], intervals: [interval])
            } else {
                // Negative on right side
                let interval = Interval(
                    lower: root,
                    upper: nil,
                    lowerInclusive: includeRoot,
                    upperInclusive: false
                )
                return InequalitySolution(criticalPoints: [root], intervals: [interval])
            }
            
        case .greaterThan, .greaterThanOrEqual:
            // Want p(x) > 0 or ≥ 0
            if positiveOnRight {
                // Positive on right side
                let interval = Interval(
                    lower: root,
                    upper: nil,
                    lowerInclusive: includeRoot,
                    upperInclusive: false
                )
                return InequalitySolution(criticalPoints: [root], intervals: [interval])
            } else {
                // Positive on left side
                let interval = Interval(
                    lower: nil,
                    upper: root,
                    lowerInclusive: false,
                    upperInclusive: includeRoot
                )
                return InequalitySolution(criticalPoints: [root], intervals: [interval])
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Evaluates polynomial at x using Horner's method
    private static func evaluate(coefficients: [Double], at x: Double) -> Double {
        var result = 0.0
        for coeff in coefficients {
            result = result * x + coeff
        }
        return result
    }
    
    /// Tests if polynomial is positive at a test point
    private static func isPositive(coefficients: [Double], at x: Double) -> Bool {
        let value = evaluate(coefficients: coefficients, at: x)
        return value > epsilon
    }
    
    /// Tests if polynomial is negative at a test point
    private static func isNegative(coefficients: [Double], at x: Double) -> Bool {
        let value = evaluate(coefficients: coefficients, at: x)
        return value < -epsilon
    }
    
    /// Tests if value is a root
    private static func isRoot(coefficients: [Double], at x: Double) -> Bool {
        let value = evaluate(coefficients: coefficients, at: x)
        return abs(value) < epsilon
    }
    
    /// Tests if polynomial satisfies the inequality at a test point
    private static func satisfiesInequality(
        _ coefficients: [Double],
        at x: Double,
        comparison: ComparisonOperator
    ) -> Bool {
        let value = evaluate(coefficients: coefficients, at: x)
        switch comparison {
        case .lessThan:
            return value < -epsilon
        case .lessThanOrEqual:
            return value < epsilon
        case .greaterThan:
            return value > epsilon
        case .greaterThanOrEqual:
            return value > -epsilon
        }
    }
    
    /// Finds test points between critical points
    private static func testPoints(criticalPoints: [Double]) -> [Double] {
        guard !criticalPoints.isEmpty else { return [0] }
        
        var points: [Double] = []
        
        // Before first critical point
        points.append(criticalPoints[0] - 1)
        
        // Between critical points
        for i in 0..<(criticalPoints.count - 1) {
            points.append((criticalPoints[i] + criticalPoints[i + 1]) / 2)
        }
        
        // After last critical point
        points.append(criticalPoints[criticalPoints.count - 1] + 1)
        
        return points
    }
    
    /// Builds solution intervals from critical points and signs
    private static func buildIntervals(
        criticalPoints: [Double],
        comparison: ComparisonOperator,
        coefficients: [Double]
    ) -> [Interval] {
        let includeEquality = comparison.includesEquality
        
        // No critical points - polynomial is either always positive or always negative
        if criticalPoints.isEmpty {
            let sign = isPositive(coefficients: coefficients, at: 0)
            let wantPositive = comparison == .greaterThan || comparison == .greaterThanOrEqual
            let wantNegative = comparison == .lessThan || comparison == .lessThanOrEqual
            
            if (wantPositive && sign) || (wantNegative && !sign) {
                return [.allReals]
            } else {
                return []
            }
        }
        
        var intervals: [Interval] = []
        
        // Test region before first critical point
        let testBefore = criticalPoints[0] - 1
        if satisfiesInequality(coefficients, at: testBefore, comparison: comparison) {
            intervals.append(Interval(
                lower: nil,
                upper: criticalPoints[0],
                lowerInclusive: false,
                upperInclusive: includeEquality
            ))
        }
        
        // Test regions between critical points
        for i in 0..<(criticalPoints.count - 1) {
            let testMid = (criticalPoints[i] + criticalPoints[i + 1]) / 2
            if satisfiesInequality(coefficients, at: testMid, comparison: comparison) {
                intervals.append(Interval(
                    lower: criticalPoints[i],
                    upper: criticalPoints[i + 1],
                    lowerInclusive: includeEquality,
                    upperInclusive: includeEquality
                ))
            }
        }
        
        // Test region after last critical point
        let testAfter = criticalPoints[criticalPoints.count - 1] + 1
        if satisfiesInequality(coefficients, at: testAfter, comparison: comparison) {
            intervals.append(Interval(
                lower: criticalPoints.last,
                upper: nil,
                lowerInclusive: includeEquality,
                upperInclusive: false
            ))
        }
        
        // For equality cases, handle isolated points where polynomial touches zero
        // but doesn't cross (e.g., x² ≥ 0 at x = 0)
        if includeEquality && intervals.isEmpty {
            // Check if any critical point is included due to equality
            var pointIntervals: [Interval] = []
            for point in criticalPoints {
                if isRoot(coefficients: coefficients, at: point) {
                    // Check if this point satisfies inequality (it does for ≤ or ≥)
                    pointIntervals.append(Interval(
                        lower: point,
                        upper: point,
                        lowerInclusive: true,
                        upperInclusive: true
                    ))
                }
            }
            if !pointIntervals.isEmpty {
                return pointIntervals
            }
        }
        
        return mergeAdjacentIntervals(intervals)
    }
    
    /// Merges adjacent intervals that share a boundary
    private static func mergeAdjacentIntervals(_ intervals: [Interval]) -> [Interval] {
        guard intervals.count > 1 else { return intervals }
        
        var merged: [Interval] = []
        var current = intervals[0]
        
        for i in 1..<intervals.count {
            let next = intervals[i]
            
            // Check if intervals are adjacent and can be merged
            if let currentUpper = current.upper,
               let nextLower = next.lower,
               abs(currentUpper - nextLower) < epsilon,
               (current.upperInclusive || next.lowerInclusive) {
                // Merge the intervals
                current = Interval(
                    lower: current.lower,
                    upper: next.upper,
                    lowerInclusive: current.lowerInclusive,
                    upperInclusive: next.upperInclusive
                )
            } else {
                merged.append(current)
                current = next
            }
        }
        merged.append(current)
        
        return merged
    }
}
