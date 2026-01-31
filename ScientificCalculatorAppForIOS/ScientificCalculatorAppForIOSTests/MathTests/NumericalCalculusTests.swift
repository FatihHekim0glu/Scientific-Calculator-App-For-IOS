import XCTest
@testable import ScientificCalculatorAppForIOS

final class NumericalCalculusTests: XCTestCase {
    
    // MARK: - Integration Tests (Adaptive Simpson)
    
    func test_Integrate_Constant_ReturnsAreaOfRectangle() throws {
        // ∫[0,2] 3 dx = 6
        let result = try NumericalCalculus.integrate({ _ in 3 }, from: 0, to: 2)
        XCTAssertEqual(result.value, 6, accuracy: 1e-10)
        XCTAssertTrue(result.converged)
    }
    
    func test_Integrate_Linear_ReturnsAreaOfTriangle() throws {
        // ∫[0,2] x dx = 2
        let result = try NumericalCalculus.integrate({ x in x }, from: 0, to: 2)
        XCTAssertEqual(result.value, 2, accuracy: 1e-10)
    }
    
    func test_Integrate_Quadratic_ReturnsCorrect() throws {
        // ∫[0,1] x² dx = 1/3
        let result = try NumericalCalculus.integrate({ x in x * x }, from: 0, to: 1)
        XCTAssertEqual(result.value, 1.0 / 3.0, accuracy: 1e-10)
    }
    
    func test_Integrate_Cubic_ReturnsCorrect() throws {
        // ∫[0,1] x³ dx = 1/4
        let result = try NumericalCalculus.integrate({ x in x * x * x }, from: 0, to: 1)
        XCTAssertEqual(result.value, 0.25, accuracy: 1e-10)
    }
    
    func test_Integrate_Sin_ReturnsCorrect() throws {
        // ∫[0,π] sin(x) dx = 2
        let result = try NumericalCalculus.integrate({ x in sin(x) }, from: 0, to: .pi)
        XCTAssertEqual(result.value, 2, accuracy: 1e-8)
    }
    
    func test_Integrate_Cos_ReturnsCorrect() throws {
        // ∫[0,π/2] cos(x) dx = 1
        let result = try NumericalCalculus.integrate({ x in cos(x) }, from: 0, to: .pi / 2)
        XCTAssertEqual(result.value, 1, accuracy: 1e-8)
    }
    
    func test_Integrate_Exp_ReturnsCorrect() throws {
        // ∫[0,1] e^x dx = e - 1
        let result = try NumericalCalculus.integrate({ x in exp(x) }, from: 0, to: 1)
        XCTAssertEqual(result.value, M_E - 1, accuracy: 1e-8)
    }
    
    func test_Integrate_ReversedBounds_ReturnsNegative() throws {
        // ∫[2,0] x dx = -2
        let result = try NumericalCalculus.integrate({ x in x }, from: 2, to: 0)
        XCTAssertEqual(result.value, -2, accuracy: 1e-10)
    }
    
    func test_Integrate_SameBounds_ReturnsZero() throws {
        let result = try NumericalCalculus.integrate({ x in x * x }, from: 5, to: 5)
        XCTAssertEqual(result.value, 0, accuracy: 1e-15)
        XCTAssertEqual(result.evaluations, 0)
    }
    
    func test_Integrate_NegativeInterval_ReturnsCorrect() throws {
        // ∫[-2,0] x² dx = 8/3
        let result = try NumericalCalculus.integrate({ x in x * x }, from: -2, to: 0)
        XCTAssertEqual(result.value, 8.0 / 3.0, accuracy: 1e-10)
    }
    
    func test_Integrate_Polynomial_ReturnsCorrect() throws {
        // ∫[0,2] (x³ - 2x² + x) dx = 4/3
        let result = try NumericalCalculus.integrate({ x in x*x*x - 2*x*x + x }, from: 0, to: 2)
        XCTAssertEqual(result.value, 4.0 / 3.0, accuracy: 1e-8)
    }
    
    func test_Integrate_TracksEvaluations() throws {
        let result = try NumericalCalculus.integrate({ x in x }, from: 0, to: 1)
        XCTAssertGreaterThan(result.evaluations, 0)
    }
    
    // MARK: - Simpson's Rule (Non-adaptive) Tests
    
    func test_Simpson_BasicQuadratic() throws {
        let result = try NumericalCalculus.simpsonIntegrate({ x in x * x }, from: 0, to: 1, n: 100)
        XCTAssertEqual(result, 1.0 / 3.0, accuracy: 1e-6)
    }
    
    func test_Simpson_Sin() throws {
        let result = try NumericalCalculus.simpsonIntegrate({ x in sin(x) }, from: 0, to: .pi, n: 1000)
        XCTAssertEqual(result, 2, accuracy: 1e-6)
    }
    
