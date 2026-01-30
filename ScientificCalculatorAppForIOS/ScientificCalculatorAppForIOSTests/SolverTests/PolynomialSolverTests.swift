import XCTest
@testable import ScientificCalculatorAppForIOS

final class PolynomialSolverTests: XCTestCase {
    
    // MARK: - Quadratic Tests - Real Roots
    
    func test_Quadratic_TwoDistinctRealRoots() throws {
        // x² - 5x + 6 = 0 → x = 2, 3
        let result = try PolynomialSolver.solveQuadratic(a: 1, b: -5, c: 6)
        
        XCTAssertEqual(result.degree, 2)
        XCTAssertEqual(result.realRoots.count, 2)
        XCTAssertTrue(result.complexRoots.isEmpty)
        XCTAssertTrue(result.allReal)
        
        let sortedRoots = result.realRoots.sorted()
        XCTAssertEqual(sortedRoots[0], 2, accuracy: 1e-10)
        XCTAssertEqual(sortedRoots[1], 3, accuracy: 1e-10)
    }
    
    func test_Quadratic_RepeatedRoot() throws {
        // x² - 4x + 4 = 0 → x = 2 (double root)
        let result = try PolynomialSolver.solveQuadratic(a: 1, b: -4, c: 4)
        
        XCTAssertEqual(result.realRoots.count, 2)
        XCTAssertEqual(result.realRoots[0], 2, accuracy: 1e-10)
        XCTAssertEqual(result.realRoots[1], 2, accuracy: 1e-10)
    }
    
    func test_Quadratic_NegativeRoots() throws {
        // x² + 5x + 6 = 0 → x = -2, -3
        let result = try PolynomialSolver.solveQuadratic(a: 1, b: 5, c: 6)
        
        XCTAssertEqual(result.realRoots.count, 2)
        let sortedRoots = result.realRoots.sorted()
        XCTAssertEqual(sortedRoots[0], -3, accuracy: 1e-10)
        XCTAssertEqual(sortedRoots[1], -2, accuracy: 1e-10)
    }
    
    func test_Quadratic_OnePositiveOneNegativeRoot() throws {
        // x² - 1 = 0 → x = ±1
        let result = try PolynomialSolver.solveQuadratic(a: 1, b: 0, c: -1)
        
        XCTAssertEqual(result.realRoots.count, 2)
        let sortedRoots = result.realRoots.sorted()
        XCTAssertEqual(sortedRoots[0], -1, accuracy: 1e-10)
        XCTAssertEqual(sortedRoots[1], 1, accuracy: 1e-10)
    }
    
    // MARK: - Quadratic Tests - Complex Roots
    
    func test_Quadratic_ComplexConjugateRoots() throws {
        // x² + 1 = 0 → x = ±i
        let result = try PolynomialSolver.solveQuadratic(a: 1, b: 0, c: 1)
        
        XCTAssertTrue(result.realRoots.isEmpty)
        XCTAssertFalse(result.allReal)
        XCTAssertEqual(result.complexRoots.count, 2)
        
        let z1 = result.complexRoots[0]
        let z2 = result.complexRoots[1]
        XCTAssertEqual(z1.real, 0, accuracy: 1e-10)
        XCTAssertEqual(z2.real, 0, accuracy: 1e-10)
        XCTAssertEqual(abs(z1.imaginary), 1, accuracy: 1e-10)
        XCTAssertEqual(abs(z2.imaginary), 1, accuracy: 1e-10)
        // Conjugate pair
        XCTAssertEqual(z1.imaginary, -z2.imaginary, accuracy: 1e-10)
    }
    
    func test_Quadratic_ComplexRootsWithRealPart() throws {
        // x² - 2x + 5 = 0 → x = 1 ± 2i
        let result = try PolynomialSolver.solveQuadratic(a: 1, b: -2, c: 5)
        
        XCTAssertTrue(result.realRoots.isEmpty)
        XCTAssertEqual(result.complexRoots.count, 2)
        
        for z in result.complexRoots {
            XCTAssertEqual(z.real, 1, accuracy: 1e-10)
            XCTAssertEqual(abs(z.imaginary), 2, accuracy: 1e-10)
        }
    }
    
