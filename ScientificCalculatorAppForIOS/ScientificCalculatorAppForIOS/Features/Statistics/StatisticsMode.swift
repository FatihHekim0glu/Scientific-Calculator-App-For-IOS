import Foundation
import SwiftUI

// MARK: - StatVariableType

/// Statistical variable types available in stat mode
enum StatVariableType: String, CaseIterable {
    // 1-Variable statistics
    case n = "n"
    case sumX = "Σx"
    case sumX2 = "Σx²"
    case meanX = "x̄"
    case popStdDevX = "σx"
    case sampleStdDevX = "sx"
    case popVarianceX = "σx²"
    case sampleVarianceX = "sx²"
    case minX = "minX"
    case maxX = "maxX"
    case rangeX = "range"
    case medianX = "Med"
    case q1 = "Q₁"
    case q3 = "Q₃"
    case iqr = "IQR"
    
    // 2-Variable statistics (y)
    case sumY = "Σy"
    case sumY2 = "Σy²"
    case meanY = "ȳ"
    case popStdDevY = "σy"
    case sampleStdDevY = "sy"
    case minY = "minY"
    case maxY = "maxY"
    
    // 2-Variable statistics (combined)
    case sumXY = "Σxy"
    case correlation = "r"
    case rSquared = "r²"
    case popCovariance = "Cov"
    case sampleCovariance = "sCov"
    
    // Regression coefficients
    case regA = "a"
    case regB = "b"
    case regC = "c"
    
    /// Display name for the variable
    var displayName: String {
        rawValue
    }
    
    /// Description of the variable
    var description: String {
        switch self {
        case .n: return "Number of data points"
        case .sumX: return "Sum of x values"
        case .sumX2: return "Sum of x squared"
        case .meanX: return "Mean of x"
        case .popStdDevX: return "Population standard deviation of x"
        case .sampleStdDevX: return "Sample standard deviation of x"
        case .popVarianceX: return "Population variance of x"
        case .sampleVarianceX: return "Sample variance of x"
        case .minX: return "Minimum x value"
        case .maxX: return "Maximum x value"
        case .rangeX: return "Range of x values"
        case .medianX: return "Median of x"
        case .q1: return "First quartile"
        case .q3: return "Third quartile"
        case .iqr: return "Interquartile range"
        case .sumY: return "Sum of y values"
        case .sumY2: return "Sum of y squared"
        case .meanY: return "Mean of y"
        case .popStdDevY: return "Population standard deviation of y"
        case .sampleStdDevY: return "Sample standard deviation of y"
        case .minY: return "Minimum y value"
        case .maxY: return "Maximum y value"
        case .sumXY: return "Sum of xy products"
        case .correlation: return "Correlation coefficient"
        case .rSquared: return "Coefficient of determination"
        case .popCovariance: return "Population covariance"
        case .sampleCovariance: return "Sample covariance"
        case .regA: return "Regression coefficient a"
        case .regB: return "Regression coefficient b"
        case .regC: return "Regression coefficient c"
        }
    }
    
    /// Whether this variable requires 2-variable data
    var requiresTwoVariable: Bool {
        switch self {
        case .sumY, .sumY2, .meanY, .popStdDevY, .sampleStdDevY, .minY, .maxY,
             .sumXY, .correlation, .rSquared, .popCovariance, .sampleCovariance,
             .regA, .regB, .regC:
            return true
        default:
            return false
        }
    }
    
    /// 1-variable statistics only
    static var oneVariableStats: [StatVariableType] {
        [.n, .sumX, .sumX2, .meanX, .popStdDevX, .sampleStdDevX,
         .popVarianceX, .sampleVarianceX, .minX, .maxX, .rangeX,
         .medianX, .q1, .q3, .iqr]
    }
    
    /// 2-variable y statistics
    static var twoVariableYStats: [StatVariableType] {
        [.sumY, .sumY2, .meanY, .popStdDevY, .sampleStdDevY, .minY, .maxY]
    }
    
    /// 2-variable combined statistics
    static var twoVariableCombinedStats: [StatVariableType] {
        [.sumXY, .correlation, .rSquared, .popCovariance, .sampleCovariance]
    }
    
    /// Regression coefficients
    static var regressionCoefficients: [StatVariableType] {
        [.regA, .regB, .regC]
    }
}

// MARK: - StatisticsMode

/// Manages statistics mode state and calculations
@Observable
class StatisticsMode {
    
    // MARK: - Data Storage
    
    /// Current statistical data
    private(set) var data: StatisticalData
    
    /// Whether using frequency mode
    var useFrequencies: Bool = false {
        didSet {
            if useFrequencies != oldValue {
                invalidateCache()
            }
        }
    }
    
    /// Currently selected regression type (backing storage)
    @ObservationIgnored
    private var _selectedRegressionType: RegressionType = .linear
    
