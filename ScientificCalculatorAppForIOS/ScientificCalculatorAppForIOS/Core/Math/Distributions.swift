import Foundation

// MARK: - NormalDistribution

/// Normal (Gaussian) distribution calculations
struct NormalDistribution: Equatable {
    /// Mean (μ)
    let mean: Double
    
    /// Standard deviation (σ)
    let stdDev: Double
    
    /// Variance (σ²)
    var variance: Double { stdDev * stdDev }
    
    /// Standard normal distribution (μ=0, σ=1)
    static let standard = try! NormalDistribution(mean: 0, stdDev: 1)
    
    // MARK: - Initialization
    
    init(mean: Double = 0, stdDev: Double = 1) throws {
        guard stdDev > 0 else {
            throw CalculatorError.invalidInput("Standard deviation must be positive")
        }
        self.mean = mean
        self.stdDev = stdDev
    }
    
    // MARK: - Probability Density Function
    
    /// PDF: f(x) = (1/σ√(2π)) × e^(-(x-μ)²/(2σ²))
    func pdf(_ x: Double) -> Double {
        let coefficient = 1.0 / (stdDev * sqrt(2.0 * Double.pi))
        let exponent = -pow(x - mean, 2) / (2.0 * variance)
        return coefficient * exp(exponent)
    }
    
    // MARK: - Cumulative Distribution Function
    
    /// CDF: P(X ≤ x) - probability that X is less than or equal to x
    func cdf(_ x: Double) -> Double {
        let z = zScore(x)
        return Distributions.standardNormalCdf(z)
    }
    
    /// Upper tail: P(X ≥ x)
    func upperCdf(_ x: Double) -> Double {
        return 1.0 - cdf(x)
    }
    
    /// Between: P(a ≤ X ≤ b)
    func between(_ a: Double, _ b: Double) -> Double {
        return cdf(b) - cdf(a)
    }
    
    // MARK: - Inverse CDF (Quantile Function)
    
    /// Inverse CDF: find x such that P(X ≤ x) = p
    /// - Parameter p: Probability (0 < p < 1)
    func inverseCdf(_ p: Double) throws -> Double {
        let z = try Distributions.standardNormalInverseCdf(p)
        return fromZScore(z)
    }
    
    /// Inverse upper: find x such that P(X ≥ x) = p
    func inverseUpperCdf(_ p: Double) throws -> Double {
        return try inverseCdf(1.0 - p)
    }
    
    // MARK: - Z-Score
    
    /// Converts a value to z-score: z = (x - μ) / σ
    func zScore(_ x: Double) -> Double {
        return (x - mean) / stdDev
    }
    
    /// Converts a z-score to value: x = μ + z·σ
    func fromZScore(_ z: Double) -> Double {
        return mean + z * stdDev
    }
}

// MARK: - BinomialDistribution

/// Binomial distribution calculations
struct BinomialDistribution: Equatable {
    /// Number of trials (n)
    let trials: Int
    
    /// Probability of success (p)
    let probability: Double
    
    /// Mean: μ = np
    var mean: Double { Double(trials) * probability }
    
    /// Variance: σ² = np(1-p)
    var variance: Double { Double(trials) * probability * (1 - probability) }
    
    /// Standard deviation
    var stdDev: Double { sqrt(variance) }
    
    // MARK: - Initialization
    
    init(trials: Int, probability: Double) throws {
        guard trials > 0 else {
            throw CalculatorError.invalidInput("Number of trials must be positive")
        }
        guard probability >= 0 && probability <= 1 else {
            throw CalculatorError.invalidInput("Probability must be between 0 and 1")
        }
        self.trials = trials
        self.probability = probability
    }
    
    // MARK: - Probability Mass Function
    
