import XCTest
@testable import ScientificCalculatorAppForIOS

final class NumericalSolverTests: XCTestCase {
    
    // MARK: - Newton-Raphson Method Tests
    
    func test_NewtonRaphson_SquareRoot_WithDerivative() throws {
        // Solve x² - 2 = 0, expect √2 ≈ 1.414
        let result = try NumericalSolver.newtonRaphson(
            function: { x in x * x - 2 },
            derivative: { x in 2 * x },
            initialGuess: 1.5
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, sqrt(2), accuracy: 1e-10)
        XCTAssertEqual(result.method, "Newton-Raphson")
        XCTAssertLessThan(result.iterations, 20)
    }
    
    func test_NewtonRaphson_SquareRoot_NumericalDerivative() throws {
        // Without explicit derivative
        let result = try NumericalSolver.newtonRaphson(
            function: { x in x * x - 4 },
            initialGuess: 3
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, 2, accuracy: 1e-8)
    }
    
    func test_NewtonRaphson_CosineZero() throws {
        // Solve cos(x) = 0, expect π/2
        let result = try NumericalSolver.newtonRaphson(
            function: { x in cos(x) },
            derivative: { x in -sin(x) },
            initialGuess: 1
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, .pi / 2, accuracy: 1e-10)
    }
    
    func test_NewtonRaphson_CubeRoot() throws {
        // Solve x³ - 8 = 0, expect 2
        let result = try NumericalSolver.newtonRaphson(
            function: { x in x * x * x - 8 },
            derivative: { x in 3 * x * x },
            initialGuess: 3
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, 2, accuracy: 1e-10)
    }
    
    func test_NewtonRaphson_Exponential() throws {
        // Solve e^x - 2 = 0, expect ln(2)
        let result = try NumericalSolver.newtonRaphson(
            function: { x in exp(x) - 2 },
            derivative: { x in exp(x) },
            initialGuess: 1
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, log(2), accuracy: 1e-10)
    }
    
    func test_NewtonRaphson_NegativeRoot() throws {
        // Solve x² - 4 = 0 starting from negative, expect -2
        let result = try NumericalSolver.newtonRaphson(
            function: { x in x * x - 4 },
            derivative: { x in 2 * x },
            initialGuess: -3
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, -2, accuracy: 1e-10)
    }
    
    func test_NewtonRaphson_ZeroDerivative_ThrowsError() {
        // f(x) = x³ at x = 0 has f'(0) = 0
        XCTAssertThrowsError(try NumericalSolver.newtonRaphson(
            function: { x in x * x * x },
            derivative: { x in 3 * x * x },
            initialGuess: 0
        )) { error in
            guard case CalculatorError.mathError = error else {
                XCTFail("Expected mathError")
                return
            }
        }
    }
    
    func test_NewtonRaphson_ResidualIsSmall() throws {
        let result = try NumericalSolver.newtonRaphson(
            function: { x in x * x - 2 },
            initialGuess: 1.5
        )
        
        XCTAssertLessThan(result.residual, 1e-10)
    }
    
    // MARK: - Bisection Method Tests
    
    func test_Bisection_SimpleRoot() throws {
        // Solve x² - 2 = 0 in [1, 2]
        let result = try NumericalSolver.bisection(
            function: { x in x * x - 2 },
            lower: 1,
            upper: 2
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, sqrt(2), accuracy: 1e-10)
        XCTAssertEqual(result.method, "Bisection")
    }
    
    func test_Bisection_NegativeRoot() throws {
        // Solve x² - 4 = 0 in [-3, -1]
        let result = try NumericalSolver.bisection(
            function: { x in x * x - 4 },
            lower: -3,
            upper: -1
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, -2, accuracy: 1e-10)
    }
    
    func test_Bisection_Linear() throws {
        // Solve 2x + 3 = 0 → x = -1.5
        let result = try NumericalSolver.bisection(
            function: { x in 2 * x + 3 },
            lower: -5,
            upper: 5
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, -1.5, accuracy: 1e-10)
    }
    
    func test_Bisection_Trigonometric() throws {
        // Solve sin(x) = 0 in [2, 4] → x = π
        let result = try NumericalSolver.bisection(
            function: { x in sin(x) },
            lower: 2,
            upper: 4
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, .pi, accuracy: 1e-10)
    }
    
