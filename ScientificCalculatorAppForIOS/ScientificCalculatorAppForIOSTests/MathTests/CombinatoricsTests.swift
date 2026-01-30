import XCTest
@testable import ScientificCalculatorAppForIOS

final class CombinatoricsTests: XCTestCase {
    
    // MARK: - Factorial Tests
    
    func test_Factorial_Zero_ReturnsOne() throws {
        let result = try Combinatorics.factorial(0)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_Factorial_One_ReturnsOne() throws {
        let result = try Combinatorics.factorial(1)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_Factorial_Two_ReturnsTwo() throws {
        let result = try Combinatorics.factorial(2)
        XCTAssertEqual(result, 2, accuracy: 1e-15)
    }
    
    func test_Factorial_Three_ReturnsSix() throws {
        let result = try Combinatorics.factorial(3)
        XCTAssertEqual(result, 6, accuracy: 1e-15)
    }
    
    func test_Factorial_Five_Returns120() throws {
        let result = try Combinatorics.factorial(5)
        XCTAssertEqual(result, 120, accuracy: 1e-15)
    }
    
    func test_Factorial_Ten_Returns3628800() throws {
        let result = try Combinatorics.factorial(10)
        XCTAssertEqual(result, 3_628_800, accuracy: 1e-10)
    }
    
    func test_Factorial_Twenty_ReturnsCorrectValue() throws {
        let result = try Combinatorics.factorial(20)
        XCTAssertEqual(result, 2_432_902_008_176_640_000, accuracy: 1e5)
    }
    
    func test_Factorial_170_DoesNotOverflow() throws {
        let result = try Combinatorics.factorial(170)
        XCTAssertTrue(result.isFinite)
        XCTAssertGreaterThan(result, 0)
    }
    
    func test_Factorial_Negative_ThrowsDomainError() {
        XCTAssertThrowsError(try Combinatorics.factorial(-1)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Factorial_NonInteger_ThrowsDomainError() {
        XCTAssertThrowsError(try Combinatorics.factorial(3.5)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Factorial_171_ThrowsOverflow() {
        XCTAssertThrowsError(try Combinatorics.factorial(171)) { error in
            XCTAssertEqual(error as? CalculatorError, .overflow)
        }
    }
    
    func test_Factorial_NegativeNonInteger_ThrowsDomainError() {
        XCTAssertThrowsError(try Combinatorics.factorial(-2.5)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    // MARK: - Permutation Tests
    
    func test_Permutation_5P3_Returns60() throws {
        let result = try Combinatorics.permutation(n: 5, r: 3)
        XCTAssertEqual(result, 60, accuracy: 1e-15)
    }
    
    func test_Permutation_10P0_Returns1() throws {
        let result = try Combinatorics.permutation(n: 10, r: 0)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_Permutation_5P5_Returns120() throws {
        let result = try Combinatorics.permutation(n: 5, r: 5)
        XCTAssertEqual(result, 120, accuracy: 1e-15)
    }
    
    func test_Permutation_10P3_Returns720() throws {
        let result = try Combinatorics.permutation(n: 10, r: 3)
        XCTAssertEqual(result, 720, accuracy: 1e-15)
    }
    
    func test_Permutation_7P2_Returns42() throws {
        let result = try Combinatorics.permutation(n: 7, r: 2)
        XCTAssertEqual(result, 42, accuracy: 1e-15)
    }
    
    func test_Permutation_0P0_Returns1() throws {
        let result = try Combinatorics.permutation(n: 0, r: 0)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_Permutation_RGreaterThanN_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.permutation(n: 3, r: 5)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Permutation_NegativeN_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.permutation(n: -5, r: 3)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Permutation_NegativeR_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.permutation(n: 5, r: -1)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Permutation_NonIntegerN_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.permutation(n: 5.5, r: 3)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Permutation_NonIntegerR_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.permutation(n: 5, r: 2.5)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    // MARK: - Combination Tests
    
    func test_Combination_5C3_Returns10() throws {
        let result = try Combinatorics.combination(n: 5, r: 3)
        XCTAssertEqual(result, 10, accuracy: 1e-15)
    }
    
    func test_Combination_10C0_Returns1() throws {
        let result = try Combinatorics.combination(n: 10, r: 0)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_Combination_10C10_Returns1() throws {
        let result = try Combinatorics.combination(n: 10, r: 10)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_Combination_10C5_Returns252() throws {
        let result = try Combinatorics.combination(n: 10, r: 5)
        XCTAssertEqual(result, 252, accuracy: 1e-15)
    }
    
    func test_Combination_20C10_Returns184756() throws {
        let result = try Combinatorics.combination(n: 20, r: 10)
        XCTAssertEqual(result, 184_756, accuracy: 1e-10)
    }
    
    func test_Combination_Symmetry_nCr_Equals_nC_n_minus_r() throws {
        let nCr = try Combinatorics.combination(n: 10, r: 3)
        let nC_n_minus_r = try Combinatorics.combination(n: 10, r: 7)
        
        XCTAssertEqual(nCr, nC_n_minus_r, accuracy: 1e-15)
    }
    
    func test_Combination_0C0_Returns1() throws {
        let result = try Combinatorics.combination(n: 0, r: 0)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_Combination_RGreaterThanN_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.combination(n: 3, r: 5)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Combination_NegativeN_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.combination(n: -5, r: 3)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Combination_NonIntegerN_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.combination(n: 5.5, r: 3)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    // MARK: - GCD Tests
    
    func test_GCD_12And8_Returns4() throws {
        let result = try Combinatorics.gcd(12, 8)
        XCTAssertEqual(result, 4, accuracy: 1e-15)
    }
    
    func test_GCD_17And13_Returns1() throws {
        let result = try Combinatorics.gcd(17, 13)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_GCD_100And25_Returns25() throws {
        let result = try Combinatorics.gcd(100, 25)
        XCTAssertEqual(result, 25, accuracy: 1e-15)
    }
    
    func test_GCD_48And18_Returns6() throws {
        let result = try Combinatorics.gcd(48, 18)
        XCTAssertEqual(result, 6, accuracy: 1e-15)
    }
    
    func test_GCD_Commutative() throws {
        let gcd1 = try Combinatorics.gcd(36, 48)
        let gcd2 = try Combinatorics.gcd(48, 36)
        
        XCTAssertEqual(gcd1, gcd2, accuracy: 1e-15)
    }
    
    func test_GCD_SameNumber_ReturnsThatNumber() throws {
        let result = try Combinatorics.gcd(42, 42)
        XCTAssertEqual(result, 42, accuracy: 1e-15)
    }
    
    func test_GCD_OneAndAny_Returns1() throws {
        let result = try Combinatorics.gcd(1, 999)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_GCD_Zero_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.gcd(0, 5)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_GCD_Negative_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.gcd(-12, 8)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_GCD_NonInteger_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.gcd(12.5, 8)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    // MARK: - LCM Tests
    
    func test_LCM_4And6_Returns12() throws {
        let result = try Combinatorics.lcm(4, 6)
        XCTAssertEqual(result, 12, accuracy: 1e-15)
    }
    
    func test_LCM_3And5_Returns15() throws {
        let result = try Combinatorics.lcm(3, 5)
        XCTAssertEqual(result, 15, accuracy: 1e-15)
    }
    
    func test_LCM_12And8_Returns24() throws {
        let result = try Combinatorics.lcm(12, 8)
        XCTAssertEqual(result, 24, accuracy: 1e-15)
    }
    
    func test_LCM_Commutative() throws {
        let lcm1 = try Combinatorics.lcm(15, 20)
        let lcm2 = try Combinatorics.lcm(20, 15)
        
        XCTAssertEqual(lcm1, lcm2, accuracy: 1e-15)
    }
    
    func test_LCM_SameNumber_ReturnsThatNumber() throws {
        let result = try Combinatorics.lcm(7, 7)
        XCTAssertEqual(result, 7, accuracy: 1e-15)
    }
    
    func test_LCM_1AndAny_ReturnsThatNumber() throws {
        let result = try Combinatorics.lcm(1, 42)
        XCTAssertEqual(result, 42, accuracy: 1e-15)
    }
    
    func test_LCM_CoprimePair_ReturnsProduct() throws {
        let result = try Combinatorics.lcm(7, 11)
        XCTAssertEqual(result, 77, accuracy: 1e-15)
    }
    
    func test_LCM_Zero_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.lcm(0, 5)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_LCM_Negative_ThrowsError() {
        XCTAssertThrowsError(try Combinatorics.lcm(-4, 6)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    // MARK: - GCD and LCM Relationship Tests
    
    func test_GCD_LCM_Product_Equals_AB() throws {
        let a: Double = 12
        let b: Double = 18
        let gcd = try Combinatorics.gcd(a, b)
        let lcm = try Combinatorics.lcm(a, b)
        
        XCTAssertEqual(gcd * lcm, a * b, accuracy: 1e-10)
    }
    
    // MARK: - Modulo Tests
    
    func test_Mod_10And3_Returns1() throws {
        let result = try Combinatorics.mod(10, 3)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_Mod_15And5_Returns0() throws {
        let result = try Combinatorics.mod(15, 5)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    func test_Mod_7And4_Returns3() throws {
        let result = try Combinatorics.mod(7, 4)
        XCTAssertEqual(result, 3, accuracy: 1e-15)
    }
    
    func test_Mod_NegativeDividend_ReturnsPositive() throws {
        // Mathematical mod: -10 mod 3 = 2 (not -1)
        let result = try Combinatorics.mod(-10, 3)
        XCTAssertEqual(result, 2, accuracy: 1e-15)
    }
    
    func test_Mod_NegativeDividend_AnotherExample() throws {
        // -7 mod 4 = 1 (not -3)
        let result = try Combinatorics.mod(-7, 4)
        XCTAssertEqual(result, 1, accuracy: 1e-15)
    }
    
    func test_Mod_FloatingPoint_Works() throws {
        let result = try Combinatorics.mod(5.5, 2.0)
        XCTAssertEqual(result, 1.5, accuracy: 1e-15)
    }
    
    func test_Mod_NegativeDivisor_Works() throws {
        let result = try Combinatorics.mod(10, -3)
        XCTAssertEqual(result, -2, accuracy: 1e-15)
    }
    
    func test_Mod_ZeroDivisor_ThrowsDivisionByZero() {
        XCTAssertThrowsError(try Combinatorics.mod(10, 0)) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_Mod_ZeroDividend_ReturnsZero() throws {
        let result = try Combinatorics.mod(0, 5)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
}
