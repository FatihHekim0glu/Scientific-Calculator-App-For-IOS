import Foundation

// MARK: - StatisticalData

/// Container for statistical data with optional frequencies
struct StatisticalData: Equatable {
    /// X values (primary data)
    var xValues: [Double]
    
    /// Y values for 2-variable statistics (optional)
    var yValues: [Double]?
    
    /// Frequency weights (optional, defaults to 1 for each value)
    var frequencies: [Double]?
    
    /// Maximum data points for 1-variable
    static let maxOneVarPoints = 160
    
    /// Maximum data points for 2-variable
    static let maxTwoVarPoints = 80
    
    /// Number of data points
    var count: Int { xValues.count }
    
    /// Whether this is 1-variable data
    var isOneVariable: Bool { yValues == nil }
    
    /// Whether this is 2-variable data
    var isTwoVariable: Bool { yValues != nil }
    
    /// Effective count considering frequencies
    var effectiveCount: Double {
        if let freq = frequencies {
            return freq.reduce(0, +)
        }
        return Double(count)
    }
    
    // MARK: - Initialization
    
    init(xValues: [Double], yValues: [Double]? = nil, frequencies: [Double]? = nil) throws {
        self.xValues = xValues
        self.yValues = yValues
        self.frequencies = frequencies
        try validate()
    }
    
    // MARK: - Validation
    
    /// Validates the data for statistical operations
    func validate() throws {
        if let yVals = yValues {
            guard xValues.count == yVals.count else {
                throw CalculatorError.invalidInput("X and Y arrays must have the same length")
            }
            guard xValues.count <= StatisticalData.maxTwoVarPoints else {
                throw CalculatorError.invalidInput("Maximum \(StatisticalData.maxTwoVarPoints) data points allowed for 2-variable statistics")
            }
        } else {
            guard xValues.count <= StatisticalData.maxOneVarPoints else {
                throw CalculatorError.invalidInput("Maximum \(StatisticalData.maxOneVarPoints) data points allowed for 1-variable statistics")
            }
        }
        
        if let freq = frequencies {
            guard freq.count == xValues.count else {
                throw CalculatorError.invalidInput("Frequencies array must match data length")
            }
            guard freq.allSatisfy({ $0 > 0 }) else {
                throw CalculatorError.invalidInput("Frequencies must be positive")
            }
        }
    }
    
    /// Adds a data point
    mutating func addPoint(x: Double, y: Double? = nil, frequency: Double = 1) throws {
        guard frequency > 0 else {
            throw CalculatorError.invalidInput("Frequency must be positive")
        }
        
        if isTwoVariable {
            guard let yVal = y else {
                throw CalculatorError.invalidInput("Y value required for 2-variable data")
            }
            guard xValues.count < StatisticalData.maxTwoVarPoints else {
                throw CalculatorError.invalidInput("Maximum data points reached")
            }
            xValues.append(x)
            yValues?.append(yVal)
        } else {
            guard xValues.count < StatisticalData.maxOneVarPoints else {
                throw CalculatorError.invalidInput("Maximum data points reached")
            }
            xValues.append(x)
        }
        
        if frequencies != nil {
            frequencies?.append(frequency)
        } else if frequency != 1 {
            frequencies = Array(repeating: 1.0, count: xValues.count - 1) + [frequency]
        }
    }
    
    /// Clears all data
    mutating func clear() {
        xValues = []
        yValues = yValues != nil ? [] : nil
        frequencies = nil
    }
}

// MARK: - OneVariableStatistics

/// Results of 1-variable statistical analysis
struct OneVariableStatistics: Equatable {
    /// Number of data points (n)
    let n: Int
    
    /// Sum of values (Σx)
    let sum: Double
    
    /// Sum of squared values (Σx²)
    let sumOfSquares: Double
    
    /// Arithmetic mean (x̄ = Σx/n)
    let mean: Double
    
    /// Population standard deviation (σx)
    let populationStdDev: Double
    
    /// Sample standard deviation (sx)
    let sampleStdDev: Double
    
    /// Population variance (σx²)
    let populationVariance: Double
    
    /// Sample variance (sx²)
    let sampleVariance: Double
    
    /// Minimum value
    let min: Double
    
    /// Maximum value
    let max: Double
    
    /// Range (max - min)
    let range: Double
    
    /// First quartile (Q1, 25th percentile)
    let q1: Double
    
    /// Median (Q2, 50th percentile)
    let median: Double
    
    /// Third quartile (Q3, 75th percentile)
    let q3: Double
    
    /// Interquartile range (Q3 - Q1)
    let iqr: Double
    