    /// Currently selected regression type
    var selectedRegressionType: RegressionType {
        get { _selectedRegressionType }
        set {
            if newValue != _selectedRegressionType {
                _selectedRegressionType = newValue
                cachedRegression = [:]
            }
        }
    }
    
    // MARK: - Computed Results (cached)
    
    /// 1-variable statistics (computed on demand)
    @ObservationIgnored
    private var cachedOneVarStats: OneVariableStatistics?
    
    /// 2-variable statistics (computed on demand)
    @ObservationIgnored
    private var cachedTwoVarStats: TwoVariableStatistics?
    
    /// Regression result (computed on demand)
    @ObservationIgnored
    private var cachedRegression: [RegressionType: RegressionResult] = [:]
    
    /// Whether cached results are valid
    @ObservationIgnored
    private var cacheValid: Bool = false
    
    // MARK: - Initialization
    
    init() {
        self.data = try! StatisticalData(xValues: [])
    }
    
    /// Initializes with existing data
    init(xValues: [Double], yValues: [Double]? = nil, frequencies: [Double]? = nil) throws {
        self.data = try StatisticalData(xValues: xValues, yValues: yValues, frequencies: frequencies)
        self.useFrequencies = frequencies != nil
    }
    
    // MARK: - Data Entry
    
    /// Adds a single value (1-variable mode)
    func addValue(_ x: Double, frequency: Double = 1) throws {
        guard !isTwoVariableMode else {
            throw CalculatorError.invalidInput("Use addPair for 2-variable mode")
        }
        
        try data.addPoint(x: x, y: nil, frequency: frequency)
        
        if frequency != 1 {
            useFrequencies = true
        }
        
        invalidateCache()
    }
    
    /// Adds a pair of values (2-variable mode)
    func addPair(x: Double, y: Double, frequency: Double = 1) throws {
        if !isTwoVariableMode && data.count == 0 {
            switchToTwoVariable()
        }
        
        guard isTwoVariableMode else {
            throw CalculatorError.invalidInput("Switch to 2-variable mode first")
        }
        
        try data.addPoint(x: x, y: y, frequency: frequency)
        
        if frequency != 1 {
            useFrequencies = true
        }
        
        invalidateCache()
    }
    
    /// Sets all x values at once
    func setXValues(_ values: [Double]) throws {
        guard !values.isEmpty else {
            throw CalculatorError.invalidInput("Values array cannot be empty")
        }
        
        let maxPoints = isTwoVariableMode ? StatisticalData.maxTwoVarPoints : StatisticalData.maxOneVarPoints
        guard values.count <= maxPoints else {
            throw CalculatorError.invalidInput("Maximum \(maxPoints) data points allowed")
        }
        
        data = try StatisticalData(
            xValues: values,
            yValues: isTwoVariableMode ? Array(repeating: 0, count: values.count) : nil,
            frequencies: useFrequencies ? Array(repeating: 1, count: values.count) : nil
        )
        
        invalidateCache()
    }
    
    /// Sets all y values at once (switches to 2-variable mode)
    func setYValues(_ values: [Double]) throws {
        guard values.count == data.count else {
            throw CalculatorError.invalidInput("Y values count must match x values count")
        }
        
        data = try StatisticalData(
            xValues: data.xValues,
            yValues: values,
            frequencies: data.frequencies
        )
        
        invalidateCache()
    }
    
    /// Sets frequencies
    func setFrequencies(_ frequencies: [Double]) throws {
        guard frequencies.count == data.count else {
            throw CalculatorError.invalidInput("Frequencies count must match data count")
        }
        
        guard frequencies.allSatisfy({ $0 > 0 }) else {
            throw CalculatorError.invalidInput("All frequencies must be positive")
        }
        
        data = try StatisticalData(
            xValues: data.xValues,
            yValues: data.yValues,
            frequencies: frequencies
        )
        
        useFrequencies = true
        invalidateCache()
    }
    
    /// Deletes a data point at index
    func deletePoint(at index: Int) throws {
        guard index >= 0 && index < data.count else {
            throw CalculatorError.invalidInput("Index out of range")
        }
        
        var xValues = data.xValues
        var yValues = data.yValues
        var frequencies = data.frequencies
        
        xValues.remove(at: index)
        yValues?.remove(at: index)
        frequencies?.remove(at: index)
        
        data = try StatisticalData(
            xValues: xValues,
            yValues: yValues,
            frequencies: frequencies
        )
        
        invalidateCache()
    }
    
    /// Clears all data
    func clearData() {
        let wasTwo = isTwoVariableMode
        data = try! StatisticalData(xValues: [], yValues: wasTwo ? [] : nil, frequencies: nil)
        useFrequencies = false
        invalidateCache()
    }
    