    /// PMF: P(X = k) = C(n,k) × p^k × (1-p)^(n-k)
    func pmf(_ k: Int) throws -> Double {
        guard k >= 0 && k <= trials else {
            throw CalculatorError.invalidInput("k must be between 0 and n")
        }
        
        // Handle edge cases
        if probability == 0 {
            return k == 0 ? 1.0 : 0.0
        }
        if probability == 1 {
            return k == trials ? 1.0 : 0.0
        }
        
        // Use log-space calculation to avoid overflow
        let logCoeff = try Distributions.logCombination(n: trials, k: k)
        let logProb = Double(k) * log(probability) + Double(trials - k) * log(1 - probability)
        
        return exp(logCoeff + logProb)
    }
    
    // MARK: - Cumulative Distribution Function
    
    /// CDF: P(X ≤ k) - at most k successes
    func cdf(_ k: Int) throws -> Double {
        guard k >= 0 else {
            return 0.0
        }
        guard k < trials else {
            return 1.0
        }
        
        var sum = 0.0
        for i in 0...k {
            sum += try pmf(i)
        }
        return min(sum, 1.0)
    }
    
    /// Upper tail: P(X ≥ k) - at least k successes
    func upperCdf(_ k: Int) throws -> Double {
        guard k > 0 else {
            return 1.0
        }
        guard k <= trials else {
            return 0.0
        }
        
        let cdfResult = try cdf(k - 1)
        return 1.0 - cdfResult
    }
    
    /// Exact: P(X = k) - exactly k successes (same as pmf)
    func exactly(_ k: Int) throws -> Double {
        return try pmf(k)
    }
    
    /// Between: P(a ≤ X ≤ b)
    func between(_ a: Int, _ b: Int) throws -> Double {
        guard a <= b else {
            throw CalculatorError.invalidInput("Lower bound must be less than or equal to upper bound")
        }
        
        if a <= 0 {
            return try cdf(b)
        }
        
        return try cdf(b) - cdf(a - 1)
    }
}

// MARK: - PoissonDistribution

/// Poisson distribution calculations
struct PoissonDistribution: Equatable {
    /// Rate parameter (λ) - average number of events
    let lambda: Double
    
    /// Mean: μ = λ
    var mean: Double { lambda }
    
    /// Variance: σ² = λ
    var variance: Double { lambda }
    
    /// Standard deviation
    var stdDev: Double { sqrt(lambda) }
    
    // MARK: - Initialization
    
    init(lambda: Double) throws {
        guard lambda > 0 else {
            throw CalculatorError.invalidInput("Lambda must be positive")
        }
        self.lambda = lambda
    }
    
    // MARK: - Probability Mass Function
    
    /// PMF: P(X = k) = (λ^k × e^(-λ)) / k!
    func pmf(_ k: Int) throws -> Double {
        guard k >= 0 else {
            throw CalculatorError.invalidInput("k must be non-negative")
        }
        
        // Use log-space calculation for numerical stability
        // log P(X = k) = k×log(λ) - λ - log(k!)
        let logFactorialK = try Distributions.logFactorial(k)
        let logProb = Double(k) * log(lambda) - lambda - logFactorialK
        
        return exp(logProb)
    }
    
    // MARK: - Cumulative Distribution Function
    
    /// CDF: P(X ≤ k) - at most k events
    func cdf(_ k: Int) throws -> Double {
        guard k >= 0 else {
            return 0.0
        }
        
        // Use regularized incomplete gamma function
        // P(X ≤ k) = Q(k+1, λ) = Γ(k+1, λ) / Γ(k+1)
        return try Distributions.regularizedGammaQ(Double(k + 1), lambda)
    }
    
    /// Upper tail: P(X ≥ k) - at least k events
    func upperCdf(_ k: Int) throws -> Double {
        guard k > 0 else {
            return 1.0
        }
        
        let cdfResult = try cdf(k - 1)
        return 1.0 - cdfResult
    }
    
    /// Exact: P(X = k) - exactly k events (same as pmf)
    func exactly(_ k: Int) throws -> Double {
        return try pmf(k)
    }
    
    /// Between: P(a ≤ X ≤ b)
    func between(_ a: Int, _ b: Int) throws -> Double {
        guard a <= b else {
            throw CalculatorError.invalidInput("Lower bound must be less than or equal to upper bound")
        }
        
        if a <= 0 {
            return try cdf(b)
        }
        
        return try cdf(b) - cdf(a - 1)
    }
}