    func test_Simpson_OddIntervals_AdjustsToEven() throws {
        let result = try NumericalCalculus.simpsonIntegrate({ x in x }, from: 0, to: 2, n: 99)
        XCTAssertEqual(result, 2, accuracy: 1e-6)
    }
    
    // MARK: - Riemann Sum Tests
    
    func test_LeftRiemannSum_Linear() {
        let result = NumericalCalculus.leftRiemannSum({ x in x }, from: 0, to: 4, n: 100)
        XCTAssertEqual(result, 8, accuracy: 0.1)
    }
    
    func test_RightRiemannSum_Linear() {
        let result = NumericalCalculus.rightRiemannSum({ x in x }, from: 0, to: 4, n: 100)
        XCTAssertEqual(result, 8, accuracy: 0.1)
    }
    
    func test_TrapezoidalSum_Linear() {
        let result = NumericalCalculus.trapezoidalSum({ x in x }, from: 0, to: 4, n: 100)
        XCTAssertEqual(result, 8, accuracy: 1e-10)
    }
    
    func test_TrapezoidalSum_Quadratic() {
        let result = NumericalCalculus.trapezoidalSum({ x in x * x }, from: 0, to: 1, n: 1000)
        XCTAssertEqual(result, 1.0 / 3.0, accuracy: 1e-5)
    }
    
    // MARK: - Differentiation Tests
    
    func test_Differentiate_Constant_ReturnsZero() {
        // d/dx(5) = 0
        let result = NumericalCalculus.differentiate({ _ in 5 }, at: 3)
        XCTAssertEqual(result.value, 0, accuracy: 1e-6)
        XCTAssertEqual(result.order, 1)
    }
    
    func test_Differentiate_Linear_ReturnsSlope() {
        // d/dx(2x + 1) at any point = 2
        let result = NumericalCalculus.differentiate({ x in 2 * x + 1 }, at: 5)
        XCTAssertEqual(result.value, 2, accuracy: 1e-6)
    }
    
    func test_Differentiate_Quadratic_ReturnsCorrect() {
        // d/dx(x²) at x=3 = 6
        let result = NumericalCalculus.differentiate({ x in x * x }, at: 3)
        XCTAssertEqual(result.value, 6, accuracy: 1e-6)
    }
    
    func test_Differentiate_Cubic_ReturnsCorrect() {
        // d/dx(x³) at x=2 = 12
        let result = NumericalCalculus.differentiate({ x in x * x * x }, at: 2)
        XCTAssertEqual(result.value, 12, accuracy: 1e-5)
    }
    
    func test_Differentiate_Sin_ReturnsCos() {
        // d/dx(sin(x)) at x=0 = cos(0) = 1
        let result = NumericalCalculus.differentiate({ x in sin(x) }, at: 0)
        XCTAssertEqual(result.value, 1, accuracy: 1e-6)
    }
    
    func test_Differentiate_Cos_ReturnsNegSin() {
        // d/dx(cos(x)) at x=π/2 = -sin(π/2) = -1
        let result = NumericalCalculus.differentiate({ x in cos(x) }, at: .pi / 2)
        XCTAssertEqual(result.value, -1, accuracy: 1e-6)
    }
    
    func test_Differentiate_Exp_ReturnsExp() {
        // d/dx(e^x) at x=1 = e
        let result = NumericalCalculus.differentiate({ x in exp(x) }, at: 1)
        XCTAssertEqual(result.value, M_E, accuracy: 1e-6)
    }
    
    func test_Differentiate_Ln_ReturnsReciprocal() {
        // d/dx(ln(x)) at x=2 = 1/2
        let result = NumericalCalculus.differentiate({ x in log(x) }, at: 2)
        XCTAssertEqual(result.value, 0.5, accuracy: 1e-6)
    }
    
    func test_Differentiate_AtZero() {
        // d/dx(x²) at x=0 = 0
        let result = NumericalCalculus.differentiate({ x in x * x }, at: 0)
        XCTAssertEqual(result.value, 0, accuracy: 1e-6)
    }
    
    func test_Differentiate_AtNegative() {
        // d/dx(x²) at x=-3 = -6
        let result = NumericalCalculus.differentiate({ x in x * x }, at: -3)
        XCTAssertEqual(result.value, -6, accuracy: 1e-6)
    }
    
    func test_Differentiate_WithCustomH() {
        let result = NumericalCalculus.differentiate({ x in x * x }, at: 2, h: 0.001)
        XCTAssertEqual(result.value, 4, accuracy: 1e-5)
    }
    
    // MARK: - Second Derivative Tests
    
    func test_SecondDerivative_Constant_ReturnsZero() {
        // d²/dx²(5) = 0
        let result = NumericalCalculus.secondDerivative({ _ in 5 }, at: 3)
        XCTAssertEqual(result.value, 0, accuracy: 1e-4)
        XCTAssertEqual(result.order, 2)
    }
    