    func test_Bisection_NoBracket_ThrowsError() {
        // Function never crosses zero in interval [1, 2] for x² + 1
        XCTAssertThrowsError(try NumericalSolver.bisection(
            function: { x in x * x + 1 },
            lower: 1,
            upper: 2
        )) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Bisection_SameSigns_ThrowsError() {
        // f(0) = 1, f(1) = 2, both positive
        XCTAssertThrowsError(try NumericalSolver.bisection(
            function: { x in x + 1 },
            lower: 0,
            upper: 1
        )) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Bisection_SwappedBounds() throws {
        // Should handle when lower > upper
        let result = try NumericalSolver.bisection(
            function: { x in x * x - 2 },
            lower: 2,
            upper: 1
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, sqrt(2), accuracy: 1e-10)
    }
    
    // MARK: - Secant Method Tests
    
    func test_Secant_SimpleRoot() throws {
        // Solve x² - 4 = 0
        let result = try NumericalSolver.secant(
            function: { x in x * x - 4 },
            x0: 1,
            x1: 3
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, 2, accuracy: 1e-8)
        XCTAssertEqual(result.method, "Secant")
    }
    
    func test_Secant_Exponential() throws {
        // Solve e^x - 3 = 0, expect ln(3)
        let result = try NumericalSolver.secant(
            function: { x in exp(x) - 3 },
            x0: 0,
            x1: 2
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, log(3), accuracy: 1e-8)
    }
    
    func test_Secant_Trigonometric() throws {
        // Solve cos(x) - 0.5 = 0, expect π/3
        let result = try NumericalSolver.secant(
            function: { x in cos(x) - 0.5 },
            x0: 0,
            x1: 2
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, .pi / 3, accuracy: 1e-8)
    }
    
    // MARK: - Brent's Method Tests
    
    func test_Brent_SimpleRoot() throws {
        let result = try NumericalSolver.brent(
            function: { x in x * x - 2 },
            lower: 1,
            upper: 2
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, sqrt(2), accuracy: 1e-10)
        XCTAssertEqual(result.method, "Brent")
    }
    
    func test_Brent_TrigFunction() throws {
        // Solve sin(x) - 0.5 = 0 in [0, 1], expect π/6
        let result = try NumericalSolver.brent(
            function: { x in sin(x) - 0.5 },
            lower: 0,
            upper: 1
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, .pi / 6, accuracy: 1e-10)
    }
    
    func test_Brent_NoBracket_ThrowsError() {
        XCTAssertThrowsError(try NumericalSolver.brent(
            function: { x in x * x + 1 },
            lower: 0,
            upper: 2
        )) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Brent_PolynomialRoot() throws {
        // Solve x³ - x - 1 = 0 (has one real root ≈ 1.3247)
        let result = try NumericalSolver.brent(
            function: { x in x * x * x - x - 1 },
            lower: 1,
            upper: 2
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, 1.3247179572, accuracy: 1e-8)
    }
    
    // MARK: - Halley's Method Tests
    
    func test_Halley_SimpleRoot() throws {
        // Solve x² - 2 = 0
        let result = try NumericalSolver.halley(
            function: { x in x * x - 2 },
            derivative: { x in 2 * x },
            secondDerivative: { x in 2 },
            initialGuess: 1.5
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, sqrt(2), accuracy: 1e-10)
        XCTAssertEqual(result.method, "Halley")
    }
    
    func test_Halley_CubicConvergence() throws {
        // Halley should converge faster than Newton
        let resultHalley = try NumericalSolver.halley(
            function: { x in x * x - 2 },
            initialGuess: 1.5
        )
        
        let resultNewton = try NumericalSolver.newtonRaphson(
            function: { x in x * x - 2 },
            initialGuess: 1.5
        )
        
        // Halley typically needs fewer iterations
        XCTAssertLessThanOrEqual(resultHalley.iterations, resultNewton.iterations)
    }
    
    // MARK: - Fixed Point Iteration Tests
    
    func test_FixedPoint_SquareRoot() throws {
        // Solve x = (x + 2/x) / 2 for √2
        let result = try NumericalSolver.fixedPoint(
            g: { x in (x + 2 / x) / 2 },
            initialGuess: 1.5
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, sqrt(2), accuracy: 1e-10)
        XCTAssertEqual(result.method, "Fixed Point")
    }
    
    // MARK: - Numerical Differentiation Tests
    
    func test_NumericalDerivative_Quadratic() {
        // f(x) = x², f'(x) = 2x, f'(3) = 6
        let deriv = NumericalSolver.numericalDerivative(
            of: { x in x * x },
            at: 3
        )
        
        XCTAssertEqual(deriv, 6, accuracy: 1e-6)
    }
    
    func test_NumericalDerivative_Sine() {
        // f(x) = sin(x), f'(x) = cos(x), f'(0) = 1
        let deriv = NumericalSolver.numericalDerivative(
            of: { x in sin(x) },
            at: 0
        )
        
        XCTAssertEqual(deriv, 1, accuracy: 1e-6)
    }
    
    func test_NumericalDerivative_Exponential() {
        // f(x) = e^x, f'(x) = e^x, f'(1) = e
        let deriv = NumericalSolver.numericalDerivative(
            of: { x in exp(x) },
            at: 1
        )
        
        XCTAssertEqual(deriv, exp(1), accuracy: 1e-6)
    }
    
    func test_NumericalSecondDerivative_Quadratic() {
        // f(x) = x², f''(x) = 2
        let deriv2 = NumericalSolver.numericalSecondDerivative(
            of: { x in x * x },
            at: 5
        )
        
        XCTAssertEqual(deriv2, 2, accuracy: 1e-4)
    }
    
    // MARK: - Bracket Finding Tests
    
    func test_FindBracket_Success() {
        let bracket = NumericalSolver.findBracket(
            function: { x in x * x - 2 },
            near: 1
        )
        
        XCTAssertNotNil(bracket)
        if let bracket = bracket {
            XCTAssertLessThan(bracket.lower, sqrt(2))
            XCTAssertGreaterThan(bracket.upper, sqrt(2))
        }
    }
    
    func test_FindBracket_NoBracketForPositiveDefinite() {
        // x² + 1 has no real roots
        let bracket = NumericalSolver.findBracket(
            function: { x in x * x + 1 },
            near: 0
        )
        
        XCTAssertNil(bracket)
    }
    
    func test_FindBracket_NearZero() {
        let bracket = NumericalSolver.findBracket(
            function: { x in x },
            near: 0
        )
        
        XCTAssertNotNil(bracket)
    }
    
    // MARK: - Automatic Solve Tests
    
    func test_Solve_SelectsAppropriateMethod() throws {
        // solve() should automatically find the root
        let result = try NumericalSolver.solve(
            function: { x in x * x - 2 },
            initialGuess: 1.5
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, sqrt(2), accuracy: 1e-8)
    }
    
    func test_Solve_FallsBackWhenNeeded() throws {
        // Function that might cause issues with one method
        let result = try NumericalSolver.solve(
            function: { x in x * x * x - x - 1 },
            initialGuess: 1.5
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, 1.3247179572, accuracy: 1e-6)
    }
    
    // MARK: - Configuration Tests
    
    func test_MaxIterations_ReturnsNonConverged() throws {
        let config = NumericalSolverConfig(maxIterations: 3, tolerance: 1e-15)
        let result = try NumericalSolver.newtonRaphson(
            function: { x in x * x - 2 },
            initialGuess: 100,
            config: config
        )
        
        XCTAssertFalse(result.converged)
        XCTAssertEqual(result.iterations, 3)
    }
    
    func test_CustomTolerance_AffectsConvergence() throws {
        let looseConfig = NumericalSolverConfig(tolerance: 0.1)
        let result = try NumericalSolver.newtonRaphson(
            function: { x in x * x - 2 },
            initialGuess: 1.5,
            config: looseConfig
        )
        
        XCTAssertTrue(result.converged)
        // With loose tolerance, should converge in fewer iterations
        XCTAssertLessThan(result.iterations, 10)
    }
    
    func test_DefaultConfig_HasReasonableValues() {
        let config = NumericalSolverConfig.default
        
        XCTAssertEqual(config.maxIterations, 100)
        XCTAssertEqual(config.tolerance, 1e-12)
        XCTAssertEqual(config.derivativeStep, 1e-8)
        XCTAssertEqual(config.timeout, 5.0)
    }
    
    // MARK: - NumericalSolution Tests
    
    func test_NumericalSolution_Properties() throws {
        let result = try NumericalSolver.newtonRaphson(
            function: { x in x * x - 4 },
            initialGuess: 3
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertGreaterThan(result.iterations, 0)
        XCTAssertLessThan(result.residual, 1e-10)
        XCTAssertFalse(result.method.isEmpty)
    }
    
    // MARK: - Edge Cases
    
    func test_RootAtZero() throws {
        // Solve x = 0
        let result = try NumericalSolver.newtonRaphson(
            function: { x in x },
            derivative: { _ in 1 },
            initialGuess: 0.5
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, 0, accuracy: 1e-10)
    }
    
    func test_LargeRoot() throws {
        // Solve x - 1000 = 0
        let result = try NumericalSolver.newtonRaphson(
            function: { x in x - 1000 },
            initialGuess: 500
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, 1000, accuracy: 1e-8)
    }
    
    func test_SmallRoot() throws {
        // Solve x - 0.001 = 0
        let result = try NumericalSolver.newtonRaphson(
            function: { x in x - 0.001 },
            initialGuess: 0.5
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, 0.001, accuracy: 1e-10)
    }
    
    func test_NegativeRoot() throws {
        // Solve x + 5 = 0, expect -5
        let result = try NumericalSolver.bisection(
            function: { x in x + 5 },
            lower: -10,
            upper: 0
        )
        
        XCTAssertTrue(result.converged)
        XCTAssertEqual(result.root, -5, accuracy: 1e-10)
    }
}
