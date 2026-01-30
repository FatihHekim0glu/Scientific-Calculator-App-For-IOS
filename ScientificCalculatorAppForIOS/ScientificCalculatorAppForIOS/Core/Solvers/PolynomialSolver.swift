import Foundation

// MARK: - PolynomialRoots

/// Results of solving a polynomial equation
struct PolynomialRoots: Equatable {
    /// Degree of the polynomial
    let degree: Int
    
    /// Real roots only
    let realRoots: [Double]
    
    /// Complex roots (non-real)
    let complexRoots: [ComplexNumber]
    
    /// All roots as complex numbers (for uniform handling)
    var allRoots: [ComplexNumber] {
        realRoots.map { ComplexNumber(real: $0, imaginary: 0) } + complexRoots
    }
    
    /// Whether all roots are real
    var allReal: Bool { complexRoots.isEmpty }
    
    /// Number of distinct roots
    var distinctRootCount: Int { realRoots.count + complexRoots.count }
}

// MARK: - PolynomialSolver

/// Solves polynomial equations of degree 2, 3, and 4
struct PolynomialSolver {
    
    /// Epsilon for zero comparisons
    private static let epsilon: Double = 1e-12
    
    // MARK: - Quadratic (ax² + bx + c = 0)
    
    /// Solves quadratic equation ax² + bx + c = 0
    /// - Parameters:
    ///   - a: Coefficient of x²
    ///   - b: Coefficient of x
    ///   - c: Constant term
    /// - Returns: Two roots (may be equal for repeated root, may be complex)
    static func solveQuadratic(a: Double, b: Double, c: Double) throws -> PolynomialRoots {
        guard abs(a) > epsilon else {
            throw CalculatorError.invalidInput("Coefficient 'a' cannot be zero for quadratic")
        }
        
        let discriminant = b * b - 4 * a * c
        
        if discriminant > epsilon {
            // Two distinct real roots
            let sqrtD = sqrt(discriminant)
            // Use more numerically stable formula
            let q = -0.5 * (b + (b >= 0 ? 1 : -1) * sqrtD)
            let x1 = q / a
            let x2 = c / q
            return PolynomialRoots(degree: 2, realRoots: [x1, x2], complexRoots: [])
            
        } else if abs(discriminant) <= epsilon {
            // Repeated real root
            let x = -b / (2 * a)
            return PolynomialRoots(degree: 2, realRoots: [x, x], complexRoots: [])
            
        } else {
            // Complex conjugate roots
            let realPart = -b / (2 * a)
            let imagPart = sqrt(-discriminant) / (2 * a)
            let z1 = ComplexNumber(real: realPart, imaginary: imagPart)
            let z2 = ComplexNumber(real: realPart, imaginary: -imagPart)
            return PolynomialRoots(degree: 2, realRoots: [], complexRoots: [z1, z2])
        }
    }
    
    // MARK: - Cubic (ax³ + bx² + cx + d = 0)
    
