import Foundation
import SwiftUI

// MARK: - DistributionType

/// Types of probability distributions
enum DistributionType: String, CaseIterable {
    case normal = "Normal"
    case binomial = "Binomial"
    case poisson = "Poisson"
    
    /// Parameters required for this distribution
    var requiredParameters: [String] {
        switch self {
        case .normal: return ["μ", "σ"]
        case .binomial: return ["n", "p"]
        case .poisson: return ["λ"]
        }
    }
    
    /// Whether this distribution is continuous
    var isContinuous: Bool {
        switch self {
        case .normal: return true
        case .binomial, .poisson: return false
        }
    }
    
    /// Display description
    var description: String {
        switch self {
        case .normal: return "Normal (Gaussian)"
        case .binomial: return "Binomial"
        case .poisson: return "Poisson"
        }
    }
}

// MARK: - DistributionCalculationType

/// Type of distribution calculation
enum DistributionCalculationType: String, CaseIterable {
    case lessThanOrEqual = "P(X ≤ x)"
    case greaterThanOrEqual = "P(X ≥ x)"
    case between = "P(a ≤ X ≤ b)"
    case exactly = "P(X = x)"
    case inverseLower = "Inverse (lower)"
    case inverseUpper = "Inverse (upper)"
    
    /// Whether this calculation type is available for continuous distributions
    var availableForContinuous: Bool {
        self != .exactly
    }
    
    /// Whether this calculation type is available for discrete distributions
    var availableForDiscrete: Bool {
        self != .inverseLower && self != .inverseUpper
    }
    
    /// Display name
    var displayName: String {
        switch self {
        case .lessThanOrEqual: return "At most x"
        case .greaterThanOrEqual: return "At least x"
        case .between: return "Between a and b"
        case .exactly: return "Exactly x"
        case .inverseLower: return "Inverse (lower tail)"
        case .inverseUpper: return "Inverse (upper tail)"
        }
    }
}

// MARK: - DistributionResult

/// Result of a distribution calculation
struct DistributionResult: Equatable {
    let distributionType: DistributionType
    let calculationType: DistributionCalculationType
    let result: Double
    let parameters: [String: Double]
    let inputValues: [String: Double]
    
    /// Formatted description of the calculation
    var description: String {
        var desc = "\(distributionType.rawValue) Distribution: "
        
        switch distributionType {
        case .normal:
            let mu = parameters["μ"] ?? 0
            let sigma = parameters["σ"] ?? 1
            desc += "μ=\(formatNumber(mu)), σ=\(formatNumber(sigma))"
        case .binomial:
            let n = Int(parameters["n"] ?? 0)
            let p = parameters["p"] ?? 0
            desc += "n=\(n), p=\(formatNumber(p))"
        case .poisson:
            let lambda = parameters["λ"] ?? 0
            desc += "λ=\(formatNumber(lambda))"
        }
        
        desc += "\n\(calculationType.rawValue) = \(formatNumber(result))"
        
        return desc
    }
    
    private func formatNumber(_ value: Double) -> String {
        if value == floor(value) && abs(value) < 1e9 {
            return String(format: "%.0f", value)
        } else if abs(value) < 0.0001 || abs(value) >= 1e9 {
            return String(format: "%.6e", value)
        } else {
            return String(format: "%.6g", value)
        }
    }
}

// MARK: - DistributionMode

/// Manages distribution mode state and calculations
@Observable
class DistributionMode {
    
    // MARK: - State
    
    /// Currently selected distribution type
    var distributionType: DistributionType = .normal
    
    /// Currently selected calculation type
    var calculationType: DistributionCalculationType = .lessThanOrEqual
    
    // MARK: - Normal Distribution Parameters
    
    /// Mean (μ) for normal distribution
    var normalMean: Double = 0
    
    /// Standard deviation (σ) for normal distribution
    var normalStdDev: Double = 1
    
    // MARK: - Binomial Distribution Parameters
    
    /// Number of trials (n) for binomial distribution
    var binomialTrials: Int = 10
    
    /// Probability of success (p) for binomial distribution
    var binomialProbability: Double = 0.5
    
    // MARK: - Poisson Distribution Parameters
    
    /// Rate parameter (λ) for Poisson distribution
    var poissonLambda: Double = 1
    
    // MARK: - Input Values
    
    /// X value for calculations
    var xValue: Double = 0
    
    /// Lower bound for "between" calculations
    var lowerBound: Double = 0
    
    /// Upper bound for "between" calculations
    var upperBound: Double = 1
    
    /// Probability for inverse calculations
    var probability: Double = 0.5
    
    // MARK: - Result
    
    /// Last calculated result
    private(set) var lastResult: Double?
    
    /// Last error message
    private(set) var lastError: String?
    
    /// Last full result with context
    private(set) var lastFullResult: DistributionResult?
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Calculations
    