    /// Edits a value at index
    func editValue(at index: Int, x: Double?, y: Double?, frequency: Double?) throws {
        guard index >= 0 && index < data.count else {
            throw CalculatorError.invalidInput("Index out of range")
        }
        
        var xValues = data.xValues
        var yValues = data.yValues
        var frequencies = data.frequencies
        
        if let x = x {
            xValues[index] = x
        }
        
        if let y = y {
            guard isTwoVariableMode else {
                throw CalculatorError.invalidInput("Cannot set y value in 1-variable mode")
            }
            yValues?[index] = y
        }
        
        if let frequency = frequency {
            guard frequency > 0 else {
                throw CalculatorError.invalidInput("Frequency must be positive")
            }
            
            if frequencies == nil {
                frequencies = Array(repeating: 1.0, count: data.count)
            }
            frequencies?[index] = frequency
            useFrequencies = true
        }
        
        data = try StatisticalData(
            xValues: xValues,
            yValues: yValues,
            frequencies: frequencies
        )
        
        invalidateCache()
    }
    
    // MARK: - Statistics Calculations
    
    /// Gets 1-variable statistics
    func getOneVariableStats() throws -> OneVariableStatistics {
        guard data.count > 0 else {
            throw CalculatorError.invalidInput("No data available")
        }
        
        if let cached = cachedOneVarStats, cacheValid {
            return cached
        }
        
        let stats = try Statistics.oneVariable(
            values: data.xValues,
            frequencies: useFrequencies ? data.frequencies : nil
        )
        
        cachedOneVarStats = stats
        cacheValid = true
        
        return stats
    }
    
    /// Gets 2-variable statistics (requires y data)
    func getTwoVariableStats() throws -> TwoVariableStatistics {
        guard isTwoVariableMode else {
            throw CalculatorError.invalidInput("2-variable mode required")
        }
        
        guard data.count > 0 else {
            throw CalculatorError.invalidInput("No data available")
        }
        
        if let cached = cachedTwoVarStats, cacheValid {
            return cached
        }
        
        let stats = try Statistics.twoVariable(
            xValues: data.xValues,
            yValues: data.yValues!,
            frequencies: useFrequencies ? data.frequencies : nil
        )
        
        cachedTwoVarStats = stats
        
        return stats
    }
    
    /// Gets regression result for current regression type
    func getRegression() throws -> RegressionResult {
        return try getRegression(type: selectedRegressionType)
    }
    
    /// Gets regression result for specified type
    func getRegression(type: RegressionType) throws -> RegressionResult {
        guard isTwoVariableMode else {
            throw CalculatorError.invalidInput("2-variable mode required for regression")
        }
        
        guard data.count >= (type == .quadratic ? 3 : 2) else {
            throw CalculatorError.invalidInput("Need at least \(type == .quadratic ? 3 : 2) data points for \(type.displayName) regression")
        }
        
        if let cached = cachedRegression[type] {
            return cached
        }
        
        let result = try Regression.regression(type, xValues: data.xValues, yValues: data.yValues!)
        cachedRegression[type] = result
        
        return result
    }
    
    /// Estimates y from x using current regression
    func estimateY(from x: Double) throws -> Double {
        let regression = try getRegression()
        return regression.estimateY(from: x)
    }
    
    /// Estimates x from y using current regression
    func estimateX(from y: Double) throws -> Double? {
        let regression = try getRegression()
        return regression.estimateX(from: y)
    }
    
    // MARK: - Stat Variables
    
    /// Gets a statistical variable by name
    func getStatVariable(_ name: String) throws -> Double {
        guard let varType = StatVariableType(rawValue: name) else {
            throw CalculatorError.invalidInput("Unknown statistical variable: \(name)")
        }
        
        return try getStatVariable(varType)
    }
    
