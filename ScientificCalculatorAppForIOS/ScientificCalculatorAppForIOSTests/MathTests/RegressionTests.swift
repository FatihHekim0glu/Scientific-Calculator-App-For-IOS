import XCTest
@testable import ScientificCalculatorAppForIOS

final class RegressionTests: XCTestCase {
    
    // MARK: - Linear Regression Tests
    
    func test_Linear_PerfectFit_ReturnsExactLine() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 6.0, 8.0, 10.0]
        
        let result = try Regression.linear(xValues: x, yValues: y)
        
        XCTAssertEqual(result.a, 0.0, accuracy: 0.001)
        XCTAssertEqual(result.b, 2.0, accuracy: 0.001)
        XCTAssertEqual(result.correlationCoefficient, 1.0, accuracy: 0.001)
        XCTAssertEqual(result.coefficientOfDetermination, 1.0, accuracy: 0.001)
    }
    
    func test_Linear_WithIntercept_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [3.0, 5.0, 7.0, 9.0, 11.0]
        
        let result = try Regression.linear(xValues: x, yValues: y)
        
        XCTAssertEqual(result.a, 1.0, accuracy: 0.001)
        XCTAssertEqual(result.b, 2.0, accuracy: 0.001)
    }
    
    func test_Linear_NegativeSlope_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [10.0, 8.0, 6.0, 4.0, 2.0]
        
        let result = try Regression.linear(xValues: x, yValues: y)
        
        XCTAssertEqual(result.a, 12.0, accuracy: 0.001)
        XCTAssertEqual(result.b, -2.0, accuracy: 0.001)
        XCTAssertEqual(result.correlationCoefficient, -1.0, accuracy: 0.001)
    }
    
    func test_Linear_EstimateY_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0]
        let y = [2.0, 4.0, 6.0]
        
        let result = try Regression.linear(xValues: x, yValues: y)
        
        XCTAssertEqual(result.estimateY(from: 4.0), 8.0, accuracy: 0.001)
        XCTAssertEqual(result.estimateY(from: 0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(result.estimateY(from: -1.0), -2.0, accuracy: 0.001)
    }
    
    func test_Linear_EstimateX_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0]
        let y = [2.0, 4.0, 6.0]
        
        let result = try Regression.linear(xValues: x, yValues: y)
        
        XCTAssertEqual(result.estimateX(from: 8.0), 4.0, accuracy: 0.001)
        XCTAssertEqual(result.estimateX(from: 10.0), 5.0, accuracy: 0.001)
    }
    
    func test_Linear_InsufficientPoints_ThrowsError() {
        let x = [1.0]
        let y = [2.0]
        
        XCTAssertThrowsError(try Regression.linear(xValues: x, yValues: y)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Linear_AllXIdentical_ThrowsError() {
        let x = [2.0, 2.0, 2.0, 2.0, 2.0]
        let y = [1.0, 2.0, 3.0, 4.0, 5.0]
        
        XCTAssertThrowsError(try Regression.linear(xValues: x, yValues: y)) { error in
            guard case CalculatorError.mathError = error else {
                XCTFail("Expected mathError")
                return
            }
        }
    }
    
    func test_Linear_MismatchedLengths_ThrowsError() {
        let x = [1.0, 2.0, 3.0]
        let y = [1.0, 2.0]
        
        XCTAssertThrowsError(try Regression.linear(xValues: x, yValues: y)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Quadratic Regression Tests
    
    func test_Quadratic_PerfectParabola_ReturnsExact() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [1.0, 4.0, 9.0, 16.0, 25.0]
        
        let result = try Regression.quadratic(xValues: x, yValues: y)
        
        XCTAssertEqual(result.a, 0.0, accuracy: 0.001)
        XCTAssertEqual(result.b, 0.0, accuracy: 0.001)
        XCTAssertEqual(result.c!, 1.0, accuracy: 0.001)
        XCTAssertEqual(result.coefficientOfDetermination, 1.0, accuracy: 0.001)
    }
    
    func test_Quadratic_WithLinearAndConstant_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 5.0, 10.0, 17.0, 26.0]
        
        let result = try Regression.quadratic(xValues: x, yValues: y)
        
        XCTAssertEqual(result.a, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.b, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.c!, 1.0, accuracy: 0.01)
    }
    
    func test_Quadratic_EstimateY_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [1.0, 4.0, 9.0, 16.0, 25.0]
        
        let result = try Regression.quadratic(xValues: x, yValues: y)
        
        XCTAssertEqual(result.estimateY(from: 6.0), 36.0, accuracy: 0.1)
        XCTAssertEqual(result.estimateY(from: 10.0), 100.0, accuracy: 0.1)
    }
    
    func test_Quadratic_RequiresMinimum3Points() {
        let x = [1.0, 2.0]
        let y = [1.0, 4.0]
        
        XCTAssertThrowsError(try Regression.quadratic(xValues: x, yValues: y)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Logarithmic Regression Tests
    
    func test_Logarithmic_KnownData_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { 2.0 + 3.0 * log($0) }
        
        let result = try Regression.logarithmic(xValues: x, yValues: y)
        
        XCTAssertEqual(result.a, 2.0, accuracy: 0.01)
        XCTAssertEqual(result.b, 3.0, accuracy: 0.01)
        XCTAssertEqual(result.coefficientOfDetermination, 1.0, accuracy: 0.001)
    }
    
    func test_Logarithmic_EstimateY_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { 2.0 + 3.0 * log($0) }
        
        let result = try Regression.logarithmic(xValues: x, yValues: y)
        
        XCTAssertEqual(result.estimateY(from: exp(1)), 2.0 + 3.0, accuracy: 0.01)
    }
    
    func test_Logarithmic_NegativeX_ThrowsError() {
        let x = [-1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [1.0, 2.0, 3.0, 4.0, 5.0]
        
        XCTAssertThrowsError(try Regression.logarithmic(xValues: x, yValues: y)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domainError")
                return
            }
        }
    }
    
    func test_Logarithmic_ZeroX_ThrowsError() {
        let x = [0.0, 2.0, 3.0, 4.0, 5.0]
        let y = [1.0, 2.0, 3.0, 4.0, 5.0]
        
        XCTAssertThrowsError(try Regression.logarithmic(xValues: x, yValues: y)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domainError")
                return
            }
        }
    }
    
    // MARK: - e-Exponential Regression Tests
    
    func test_EExponential_KnownData_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { 2.0 * exp(0.5 * $0) }
        
        let result = try Regression.eExponential(xValues: x, yValues: y)
        
        XCTAssertEqual(result.a, 2.0, accuracy: 0.01)
        XCTAssertEqual(result.b, 0.5, accuracy: 0.01)
        XCTAssertEqual(result.coefficientOfDetermination, 1.0, accuracy: 0.001)
    }
    
    func test_EExponential_EstimateY_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { 2.0 * exp(0.5 * $0) }
        
        let result = try Regression.eExponential(xValues: x, yValues: y)
        
        let expected = 2.0 * exp(0.5 * 6.0)
        XCTAssertEqual(result.estimateY(from: 6.0), expected, accuracy: 0.1)
    }
    
    func test_EExponential_NegativeY_ThrowsError() {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [-1.0, 2.0, 3.0, 4.0, 5.0]
        
        XCTAssertThrowsError(try Regression.eExponential(xValues: x, yValues: y)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domainError")
                return
            }
        }
    }
    
    // MARK: - ab-Exponential Regression Tests
    
    func test_ABExponential_KnownData_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { 3.0 * pow(2.0, $0) }
        
        let result = try Regression.abExponential(xValues: x, yValues: y)
        
        XCTAssertEqual(result.a, 3.0, accuracy: 0.1)
        XCTAssertEqual(result.b, 2.0, accuracy: 0.1)
        XCTAssertEqual(result.coefficientOfDetermination, 1.0, accuracy: 0.001)
    }
    
    func test_ABExponential_EstimateY_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { 3.0 * pow(2.0, $0) }
        
        let result = try Regression.abExponential(xValues: x, yValues: y)
        
        let expected = 3.0 * pow(2.0, 6.0)
        XCTAssertEqual(result.estimateY(from: 6.0), expected, accuracy: 1.0)
    }
    
    func test_ABExponential_NegativeY_ThrowsError() {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [1.0, 2.0, -3.0, 4.0, 5.0]
        
        XCTAssertThrowsError(try Regression.abExponential(xValues: x, yValues: y)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domainError")
                return
            }
        }
    }
    
    // MARK: - Power Regression Tests
    
    func test_Power_KnownData_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { 2.0 * pow($0, 3.0) }
        
        let result = try Regression.power(xValues: x, yValues: y)
        
        XCTAssertEqual(result.a, 2.0, accuracy: 0.1)
        XCTAssertEqual(result.b, 3.0, accuracy: 0.1)
        XCTAssertEqual(result.coefficientOfDetermination, 1.0, accuracy: 0.001)
    }
    
    func test_Power_EstimateY_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { 2.0 * pow($0, 3.0) }
        
        let result = try Regression.power(xValues: x, yValues: y)
        
        let expected = 2.0 * pow(6.0, 3.0)
        XCTAssertEqual(result.estimateY(from: 6.0), expected, accuracy: 1.0)
    }
    
    func test_Power_NegativeX_ThrowsError() {
        let x = [-1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [1.0, 2.0, 3.0, 4.0, 5.0]
        
        XCTAssertThrowsError(try Regression.power(xValues: x, yValues: y)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domainError")
                return
            }
        }
    }
    
    func test_Power_NegativeY_ThrowsError() {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [1.0, 2.0, -3.0, 4.0, 5.0]
        
        XCTAssertThrowsError(try Regression.power(xValues: x, yValues: y)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domainError")
                return
            }
        }
    }
    
    // MARK: - Inverse Regression Tests
    
    func test_Inverse_KnownData_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { 2.0 + 6.0 / $0 }
        
        let result = try Regression.inverse(xValues: x, yValues: y)
        
        XCTAssertEqual(result.a, 2.0, accuracy: 0.01)
        XCTAssertEqual(result.b, 6.0, accuracy: 0.01)
        XCTAssertEqual(result.coefficientOfDetermination, 1.0, accuracy: 0.001)
    }
    
    func test_Inverse_EstimateY_ReturnsCorrect() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { 2.0 + 6.0 / $0 }
        
        let result = try Regression.inverse(xValues: x, yValues: y)
        
        let expected = 2.0 + 6.0 / 10.0
        XCTAssertEqual(result.estimateY(from: 10.0), expected, accuracy: 0.01)
    }
    
    func test_Inverse_ZeroX_ThrowsError() {
        let x = [0.0, 2.0, 3.0, 4.0, 5.0]
        let y = [1.0, 2.0, 3.0, 4.0, 5.0]
        
        XCTAssertThrowsError(try Regression.inverse(xValues: x, yValues: y)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domainError")
                return
            }
        }
    }
    
    // MARK: - Best Fit Tests
    
    func test_BestFit_LinearData_ReturnsLinear() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 6.0, 8.0, 10.0]
        
        let result = try Regression.bestFit(xValues: x, yValues: y)
        
        XCTAssertEqual(result.coefficientOfDetermination, 1.0, accuracy: 0.001)
    }
    
    func test_BestFit_ExponentialData_HighRSquared() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { exp($0) }
        
        let result = try Regression.bestFit(xValues: x, yValues: y)
        
        XCTAssertGreaterThan(result.coefficientOfDetermination, 0.99)
    }
    
    func test_BestFit_QuadraticData_HighRSquared() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { $0 * $0 }
        
        let result = try Regression.bestFit(xValues: x, yValues: y)
        
        XCTAssertGreaterThan(result.coefficientOfDetermination, 0.99)
    }
    
    // MARK: - Regression Type Tests
    
    func test_Regression_ByType_Works() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [2.0, 4.0, 6.0, 8.0, 10.0]
        
        let linearResult = try Regression.regression(.linear, xValues: x, yValues: y)
        XCTAssertEqual(linearResult.type, .linear)
        
        let quadResult = try Regression.regression(.quadratic, xValues: x, yValues: y)
        XCTAssertEqual(quadResult.type, .quadratic)
    }
    
    // MARK: - RegressionType Tests
    
    func test_RegressionType_DisplayNames() {
        XCTAssertEqual(RegressionType.linear.displayName, "Linear")
        XCTAssertEqual(RegressionType.quadratic.displayName, "Quadratic")
        XCTAssertEqual(RegressionType.logarithmic.displayName, "Logarithmic")
        XCTAssertEqual(RegressionType.eExponential.displayName, "e Exponential")
        XCTAssertEqual(RegressionType.abExponential.displayName, "ab Exponential")
        XCTAssertEqual(RegressionType.power.displayName, "Power")
        XCTAssertEqual(RegressionType.inverse.displayName, "Inverse")
    }
    
    func test_RegressionType_CoefficientCount() {
        XCTAssertEqual(RegressionType.linear.coefficientCount, 2)
        XCTAssertEqual(RegressionType.quadratic.coefficientCount, 3)
        XCTAssertEqual(RegressionType.logarithmic.coefficientCount, 2)
    }
    
    // MARK: - RegressionResult Tests
    
    func test_RegressionResult_Equation_Linear() throws {
        let x = [1.0, 2.0, 3.0]
        let y = [3.0, 5.0, 7.0]
        
        let result = try Regression.linear(xValues: x, yValues: y)
        XCTAssertTrue(result.equation.contains("y ="))
    }
    
    func test_RegressionResult_Coefficients_Dictionary() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = x.map { $0 * $0 }
        
        let result = try Regression.quadratic(xValues: x, yValues: y)
        
        XCTAssertNotNil(result.coefficients["a"])
        XCTAssertNotNil(result.coefficients["b"])
        XCTAssertNotNil(result.coefficients["c"])
    }
    
    func test_RegressionResult_EstimateX_Linear() throws {
        let x = [1.0, 2.0, 3.0]
        let y = [2.0, 4.0, 6.0]
        
        let result = try Regression.linear(xValues: x, yValues: y)
        
        XCTAssertEqual(result.estimateX(from: 8.0), 4.0, accuracy: 0.001)
    }
    
    func test_RegressionResult_EstimateX_ZeroSlope_ReturnsNil() throws {
        let x = [1.0, 2.0, 3.0, 4.0, 5.0]
        let y = [5.0, 5.0, 5.0, 5.0, 5.0]
        
        let result = try Regression.linear(xValues: x, yValues: y)
        
        XCTAssertNil(result.estimateX(from: 5.0))
    }
}
