import Foundation

// MARK: - RegressionType

/// Types of regression models
enum RegressionType: String, CaseIterable {
    case linear = "y = a + bx"
    case quadratic = "y = a + bx + cx²"
    case logarithmic = "y = a + b·ln(x)"
    case eExponential = "y = a·e^(bx)"
    case abExponential = "y = a·b^x"
    case power = "y = a·x^b"
    case inverse = "y = a + b/x"
    
    /// Display name for the regression type
    var displayName: String {
        switch self {
        case .linear: return "Linear"
        case .quadratic: return "Quadratic"
        case .logarithmic: return "Logarithmic"
        case .eExponential: return "e Exponential"
        case .abExponential: return "ab Exponential"
        case .power: return "Power"
        case .inverse: return "Inverse"
        }
    }
    
    /// Number of coefficients for this regression type
    var coefficientCount: Int {
        self == .quadratic ? 3 : 2
    }
}

// MARK: - RegressionResult

/// Result of a regression calculation
struct RegressionResult: Equatable {
    /// Type of regression performed
    let type: RegressionType
    
    /// Coefficient a (intercept for linear)
    let a: Double
    
    /// Coefficient b (slope for linear)
    let b: Double
    
    /// Coefficient c (only for quadratic)
    let c: Double?
    
    /// Pearson correlation coefficient
    let correlationCoefficient: Double
    
    /// Coefficient of determination (r²)
    let coefficientOfDetermination: Double
    
    /// All coefficients as dictionary
    var coefficients: [String: Double] {
        var result = ["a": a, "b": b]
        if let c = c { result["c"] = c }
        return result
    }
    
    /// Estimates y from x using the regression equation
    func estimateY(from x: Double) -> Double {
        switch type {
        case .linear:
            return a + b * x
        case .quadratic:
            guard let c = c else { return .nan }
            return a + b * x + c * x * x
        case .logarithmic:
            guard x > 0 else { return .nan }
            return a + b * log(x)
        case .eExponential:
            return a * exp(b * x)
        case .abExponential:
            return a * pow(b, x)
        case .power:
            guard x > 0 else { return .nan }
            return a * pow(x, b)
        case .inverse:
            guard x != 0 else { return .nan }
            return a + b / x
        }
    }
    
    /// Estimates x from y using the regression equation (may return nil for some types)
    func estimateX(from y: Double) -> Double? {
        switch type {
        case .linear:
            guard b != 0 else { return nil }
            return (y - a) / b
        case .quadratic:
            guard let c = c, c != 0 else {
                guard b != 0 else { return nil }
                return (y - a) / b
            }
            let discriminant = b * b - 4 * c * (a - y)
            guard discriminant >= 0 else { return nil }
            return (-b + sqrt(discriminant)) / (2 * c)
        case .logarithmic:
            guard b != 0 else { return nil }
            let lnX = (y - a) / b
            return exp(lnX)
        case .eExponential:
            guard a != 0, y / a > 0 else { return nil }
            guard b != 0 else { return nil }
            return log(y / a) / b
        case .abExponential:
            guard a != 0, y / a > 0, b > 0, b != 1 else { return nil }
            return log(y / a) / log(b)
        case .power:
            guard a != 0, y / a > 0, b != 0 else { return nil }
            return pow(y / a, 1 / b)
        case .inverse:
            guard y != a else { return nil }
            return b / (y - a)
        }
    }
    
    /// Returns the regression equation as a string with coefficients
    var equation: String {
        let formatNum = { (num: Double) -> String in
            if abs(num - round(num)) < 0.0001 {
                return String(format: "%.0f", num)
            }
            return String(format: "%.4f", num)
        }
        
        switch type {
        case .linear:
            let sign = b >= 0 ? "+" : "-"
            return "y = \(formatNum(a)) \(sign) \(formatNum(abs(b)))x"
        case .quadratic:
            guard let c = c else { return "Invalid" }
            let signB = b >= 0 ? "+" : "-"
            let signC = c >= 0 ? "+" : "-"
            return "y = \(formatNum(a)) \(signB) \(formatNum(abs(b)))x \(signC) \(formatNum(abs(c)))x²"
        case .logarithmic:
            let sign = b >= 0 ? "+" : "-"
            return "y = \(formatNum(a)) \(sign) \(formatNum(abs(b)))·ln(x)"
        case .eExponential:
            return "y = \(formatNum(a))·e^(\(formatNum(b))x)"
        case .abExponential:
            return "y = \(formatNum(a))·\(formatNum(b))^x"
        case .power:
            return "y = \(formatNum(a))·x^\(formatNum(b))"
        case .inverse:
            let sign = b >= 0 ? "+" : "-"
            return "y = \(formatNum(a)) \(sign) \(formatNum(abs(b)))/x"
        }
    }
}