    /// Solves cubic equation ax³ + bx² + cx + d = 0 using Cardano's formula
    /// - Parameters:
    ///   - a: Coefficient of x³
    ///   - b: Coefficient of x²
    ///   - c: Coefficient of x
    ///   - d: Constant term
    /// - Returns: Three roots (one or three real roots)
    static func solveCubic(a: Double, b: Double, c: Double, d: Double) throws -> PolynomialRoots {
        guard abs(a) > epsilon else {
            throw CalculatorError.invalidInput("Leading coefficient cannot be zero")
        }
        
        // Normalize: x³ + px² + qx + r = 0
        let p = b / a
        let q = c / a
        let r = d / a
        
        // Substitution x = t - p/3 gives: t³ + At + B = 0 (depressed cubic)
        let A = q - p * p / 3.0
        let B = (2.0 * p * p * p - 9.0 * p * q + 27.0 * r) / 27.0
        
        // Discriminant: Δ = -(4A³ + 27B²)
        let discriminant = -(4.0 * A * A * A + 27.0 * B * B)
        
        let offset = p / 3.0
        
        if discriminant > epsilon {
            // Three distinct real roots - use trigonometric method
            let m = 2.0 * sqrt(-A / 3.0)
            let cosArg = 3.0 * B / (A * m)
            // Clamp to [-1, 1] for numerical stability
            let clampedCosArg = max(-1.0, min(1.0, cosArg))
            let theta = acos(clampedCosArg) / 3.0
            
            let t1 = m * cos(theta)
            let t2 = m * cos(theta - 2.0 * .pi / 3.0)
            let t3 = m * cos(theta - 4.0 * .pi / 3.0)
            
            return PolynomialRoots(
                degree: 3,
                realRoots: [t1 - offset, t2 - offset, t3 - offset],
                complexRoots: []
            )
            
        } else if abs(discriminant) <= epsilon {
            // Multiple root case
            if abs(A) < epsilon && abs(B) < epsilon {
                // Triple root at 0
                return PolynomialRoots(
                    degree: 3,
                    realRoots: [-offset, -offset, -offset],
                    complexRoots: []
                )
            }
            
            // One single root and one double root
            let doubleRoot = 3.0 * B / (2.0 * A)
            let singleRoot = -3.0 * B / A
            
            return PolynomialRoots(
                degree: 3,
                realRoots: [singleRoot - offset, doubleRoot - offset, doubleRoot - offset],
                complexRoots: []
            )
            
        } else {
            // One real root, two complex conjugate roots - use Cardano's formula
            let sqrtDiscrim = sqrt(-discriminant / 27.0)
            
            // Calculate cube roots
            let term1 = -B / 2.0 + sqrtDiscrim / 2.0
            let term2 = -B / 2.0 - sqrtDiscrim / 2.0
            
            let cubeRoot1 = cbrt(term1)
            let cubeRoot2 = cbrt(term2)
            
            // Real root
            let t1 = cubeRoot1 + cubeRoot2
            let realRoot = t1 - offset
            
            // Complex roots using cube roots of unity
            let omega = ComplexNumber(real: -0.5, imaginary: sqrt(3.0) / 2.0)
            let omega2 = ComplexNumber(real: -0.5, imaginary: -sqrt(3.0) / 2.0)
            
            let cr1 = ComplexNumber(cubeRoot1)
            let cr2 = ComplexNumber(cubeRoot2)
            
            let t2Complex = omega * cr1 + omega2 * cr2
            let t3Complex = omega2 * cr1 + omega * cr2
            
            let complexRoot1 = ComplexNumber(real: t2Complex.real - offset, imaginary: t2Complex.imaginary)
            let complexRoot2 = ComplexNumber(real: t3Complex.real - offset, imaginary: t3Complex.imaginary)
            
            return PolynomialRoots(
                degree: 3,
                realRoots: [realRoot],
                complexRoots: [complexRoot1, complexRoot2]
            )
        }
    }
    
    /// Cube root that preserves sign for negative numbers
    private static func cbrt(_ x: Double) -> Double {
        if x >= 0 {
            return pow(x, 1.0 / 3.0)
        } else {
            return -pow(-x, 1.0 / 3.0)
        }
    }
    
    // MARK: - Quartic (ax⁴ + bx³ + cx² + dx + e = 0)
    