    /// Mode(s) - most frequent value(s)
    let mode: [Double]?
    
    /// Sum of frequencies (if using frequency data)
    let sumOfFrequencies: Double?
}

// MARK: - TwoVariableStatistics

/// Results of 2-variable statistical analysis
struct TwoVariableStatistics: Equatable {
    /// Statistics for x values
    let xStats: OneVariableStatistics
    
    /// Statistics for y values
    let yStats: OneVariableStatistics
    
    /// Sum of products (Σxy)
    let sumOfProducts: Double
    
    /// Sum of x·y²
    let sumXYSquared: Double
    
    /// Population covariance
    let populationCovariance: Double
    
    /// Sample covariance
    let sampleCovariance: Double
    
    /// Pearson correlation coefficient (r)
    let correlation: Double
    
    /// Coefficient of determination (r²)
    let rSquared: Double
}

// MARK: - Statistics

/// Statistical calculation functions
struct Statistics {
    
    // MARK: - 1-Variable Statistics
    
    /// Calculates all 1-variable statistics for the given data
    static func oneVariable(data: StatisticalData) throws -> OneVariableStatistics {
        return try oneVariable(values: data.xValues, frequencies: data.frequencies)
    }
    
    /// Calculates all 1-variable statistics from raw values
    static func oneVariable(values: [Double], frequencies: [Double]? = nil) throws -> OneVariableStatistics {
        guard !values.isEmpty else {
            throw CalculatorError.invalidInput("Cannot calculate statistics for empty data")
        }
        
        let n = values.count
        let freq = frequencies ?? Array(repeating: 1.0, count: n)
        
        guard freq.count == n else {
            throw CalculatorError.invalidInput("Frequencies array must match data length")
        }
        
        let sumFreq = freq.reduce(0, +)
        let sumX = sum(values, frequencies: frequencies)
        let sumX2 = sumOfSquares(values, frequencies: frequencies)
        let meanVal = sumX / sumFreq
        
        let popVar = calculateVariance(values, frequencies: frequencies, mean: meanVal, population: true)
        let sampVar = sumFreq > 1 ? calculateVariance(values, frequencies: frequencies, mean: meanVal, population: false) : 0
        
        let popStd = sqrt(popVar)
        let sampStd = sqrt(sampVar)
        
        let sortedValues = values.sorted()
        let minVal = sortedValues.first!
        let maxVal = sortedValues.last!
        let rangeVal = maxVal - minVal
        
        let medianVal = median(values)
        let q1Val = try quartile(values, q: 1)
        let q3Val = try quartile(values, q: 3)
        let iqrVal = q3Val - q1Val
        
        let modeVal = mode(values)
        
        return OneVariableStatistics(
            n: n,
            sum: sumX,
            sumOfSquares: sumX2,
            mean: meanVal,
            populationStdDev: popStd,
            sampleStdDev: sampStd,
            populationVariance: popVar,
            sampleVariance: sampVar,
            min: minVal,
            max: maxVal,
            range: rangeVal,
            q1: q1Val,
            median: medianVal,
            q3: q3Val,
            iqr: iqrVal,
            mode: modeVal,
            sumOfFrequencies: frequencies != nil ? sumFreq : nil
        )
    }
    
    // MARK: - 2-Variable Statistics
    
    /// Calculates all 2-variable statistics for the given data
    static func twoVariable(data: StatisticalData) throws -> TwoVariableStatistics {
        guard let yValues = data.yValues else {
            throw CalculatorError.invalidInput("2-variable statistics requires Y values")
        }
        return try twoVariable(xValues: data.xValues, yValues: yValues, frequencies: data.frequencies)
    }
    
    /// Calculates all 2-variable statistics from raw values
    static func twoVariable(xValues: [Double], yValues: [Double], frequencies: [Double]? = nil) throws -> TwoVariableStatistics {
        guard xValues.count == yValues.count else {
            throw CalculatorError.invalidInput("X and Y arrays must have the same length")
        }
        
        guard !xValues.isEmpty else {
            throw CalculatorError.invalidInput("Cannot calculate statistics for empty data")
        }
        
        let xStats = try oneVariable(values: xValues, frequencies: frequencies)
        let yStats = try oneVariable(values: yValues, frequencies: frequencies)
        
        let n = xValues.count
        let freq = frequencies ?? Array(repeating: 1.0, count: n)
        let sumFreq = freq.reduce(0, +)
        
        var sumXY = 0.0
        var sumXY2 = 0.0
        
        for i in 0..<n {
            let f = freq[i]
            sumXY += f * xValues[i] * yValues[i]
            sumXY2 += f * xValues[i] * yValues[i] * yValues[i]
        }
        
        let popCov = try covariance(xValues, yValues, frequencies: frequencies, population: true)
        let sampCov = sumFreq > 1 ? try covariance(xValues, yValues, frequencies: frequencies, population: false) : 0
        
        let r = try correlation(xValues, yValues, frequencies: frequencies)
        let r2 = r * r
        
        return TwoVariableStatistics(
            xStats: xStats,
            yStats: yStats,
            sumOfProducts: sumXY,
            sumXYSquared: sumXY2,
            populationCovariance: popCov,
            sampleCovariance: sampCov,
            correlation: r,
            rSquared: r2
        )
    }
    