    /// Performs the calculation with current settings
    func calculate() throws -> Double {
        lastError = nil
        
        do {
            try validateParameters()
            
            let result: Double
            
            switch distributionType {
            case .normal:
                result = try calculateNormal()
            case .binomial:
                result = try calculateBinomial()
            case .poisson:
                result = try calculatePoisson()
            }
            
            lastResult = result
            lastFullResult = createResult(value: result)
            return result
            
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }
    
    /// Normal distribution calculations
    private func calculateNormal() throws -> Double {
        let dist = try NormalDistribution(mean: normalMean, stdDev: normalStdDev)
        
        switch calculationType {
        case .lessThanOrEqual:
            return dist.cdf(xValue)
            
        case .greaterThanOrEqual:
            return dist.upperCdf(xValue)
            
        case .between:
            guard lowerBound <= upperBound else {
                throw CalculatorError.invalidInput("Lower bound must be less than or equal to upper bound")
            }
            return dist.between(lowerBound, upperBound)
            
        case .inverseLower:
            return try dist.inverseCdf(probability)
            
        case .inverseUpper:
            return try dist.inverseUpperCdf(probability)
            
        case .exactly:
            throw CalculatorError.invalidInput("Cannot calculate exact probability for continuous distribution")
        }
    }
    
    /// Binomial distribution calculations
    private func calculateBinomial() throws -> Double {
        let dist = try BinomialDistribution(trials: binomialTrials, probability: binomialProbability)
        let k = Int(xValue)
        
        switch calculationType {
        case .exactly:
            return try dist.exactly(k)
            
        case .lessThanOrEqual:
            return try dist.cdf(k)
            
        case .greaterThanOrEqual:
            return try dist.upperCdf(k)
            
        case .between:
            guard lowerBound <= upperBound else {
                throw CalculatorError.invalidInput("Lower bound must be less than or equal to upper bound")
            }
            return try dist.between(Int(lowerBound), Int(upperBound))
            
        case .inverseLower, .inverseUpper:
            throw CalculatorError.invalidInput("Inverse calculation not available for binomial distribution")
        }
    }
    
    /// Poisson distribution calculations
    private func calculatePoisson() throws -> Double {
        let dist = try PoissonDistribution(lambda: poissonLambda)
        let k = Int(xValue)
        
        switch calculationType {
        case .exactly:
            return try dist.exactly(k)
            
        case .lessThanOrEqual:
            return try dist.cdf(k)
            
        case .greaterThanOrEqual:
            return try dist.upperCdf(k)
            
        case .between:
            guard lowerBound <= upperBound else {
                throw CalculatorError.invalidInput("Lower bound must be less than or equal to upper bound")
            }
            return try dist.between(Int(lowerBound), Int(upperBound))
            
        case .inverseLower, .inverseUpper:
            throw CalculatorError.invalidInput("Inverse calculation not available for Poisson distribution")
        }
    }
    
    // MARK: - Validation
    
    /// Validates current parameters
    func validateParameters() throws {
        switch distributionType {
        case .normal:
            guard normalStdDev > 0 else {
                throw CalculatorError.invalidInput("Standard deviation must be positive")
            }
            
            if calculationType == .inverseLower || calculationType == .inverseUpper {
                guard probability > 0 && probability < 1 else {
                    throw CalculatorError.invalidInput("Probability must be between 0 and 1 (exclusive)")
                }
            }
            
        case .binomial:
            guard binomialTrials > 0 else {
                throw CalculatorError.invalidInput("Number of trials must be positive")
            }
            guard binomialProbability >= 0 && binomialProbability <= 1 else {
                throw CalculatorError.invalidInput("Probability must be between 0 and 1")
            }
            
            if calculationType != .between {
                let k = Int(xValue)
                guard k >= 0 && k <= binomialTrials else {
                    throw CalculatorError.invalidInput("k must be between 0 and n")
                }
            }
            
        case .poisson:
            guard poissonLambda > 0 else {
                throw CalculatorError.invalidInput("Lambda must be positive")
            }
            
            if calculationType != .between {
                let k = Int(xValue)
                guard k >= 0 else {
                    throw CalculatorError.invalidInput("k must be non-negative")
                }
            }
        }
        
        if !isCalculationTypeValid {
            throw CalculatorError.invalidInput("Selected calculation type not available for \(distributionType.rawValue) distribution")
        }
    }
    
    /// Whether current calculation type is valid for current distribution
    var isCalculationTypeValid: Bool {
        switch distributionType {
        case .normal:
            return calculationType.availableForContinuous
        case .binomial, .poisson:
            return calculationType.availableForDiscrete
        }
    }
    
    /// Available calculation types for current distribution
    var availableCalculationTypes: [DistributionCalculationType] {
        DistributionCalculationType.allCases.filter { calcType in
            switch distributionType {
            case .normal:
                return calcType.availableForContinuous
            case .binomial, .poisson:
                return calcType.availableForDiscrete
            }
        }
    }
    
    // MARK: - Presets
    
    /// Resets to default values for current distribution
    func resetToDefaults() {
        switch distributionType {
        case .normal:
            normalMean = 0
            normalStdDev = 1
        case .binomial:
            binomialTrials = 10
            binomialProbability = 0.5
        case .poisson:
            poissonLambda = 1
        }
        
        xValue = 0
        lowerBound = 0
        upperBound = 1
        probability = 0.5
        calculationType = .lessThanOrEqual
        lastResult = nil
        lastError = nil
        lastFullResult = nil
    }
    
    /// Standard normal preset (μ=0, σ=1)
    func setStandardNormal() {
        distributionType = .normal
        normalMean = 0
        normalStdDev = 1
        calculationType = .lessThanOrEqual
    }
    
    /// Common binomial preset (n=10, p=0.5)
    func setBinomialDefaults() {
        distributionType = .binomial
        binomialTrials = 10
        binomialProbability = 0.5
        calculationType = .lessThanOrEqual
    }
    
    /// Common Poisson preset (λ=5)
    func setPoissonDefaults() {
        distributionType = .poisson
        poissonLambda = 5
        calculationType = .lessThanOrEqual
    }
    
    // MARK: - Distribution Statistics
    
    /// Current distribution mean
    var currentMean: Double {
        switch distributionType {
        case .normal:
            return normalMean
        case .binomial:
            return Double(binomialTrials) * binomialProbability
        case .poisson:
            return poissonLambda
        }
    }
    
    /// Current distribution variance
    var currentVariance: Double {
        switch distributionType {
        case .normal:
            return normalStdDev * normalStdDev
        case .binomial:
            return Double(binomialTrials) * binomialProbability * (1 - binomialProbability)
        case .poisson:
            return poissonLambda
        }
    }
    
    /// Current distribution standard deviation
    var currentStdDev: Double {
        sqrt(currentVariance)
    }
    
    // MARK: - Helper Methods
    
    /// Creates a DistributionResult from the current state
    private func createResult(value: Double) -> DistributionResult {
        var parameters: [String: Double] = [:]
        var inputValues: [String: Double] = [:]
        
        switch distributionType {
        case .normal:
            parameters["μ"] = normalMean
            parameters["σ"] = normalStdDev
        case .binomial:
            parameters["n"] = Double(binomialTrials)
            parameters["p"] = binomialProbability
        case .poisson:
            parameters["λ"] = poissonLambda
        }
        
        switch calculationType {
        case .lessThanOrEqual, .greaterThanOrEqual, .exactly:
            inputValues["x"] = xValue
        case .between:
            inputValues["a"] = lowerBound
            inputValues["b"] = upperBound
        case .inverseLower, .inverseUpper:
            inputValues["p"] = probability
        }
        
        return DistributionResult(
            distributionType: distributionType,
            calculationType: calculationType,
            result: value,
            parameters: parameters,
            inputValues: inputValues
        )
    }
    
    /// Clears all results
    func clearResults() {
        lastResult = nil
        lastError = nil
        lastFullResult = nil
    }
    
    // MARK: - Quick Calculations
    
    /// Quick calculation for normal CDF
    func normalCdf(x: Double, mean: Double = 0, stdDev: Double = 1) throws -> Double {
        let dist = try NormalDistribution(mean: mean, stdDev: stdDev)
        return dist.cdf(x)
    }
    
    /// Quick calculation for normal inverse CDF
    func normalInverseCdf(p: Double, mean: Double = 0, stdDev: Double = 1) throws -> Double {
        let dist = try NormalDistribution(mean: mean, stdDev: stdDev)
        return try dist.inverseCdf(p)
    }
    
    /// Quick calculation for binomial PMF
    func binomialPmf(k: Int, n: Int, p: Double) throws -> Double {
        let dist = try BinomialDistribution(trials: n, probability: p)
        return try dist.pmf(k)
    }
    
    /// Quick calculation for binomial CDF
    func binomialCdf(k: Int, n: Int, p: Double) throws -> Double {
        let dist = try BinomialDistribution(trials: n, probability: p)
        return try dist.cdf(k)
    }
    
    /// Quick calculation for Poisson PMF
    func poissonPmf(k: Int, lambda: Double) throws -> Double {
        let dist = try PoissonDistribution(lambda: lambda)
        return try dist.pmf(k)
    }
    
    /// Quick calculation for Poisson CDF
    func poissonCdf(k: Int, lambda: Double) throws -> Double {
        let dist = try PoissonDistribution(lambda: lambda)
        return try dist.cdf(k)
    }
}