    func test_SecondDerivative_Linear_ReturnsZero() {
        // d²/dx²(2x + 1) = 0
        let result = NumericalCalculus.secondDerivative({ x in 2 * x + 1 }, at: 5)
        XCTAssertEqual(result.value, 0, accuracy: 1e-4)
    }
    
    func test_SecondDerivative_Quadratic_ReturnsConstant() {
        // d²/dx²(x²) = 2
        let result = NumericalCalculus.secondDerivative({ x in x * x }, at: 5)
        XCTAssertEqual(result.value, 2, accuracy: 1e-4)
    }
    
    func test_SecondDerivative_Cubic_ReturnsLinear() {
        // d²/dx²(x³) at x=2 = 12
        let result = NumericalCalculus.secondDerivative({ x in x * x * x }, at: 2)
        XCTAssertEqual(result.value, 12, accuracy: 1e-3)
    }
    
    func test_SecondDerivative_Sin() {
        // d²/dx²(sin(x)) at x=0 = -sin(0) = 0
        let result = NumericalCalculus.secondDerivative({ x in sin(x) }, at: 0)
        XCTAssertEqual(result.value, 0, accuracy: 1e-4)
    }
    
    // MARK: - Higher Order Derivative Tests
    
    func test_NthDerivative_First_MatchesDifferentiate() throws {
        let first = NumericalCalculus.differentiate({ x in x * x * x }, at: 2)
        let nth = try NumericalCalculus.nthDerivative({ x in x * x * x }, at: 2, order: 1)
        XCTAssertEqual(first.value, nth.value, accuracy: 1e-5)
    }
    
    func test_NthDerivative_Second_MatchesSecondDerivative() throws {
        let second = NumericalCalculus.secondDerivative({ x in x * x * x }, at: 2)
        let nth = try NumericalCalculus.nthDerivative({ x in x * x * x }, at: 2, order: 2)
        XCTAssertEqual(second.value, nth.value, accuracy: 1e-3)
    }
    
    func test_NthDerivative_Third_Cubic() throws {
        // d³/dx³(x³) = 6
        let result = try NumericalCalculus.nthDerivative({ x in x * x * x }, at: 5, order: 3)
        XCTAssertEqual(result.value, 6, accuracy: 0.1)
    }
    
    func test_NthDerivative_Fourth_Quartic() throws {
        // d⁴/dx⁴(x⁴) = 24
        let result = try NumericalCalculus.nthDerivative({ x in pow(x, 4) }, at: 1, order: 4)
        XCTAssertEqual(result.value, 24, accuracy: 1)
    }
    
    func test_NthDerivative_InvalidOrder_ThrowsError() {
        XCTAssertThrowsError(try NumericalCalculus.nthDerivative({ x in x }, at: 1, order: 0))
        XCTAssertThrowsError(try NumericalCalculus.nthDerivative({ x in x }, at: 1, order: 5))
    }
    
    // MARK: - Summation Tests
    
    func test_Summation_Integers() throws {
        // Σ(i) for i=1 to 100 = 5050
        let result = try NumericalCalculus.summation({ i in i }, from: 1, to: 100)
        XCTAssertEqual(result, 5050, accuracy: 1e-10)
    }
    
    func test_Summation_Squares() throws {
        // Σ(i²) for i=1 to 10 = 385
        let result = try NumericalCalculus.summation({ i in i * i }, from: 1, to: 10)
        XCTAssertEqual(result, 385, accuracy: 1e-10)
    }
    
    func test_Summation_Cubes() throws {
        // Σ(i³) for i=1 to 5 = 225
        let result = try NumericalCalculus.summation({ i in i * i * i }, from: 1, to: 5)
        XCTAssertEqual(result, 225, accuracy: 1e-10)
    }
    
    func test_Summation_SingleTerm() throws {
        let result = try NumericalCalculus.summation({ i in i * 2 }, from: 5, to: 5)
        XCTAssertEqual(result, 10, accuracy: 1e-10)
    }
    
    func test_Summation_NegativeToPositive() throws {
        // Σ(i) for i=-2 to 2 = 0
        let result = try NumericalCalculus.summation({ i in i }, from: -2, to: 2)
        XCTAssertEqual(result, 0, accuracy: 1e-10)
    }
    
    func test_Summation_GeometricSeries() throws {
        // Σ(2^i) for i=0 to 5 = 63
        let result = try NumericalCalculus.summation({ i in pow(2, i) }, from: 0, to: 5)
        XCTAssertEqual(result, 63, accuracy: 1e-10)
    }
    
    func test_Summation_Reciprocals() throws {
        // Σ(1/i) for i=1 to 4 = 1 + 0.5 + 0.333... + 0.25 = 2.083...
        let result = try NumericalCalculus.summation({ i in 1.0 / i }, from: 1, to: 4)
        XCTAssertEqual(result, 1.0 + 0.5 + 1.0/3.0 + 0.25, accuracy: 1e-10)
    }
    
