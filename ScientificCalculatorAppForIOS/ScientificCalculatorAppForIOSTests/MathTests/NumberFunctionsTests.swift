import XCTest
@testable import ScientificCalculatorAppForIOS

final class NumberFunctionsTests: XCTestCase {
    
    // MARK: - Integer Part Tests
    
    func test_IntPart_Positive_TruncatesTowardZero() {
        let result = NumberFunctions.integerPart(3.7)
        XCTAssertEqual(result, 3, accuracy: 1e-15)
    }
    
    func test_IntPart_Negative_TruncatesTowardZero() {
        let result = NumberFunctions.integerPart(-3.7)
        XCTAssertEqual(result, -3, accuracy: 1e-15)
    }
    
    func test_IntPart_WholeNumber_ReturnsSame() {
        let result = NumberFunctions.integerPart(5.0)
        XCTAssertEqual(result, 5, accuracy: 1e-15)
    }
    
    func test_IntPart_Zero_ReturnsZero() {
        let result = NumberFunctions.integerPart(0.0)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    func test_IntPart_SmallPositive_ReturnsZero() {
        let result = NumberFunctions.integerPart(0.999)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    func test_IntPart_SmallNegative_ReturnsZero() {
        let result = NumberFunctions.integerPart(-0.999)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    // MARK: - Fractional Part Tests
    
    func test_FracPart_Positive_ReturnsFraction() {
        let result = NumberFunctions.fractionalPart(3.7)
        XCTAssertEqual(result, 0.7, accuracy: 1e-15)
    }
    
    func test_FracPart_Negative_ReturnsNegativeFraction() {
        let result = NumberFunctions.fractionalPart(-3.7)
        XCTAssertEqual(result, -0.7, accuracy: 1e-15)
    }
    
    func test_FracPart_WholeNumber_ReturnsZero() {
        let result = NumberFunctions.fractionalPart(5.0)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    func test_FracPart_Zero_ReturnsZero() {
        let result = NumberFunctions.fractionalPart(0.0)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    func test_IntPart_Plus_FracPart_Equals_Original() {
        let value = 7.25
        let intPart = NumberFunctions.integerPart(value)
        let fracPart = NumberFunctions.fractionalPart(value)
        
        XCTAssertEqual(intPart + fracPart, value, accuracy: 1e-15)
    }
    
    func test_IntPart_Plus_FracPart_Equals_Original_Negative() {
        let value = -7.25
        let intPart = NumberFunctions.integerPart(value)
        let fracPart = NumberFunctions.fractionalPart(value)
        
        XCTAssertEqual(intPart + fracPart, value, accuracy: 1e-15)
    }
    
    // MARK: - Rounding Tests
    
    func test_Round_ToTwoPlaces() {
        let result = NumberFunctions.round(3.14159, places: 2)
        XCTAssertEqual(result, 3.14, accuracy: 1e-15)
    }
    
    func test_Round_ToZeroPlaces() {
        let result = NumberFunctions.round(3.7, places: 0)
        XCTAssertEqual(result, 4, accuracy: 1e-15)
    }
    
    func test_Round_Negative_ToTwoPlaces() {
        let result = NumberFunctions.round(-3.14159, places: 2)
        XCTAssertEqual(result, -3.14, accuracy: 1e-15)
    }
    
    func test_Round_HalfUp() {
        let result = NumberFunctions.round(2.5, places: 0)
        XCTAssertEqual(result, 3, accuracy: 1e-15)
    }
    
    func test_Round_PlacesClamped_Negative() {
        let result = NumberFunctions.round(3.14159, places: -5)
        XCTAssertEqual(result, 3, accuracy: 1e-15)
    }
    
    func test_Round_PlacesClamped_TooBig() {
        let result = NumberFunctions.round(3.14159, places: 100)
        XCTAssertEqual(result, 3.14159, accuracy: 1e-9)
    }
    
    func test_RoundToDisplayPrecision_Works() {
        let result = NumberFunctions.roundToDisplayPrecision(123.456789012345)
        XCTAssertEqual(result, 123.4567890, accuracy: 1e-7)
    }
    
    func test_RoundToDisplayPrecision_Zero_ReturnsZero() {
        let result = NumberFunctions.roundToDisplayPrecision(0)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    // MARK: - Floor and Ceiling Tests
    
    func test_Floor_Positive_RoundsDown() {
        let result = NumberFunctions.floor(3.7)
        XCTAssertEqual(result, 3, accuracy: 1e-15)
    }
    
    func test_Floor_Negative_RoundsDown() {
        let result = NumberFunctions.floor(-3.2)
        XCTAssertEqual(result, -4, accuracy: 1e-15)
    }
    
    func test_Floor_WholeNumber_ReturnsSame() {
        let result = NumberFunctions.floor(5.0)
        XCTAssertEqual(result, 5, accuracy: 1e-15)
    }
    
    func test_Ceil_Positive_RoundsUp() {
        let result = NumberFunctions.ceil(3.2)
        XCTAssertEqual(result, 4, accuracy: 1e-15)
    }
    
    func test_Ceil_Negative_RoundsUp() {
        let result = NumberFunctions.ceil(-3.7)
        XCTAssertEqual(result, -3, accuracy: 1e-15)
    }
    
    func test_Ceil_WholeNumber_ReturnsSame() {
        let result = NumberFunctions.ceil(5.0)
        XCTAssertEqual(result, 5, accuracy: 1e-15)
    }
    
    // MARK: - Random Number Tests
    
    func test_Random_ReturnsBetweenZeroAndOne() {
        for _ in 0..<100 {
            let result = NumberFunctions.random()
            XCTAssertGreaterThanOrEqual(result, 0)
            XCTAssertLessThan(result, 1)
        }
    }
    
    func test_RandomInt_ReturnsWithinRange() throws {
        for _ in 0..<100 {
            let result = try NumberFunctions.randomInt(min: 1, max: 10)
            XCTAssertGreaterThanOrEqual(result, 1)
            XCTAssertLessThanOrEqual(result, 10)
            XCTAssertEqual(result, Foundation.round(result))
        }
    }
    
    func test_RandomInt_SingleValue_ReturnsThatValue() throws {
        let result = try NumberFunctions.randomInt(min: 5, max: 5)
        XCTAssertEqual(result, 5, accuracy: 1e-15)
    }
    
    func test_RandomInt_NegativeRange_Works() throws {
        for _ in 0..<100 {
            let result = try NumberFunctions.randomInt(min: -10, max: -5)
            XCTAssertGreaterThanOrEqual(result, -10)
            XCTAssertLessThanOrEqual(result, -5)
        }
    }
    
    func test_RandomInt_MinGreaterThanMax_ThrowsError() {
        XCTAssertThrowsError(try NumberFunctions.randomInt(min: 10, max: 5)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_RandomInt_NonIntegerMin_ThrowsError() {
        XCTAssertThrowsError(try NumberFunctions.randomInt(min: 1.5, max: 10)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_RandomInt_NonIntegerMax_ThrowsError() {
        XCTAssertThrowsError(try NumberFunctions.randomInt(min: 1, max: 10.5)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    // MARK: - Sign and Absolute Value Tests
    
    func test_Sign_Positive_Returns1() {
        let result = NumberFunctions.sign(42)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_Sign_Negative_ReturnsMinus1() {
        let result = NumberFunctions.sign(-42)
        XCTAssertEqual(result, -1, accuracy: 1e-15)
    }
    
    func test_Sign_Zero_ReturnsZero() {
        let result = NumberFunctions.sign(0)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    func test_Abs_Positive_ReturnsSame() {
        let result = NumberFunctions.abs(5)
        XCTAssertEqual(result, 5, accuracy: 1e-15)
    }
    
    func test_Abs_Negative_ReturnsPositive() {
        let result = NumberFunctions.abs(-5)
        XCTAssertEqual(result, 5, accuracy: 1e-15)
    }
    
    func test_Abs_Zero_ReturnsZero() {
        let result = NumberFunctions.abs(0)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    // MARK: - TenPow Tests
    
    func test_TenPow_2_Returns100() throws {
        let result = try NumberFunctions.tenPow(2)
        XCTAssertEqual(result, 100, accuracy: 1e-15)
    }
    
    func test_TenPow_0_Returns1() throws {
        let result = try NumberFunctions.tenPow(0)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_TenPow_Negative2_Returns0point01() throws {
        let result = try NumberFunctions.tenPow(-2)
        XCTAssertEqual(result, 0.01, accuracy: 1e-15)
    }
    
    func test_TenPow_3_Returns1000() throws {
        let result = try NumberFunctions.tenPow(3)
        XCTAssertEqual(result, 1000, accuracy: 1e-15)
    }
    
    func test_TenPow_0point5_ReturnsSqrt10() throws {
        let result = try NumberFunctions.tenPow(0.5)
        XCTAssertEqual(result, sqrt(10), accuracy: 1e-10)
    }
    
    func test_TenPow_TooLarge_ThrowsOverflow() {
        XCTAssertThrowsError(try NumberFunctions.tenPow(309)) { error in
            XCTAssertEqual(error as? CalculatorError, .overflow)
        }
    }
    
    func test_TenPow_TooSmall_ThrowsUnderflow() {
        XCTAssertThrowsError(try NumberFunctions.tenPow(-324)) { error in
            XCTAssertEqual(error as? CalculatorError, .underflow)
        }
    }
    
    // MARK: - Reciprocal Tests
    
    func test_Reciprocal_4_Returns0point25() throws {
        let result = try NumberFunctions.reciprocal(4)
        XCTAssertEqual(result, 0.25, accuracy: 1e-15)
    }
    
    func test_Reciprocal_0point5_Returns2() throws {
        let result = try NumberFunctions.reciprocal(0.5)
        XCTAssertEqual(result, 2, accuracy: 1e-15)
    }
    
    func test_Reciprocal_Negative2_ReturnsMinus0point5() throws {
        let result = try NumberFunctions.reciprocal(-2)
        XCTAssertEqual(result, -0.5, accuracy: 1e-15)
    }
    
    func test_Reciprocal_1_Returns1() throws {
        let result = try NumberFunctions.reciprocal(1)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_Reciprocal_Zero_ThrowsDivisionByZero() {
        XCTAssertThrowsError(try NumberFunctions.reciprocal(0)) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_Reciprocal_Involution() throws {
        let value = 3.5
        let reciprocal = try NumberFunctions.reciprocal(value)
        let doubleReciprocal = try NumberFunctions.reciprocal(reciprocal)
        
        XCTAssertEqual(doubleReciprocal, value, accuracy: 1e-15)
    }
    
    // MARK: - Square Tests
    
    func test_Square_5_Returns25() throws {
        let result = try NumberFunctions.square(5)
        XCTAssertEqual(result, 25, accuracy: 1e-15)
    }
    
    func test_Square_Negative3_Returns9() throws {
        let result = try NumberFunctions.square(-3)
        XCTAssertEqual(result, 9, accuracy: 1e-15)
    }
    
    func test_Square_Zero_ReturnsZero() throws {
        let result = try NumberFunctions.square(0)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    func test_Square_0point5_Returns0point25() throws {
        let result = try NumberFunctions.square(0.5)
        XCTAssertEqual(result, 0.25, accuracy: 1e-15)
    }
    
    // MARK: - Cube Tests
    
    func test_Cube_3_Returns27() throws {
        let result = try NumberFunctions.cube(3)
        XCTAssertEqual(result, 27, accuracy: 1e-15)
    }
    
    func test_Cube_Negative2_ReturnsMinus8() throws {
        let result = try NumberFunctions.cube(-2)
        XCTAssertEqual(result, -8, accuracy: 1e-15)
    }
    
    func test_Cube_Zero_ReturnsZero() throws {
        let result = try NumberFunctions.cube(0)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    func test_Cube_0point5_Returns0point125() throws {
        let result = try NumberFunctions.cube(0.5)
        XCTAssertEqual(result, 0.125, accuracy: 1e-15)
    }
    
    // MARK: - nth Root Tests
    
    func test_NthRoot_CubeRoot27_Returns3() throws {
        let result = try NumberFunctions.nthRoot(index: 3, radicand: 27)
        XCTAssertEqual(result, 3, accuracy: 1e-10)
    }
    
    func test_NthRoot_4thRoot16_Returns2() throws {
        let result = try NumberFunctions.nthRoot(index: 4, radicand: 16)
        XCTAssertEqual(result, 2, accuracy: 1e-10)
    }
    
    func test_NthRoot_SquareRoot4_Returns2() throws {
        let result = try NumberFunctions.nthRoot(index: 2, radicand: 4)
        XCTAssertEqual(result, 2, accuracy: 1e-10)
    }
    
    func test_NthRoot_5thRoot32_Returns2() throws {
        let result = try NumberFunctions.nthRoot(index: 5, radicand: 32)
        XCTAssertEqual(result, 2, accuracy: 1e-10)
    }
    
    func test_NthRoot_CubeRoot0_Returns0() throws {
        let result = try NumberFunctions.nthRoot(index: 3, radicand: 0)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    func test_NthRoot_NegativeWithOddRoot_ReturnsNegative() throws {
        let result = try NumberFunctions.nthRoot(index: 3, radicand: -8)
        XCTAssertEqual(result, -2, accuracy: 1e-10)
    }
    
    func test_NthRoot_5thRootOfNegative_ReturnsNegative() throws {
        let result = try NumberFunctions.nthRoot(index: 5, radicand: -32)
        XCTAssertEqual(result, -2, accuracy: 1e-10)
    }
    
    func test_NthRoot_NegativeWithEvenRoot_ThrowsDomainError() {
        XCTAssertThrowsError(try NumberFunctions.nthRoot(index: 2, radicand: -4)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_NthRoot_4thRootOfNegative_ThrowsDomainError() {
        XCTAssertThrowsError(try NumberFunctions.nthRoot(index: 4, radicand: -16)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_NthRoot_IndexZero_ThrowsDomainError() {
        XCTAssertThrowsError(try NumberFunctions.nthRoot(index: 0, radicand: 8)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    // MARK: - Log Base Tests
    
    func test_LogBase_2Of8_Returns3() throws {
        let result = try NumberFunctions.logBase(2, of: 8)
        XCTAssertEqual(result, 3, accuracy: 1e-10)
    }
    
    func test_LogBase_10Of100_Returns2() throws {
        let result = try NumberFunctions.logBase(10, of: 100)
        XCTAssertEqual(result, 2, accuracy: 1e-10)
    }
    
    func test_LogBase_EOfE_Returns1() throws {
        let result = try NumberFunctions.logBase(M_E, of: M_E)
        XCTAssertEqual(result, 1, accuracy: 1e-10)
    }
    
    func test_LogBase_AnyOf1_Returns0() throws {
        let result = try NumberFunctions.logBase(5, of: 1)
        XCTAssertEqual(result, 0, accuracy: 1e-10)
    }
    
    func test_LogBase_3Of81_Returns4() throws {
        let result = try NumberFunctions.logBase(3, of: 81)
        XCTAssertEqual(result, 4, accuracy: 1e-10)
    }
    
    func test_LogBase_FractionalBase_Works() throws {
        let result = try NumberFunctions.logBase(0.5, of: 0.25)
        XCTAssertEqual(result, 2, accuracy: 1e-10)
    }
    
    func test_LogBase_BaseZero_ThrowsDomainError() {
        XCTAssertThrowsError(try NumberFunctions.logBase(0, of: 8)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_LogBase_NegativeBase_ThrowsDomainError() {
        XCTAssertThrowsError(try NumberFunctions.logBase(-2, of: 8)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_LogBase_BaseOne_ThrowsDomainError() {
        XCTAssertThrowsError(try NumberFunctions.logBase(1, of: 8)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_LogBase_ValueZero_ThrowsDomainError() {
        XCTAssertThrowsError(try NumberFunctions.logBase(2, of: 0)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_LogBase_NegativeValue_ThrowsDomainError() {
        XCTAssertThrowsError(try NumberFunctions.logBase(2, of: -8)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    // MARK: - Percent Tests
    
    func test_Percent_50_Returns0point5() {
        let result = NumberFunctions.percent(50)
        XCTAssertEqual(result, 0.5, accuracy: 1e-15)
    }
    
    func test_Percent_100_Returns1() {
        let result = NumberFunctions.percent(100)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_Percent_0_Returns0() {
        let result = NumberFunctions.percent(0)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    func test_Percent_25_Returns0point25() {
        let result = NumberFunctions.percent(25)
        XCTAssertEqual(result, 0.25, accuracy: 1e-15)
    }
    
    func test_Percent_Negative10_ReturnsMinus0point1() {
        let result = NumberFunctions.percent(-10)
        XCTAssertEqual(result, -0.1, accuracy: 1e-15)
    }
    
    func test_Percent_150_Returns1point5() {
        let result = NumberFunctions.percent(150)
        XCTAssertEqual(result, 1.5, accuracy: 1e-15)
    }
}
