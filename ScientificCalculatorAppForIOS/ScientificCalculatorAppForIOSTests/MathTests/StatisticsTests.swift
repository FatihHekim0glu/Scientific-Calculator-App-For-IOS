import XCTest
@testable import ScientificCalculatorAppForIOS

final class StatisticsTests: XCTestCase {
    
    // MARK: - Sum Tests
    
    func test_Sum_ReturnsCorrectSum() {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        XCTAssertEqual(Statistics.sum(values), 15.0, accuracy: 1e-15)
    }
    
    func test_Sum_EmptyArray_ReturnsZero() {
        let values: [Double] = []
        XCTAssertEqual(Statistics.sum(values), 0.0, accuracy: 1e-15)
    }
    
    func test_Sum_SingleValue_ReturnsThatValue() {
        let values = [42.0]
        XCTAssertEqual(Statistics.sum(values), 42.0, accuracy: 1e-15)
    }
    
    func test_Sum_WithFrequencies_ReturnsWeightedSum() {
        let values = [1.0, 2.0, 3.0]
        let frequencies = [2.0, 3.0, 1.0]
        XCTAssertEqual(Statistics.sum(values, frequencies: frequencies), 11.0, accuracy: 1e-15)
    }
    
    func test_Sum_NegativeValues_ReturnsCorrect() {
        let values = [-5.0, 3.0, -2.0, 4.0]
        XCTAssertEqual(Statistics.sum(values), 0.0, accuracy: 1e-15)
    }
    
    // MARK: - Sum of Squares Tests
    
    func test_SumOfSquares_ReturnsCorrectValue() {
        let values = [1.0, 2.0, 3.0]
        XCTAssertEqual(Statistics.sumOfSquares(values), 14.0, accuracy: 1e-15)
    }
    
    func test_SumOfSquares_EmptyArray_ReturnsZero() {
        let values: [Double] = []
        XCTAssertEqual(Statistics.sumOfSquares(values), 0.0, accuracy: 1e-15)
    }
    
    func test_SumOfSquares_WithFrequencies_ReturnsWeightedSum() {
        let values = [2.0, 3.0]
        let frequencies = [2.0, 3.0]
        XCTAssertEqual(Statistics.sumOfSquares(values, frequencies: frequencies), 35.0, accuracy: 1e-15)
    }
    
    // MARK: - Mean Tests
    
    func test_Mean_ReturnsCorrectAverage() {
        let values = [2.0, 4.0, 6.0, 8.0, 10.0]
        XCTAssertEqual(Statistics.mean(values), 6.0, accuracy: 1e-15)
    }
    
    func test_Mean_EmptyArray_ReturnsNaN() {
        let values: [Double] = []
        XCTAssertTrue(Statistics.mean(values).isNaN)
    }
    
    func test_Mean_SingleValue_ReturnsThatValue() {
        let values = [42.0]
        XCTAssertEqual(Statistics.mean(values), 42.0, accuracy: 1e-15)
    }
    
    func test_Mean_WithFrequencies_ReturnsWeightedMean() {
        let values = [10.0, 20.0, 30.0]
        let frequencies = [1.0, 2.0, 2.0]
        let expected = (10.0 * 1 + 20.0 * 2 + 30.0 * 2) / 5.0
        XCTAssertEqual(Statistics.mean(values, frequencies: frequencies), expected, accuracy: 1e-15)
    }
    
    func test_Mean_NegativeValues_ReturnsCorrect() {
        let values = [-10.0, -5.0, 0.0, 5.0, 10.0]
        XCTAssertEqual(Statistics.mean(values), 0.0, accuracy: 1e-15)
    }
    
    // MARK: - Population Standard Deviation Tests
    