    // MARK: - Individual Calculations
    
    /// Sum of values: Σ(xᵢ × fᵢ)
    static func sum(_ values: [Double], frequencies: [Double]? = nil) -> Double {
        guard !values.isEmpty else { return 0 }
        
        if let freq = frequencies {
            return zip(values, freq).map(*).reduce(0, +)
        }
        return values.reduce(0, +)
    }
    
    /// Sum of squared values: Σ(xᵢ² × fᵢ)
    static func sumOfSquares(_ values: [Double], frequencies: [Double]? = nil) -> Double {
        guard !values.isEmpty else { return 0 }
        
        if let freq = frequencies {
            return zip(values, freq).map { $0 * $0 * $1 }.reduce(0, +)
        }
        return values.map { $0 * $0 }.reduce(0, +)
    }
    
    /// Arithmetic mean: x̄ = Σ(xᵢ × fᵢ) / Σfᵢ
    static func mean(_ values: [Double], frequencies: [Double]? = nil) -> Double {
        guard !values.isEmpty else { return .nan }
        
        let sumFreq = frequencies?.reduce(0, +) ?? Double(values.count)
        return sum(values, frequencies: frequencies) / sumFreq
    }
    
    /// Population standard deviation: σ = √(Σfᵢ(xᵢ - x̄)² / Σfᵢ)
    static func populationStdDev(_ values: [Double], frequencies: [Double]? = nil) -> Double {
        guard values.count >= 1 else { return .nan }
        
        let meanVal = mean(values, frequencies: frequencies)
        let variance = calculateVariance(values, frequencies: frequencies, mean: meanVal, population: true)
        return sqrt(variance)
    }
    
    /// Sample standard deviation: s = √(Σfᵢ(xᵢ - x̄)² / (Σfᵢ - 1))
    static func sampleStdDev(_ values: [Double], frequencies: [Double]? = nil) -> Double {
        let effectiveN = frequencies?.reduce(0, +) ?? Double(values.count)
        guard effectiveN > 1 else { return .nan }
        
        let meanVal = mean(values, frequencies: frequencies)
        let variance = calculateVariance(values, frequencies: frequencies, mean: meanVal, population: false)
        return sqrt(variance)
    }
    
    /// Median (Q2)
    static func median(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return .nan }
        
        let sorted = values.sorted()
        let n = sorted.count
        