// MARK: - Regression

/// Regression calculation functions
struct Regression {
    
    // MARK: - Main Regression Functions
    
    /// Performs linear regression: y = a + bx
    static func linear(xValues: [Double], yValues: [Double]) throws -> RegressionResult {
        try validateInput(xValues: xValues, yValues: yValues, minPoints: 2)
        
        let n = Double(xValues.count)
        let sumX = xValues.reduce(0, +)
        let sumY = yValues.reduce(0, +)
        let sumXY = zip(xValues, yValues).map(*).reduce(0, +)
        let sumX2 = xValues.map { $0 * $0 }.reduce(0, +)
        let sumY2 = yValues.map { $0 * $0 }.reduce(0, +)
        
        let denominator = n * sumX2 - sumX * sumX
        guard abs(denominator) > 1e-15 else {
            throw CalculatorError.mathError("Cannot compute regression (all x values identical)")
        }
        
        let b = (n * sumXY - sumX * sumY) / denominator
        let a = (sumY - b * sumX) / n
        
        let rNumerator = n * sumXY - sumX * sumY
        let rDenominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))
        
        let r: Double
        if abs(rDenominator) < 1e-15 {
            r = sumY2 == sumY * sumY / n ? 1.0 : 0.0
        } else {
            r = rNumerator / rDenominator
        }
        
        return RegressionResult(
            type: .linear,
            a: a,
            b: b,
            c: nil,
            correlationCoefficient: r,
            coefficientOfDetermination: r * r
        )
    }
    
    /// Performs quadratic regression: y = a + bx + cx²
    static func quadratic(xValues: [Double], yValues: [Double]) throws -> RegressionResult {
        try validateInput(xValues: xValues, yValues: yValues, minPoints: 3)
        
        let n = Double(xValues.count)
        
        let sumX = xValues.reduce(0, +)
        let sumX2 = xValues.map { $0 * $0 }.reduce(0, +)
        let sumX3 = xValues.map { pow($0, 3) }.reduce(0, +)
        let sumX4 = xValues.map { pow($0, 4) }.reduce(0, +)
        let sumY = yValues.reduce(0, +)
        let sumXY = zip(xValues, yValues).map(*).reduce(0, +)
        let sumX2Y = zip(xValues, yValues).map { $0 * $0 * $1 }.reduce(0, +)
        let sumY2 = yValues.map { $0 * $0 }.reduce(0, +)
        
        // Solve system: [n, Σx, Σx²] [a]   [Σy]
        //               [Σx, Σx², Σx³] [b] = [Σxy]
        //               [Σx², Σx³, Σx⁴] [c]   [Σx²y]
        let coefficients = try solveLinearSystem3x3(
            a11: n, a12: sumX, a13: sumX2,
            a21: sumX, a22: sumX2, a23: sumX3,
            a31: sumX2, a32: sumX3, a33: sumX4,
            b1: sumY, b2: sumXY, b3: sumX2Y
        )
        
        let a = coefficients.0
        let b = coefficients.1
        let c = coefficients.2
        
        // Calculate r² using total sum of squares and residual sum of squares
        let meanY = sumY / n
        let ssTotal = yValues.map { ($0 - meanY) * ($0 - meanY) }.reduce(0, +)
        let ssResidual = zip(xValues, yValues).map { x, y -> Double in
            let predicted = a + b * x + c * x * x
            return (y - predicted) * (y - predicted)
        }.reduce(0, +)
        
        let rSquared: Double
        if abs(ssTotal) < 1e-15 {
            rSquared = 1.0
        } else {
            rSquared = max(0, 1 - ssResidual / ssTotal)
        }
        
        let r = sqrt(rSquared)
        
        return RegressionResult(
            type: .quadratic,
            a: a,
            b: b,
            c: c,
            correlationCoefficient: r,
            coefficientOfDetermination: rSquared
        )
    }
    
    /// Performs logarithmic regression: y = a + b·ln(x)
    static func logarithmic(xValues: [Double], yValues: [Double]) throws -> RegressionResult {
        try validateInput(xValues: xValues, yValues: yValues, minPoints: 2)
        
        guard xValues.allSatisfy({ $0 > 0 }) else {
            throw CalculatorError.domainError("Logarithmic regression requires all x values > 0")
        }
        
        let lnX = xValues.map { log($0) }
        let linearResult = try linear(xValues: lnX, yValues: yValues)
        
        return RegressionResult(
            type: .logarithmic,
            a: linearResult.a,
            b: linearResult.b,
            c: nil,
            correlationCoefficient: linearResult.correlationCoefficient,
            coefficientOfDetermination: linearResult.coefficientOfDetermination
        )
    }
    
    /// Performs e-exponential regression: y = a·e^(bx)
    static func eExponential(xValues: [Double], yValues: [Double]) throws -> RegressionResult {
        try validateInput(xValues: xValues, yValues: yValues, minPoints: 2)
        
        guard yValues.allSatisfy({ $0 > 0 }) else {
            throw CalculatorError.domainError("Exponential regression requires all y values > 0")
        }
        
        let lnY = yValues.map { log($0) }
        let linearResult = try linear(xValues: xValues, yValues: lnY)
        
        let a = exp(linearResult.a)
        let b = linearResult.b
        
        return RegressionResult(
            type: .eExponential,
            a: a,
            b: b,
            c: nil,
            correlationCoefficient: linearResult.correlationCoefficient,
            coefficientOfDetermination: linearResult.coefficientOfDetermination
        )
    }
    
    /// Performs ab-exponential regression: y = a·b^x
    static func abExponential(xValues: [Double], yValues: [Double]) throws -> RegressionResult {
        try validateInput(xValues: xValues, yValues: yValues, minPoints: 2)
        
        guard yValues.allSatisfy({ $0 > 0 }) else {
            throw CalculatorError.domainError("Exponential regression requires all y values > 0")
        }
        
        let lnY = yValues.map { log($0) }
        let linearResult = try linear(xValues: xValues, yValues: lnY)
        
        let a = exp(linearResult.a)
        let b = exp(linearResult.b)
        
        return RegressionResult(
            type: .abExponential,
            a: a,
            b: b,
            c: nil,
            correlationCoefficient: linearResult.correlationCoefficient,
            coefficientOfDetermination: linearResult.coefficientOfDetermination
        )
    }
    
    /// Performs power regression: y = a·x^b
    static func power(xValues: [Double], yValues: [Double]) throws -> RegressionResult {
        try validateInput(xValues: xValues, yValues: yValues, minPoints: 2)
        
        guard xValues.allSatisfy({ $0 > 0 }) else {
            throw CalculatorError.domainError("Power regression requires all x values > 0")
        }
        guard yValues.allSatisfy({ $0 > 0 }) else {
            throw CalculatorError.domainError("Power regression requires all y values > 0")
        }
        
        let lnX = xValues.map { log($0) }
        let lnY = yValues.map { log($0) }
        let linearResult = try linear(xValues: lnX, yValues: lnY)
        
        let a = exp(linearResult.a)
        let b = linearResult.b
        
        return RegressionResult(
            type: .power,
            a: a,
            b: b,
            c: nil,
            correlationCoefficient: linearResult.correlationCoefficient,
            coefficientOfDetermination: linearResult.coefficientOfDetermination
        )
    }
    
    /// Performs inverse regression: y = a + b/x
    static func inverse(xValues: [Double], yValues: [Double]) throws -> RegressionResult {
        try validateInput(xValues: xValues, yValues: yValues, minPoints: 2)
        
        guard xValues.allSatisfy({ $0 != 0 }) else {
            throw CalculatorError.domainError("Inverse regression requires all x values ≠ 0")
        }
        
        let inverseX = xValues.map { 1 / $0 }
        let linearResult = try linear(xValues: inverseX, yValues: yValues)
        
        return RegressionResult(
            type: .inverse,
            a: linearResult.a,
            b: linearResult.b,
            c: nil,
            correlationCoefficient: linearResult.correlationCoefficient,
            coefficientOfDetermination: linearResult.coefficientOfDetermination
        )
    }
    
    /// Performs regression of specified type
    static func regression(_ type: RegressionType, xValues: [Double], yValues: [Double]) throws -> RegressionResult {
        switch type {
        case .linear:
            return try linear(xValues: xValues, yValues: yValues)
        case .quadratic:
            return try quadratic(xValues: xValues, yValues: yValues)
        case .logarithmic:
            return try logarithmic(xValues: xValues, yValues: yValues)
        case .eExponential:
            return try eExponential(xValues: xValues, yValues: yValues)
        case .abExponential:
            return try abExponential(xValues: xValues, yValues: yValues)
        case .power:
            return try power(xValues: xValues, yValues: yValues)
        case .inverse:
            return try inverse(xValues: xValues, yValues: yValues)
        }
    }
    
    // MARK: - Best Fit
    
    /// Finds the best fitting regression type based on highest r²
    static func bestFit(xValues: [Double], yValues: [Double]) throws -> RegressionResult {
        var bestResult: RegressionResult?
        var bestR2 = -Double.infinity
        
        // Try linear
        if let result = try? linear(xValues: xValues, yValues: yValues) {
            if result.coefficientOfDetermination > bestR2 {
                bestR2 = result.coefficientOfDetermination
                bestResult = result
            }
        }
        
        // Try quadratic (needs at least 3 points)
        if xValues.count >= 3 {
            if let result = try? quadratic(xValues: xValues, yValues: yValues) {
                if result.coefficientOfDetermination > bestR2 {
                    bestR2 = result.coefficientOfDetermination
                    bestResult = result
                }
            }
        }
        
        // Try logarithmic (needs x > 0)
        if let result = try? logarithmic(xValues: xValues, yValues: yValues) {
            if result.coefficientOfDetermination > bestR2 {
                bestR2 = result.coefficientOfDetermination
                bestResult = result
            }
        }
        
        // Try e-exponential (needs y > 0)
        if let result = try? eExponential(xValues: xValues, yValues: yValues) {
            if result.coefficientOfDetermination > bestR2 {
                bestR2 = result.coefficientOfDetermination
                bestResult = result
            }
        }
        
        // Try ab-exponential (needs y > 0)
        if let result = try? abExponential(xValues: xValues, yValues: yValues) {
            if result.coefficientOfDetermination > bestR2 {
                bestR2 = result.coefficientOfDetermination
                bestResult = result
            }
        }
        
        // Try power (needs x > 0 and y > 0)
        if let result = try? power(xValues: xValues, yValues: yValues) {
            if result.coefficientOfDetermination > bestR2 {
                bestR2 = result.coefficientOfDetermination
                bestResult = result
            }
        }
        
        // Try inverse (needs x ≠ 0)
        if let result = try? inverse(xValues: xValues, yValues: yValues) {
            if result.coefficientOfDetermination > bestR2 {
                bestR2 = result.coefficientOfDetermination
                bestResult = result
            }
        }
        
        guard let result = bestResult else {
            throw CalculatorError.invalidInput("Could not perform any regression on the given data")
        }
        
        return result
    }
    
    // MARK: - Helper Functions
    
    /// Validates regression input data
    private static func validateInput(xValues: [Double], yValues: [Double], minPoints: Int) throws {
        guard xValues.count >= minPoints else {
            throw CalculatorError.invalidInput("Need at least \(minPoints) data points")
        }
        
        guard xValues.count == yValues.count else {
            throw CalculatorError.invalidInput("X and Y arrays must have the same length")
        }
        
        guard xValues.allSatisfy({ $0.isFinite }) else {
            throw CalculatorError.invalidInput("X values must be finite")
        }
        
        guard yValues.allSatisfy({ $0.isFinite }) else {
            throw CalculatorError.invalidInput("Y values must be finite")
        }
    }
    
    /// Solves a 3x3 linear system using Cramer's rule
    private static func solveLinearSystem3x3(
        a11: Double, a12: Double, a13: Double,
        a21: Double, a22: Double, a23: Double,
        a31: Double, a32: Double, a33: Double,
        b1: Double, b2: Double, b3: Double
    ) throws -> (Double, Double, Double) {
        // Calculate determinant of coefficient matrix
        let det = a11 * (a22 * a33 - a23 * a32)
                - a12 * (a21 * a33 - a23 * a31)
                + a13 * (a21 * a32 - a22 * a31)
        
        guard abs(det) > 1e-15 else {
            throw CalculatorError.mathError("Singular matrix in quadratic regression")
        }
        
        // Calculate x1 (a) using Cramer's rule
        let detX1 = b1 * (a22 * a33 - a23 * a32)
                  - a12 * (b2 * a33 - a23 * b3)
                  + a13 * (b2 * a32 - a22 * b3)
        
        // Calculate x2 (b) using Cramer's rule
        let detX2 = a11 * (b2 * a33 - a23 * b3)
                  - b1 * (a21 * a33 - a23 * a31)
                  + a13 * (a21 * b3 - b2 * a31)
        
        // Calculate x3 (c) using Cramer's rule
        let detX3 = a11 * (a22 * b3 - b2 * a32)
                  - a12 * (a21 * b3 - b2 * a31)
                  + b1 * (a21 * a32 - a22 * a31)
        
        return (detX1 / det, detX2 / det, detX3 / det)
    }
}