    func test_Summation_InvalidRange_ThrowsError() {
        XCTAssertThrowsError(try NumericalCalculus.summation({ i in i }, from: 10, to: 5)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Summation_ZeroInDenominator_ThrowsError() {
        XCTAssertThrowsError(try NumericalCalculus.summation({ i in 1.0 / i }, from: 0, to: 5)) { error in
            guard case CalculatorError.mathError = error else {
                XCTFail("Expected mathError")
                return
            }
        }
    }
    
    // MARK: - Product Tests
    
    func test_Product_Factorial() throws {
        // Π(i) for i=1 to 5 = 5! = 120
        let result = try NumericalCalculus.product({ i in i }, from: 1, to: 5)
        XCTAssertEqual(result, 120, accuracy: 1e-10)
    }
    
    func test_Product_Factorial10() throws {
        // Π(i) for i=1 to 10 = 10! = 3628800
        let result = try NumericalCalculus.product({ i in i }, from: 1, to: 10)
        XCTAssertEqual(result, 3628800, accuracy: 1e-10)
    }
    
    func test_Product_Powers() throws {
        // Π(2) for i=1 to 10 = 2^10 = 1024
        let result = try NumericalCalculus.product({ _ in 2 }, from: 1, to: 10)
        XCTAssertEqual(result, 1024, accuracy: 1e-10)
    }
    
    func test_Product_Squares() throws {
        // Π(i²) for i=1 to 3 = 1 × 4 × 9 = 36
        let result = try NumericalCalculus.product({ i in i * i }, from: 1, to: 3)
        XCTAssertEqual(result, 36, accuracy: 1e-10)
    }
    
    func test_Product_SingleTerm() throws {
        let result = try NumericalCalculus.product({ i in i * 3 }, from: 5, to: 5)
        XCTAssertEqual(result, 15, accuracy: 1e-10)
    }
    
    func test_Product_ContainsZero_ReturnsZero() throws {
        // Product containing 0 = 0
        let result = try NumericalCalculus.product({ i in i - 3 }, from: 1, to: 5)
        XCTAssertEqual(result, 0, accuracy: 1e-10)
    }
    
    func test_Product_NegativeValues() throws {
        // Π(i) for i=-2 to 2 includes 0, so = 0
        let result = try NumericalCalculus.product({ i in i }, from: -2, to: 2)
        XCTAssertEqual(result, 0, accuracy: 1e-10)
    }
    
    func test_Product_InvalidRange_ThrowsError() {
        XCTAssertThrowsError(try NumericalCalculus.product({ i in i }, from: 10, to: 5)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Product_DivideByZero_ThrowsError() {
        XCTAssertThrowsError(try NumericalCalculus.product({ i in 1.0 / i }, from: 0, to: 5)) { error in
            guard case CalculatorError.mathError = error else {
                XCTFail("Expected mathError")
                return
            }
        }
    }
    
    // MARK: - Integration Result Tests
    
    func test_IntegrationResult_Equality() {
        let result1 = IntegrationResult(value: 1.0, estimatedError: 0.001, evaluations: 10, converged: true)
        let result2 = IntegrationResult(value: 1.0, estimatedError: 0.001, evaluations: 10, converged: true)
        XCTAssertEqual(result1, result2)
    }
    
    // MARK: - Derivative Result Tests
    
    func test_DerivativeResult_Equality() {
        let result1 = DerivativeResult(value: 2.0, estimatedError: 0.001, order: 1)
        let result2 = DerivativeResult(value: 2.0, estimatedError: 0.001, order: 1)
        XCTAssertEqual(result1, result2)
    }
    
    // MARK: - Edge Cases
    
    func test_Integrate_VerySmallInterval() throws {
        let result = try NumericalCalculus.integrate({ x in x }, from: 0, to: 1e-10)
        XCTAssertEqual(result.value, 0.5e-20, accuracy: 1e-25)
    }
    
    func test_Integrate_LargeInterval() throws {
        let result = try NumericalCalculus.integrate({ x in 1 }, from: 0, to: 1000)
        XCTAssertEqual(result.value, 1000, accuracy: 1e-6)
    }
    
    func test_Differentiate_LargeValue() {
        let result = NumericalCalculus.differentiate({ x in x * x }, at: 1000)
        XCTAssertEqual(result.value, 2000, accuracy: 1)
    }
    
    func test_Summation_LargeRange() throws {
        // Σ(1) for i=1 to 10000 = 10000
        let result = try NumericalCalculus.summation({ _ in 1 }, from: 1, to: 10000)
        XCTAssertEqual(result, 10000, accuracy: 1e-10)
    }
}