    /// Solves quartic equation ax⁴ + bx³ + cx² + dx + e = 0 using Ferrari's method
    /// - Parameters:
    ///   - a: Coefficient of x⁴
    ///   - b: Coefficient of x³
    ///   - c: Coefficient of x²
    ///   - d: Coefficient of x
    ///   - e: Constant term
    /// - Returns: Four roots (0, 2, or 4 real roots)
    static func solveQuartic(a: Double, b: Double, c: Double, d: Double, e: Double) throws -> PolynomialRoots {
        guard abs(a) > epsilon else {
            throw CalculatorError.invalidInput("Leading coefficient cannot be zero")
        }
        
        // Normalize coefficients
        let p = b / a
        let q = c / a
        let r = d / a
        let s = e / a
        
        // Depress the quartic: substitute x = y - p/4
        // Result: y⁴ + Py² + Qy + R = 0
        let p2 = p * p
        let p3 = p2 * p
        let p4 = p3 * p
        
        let P = q - 3.0 * p2 / 8.0
        let Q = p3 / 8.0 - p * q / 2.0 + r
        let R = -3.0 * p4 / 256.0 + p2 * q / 16.0 - p * r / 4.0 + s
        
        let offset = p / 4.0
        
        // Special case: biquadratic (Q = 0)
        if abs(Q) < epsilon {
            return try solveBiquadratic(P: P, R: R, offset: offset)
        }
        
        // Solve the resolvent cubic: m³ + (P/2)m² + ((P²-4R)/16)m - Q²/64 = 0
        let resolventRoots = try solveCubic(
            a: 1,
            b: P / 2.0,
            c: (P * P - 4.0 * R) / 16.0,
            d: -Q * Q / 64.0
        )
        
        // Find a suitable real root m > 0 (or any real root if none positive)
        var m: Double
        if let positiveRoot = resolventRoots.realRoots.first(where: { $0 > epsilon }) {
            m = positiveRoot
        } else if let anyRoot = resolventRoots.realRoots.first(where: { abs($0) > epsilon }) {
            m = anyRoot
        } else {
            // Fallback to the first root
            m = resolventRoots.realRoots.first ?? 0
        }
        
        // Factor into two quadratics using m
        // y⁴ + Py² + Qy + R = (y² + √(2m)y + (P/2 + m - Q/(2√(2m))))(y² - √(2m)y + (P/2 + m + Q/(2√(2m))))
        
        let sqrt2m = sqrt(abs(2.0 * m))
        
        var realRoots: [Double] = []
        var complexRoots: [ComplexNumber] = []
        
        if sqrt2m > epsilon {
            let k = Q / (2.0 * sqrt2m)
            
            // First quadratic: y² + √(2m)y + (P/2 + m - k) = 0
            let a1 = 1.0
            let b1 = sqrt2m
            let c1 = P / 2.0 + m - k
            
            // Second quadratic: y² - √(2m)y + (P/2 + m + k) = 0
            let a2 = 1.0
            let b2 = -sqrt2m
            let c2 = P / 2.0 + m + k
            
            // Solve first quadratic
            let disc1 = b1 * b1 - 4.0 * a1 * c1
            if disc1 >= -epsilon {
                if disc1 > epsilon {
                    let sqrtD = sqrt(max(0, disc1))
                    realRoots.append((-b1 + sqrtD) / 2.0 - offset)
                    realRoots.append((-b1 - sqrtD) / 2.0 - offset)
                } else {
                    let root = -b1 / 2.0 - offset
                    realRoots.append(root)
                    realRoots.append(root)
                }
            } else {
                let realPart = -b1 / 2.0 - offset
                let imagPart = sqrt(-disc1) / 2.0
                complexRoots.append(ComplexNumber(real: realPart, imaginary: imagPart))
                complexRoots.append(ComplexNumber(real: realPart, imaginary: -imagPart))
            }
            
            // Solve second quadratic
            let disc2 = b2 * b2 - 4.0 * a2 * c2
            if disc2 >= -epsilon {
                if disc2 > epsilon {
                    let sqrtD = sqrt(max(0, disc2))
                    realRoots.append((-b2 + sqrtD) / 2.0 - offset)
                    realRoots.append((-b2 - sqrtD) / 2.0 - offset)
                } else {
                    let root = -b2 / 2.0 - offset
                    realRoots.append(root)
                    realRoots.append(root)
                }
            } else {
                let realPart = -b2 / 2.0 - offset
                let imagPart = sqrt(-disc2) / 2.0
                complexRoots.append(ComplexNumber(real: realPart, imaginary: imagPart))
                complexRoots.append(ComplexNumber(real: realPart, imaginary: -imagPart))
            }
        } else {
            // m ≈ 0, handle specially
            return try solveBiquadratic(P: P, R: R, offset: offset)
        }
        
        return PolynomialRoots(degree: 4, realRoots: realRoots, complexRoots: complexRoots)
    }
    