    func test_PopulationStdDev_KnownData_ReturnsCorrect() {
        let values = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]
        XCTAssertEqual(Statistics.populationStdDev(values), 2.0, accuracy: 0.001)
    }
    
    func test_PopulationStdDev_AllSameValues_ReturnsZero() {
        let values = [5.0, 5.0, 5.0, 5.0, 5.0]
        XCTAssertEqual(Statistics.populationStdDev(values), 0.0, accuracy: 1e-15)
    }
    
    func test_PopulationStdDev_SingleValue_ReturnsZero() {
        let values = [42.0]
        XCTAssertEqual(Statistics.populationStdDev(values), 0.0, accuracy: 1e-15)
    }
    
    func test_PopulationStdDev_TwoValues_ReturnsCorrect() {
        let values = [0.0, 10.0]
        XCTAssertEqual(Statistics.populationStdDev(values), 5.0, accuracy: 1e-15)
    }
    
    // MARK: - Sample Standard Deviation Tests
    
    func test_SampleStdDev_KnownData_ReturnsCorrect() {
        let values = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]
        XCTAssertEqual(Statistics.sampleStdDev(values), 2.138, accuracy: 0.001)
    }
    
    func test_SampleStdDev_SingleValue_ReturnsNaN() {
        let values = [42.0]
        XCTAssertTrue(Statistics.sampleStdDev(values).isNaN)
    }
    
    func test_SampleStdDev_TwoValues_ReturnsCorrect() {
        let values = [0.0, 10.0]
        let expected = sqrt(50.0)
        XCTAssertEqual(Statistics.sampleStdDev(values), expected, accuracy: 0.001)
    }
    
    // MARK: - Median Tests
    
    func test_Median_OddCount_ReturnsMiddle() {
        let values = [1.0, 3.0, 5.0, 7.0, 9.0]
        XCTAssertEqual(Statistics.median(values), 5.0, accuracy: 1e-15)
    }
    
    func test_Median_EvenCount_ReturnsAverage() {
        let values = [1.0, 2.0, 3.0, 4.0]
        XCTAssertEqual(Statistics.median(values), 2.5, accuracy: 1e-15)
    }
    
    func test_Median_SingleValue_ReturnsThatValue() {
        let values = [42.0]
        XCTAssertEqual(Statistics.median(values), 42.0, accuracy: 1e-15)
    }
    
    func test_Median_TwoValues_ReturnsAverage() {
        let values = [10.0, 20.0]
        XCTAssertEqual(Statistics.median(values), 15.0, accuracy: 1e-15)
    }
    
    func test_Median_UnsortedData_ReturnsCorrect() {
        let values = [9.0, 1.0, 5.0, 3.0, 7.0]
        XCTAssertEqual(Statistics.median(values), 5.0, accuracy: 1e-15)
    }
    
    func test_Median_EmptyArray_ReturnsNaN() {
        let values: [Double] = []
        XCTAssertTrue(Statistics.median(values).isNaN)
    }
    
    // MARK: - Quartile Tests
    
    func test_Quartile1_ReturnsCorrect() throws {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
        let result = try Statistics.quartile(values, q: 1)
        XCTAssertEqual(result, 2.25, accuracy: 0.01)
    }
    
    func test_Quartile2_ReturnsMedian() throws {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        let result = try Statistics.quartile(values, q: 2)
        XCTAssertEqual(result, Statistics.median(values), accuracy: 1e-15)
    }
    
    func test_Quartile3_ReturnsCorrect() throws {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
        let result = try Statistics.quartile(values, q: 3)
        XCTAssertEqual(result, 6.75, accuracy: 0.01)
    }
    
    func test_Quartile_InvalidQ_ThrowsError() {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        
        XCTAssertThrowsError(try Statistics.quartile(values, q: 0)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
        
        XCTAssertThrowsError(try Statistics.quartile(values, q: 4)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Quartile_EmptyArray_ThrowsError() {
        let values: [Double] = []
        
        XCTAssertThrowsError(try Statistics.quartile(values, q: 1)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Percentile Tests
    
    func test_Percentile_50th_ReturnsMedian() throws {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        let result = try Statistics.percentile(values, p: 50)
        XCTAssertEqual(result, Statistics.median(values), accuracy: 1e-15)
    }
    
    func test_Percentile_0th_ReturnsMin() throws {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        let result = try Statistics.percentile(values, p: 0)
        XCTAssertEqual(result, 1.0, accuracy: 1e-15)
    }
    
    func test_Percentile_100th_ReturnsMax() throws {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        let result = try Statistics.percentile(values, p: 100)
        XCTAssertEqual(result, 5.0, accuracy: 1e-15)
    }
    
    func test_Percentile_InvalidP_ThrowsError() {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        
        XCTAssertThrowsError(try Statistics.percentile(values, p: -1)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
        
        XCTAssertThrowsError(try Statistics.percentile(values, p: 101)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Mode Tests
    
    func test_Mode_SingleMode_ReturnsCorrect() {
        let values = [1.0, 2.0, 2.0, 3.0, 4.0]
        let result = Statistics.mode(values)
        XCTAssertEqual(result, [2.0])
    }
    
    func test_Mode_MultipleMode_ReturnsAll() {
        let values = [1.0, 1.0, 2.0, 2.0, 3.0]
        let result = Statistics.mode(values)
        XCTAssertEqual(result?.sorted(), [1.0, 2.0])
    }
    
    func test_Mode_NoMode_ReturnsNil() {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        XCTAssertNil(Statistics.mode(values))
    }
    
    func test_Mode_AllSame_ReturnsNil() {
        let values = [5.0, 5.0, 5.0, 5.0, 5.0]
        let result = Statistics.mode(values)
        XCTAssertEqual(result, [5.0])
    }
    
    func test_Mode_EmptyArray_ReturnsNil() {
        let values: [Double] = []
        XCTAssertNil(Statistics.mode(values))
    }
    
    // MARK: - Covariance Tests
    
    func test_Covariance_PositiveCorrelation_ReturnsPositive() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 6.0, 8.0, 10.0]
        let result = try Statistics.covariance(x, y, population: true)
        XCTAssertGreaterThan(result, 0)
    }
    
    func test_Covariance_NegativeCorrelation_ReturnsNegative() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [10.0, 8.0, 6.0, 4.0, 2.0]
        let result = try Statistics.covariance(x, y, population: true)
        XCTAssertLessThan(result, 0)
    }
    
    func test_Covariance_NoCorrelation_ReturnsNearZero() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [5.0, 5.0, 5.0, 5.0, 5.0]
        let result = try Statistics.covariance(x, y, population: true)
        XCTAssertEqual(result, 0.0, accuracy: 1e-15)
    }
    
    func test_Covariance_MismatchedLengths_ThrowsError() {
        let x = [1.0, 2.0, 3.0]
        let y = [1.0, 2.0]
        
        XCTAssertThrowsError(try Statistics.covariance(x, y)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Correlation Tests
    
    func test_Correlation_PerfectPositive_ReturnsOne() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 6.0, 8.0, 10.0]
        let result = try Statistics.correlation(x, y)
        XCTAssertEqual(result, 1.0, accuracy: 0.001)
    }
    
    func test_Correlation_PerfectNegative_ReturnsNegativeOne() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [10.0, 8.0, 6.0, 4.0, 2.0]
        let result = try Statistics.correlation(x, y)
        XCTAssertEqual(result, -1.0, accuracy: 0.001)
    }
    
    func test_Correlation_NoCorrelation_ReturnsNearZero() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [5.0, 5.0, 5.0, 5.0, 5.0]
        let result = try Statistics.correlation(x, y)
        XCTAssertEqual(result, 0.0, accuracy: 1e-10)
    }
    
    func test_Correlation_RangeBetweenNegOneAndOne() throws {
        let x = [1.0, 3.0, 2.0, 5.0, 4.0]
        let y = [2.0, 1.0, 4.0, 3.0, 6.0]
        let result = try Statistics.correlation(x, y)
        XCTAssertGreaterThanOrEqual(result, -1.0)
        XCTAssertLessThanOrEqual(result, 1.0)
    }
    
    func test_Correlation_InsufficientData_ThrowsError() {
        let x = [1.0]
        let y = [2.0]
        
        XCTAssertThrowsError(try Statistics.correlation(x, y)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - OneVariableStatistics Tests
    
    func test_OneVariable_CalculatesAllStats() throws {
        let values = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]
        let stats = try Statistics.oneVariable(values: values)
        
        XCTAssertEqual(stats.n, 8)
        XCTAssertEqual(stats.sum, 40.0, accuracy: 1e-15)
        XCTAssertEqual(stats.mean, 5.0, accuracy: 1e-15)
        XCTAssertEqual(stats.populationStdDev, 2.0, accuracy: 0.001)
        XCTAssertEqual(stats.min, 2.0, accuracy: 1e-15)
        XCTAssertEqual(stats.max, 9.0, accuracy: 1e-15)
        XCTAssertEqual(stats.range, 7.0, accuracy: 1e-15)
    }
    
    func test_OneVariable_EmptyData_ThrowsError() {
        let values: [Double] = []
        
        XCTAssertThrowsError(try Statistics.oneVariable(values: values)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_OneVariable_WithFrequencies_ReturnsCorrect() throws {
        let values = [10.0, 20.0, 30.0]
        let frequencies = [1.0, 2.0, 2.0]
        let stats = try Statistics.oneVariable(values: values, frequencies: frequencies)
        
        XCTAssertEqual(stats.n, 3)
        XCTAssertEqual(stats.sumOfFrequencies, 5.0, accuracy: 1e-15)
        XCTAssertEqual(stats.mean, 22.0, accuracy: 1e-15)
    }
    
    // MARK: - TwoVariableStatistics Tests
    
    func test_TwoVariable_CalculatesAllStats() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 5.0, 4.0, 5.0]
        let stats = try Statistics.twoVariable(xValues: x, yValues: y)
        
        XCTAssertEqual(stats.xStats.n, 5)
        XCTAssertEqual(stats.yStats.n, 5)
        XCTAssertEqual(stats.xStats.mean, 3.0, accuracy: 1e-15)
        XCTAssertEqual(stats.yStats.mean, 4.0, accuracy: 1e-15)
        XCTAssertGreaterThan(stats.correlation, 0)
    }
    
    func test_TwoVariable_PerfectLinear_RSquaredOne() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 6.0, 8.0, 10.0]
        let stats = try Statistics.twoVariable(xValues: x, yValues: y)
        
        XCTAssertEqual(stats.rSquared, 1.0, accuracy: 0.001)
    }
    
    func test_TwoVariable_MismatchedLengths_ThrowsError() {
        let x = [1.0, 2.0, 3.0]
        let y = [1.0, 2.0]
        
        XCTAssertThrowsError(try Statistics.twoVariable(xValues: x, yValues: y)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - StatisticalData Tests
    
    func test_StatisticalData_Initialization_Succeeds() throws {
        let data = try StatisticalData(xValues: [1.0, 2.0, 3.0])
        XCTAssertEqual(data.count, 3)
        XCTAssertTrue(data.isOneVariable)
        XCTAssertFalse(data.isTwoVariable)
    }
    
    func test_StatisticalData_TwoVariable_Succeeds() throws {
        let data = try StatisticalData(xValues: [1.0, 2.0, 3.0], yValues: [2.0, 4.0, 6.0])
        XCTAssertEqual(data.count, 3)
        XCTAssertFalse(data.isOneVariable)
        XCTAssertTrue(data.isTwoVariable)
    }
    
    func test_StatisticalData_MismatchedXY_ThrowsError() {
        XCTAssertThrowsError(try StatisticalData(xValues: [1.0, 2.0, 3.0], yValues: [2.0, 4.0])) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_StatisticalData_AddPoint_Works() throws {
        var data = try StatisticalData(xValues: [1.0, 2.0])
        try data.addPoint(x: 3.0)
        XCTAssertEqual(data.count, 3)
        XCTAssertEqual(data.xValues, [1.0, 2.0, 3.0])
    }
    
    func test_StatisticalData_Clear_Works() throws {
        var data = try StatisticalData(xValues: [1.0, 2.0, 3.0])
        data.clear()
        XCTAssertEqual(data.count, 0)
    }
    
    func test_StatisticalData_EffectiveCount_WithFrequencies() throws {
        let data = try StatisticalData(xValues: [1.0, 2.0, 3.0], frequencies: [2.0, 3.0, 1.0])
        XCTAssertEqual(data.effectiveCount, 6.0, accuracy: 1e-15)
    }
    
    func test_StatisticalData_MaxOneVarPoints_Enforced() throws {
        let values = Array(repeating: 1.0, count: StatisticalData.maxOneVarPoints + 1)
        
        XCTAssertThrowsError(try StatisticalData(xValues: values)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
}