        if n % 2 == 0 {
            return (sorted[n / 2 - 1] + sorted[n / 2]) / 2.0
        } else {
            return sorted[n / 2]
        }
    }
    
    /// Quartile (1, 2, or 3) using inclusive method
    static func quartile(_ values: [Double], q: Int) throws -> Double {
        guard q >= 1 && q <= 3 else {
            throw CalculatorError.invalidInput("Quartile must be 1, 2, or 3")
        }
        
        guard !values.isEmpty else {
            throw CalculatorError.invalidInput("Cannot calculate quartile for empty data")
        }
        
        if q == 2 {
            return median(values)
        }
        
        let sorted = values.sorted()
        let n = Double(sorted.count)
        
        let position = Double(q) * (n + 1) / 4.0
        
        let lowerIndex = Int(floor(position)) - 1
        let upperIndex = Int(ceil(position)) - 1
        let fraction = position - floor(position)
        
        let clampedLower = Swift.max(0, Swift.min(lowerIndex, sorted.count - 1))
        let clampedUpper = Swift.max(0, Swift.min(upperIndex, sorted.count - 1))
        
        if clampedLower == clampedUpper {
            return sorted[clampedLower]
        }
        
        return sorted[clampedLower] + fraction * (sorted[clampedUpper] - sorted[clampedLower])
    }
    
    /// Percentile (0-100) using linear interpolation
    static func percentile(_ values: [Double], p: Double) throws -> Double {
        guard p >= 0 && p <= 100 else {
            throw CalculatorError.invalidInput("Percentile must be between 0 and 100")
        }
        
        guard !values.isEmpty else {
            throw CalculatorError.invalidInput("Cannot calculate percentile for empty data")
        }
        
        let sorted = values.sorted()
        let n = Double(sorted.count)
        
        if p == 0 { return sorted.first! }
        if p == 100 { return sorted.last! }
        
        let rank = p / 100.0 * (n - 1)
        let lowerIndex = Int(floor(rank))
        let upperIndex = Int(ceil(rank))
        let fraction = rank - Double(lowerIndex)
        
        if lowerIndex == upperIndex {
            return sorted[lowerIndex]
        }
        
        return sorted[lowerIndex] + fraction * (sorted[upperIndex] - sorted[lowerIndex])
    }
    
    /// Mode(s) - most frequent value(s)
    static func mode(_ values: [Double]) -> [Double]? {
        guard !values.isEmpty else { return nil }
        
        var frequency: [Double: Int] = [:]
        for value in values {
            frequency[value, default: 0] += 1
        }
        
        guard let maxCount = frequency.values.max(), maxCount > 1 else {
            return nil
        }
        
        let modes = frequency.filter { $0.value == maxCount }.keys.sorted()
        return modes.isEmpty ? nil : Array(modes)
    }
    
    /// Covariance: Cov(X,Y) = Σfᵢ(xᵢ - x̄)(yᵢ - ȳ) / n
    static func covariance(_ xValues: [Double], _ yValues: [Double], frequencies: [Double]? = nil, population: Bool = true) throws -> Double {
        guard xValues.count == yValues.count else {
            throw CalculatorError.invalidInput("X and Y arrays must have the same length")
        }
        
        guard !xValues.isEmpty else {
            throw CalculatorError.invalidInput("Cannot calculate covariance for empty data")
        }
        
        let n = xValues.count
        let freq = frequencies ?? Array(repeating: 1.0, count: n)
        let sumFreq = freq.reduce(0, +)
        
        guard sumFreq > (population ? 0 : 1) else {
            throw CalculatorError.divisionByZero
        }
        
        let xMean = mean(xValues, frequencies: frequencies)
        let yMean = mean(yValues, frequencies: frequencies)
        
        var sumProduct = 0.0
        for i in 0..<n {
            sumProduct += freq[i] * (xValues[i] - xMean) * (yValues[i] - yMean)
        }
        
        let divisor = population ? sumFreq : (sumFreq - 1)
        return sumProduct / divisor
    }
    
    /// Pearson correlation coefficient: r = Cov(X,Y) / (σx × σy)
    static func correlation(_ xValues: [Double], _ yValues: [Double], frequencies: [Double]? = nil) throws -> Double {
        guard xValues.count == yValues.count else {
            throw CalculatorError.invalidInput("X and Y arrays must have the same length")
        }
        
        guard xValues.count >= 2 else {
            throw CalculatorError.invalidInput("Correlation requires at least 2 data points")
        }
        
        let n = Double(xValues.count)
        let freq = frequencies ?? Array(repeating: 1.0, count: xValues.count)
        let sumFreq = freq.reduce(0, +)
        
        var sumX = 0.0, sumY = 0.0, sumXY = 0.0, sumX2 = 0.0, sumY2 = 0.0
        
        for i in 0..<xValues.count {
            let f = freq[i]
            sumX += f * xValues[i]
            sumY += f * yValues[i]
            sumXY += f * xValues[i] * yValues[i]
            sumX2 += f * xValues[i] * xValues[i]
            sumY2 += f * yValues[i] * yValues[i]
        }
        
        let numerator = sumFreq * sumXY - sumX * sumY
        let denominator = sqrt((sumFreq * sumX2 - sumX * sumX) * (sumFreq * sumY2 - sumY * sumY))
        
        guard denominator > 1e-15 else {
            return 0
        }
        
        let r = numerator / denominator
        return Swift.max(-1.0, Swift.min(1.0, r))
    }
    
    // MARK: - Private Helpers
    
    /// Calculates variance with given mean
    private static func calculateVariance(_ values: [Double], frequencies: [Double]?, mean: Double, population: Bool) -> Double {
        let n = values.count
        let freq = frequencies ?? Array(repeating: 1.0, count: n)
        let sumFreq = freq.reduce(0, +)
        
        guard sumFreq > (population ? 0 : 1) else { return 0 }
        
        var sumSquaredDiff = 0.0
        for i in 0..<n {
            let diff = values[i] - mean
            sumSquaredDiff += freq[i] * diff * diff
        }
        
        let divisor = population ? sumFreq : (sumFreq - 1)
        return sumSquaredDiff / divisor
    }
}