    /// Solves biquadratic equation y⁴ + Py² + R = 0 (when Q = 0)
    private static func solveBiquadratic(P: Double, R: Double, offset: Double) throws -> PolynomialRoots {
        // Substitute z = y², solve z² + Pz + R = 0
        let zRoots = try solveQuadratic(a: 1, b: P, c: R)
        
        var realRoots: [Double] = []
        var complexRoots: [ComplexNumber] = []
        
        for z in zRoots.realRoots {
            if z > epsilon {
                // y = ±√z
                let sqrtZ = sqrt(z)
                realRoots.append(sqrtZ - offset)
                realRoots.append(-sqrtZ - offset)
            } else if abs(z) <= epsilon {
                // y = 0 (double root)
                realRoots.append(-offset)
                realRoots.append(-offset)
            } else {
                // z < 0, y = ±i√|z|
                let sqrtAbsZ = sqrt(-z)
                complexRoots.append(ComplexNumber(real: -offset, imaginary: sqrtAbsZ))
                complexRoots.append(ComplexNumber(real: -offset, imaginary: -sqrtAbsZ))
            }
        }
        
        // Handle complex z values
        for z in zRoots.complexRoots {
            // y² = z (complex), y = ±√z
            let root = z.squareRoot()
            complexRoots.append(ComplexNumber(real: root.real - offset, imaginary: root.imaginary))
            complexRoots.append(ComplexNumber(real: -root.real - offset, imaginary: -root.imaginary))
        }
        
        return PolynomialRoots(degree: 4, realRoots: realRoots, complexRoots: complexRoots)
    }
    
    // MARK: - General Solver
    
    /// Solves a polynomial given coefficients [aₙ, aₙ₋₁, ..., a₁, a₀]
    /// Highest degree coefficient first
    /// - Parameter coefficients: Array of coefficients from highest to lowest power
    /// - Returns: Roots of the polynomial
    static func solve(coefficients: [Double]) throws -> PolynomialRoots {
        // Remove leading zeros
        var coeffs = coefficients
        while coeffs.count > 1 && abs(coeffs[0]) < epsilon {
            coeffs.removeFirst()
        }
        
        guard !coeffs.isEmpty else {
            throw CalculatorError.invalidInput("Polynomial must have at least one non-zero coefficient")
        }
        
        let degree = coeffs.count - 1
        
        switch degree {
        case 0:
            // Constant polynomial
            if abs(coeffs[0]) < epsilon {
                throw CalculatorError.invalidInput("Zero polynomial has infinite roots")
            }
            return PolynomialRoots(degree: 0, realRoots: [], complexRoots: [])
            
        case 1:
            // Linear: ax + b = 0 → x = -b/a
            let root = -coeffs[1] / coeffs[0]
            return PolynomialRoots(degree: 1, realRoots: [root], complexRoots: [])
            
        case 2:
            return try solveQuadratic(a: coeffs[0], b: coeffs[1], c: coeffs[2])
            
        case 3:
            return try solveCubic(a: coeffs[0], b: coeffs[1], c: coeffs[2], d: coeffs[3])
            
        case 4:
            return try solveQuartic(a: coeffs[0], b: coeffs[1], c: coeffs[2], d: coeffs[3], e: coeffs[4])
            
        default:
            throw CalculatorError.invalidInput("Polynomials of degree \(degree) are not supported (max degree: 4)")
        }
    }
    
    // MARK: - Polynomial Evaluation
    