// MARK: - Distributions

/// Distribution calculation utilities
struct Distributions {
    
    // MARK: - Error Function
    
    /// Error function: erf(x) = (2/√π) ∫₀ˣ e^(-t²) dt
    /// Uses Abramowitz and Stegun approximation (maximum error: 1.5×10⁻⁷)
    static func erf(_ x: Double) -> Double {
        let sign = x < 0 ? -1.0 : 1.0
        let absX = abs(x)
        
        // Constants for Abramowitz and Stegun approximation
        let a1 =  0.254829592
        let a2 = -0.284496736
        let a3 =  1.421413741
        let a4 = -1.453152027
        let a5 =  1.061405429
        let p  =  0.3275911
        
        let t = 1.0 / (1.0 + p * absX)
        let y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-absX * absX)
        
        return sign * y
    }
    
    /// Complementary error function: erfc(x) = 1 - erf(x)
    static func erfc(_ x: Double) -> Double {
        return 1.0 - erf(x)
    }
    
    // MARK: - Standard Normal
    
    /// Standard normal CDF: Φ(z) = (1/2) × [1 + erf(z/√2)]
    static func standardNormalCdf(_ z: Double) -> Double {
        return 0.5 * (1.0 + erf(z / sqrt(2.0)))
    }
    
    /// Standard normal inverse CDF (probit function)
    /// Uses Acklam's algorithm for high precision
    static func standardNormalInverseCdf(_ p: Double) throws -> Double {
        guard p > 0 && p < 1 else {
            throw CalculatorError.invalidInput("Probability must be between 0 and 1 (exclusive)")
        }
        
        // Handle extreme values
        if p < 1e-300 {
            return -38.4 // Approximate lower bound
        }
        if p > 1.0 - 1e-16 {
            return 8.2 // Approximate upper bound
        }
        
        // Coefficients for Acklam's algorithm
        let a1 = -3.969683028665376e+01
        let a2 =  2.209460984245205e+02
        let a3 = -2.759285104469687e+02
        let a4 =  1.383577518672690e+02
        let a5 = -3.066479806614716e+01
        let a6 =  2.506628277459239e+00
        
        let b1 = -5.447609879822406e+01
        let b2 =  1.615858368580409e+02
        let b3 = -1.556989798598866e+02
        let b4 =  6.680131188771972e+01
        let b5 = -1.328068155288572e+01
        
        let c1 = -7.784894002430293e-03
        let c2 = -3.223964580411365e-01
        let c3 = -2.400758277161838e+00
        let c4 = -2.549732539343734e+00
        let c5 =  4.374664141464968e+00
        let c6 =  2.938163982698783e+00
        
        let d1 =  7.784695709041462e-03
        let d2 =  3.224671290700398e-01
        let d3 =  2.445134137142996e+00
        let d4 =  3.754408661907416e+00
        
        let pLow = 0.02425
        let pHigh = 1.0 - pLow
        
        var q: Double
        var r: Double
        var x: Double
        
        if p < pLow {
            // Rational approximation for lower region
            q = sqrt(-2.0 * log(p))
            x = (((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) /
                ((((d1 * q + d2) * q + d3) * q + d4) * q + 1.0)
        } else if p <= pHigh {
            // Rational approximation for central region
            q = p - 0.5
            r = q * q
            x = (((((a1 * r + a2) * r + a3) * r + a4) * r + a5) * r + a6) * q /
                (((((b1 * r + b2) * r + b3) * r + b4) * r + b5) * r + 1.0)
        } else {
            // Rational approximation for upper region
            q = sqrt(-2.0 * log(1.0 - p))
            x = -(((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) /
                 ((((d1 * q + d2) * q + d3) * q + d4) * q + 1.0)
        }
        
        // Refinement using Halley's method
        let e = 0.5 * erfc(-x / sqrt(2.0)) - p
        let u = e * sqrt(2.0 * Double.pi) * exp(x * x / 2.0)
        x = x - u / (1.0 + x * u / 2.0)
        
        return x
    }
    
    // MARK: - Gamma Function
    
    /// Gamma function: Γ(n) = (n-1)! for positive integers
    /// Uses Lanczos approximation for real numbers
    static func gamma(_ x: Double) throws -> Double {
        guard x > 0 || x != floor(x) else {
            throw CalculatorError.domainError("Gamma function undefined for non-positive integers")
        }
        
        if x < 0.5 {
            // Reflection formula: Γ(1-z)Γ(z) = π/sin(πz)
            return Double.pi / (sin(Double.pi * x) * (try gamma(1.0 - x)))
        }
        
        let z = x - 1.0
        
        // Lanczos coefficients
        let g = 7.0
        let c: [Double] = [
            0.99999999999980993,
            676.5203681218851,
            -1259.1392167224028,
            771.32342877765313,
            -176.61502916214059,
            12.507343278686905,
            -0.13857109526572012,
            9.9843695780195716e-6,
            1.5056327351493116e-7
        ]
        
        var sum = c[0]
        for i in 1..<c.count {
            sum += c[i] / (z + Double(i))
        }
        
        let t = z + g + 0.5
        let result = sqrt(2.0 * Double.pi) * pow(t, z + 0.5) * exp(-t) * sum
        
        guard result.isFinite else {
            throw CalculatorError.overflow
        }
        
        return result
    }
    
    /// Log gamma function (for large values)
    static func logGamma(_ x: Double) throws -> Double {
        guard x > 0 else {
            throw CalculatorError.domainError("Log gamma requires positive argument")
        }
        
        if x < 12.0 {
            return log(try gamma(x))
        }
        
        // Stirling's approximation for large values
        let c: [Double] = [
            1.0/12.0,
            -1.0/360.0,
            1.0/1260.0,
            -1.0/1680.0,
            1.0/1188.0
        ]
        
        var sum = 0.0
        var xPower = x
        for coeff in c {
            sum += coeff / xPower
            xPower *= x * x
        }
        
        return (x - 0.5) * log(x) - x + 0.5 * log(2.0 * Double.pi) + sum
    }
    
    /// Log factorial: log(n!)
    static func logFactorial(_ n: Int) throws -> Double {
        guard n >= 0 else {
            throw CalculatorError.domainError("Factorial requires non-negative integer")
        }
        
        if n <= 1 {
            return 0.0
        }
        
        return try logGamma(Double(n + 1))
    }
    
    /// Log combination: log(C(n,k))
    static func logCombination(n: Int, k: Int) throws -> Double {
        guard n >= 0 && k >= 0 && k <= n else {
            throw CalculatorError.domainError("Invalid combination parameters")
        }
        
        if k == 0 || k == n {
            return 0.0
        }
        
        return try logFactorial(n) - logFactorial(k) - logFactorial(n - k)
    }
    
    // MARK: - Incomplete Gamma
    
    /// Lower incomplete gamma function using series expansion
    /// γ(a, x) = x^a × e^(-x) × Σ(x^n / Γ(a+n+1))
    static func lowerIncompleteGamma(_ a: Double, _ x: Double) throws -> Double {
        guard a > 0 else {
            throw CalculatorError.domainError("Parameter 'a' must be positive")
        }
        guard x >= 0 else {
            throw CalculatorError.domainError("Parameter 'x' must be non-negative")
        }
        
        if x == 0 {
            return 0.0
        }
        
        // Use series expansion for small x
        if x < a + 1.0 {
            return try lowerIncompleteGammaSeries(a, x)
        }
        
        // Use continued fraction for large x
        return try gamma(a) - upperIncompleteGammaCF(a, x)
    }
    
    /// Series expansion for lower incomplete gamma
    private static func lowerIncompleteGammaSeries(_ a: Double, _ x: Double) throws -> Double {
        let maxIterations = 200
        let epsilon = 1e-15
        
        var sum = 1.0 / a
        var term = 1.0 / a
        
        for n in 1..<maxIterations {
            term *= x / (a + Double(n))
            sum += term
            
            if abs(term) < abs(sum) * epsilon {
                break
            }
        }
        
        return exp(-x + a * log(x)) * sum
    }
    
    /// Continued fraction for upper incomplete gamma
    private static func upperIncompleteGammaCF(_ a: Double, _ x: Double) throws -> Double {
        let maxIterations = 200
        let epsilon = 1e-15
        
        var b = x + 1.0 - a
        var c = 1.0 / 1e-30
        var d = 1.0 / b
        var h = d
        
        for i in 1..<maxIterations {
            let an = -Double(i) * (Double(i) - a)
            b += 2.0
            d = an * d + b
            if abs(d) < 1e-30 { d = 1e-30 }
            c = b + an / c
            if abs(c) < 1e-30 { c = 1e-30 }
            d = 1.0 / d
            let delta = d * c
            h *= delta
            
            if abs(delta - 1.0) < epsilon {
                break
            }
        }
        
        return exp(-x + a * log(x)) * h
    }
    
    /// Regularized lower incomplete gamma: P(a, x) = γ(a, x) / Γ(a)
    static func regularizedGammaP(_ a: Double, _ x: Double) throws -> Double {
        guard a > 0 else {
            throw CalculatorError.domainError("Parameter 'a' must be positive")
        }
        guard x >= 0 else {
            throw CalculatorError.domainError("Parameter 'x' must be non-negative")
        }
        
        if x == 0 {
            return 0.0
        }
        
        // Use series for x < a + 1, continued fraction otherwise
        if x < a + 1.0 {
            return try regularizedGammaPSeries(a, x)
        }
        
        let gammaQCF = try regularizedGammaQCF(a, x)
        return 1.0 - gammaQCF
    }
    
    /// Regularized upper incomplete gamma: Q(a, x) = Γ(a, x) / Γ(a) = 1 - P(a, x)
    static func regularizedGammaQ(_ a: Double, _ x: Double) throws -> Double {
        guard a > 0 else {
            throw CalculatorError.domainError("Parameter 'a' must be positive")
        }
        guard x >= 0 else {
            throw CalculatorError.domainError("Parameter 'x' must be non-negative")
        }
        
        if x == 0 {
            return 1.0
        }
        
        // Use continued fraction for x >= a + 1, series otherwise
        if x >= a + 1.0 {
            return try regularizedGammaQCF(a, x)
        }
        
        let gammaPSeries = try regularizedGammaPSeries(a, x)
        return 1.0 - gammaPSeries
    }
    
    /// Series expansion for regularized gamma P
    private static func regularizedGammaPSeries(_ a: Double, _ x: Double) throws -> Double {
        let maxIterations = 200
        let epsilon = 1e-15
        
        var ap = a
        var sum = 1.0 / a
        var term = sum
        
        for _ in 1..<maxIterations {
            ap += 1.0
            term *= x / ap
            sum += term
            
            if abs(term) < abs(sum) * epsilon {
                break
            }
        }
        
        let logGammaA = try logGamma(a)
        return sum * exp(-x + a * log(x) - logGammaA)
    }
    
    /// Continued fraction for regularized gamma Q
    private static func regularizedGammaQCF(_ a: Double, _ x: Double) throws -> Double {
        let maxIterations = 200
        let epsilon = 1e-15
        
        var b = x + 1.0 - a
        var c = 1.0 / 1e-30
        var d = 1.0 / b
        var h = d
        
        for i in 1..<maxIterations {
            let an = -Double(i) * (Double(i) - a)
            b += 2.0
            d = an * d + b
            if abs(d) < 1e-30 { d = 1e-30 }
            c = b + an / c
            if abs(c) < 1e-30 { c = 1e-30 }
            d = 1.0 / d
            let delta = d * c
            h *= delta
            
            if abs(delta - 1.0) < epsilon {
                break
            }
        }
        
        let logGammaA = try logGamma(a)
        return exp(-x + a * log(x) - logGammaA) * h
    }
}