    /// Gets a statistical variable by type
    func getStatVariable(_ varType: StatVariableType) throws -> Double {
        guard data.count > 0 else {
            throw CalculatorError.invalidInput("No data available")
        }
        
        if varType.requiresTwoVariable && !isTwoVariableMode {
            throw CalculatorError.invalidInput("\(varType.displayName) requires 2-variable data")
        }
        
        switch varType {
        // 1-Variable x statistics
        case .n:
            return Double(data.count)
            
        case .sumX:
            let stats = try getOneVariableStats()
            return stats.sum
            
        case .sumX2:
            let stats = try getOneVariableStats()
            return stats.sumOfSquares
            
        case .meanX:
            let stats = try getOneVariableStats()
            return stats.mean
            
        case .popStdDevX:
            let stats = try getOneVariableStats()
            return stats.populationStdDev
            
        case .sampleStdDevX:
            let stats = try getOneVariableStats()
            return stats.sampleStdDev
            
        case .popVarianceX:
            let stats = try getOneVariableStats()
            return stats.populationVariance
            
        case .sampleVarianceX:
            let stats = try getOneVariableStats()
            return stats.sampleVariance
            
        case .minX:
            let stats = try getOneVariableStats()
            return stats.min
            
        case .maxX:
            let stats = try getOneVariableStats()
            return stats.max
            
        case .rangeX:
            let stats = try getOneVariableStats()
            return stats.range
            
        case .medianX:
            let stats = try getOneVariableStats()
            return stats.median
            
        case .q1:
            let stats = try getOneVariableStats()
            return stats.q1
            
        case .q3:
            let stats = try getOneVariableStats()
            return stats.q3
            
        case .iqr:
            let stats = try getOneVariableStats()
            return stats.iqr
            
        // 2-Variable y statistics
        case .sumY:
            let stats = try getTwoVariableStats()
            return stats.yStats.sum
            
        case .sumY2:
            let stats = try getTwoVariableStats()
            return stats.yStats.sumOfSquares
            
        case .meanY:
            let stats = try getTwoVariableStats()
            return stats.yStats.mean
            
        case .popStdDevY:
            let stats = try getTwoVariableStats()
            return stats.yStats.populationStdDev
            
        case .sampleStdDevY:
            let stats = try getTwoVariableStats()
            return stats.yStats.sampleStdDev
            
        case .minY:
            let stats = try getTwoVariableStats()
            return stats.yStats.min
            
        case .maxY:
            let stats = try getTwoVariableStats()
            return stats.yStats.max
            
        // 2-Variable combined statistics
        case .sumXY:
            let stats = try getTwoVariableStats()
            return stats.sumOfProducts
            
        case .correlation:
            let stats = try getTwoVariableStats()
            return stats.correlation
            
        case .rSquared:
            let stats = try getTwoVariableStats()
            return stats.rSquared
            
        case .popCovariance:
            let stats = try getTwoVariableStats()
            return stats.populationCovariance
            
        case .sampleCovariance:
            let stats = try getTwoVariableStats()
            return stats.sampleCovariance
            
        // Regression coefficients
        case .regA:
            let reg = try getRegression()
            return reg.a
            
        case .regB:
            let reg = try getRegression()
            return reg.b
            
        case .regC:
            let reg = try getRegression()
            guard let c = reg.c else {
                throw CalculatorError.invalidInput("Coefficient c only available for quadratic regression")
            }
            return c
        }
    }
    
    /// All available stat variable names
    static let statVariables: [String] = StatVariableType.allCases.map { $0.rawValue }
    
    // MARK: - Mode State
    
    /// Whether in 2-variable mode
    var isTwoVariableMode: Bool {
        data.yValues != nil
    }
    
    /// Number of data points
    var dataCount: Int {
        data.count
    }
    
    /// Effective count considering frequencies
    var effectiveCount: Double {
        data.effectiveCount
    }
    
    /// X values array
    var xValues: [Double] {
        data.xValues
    }
    
    /// Y values array (nil if 1-variable mode)
    var yValues: [Double]? {
        data.yValues
    }
    
    /// Frequencies array (nil if not using frequencies)
    var frequencies: [Double]? {
        useFrequencies ? data.frequencies : nil
    }
    
    /// Switches to 1-variable mode
    func switchToOneVariable() {
        if isTwoVariableMode {
            data = try! StatisticalData(
                xValues: data.xValues,
                yValues: nil,
                frequencies: data.frequencies
            )
            invalidateCache()
        }
    }
    
    /// Switches to 2-variable mode
    func switchToTwoVariable() {
        if !isTwoVariableMode {
            let yVals = Array(repeating: 0.0, count: data.count)
            data = try! StatisticalData(
                xValues: data.xValues,
                yValues: yVals,
                frequencies: data.frequencies
            )
            invalidateCache()
        }
    }
    
    // MARK: - Cache Management
    
    /// Invalidates cached calculations
    private func invalidateCache() {
        cachedOneVarStats = nil
        cachedTwoVarStats = nil
        cachedRegression = [:]
        cacheValid = false
    }
    
    /// Recalculates all statistics
    func recalculate() throws {
        invalidateCache()
        
        if data.count > 0 {
            _ = try getOneVariableStats()
            
            if isTwoVariableMode {
                _ = try getTwoVariableStats()
                _ = try? getRegression()
            }
        }
    }
    
    // MARK: - Data Access Helpers
    
    /// Gets data point at index
    func getPoint(at index: Int) -> (x: Double, y: Double?, frequency: Double)? {
        guard index >= 0 && index < data.count else {
            return nil
        }
        
        let x = data.xValues[index]
        let y = data.yValues?[index]
        let freq = data.frequencies?[index] ?? 1.0
        
        return (x, y, freq)
    }
    
    /// Returns all data as formatted array of tuples
    func getAllData() -> [(x: Double, y: Double?, frequency: Double)] {
        return (0..<data.count).compactMap { getPoint(at: $0) }
    }
}