    /// Evaluates polynomial at x using Horner's method
    /// - Parameters:
    ///   - coefficients: Coefficients [aₙ, aₙ₋₁, ..., a₁, a₀]
    ///   - x: Value to evaluate at
    /// - Returns: p(x)
    static func evaluate(coefficients: [Double], at x: Double) -> Double {
        var result = 0.0
        for coeff in coefficients {
            result = result * x + coeff
        }
        return result
    }
    
    /// Evaluates polynomial at complex z using Horner's method
    /// - Parameters:
    ///   - coefficients: Coefficients [aₙ, aₙ₋₁, ..., a₁, a₀]
    ///   - z: Complex value to evaluate at
    /// - Returns: p(z)
    static func evaluate(coefficients: [Double], at z: ComplexNumber) -> ComplexNumber {
        var result = ComplexNumber.zero
        for coeff in coefficients {
            result = result * z + ComplexNumber(coeff)
        }
        return result
    }
    
    // MARK: - Utility Methods
    
    /// Verifies a root by evaluating the polynomial
    /// - Parameters:
    ///   - coefficients: Polynomial coefficients
    ///   - root: Root to verify
    ///   - tolerance: Tolerance for considering value as zero
    /// - Returns: True if root is valid within tolerance
    static func verifyRoot(coefficients: [Double], root: Double, tolerance: Double = 1e-8) -> Bool {
        let value = evaluate(coefficients: coefficients, at: root)
        return abs(value) < tolerance
    }
    
    /// Verifies a complex root by evaluating the polynomial
    static func verifyRoot(coefficients: [Double], root: ComplexNumber, tolerance: Double = 1e-8) -> Bool {
        let value = evaluate(coefficients: coefficients, at: root)
        return value.magnitude < tolerance
    }
    
    /// Returns the derivative polynomial coefficients
    /// - Parameter coefficients: Original polynomial coefficients [aₙ, ..., a₁, a₀]
    /// - Returns: Derivative coefficients [n·aₙ, ..., 2·a₂, a₁]
    static func derivative(coefficients: [Double]) -> [Double] {
        guard coefficients.count > 1 else {
            return [0]
        }
        
        let n = coefficients.count - 1
        var derivCoeffs: [Double] = []
        
        for i in 0..<n {
            let power = n - i
            derivCoeffs.append(Double(power) * coefficients[i])
        }
        
        return derivCoeffs
    }
    
    /// Formats polynomial as string for display
    /// - Parameter coefficients: Polynomial coefficients [aₙ, ..., a₁, a₀]
    /// - Returns: Formatted string like "x³ - 2x² + x - 1"
    static func format(coefficients: [Double]) -> String {
        let n = coefficients.count - 1
        var terms: [String] = []
        
        for (i, coeff) in coefficients.enumerated() {
            let power = n - i
            
            if abs(coeff) < epsilon {
                continue
            }
            
            var term = ""
            
            // Handle sign
            if coeff < 0 {
                term = terms.isEmpty ? "-" : "- "
            } else if !terms.isEmpty {
                term = "+ "
            }
            
            let absCoeff = abs(coeff)
            
            // Build term
            if power == 0 {
                term += formatNumber(absCoeff)
            } else if absCoeff == 1.0 {
                term += power == 1 ? "x" : "x\(superscript(power))"
            } else {
                term += formatNumber(absCoeff)
                term += power == 1 ? "x" : "x\(superscript(power))"
            }
            
            terms.append(term)
        }
        
        return terms.isEmpty ? "0" : terms.joined(separator: " ")
    }
    
    private static func formatNumber(_ value: Double) -> String {
        if value == floor(value) && abs(value) < 1e10 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.6g", value)
    }
    
    private static func superscript(_ n: Int) -> String {
        let superscripts: [Character] = ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"]
        return String(n).map { char in
            if let digit = Int(String(char)), digit < superscripts.count {
                return superscripts[digit]
            }
            return char
        }.reduce("") { String($0) + String($1) }
    }
}