    // MARK: - Quadratic Tests - Error Cases
    
    func test_Quadratic_LeadingZero_ThrowsError() {
        XCTAssertThrowsError(try PolynomialSolver.solveQuadratic(a: 0, b: 2, c: 1)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Quadratic_WithScaling() throws {
        // 2x² - 10x + 12 = 0 → x = 2, 3
        let result = try PolynomialSolver.solveQuadratic(a: 2, b: -10, c: 12)
        
        XCTAssertEqual(result.realRoots.count, 2)
        let sortedRoots = result.realRoots.sorted()
        XCTAssertEqual(sortedRoots[0], 2, accuracy: 1e-10)
        XCTAssertEqual(sortedRoots[1], 3, accuracy: 1e-10)
    }
    
    // MARK: - Cubic Tests - Three Real Roots
    
    func test_Cubic_ThreeDistinctRealRoots() throws {
        // x³ - 6x² + 11x - 6 = 0 → x = 1, 2, 3
        let result = try PolynomialSolver.solveCubic(a: 1, b: -6, c: 11, d: -6)
        
        XCTAssertEqual(result.degree, 3)
        XCTAssertEqual(result.realRoots.count, 3)
        XCTAssertTrue(result.complexRoots.isEmpty)
        
        let sortedRoots = result.realRoots.sorted()
        XCTAssertEqual(sortedRoots[0], 1, accuracy: 1e-8)
        XCTAssertEqual(sortedRoots[1], 2, accuracy: 1e-8)
        XCTAssertEqual(sortedRoots[2], 3, accuracy: 1e-8)
    }
    
    func test_Cubic_TripleRoot() throws {
        // (x - 2)³ = x³ - 6x² + 12x - 8 = 0 → x = 2 (triple)
        let result = try PolynomialSolver.solveCubic(a: 1, b: -6, c: 12, d: -8)
        
        XCTAssertEqual(result.realRoots.count, 3)
        for root in result.realRoots {
            XCTAssertEqual(root, 2, accuracy: 1e-8)
        }
    }
    
    func test_Cubic_SingleAndDoubleRoot() throws {
        // (x - 1)(x - 2)² = x³ - 5x² + 8x - 4 = 0 → x = 1, 2 (double)
        let result = try PolynomialSolver.solveCubic(a: 1, b: -5, c: 8, d: -4)
        
        XCTAssertEqual(result.realRoots.count, 3)
        let sortedRoots = result.realRoots.sorted()
        XCTAssertEqual(sortedRoots[0], 1, accuracy: 1e-8)
        XCTAssertEqual(sortedRoots[1], 2, accuracy: 1e-8)
        XCTAssertEqual(sortedRoots[2], 2, accuracy: 1e-8)
    }
    
    // MARK: - Cubic Tests - One Real, Two Complex Roots
    
    func test_Cubic_OneRealTwoComplex() throws {
        // x³ + 1 = 0 → x = -1, (1 ± i√3)/2
        let result = try PolynomialSolver.solveCubic(a: 1, b: 0, c: 0, d: 1)
        
        XCTAssertEqual(result.realRoots.count, 1)
        XCTAssertEqual(result.realRoots[0], -1, accuracy: 1e-8)
        XCTAssertEqual(result.complexRoots.count, 2)
        
        // Complex roots should be conjugates
        let z1 = result.complexRoots[0]
        let z2 = result.complexRoots[1]
        XCTAssertEqual(z1.real, z2.real, accuracy: 1e-8)
        XCTAssertEqual(z1.imaginary, -z2.imaginary, accuracy: 1e-8)
    }
    
    func test_Cubic_WithComplexRoots_Simple() throws {
        // x³ - 1 = 0 → x = 1, (-1 ± i√3)/2
        let result = try PolynomialSolver.solveCubic(a: 1, b: 0, c: 0, d: -1)
        
        XCTAssertEqual(result.realRoots.count, 1)
        XCTAssertEqual(result.realRoots[0], 1, accuracy: 1e-8)
        XCTAssertEqual(result.complexRoots.count, 2)
    }
    
    // MARK: - Cubic Tests - Error Cases
    
    func test_Cubic_LeadingZero_ThrowsError() {
        XCTAssertThrowsError(try PolynomialSolver.solveCubic(a: 0, b: 1, c: 0, d: 1)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Quartic Tests - Four Real Roots
    
    func test_Quartic_FourDistinctRealRoots() throws {
        // (x-1)(x-2)(x-3)(x-4) = x⁴ - 10x³ + 35x² - 50x + 24 = 0
        let result = try PolynomialSolver.solveQuartic(a: 1, b: -10, c: 35, d: -50, e: 24)
        
        XCTAssertEqual(result.degree, 4)
        XCTAssertEqual(result.realRoots.count, 4)
        XCTAssertTrue(result.complexRoots.isEmpty)
        
        let sortedRoots = result.realRoots.sorted()
        XCTAssertEqual(sortedRoots[0], 1, accuracy: 1e-6)
        XCTAssertEqual(sortedRoots[1], 2, accuracy: 1e-6)
        XCTAssertEqual(sortedRoots[2], 3, accuracy: 1e-6)
        XCTAssertEqual(sortedRoots[3], 4, accuracy: 1e-6)
    }
    
    func test_Quartic_SymmetricRoots() throws {
        // (x-1)(x+1)(x-2)(x+2) = (x²-1)(x²-4) = x⁴ - 5x² + 4 = 0 → x = ±1, ±2
        let result = try PolynomialSolver.solveQuartic(a: 1, b: 0, c: -5, d: 0, e: 4)
        
        XCTAssertEqual(result.realRoots.count, 4)
        let sortedRoots = result.realRoots.sorted()
        XCTAssertEqual(sortedRoots[0], -2, accuracy: 1e-8)
        XCTAssertEqual(sortedRoots[1], -1, accuracy: 1e-8)
        XCTAssertEqual(sortedRoots[2], 1, accuracy: 1e-8)
        XCTAssertEqual(sortedRoots[3], 2, accuracy: 1e-8)
    }
    
    // MARK: - Quartic Tests - Two Real, Two Complex
    
    func test_Quartic_TwoRealTwoComplex() throws {
        // (x-1)(x-2)(x² + 1) = x⁴ - 3x³ + 3x² - 3x + 2 = 0
        let result = try PolynomialSolver.solveQuartic(a: 1, b: -3, c: 3, d: -3, e: 2)
        
        XCTAssertEqual(result.realRoots.count, 2)
        XCTAssertEqual(result.complexRoots.count, 2)
        
        let sortedRoots = result.realRoots.sorted()
        XCTAssertEqual(sortedRoots[0], 1, accuracy: 1e-6)
        XCTAssertEqual(sortedRoots[1], 2, accuracy: 1e-6)
    }
    
    // MARK: - Quartic Tests - Four Complex Roots
    
    func test_Quartic_FourComplexRoots() throws {
        // (x² + 1)(x² + 4) = x⁴ + 5x² + 4 = 0 → x = ±i, ±2i
        let result = try PolynomialSolver.solveQuartic(a: 1, b: 0, c: 5, d: 0, e: 4)
        
        XCTAssertTrue(result.realRoots.isEmpty)
        XCTAssertEqual(result.complexRoots.count, 4)
        
        // All roots should be purely imaginary
        for z in result.complexRoots {
            XCTAssertEqual(z.real, 0, accuracy: 1e-8)
            XCTAssertTrue(abs(z.imaginary) == 1 || abs(z.imaginary) == 2 ||
                         abs(abs(z.imaginary) - 1) < 1e-6 || abs(abs(z.imaginary) - 2) < 1e-6)
        }
    }
    
    // MARK: - Quartic Tests - Biquadratic
    
    func test_Quartic_Biquadratic() throws {
        // x⁴ - 13x² + 36 = 0 → x = ±2, ±3
        let result = try PolynomialSolver.solveQuartic(a: 1, b: 0, c: -13, d: 0, e: 36)
        
        XCTAssertEqual(result.realRoots.count, 4)
        let sortedRoots = result.realRoots.sorted()
        XCTAssertEqual(sortedRoots[0], -3, accuracy: 1e-8)
        XCTAssertEqual(sortedRoots[1], -2, accuracy: 1e-8)
        XCTAssertEqual(sortedRoots[2], 2, accuracy: 1e-8)
        XCTAssertEqual(sortedRoots[3], 3, accuracy: 1e-8)
    }
    
    // MARK: - Quartic Tests - Error Cases
    
    func test_Quartic_LeadingZero_ThrowsError() {
        XCTAssertThrowsError(try PolynomialSolver.solveQuartic(a: 0, b: 1, c: 0, d: 0, e: 1)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - General Solve Method Tests
    
    func test_Solve_Linear() throws {
        // 2x + 4 = 0 → x = -2
        let result = try PolynomialSolver.solve(coefficients: [2, 4])
        
        XCTAssertEqual(result.degree, 1)
        XCTAssertEqual(result.realRoots.count, 1)
        XCTAssertEqual(result.realRoots[0], -2, accuracy: 1e-10)
    }
    
    func test_Solve_Quadratic() throws {
        let result = try PolynomialSolver.solve(coefficients: [1, -5, 6])
        
        XCTAssertEqual(result.degree, 2)
        XCTAssertEqual(result.realRoots.count, 2)
    }
    
    func test_Solve_Cubic() throws {
        let result = try PolynomialSolver.solve(coefficients: [1, -6, 11, -6])
        
        XCTAssertEqual(result.degree, 3)
        XCTAssertEqual(result.realRoots.count, 3)
    }
    
    func test_Solve_Quartic() throws {
        let result = try PolynomialSolver.solve(coefficients: [1, -10, 35, -50, 24])
        
        XCTAssertEqual(result.degree, 4)
        XCTAssertEqual(result.realRoots.count, 4)
    }
    
    func test_Solve_RemovesLeadingZeros() throws {
        // [0, 0, 1, -5, 6] represents x² - 5x + 6
        let result = try PolynomialSolver.solve(coefficients: [0, 0, 1, -5, 6])
        
        XCTAssertEqual(result.degree, 2)
        XCTAssertEqual(result.realRoots.count, 2)
    }
    
    func test_Solve_Constant_NonZero_NoRoots() throws {
        // 5 = 0 has no solution
        let result = try PolynomialSolver.solve(coefficients: [5])
        
        XCTAssertEqual(result.degree, 0)
        XCTAssertTrue(result.realRoots.isEmpty)
        XCTAssertTrue(result.complexRoots.isEmpty)
    }
    
    func test_Solve_HighDegree_ThrowsError() {
        XCTAssertThrowsError(try PolynomialSolver.solve(coefficients: [1, 0, 0, 0, 0, 0])) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Solve_EmptyCoefficients_ThrowsError() {
        XCTAssertThrowsError(try PolynomialSolver.solve(coefficients: [])) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Horner's Method Tests
    
    func test_Evaluate_ReturnsCorrectValue_AtRoot() {
        // p(x) = x² - 5x + 6, p(2) = 0
        let value = PolynomialSolver.evaluate(coefficients: [1, -5, 6], at: 2)
        XCTAssertEqual(value, 0, accuracy: 1e-10)
    }
    
    func test_Evaluate_ReturnsCorrectValue_AtNonRoot() {
        // p(x) = x² - 5x + 6, p(0) = 6
        let value = PolynomialSolver.evaluate(coefficients: [1, -5, 6], at: 0)
        XCTAssertEqual(value, 6, accuracy: 1e-10)
    }
    
    func test_Evaluate_Linear() {
        // p(x) = 2x + 3, p(5) = 13
        let value = PolynomialSolver.evaluate(coefficients: [2, 3], at: 5)
        XCTAssertEqual(value, 13, accuracy: 1e-10)
    }
    
    func test_Evaluate_Cubic() {
        // p(x) = x³ - 6x² + 11x - 6, p(1) = 0
        let value = PolynomialSolver.evaluate(coefficients: [1, -6, 11, -6], at: 1)
        XCTAssertEqual(value, 0, accuracy: 1e-10)
    }
    
    func test_Evaluate_Complex() {
        // p(x) = x² + 1, p(i) = 0
        let z = ComplexNumber(real: 0, imaginary: 1)
        let value = PolynomialSolver.evaluate(coefficients: [1, 0, 1], at: z)
        XCTAssertEqual(value.magnitude, 0, accuracy: 1e-10)
    }
    
    // MARK: - Root Verification Tests
    
    func test_VerifyRoot_ValidRoot_ReturnsTrue() {
        let isValid = PolynomialSolver.verifyRoot(coefficients: [1, -5, 6], root: 2)
        XCTAssertTrue(isValid)
    }
    
    func test_VerifyRoot_InvalidRoot_ReturnsFalse() {
        let isValid = PolynomialSolver.verifyRoot(coefficients: [1, -5, 6], root: 0)
        XCTAssertFalse(isValid)
    }
    
    func test_VerifyRoot_ComplexRoot_ReturnsTrue() {
        let z = ComplexNumber(real: 0, imaginary: 1)
        let isValid = PolynomialSolver.verifyRoot(coefficients: [1, 0, 1], root: z)
        XCTAssertTrue(isValid)
    }
    
    // MARK: - Derivative Tests
    
    func test_Derivative_Quadratic() {
        // d/dx(x² - 5x + 6) = 2x - 5
        let deriv = PolynomialSolver.derivative(coefficients: [1, -5, 6])
        
        XCTAssertEqual(deriv.count, 2)
        XCTAssertEqual(deriv[0], 2, accuracy: 1e-10)
        XCTAssertEqual(deriv[1], -5, accuracy: 1e-10)
    }
    
    func test_Derivative_Cubic() {
        // d/dx(x³ - 3x² + 2x - 1) = 3x² - 6x + 2
        let deriv = PolynomialSolver.derivative(coefficients: [1, -3, 2, -1])
        
        XCTAssertEqual(deriv.count, 3)
        XCTAssertEqual(deriv[0], 3, accuracy: 1e-10)
        XCTAssertEqual(deriv[1], -6, accuracy: 1e-10)
        XCTAssertEqual(deriv[2], 2, accuracy: 1e-10)
    }
    
    func test_Derivative_Constant_ReturnsZero() {
        let deriv = PolynomialSolver.derivative(coefficients: [5])
        
        XCTAssertEqual(deriv.count, 1)
        XCTAssertEqual(deriv[0], 0, accuracy: 1e-10)
    }
    
    // MARK: - Format Tests
    
    func test_Format_Quadratic() {
        let formatted = PolynomialSolver.format(coefficients: [1, -5, 6])
        
        XCTAssertTrue(formatted.contains("x²"))
        XCTAssertTrue(formatted.contains("5x"))
        XCTAssertTrue(formatted.contains("6"))
    }
    
    func test_Format_ZeroPolynomial() {
        let formatted = PolynomialSolver.format(coefficients: [0, 0, 0])
        XCTAssertEqual(formatted, "0")
    }
    
    // MARK: - PolynomialRoots Properties Tests
    
    func test_PolynomialRoots_AllRoots_CombinesBoth() throws {
        let result = try PolynomialSolver.solveCubic(a: 1, b: 0, c: 0, d: 1)
        
        // Should have 1 real + 2 complex = 3 total in allRoots
        XCTAssertEqual(result.allRoots.count, 3)
    }
    
    func test_PolynomialRoots_DistinctRootCount() throws {
        let result = try PolynomialSolver.solveQuadratic(a: 1, b: -4, c: 4)
        
        // x = 2 (double root), distinctRootCount should be 2
        XCTAssertEqual(result.distinctRootCount, 2)
    }
}
