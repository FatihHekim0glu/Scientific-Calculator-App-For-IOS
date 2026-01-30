import Foundation

// MARK: - NumericalSolution

/// Result of numerical root finding
struct NumericalSolution: Equatable {
    /// The found root
    let root: Double
    
    /// Number of iterations taken
    let iterations: Int
    
    /// Final error estimate |f(root)|
    let residual: Double
    
    /// Whether the method converged
    let converged: Bool
    
    /// Method used to find the root
    let method: String
}

// MARK: - NumericalSolverConfig

/// Configuration for numerical solvers
struct NumericalSolverConfig: Equatable {
    /// Maximum iterations allowed
    var maxIterations: Int
    
    /// Tolerance for convergence
    var tolerance: Double
    
    /// Step size for numerical differentiation
    var derivativeStep: Double
    
    /// Timeout in seconds
    var timeout: TimeInterval
    
    /// Default configuration
    static let `default` = NumericalSolverConfig()
    
    init(
        maxIterations: Int = 100,
        tolerance: Double = 1e-12,
        derivativeStep: Double = 1e-8,
        timeout: TimeInterval = 5.0
    ) {
        self.maxIterations = maxIterations
        self.tolerance = tolerance
        self.derivativeStep = derivativeStep
        self.timeout = timeout
    }
}

// MARK: - NumericalSolver

/// Numerical equation solver using various root-finding methods
struct NumericalSolver {
    
    // MARK: - Newton-Raphson Method
    
    /// Solves f(x) = 0 using Newton-Raphson method
    /// - Parameters:
    ///   - function: The function f(x)
    ///   - derivative: The derivative f'(x), or nil for numerical differentiation
    ///   - initialGuess: Starting point x₀
    ///   - config: Solver configuration
    /// - Returns: Solution with root and convergence info
    static func newtonRaphson(
        function: (Double) -> Double,
        derivative: ((Double) -> Double)? = nil,
        initialGuess: Double,
        config: NumericalSolverConfig = .default
    ) throws -> NumericalSolution {
        var x = initialGuess
        let startTime = Date()
        
        let deriv = derivative ?? { x in
            numericalDerivative(of: function, at: x, h: config.derivativeStep)
        }
        
        for iteration in 1...config.maxIterations {
            // Check for timeout
            if Date().timeIntervalSince(startTime) > config.timeout {
                throw CalculatorError.timeout
            }
            
            let fx = function(x)
            
            // Check for NaN or Infinity
            guard fx.isFinite else {
                throw CalculatorError.mathError("Newton-Raphson: function returned non-finite value")
            }
            
            // Check for convergence by function value
            if abs(fx) < config.tolerance {
                return NumericalSolution(
                    root: x,
                    iterations: iteration,
                    residual: abs(fx),
                    converged: true,
                    method: "Newton-Raphson"
                )
            }
            
            let fpx = deriv(x)
            
            // Check for zero derivative
            guard abs(fpx) > 1e-15 else {
                throw CalculatorError.mathError("Newton-Raphson: derivative is zero")
            }
            
            // Newton step
            let dx = fx / fpx
            
            // Check for non-finite step
            guard dx.isFinite else {
                throw CalculatorError.mathError("Newton-Raphson: step is non-finite")
            }
            
            x = x - dx
            
            // Check for convergence by step size
            if abs(dx) < config.tolerance {
                let finalResidual = abs(function(x))
                return NumericalSolution(
                    root: x,
                    iterations: iteration,
                    residual: finalResidual,
                    converged: true,
                    method: "Newton-Raphson"
                )
            }
        }
        
        // Did not converge within max iterations
        return NumericalSolution(
            root: x,
            iterations: config.maxIterations,
            residual: abs(function(x)),
            converged: false,
            method: "Newton-Raphson"
        )
    }
    
    /// Solves f(x) = 0 using Newton-Raphson with an AST expression
    /// - Parameters:
    ///   - expression: AST node representing f(x)
    ///   - variable: Name of the variable (default "x")
    ///   - initialGuess: Starting point
    ///   - context: Evaluation context
    ///   - config: Solver configuration
    static func solveExpression(
        _ expression: ASTNode,
        variable: String = "x",
        initialGuess: Double,
        context: EvaluationContext,
        config: NumericalSolverConfig = .default
    ) throws -> NumericalSolution {
        // Create function that evaluates expression at x
        let function: (Double) -> Double = { xValue in
            var ctx = context
            ctx.variables[variable] = xValue
            var evaluator = Evaluator(context: ctx)
            do {
                let result = try evaluator.evaluate(expression)
                return result.doubleValue ?? .nan
            } catch {
                return .nan
            }
        }
        
        return try newtonRaphson(
            function: function,
            initialGuess: initialGuess,
            config: config
        )
    }
    
    // MARK: - Bisection Method
    
    /// Solves f(x) = 0 using bisection method (requires bracket)
    /// - Parameters:
    ///   - function: The function f(x)
    ///   - lower: Lower bound of bracket
    ///   - upper: Upper bound of bracket
    ///   - config: Solver configuration
    static func bisection(
        function: (Double) -> Double,
        lower: Double,
        upper: Double,
        config: NumericalSolverConfig = .default
    ) throws -> NumericalSolution {
        var a = lower
        var b = upper
        var fa = function(a)
        var fb = function(b)
        let startTime = Date()
        
        // Verify bracket
        guard fa * fb < 0 else {
            throw CalculatorError.invalidInput("Bisection requires f(a) and f(b) to have opposite signs")
        }
        
        // Ensure a < b
        if a > b {
            swap(&a, &b)
            swap(&fa, &fb)
        }
        
        for iteration in 1...config.maxIterations {
            // Check for timeout
            if Date().timeIntervalSince(startTime) > config.timeout {
                throw CalculatorError.timeout
            }
            
            let mid = (a + b) / 2
            let fmid = function(mid)
            
            // Check for convergence
            if abs(fmid) < config.tolerance || (b - a) / 2 < config.tolerance {
                return NumericalSolution(
                    root: mid,
                    iterations: iteration,
                    residual: abs(fmid),
                    converged: true,
                    method: "Bisection"
                )
            }
            
            // Update bracket
            if fa * fmid < 0 {
                b = mid
                fb = fmid
            } else {
                a = mid
                fa = fmid
            }
        }
        
        let mid = (a + b) / 2
        return NumericalSolution(
            root: mid,
            iterations: config.maxIterations,
            residual: abs(function(mid)),
            converged: false,
            method: "Bisection"
        )
    }
    
    // MARK: - Secant Method
    
    /// Solves f(x) = 0 using secant method (no derivative needed)
    /// - Parameters:
    ///   - function: The function f(x)
    ///   - x0: First initial guess
    ///   - x1: Second initial guess
    ///   - config: Solver configuration
    static func secant(
        function: (Double) -> Double,
        x0: Double,
        x1: Double,
        config: NumericalSolverConfig = .default
    ) throws -> NumericalSolution {
        var xPrev = x0
        var xCurr = x1
        var fPrev = function(xPrev)
        var fCurr = function(xCurr)
        let startTime = Date()
        
        for iteration in 1...config.maxIterations {
            // Check for timeout
            if Date().timeIntervalSince(startTime) > config.timeout {
                throw CalculatorError.timeout
            }
            
            // Check for convergence
            if abs(fCurr) < config.tolerance {
                return NumericalSolution(
                    root: xCurr,
                    iterations: iteration,
                    residual: abs(fCurr),
                    converged: true,
                    method: "Secant"
                )
            }
            
            // Check for division by zero (parallel secant)
            let denominator = fCurr - fPrev
            guard abs(denominator) > 1e-15 else {
                throw CalculatorError.mathError("Secant: division by zero (parallel secant line)")
            }
            
            // Secant step
            let xNext = xCurr - fCurr * (xCurr - xPrev) / denominator
            
            // Check for non-finite result
            guard xNext.isFinite else {
                throw CalculatorError.mathError("Secant: step is non-finite")
            }
            
            // Check for convergence by step size
            if abs(xNext - xCurr) < config.tolerance {
                let finalResidual = abs(function(xNext))
                return NumericalSolution(
                    root: xNext,
                    iterations: iteration,
                    residual: finalResidual,
                    converged: true,
                    method: "Secant"
                )
            }
            
            // Update for next iteration
            xPrev = xCurr
            fPrev = fCurr
            xCurr = xNext
            fCurr = function(xCurr)
        }
        
        return NumericalSolution(
            root: xCurr,
            iterations: config.maxIterations,
            residual: abs(fCurr),
            converged: false,
            method: "Secant"
        )
    }
    
    // MARK: - Brent's Method
    
    /// Solves f(x) = 0 using Brent's method (robust hybrid)
    /// - Parameters:
    ///   - function: The function f(x)
    ///   - lower: Lower bound of bracket
    ///   - upper: Upper bound of bracket
    ///   - config: Solver configuration
    static func brent(
        function: (Double) -> Double,
        lower: Double,
        upper: Double,
        config: NumericalSolverConfig = .default
    ) throws -> NumericalSolution {
        var a = lower
        var b = upper
        var fa = function(a)
        var fb = function(b)
        let startTime = Date()
        
        // Verify bracket
        guard fa * fb < 0 else {
            throw CalculatorError.invalidInput("Brent's method requires f(a) and f(b) to have opposite signs")
        }
        
        // Ensure |f(a)| >= |f(b)|
        if abs(fa) < abs(fb) {
            swap(&a, &b)
            swap(&fa, &fb)
        }
        
        var c = a
        var fc = fa
        var d = b - a
        var e = d
        
        for iteration in 1...config.maxIterations {
            // Check for timeout
            if Date().timeIntervalSince(startTime) > config.timeout {
                throw CalculatorError.timeout
            }
            
            // Check for convergence
            if abs(fb) < config.tolerance {
                return NumericalSolution(
                    root: b,
                    iterations: iteration,
                    residual: abs(fb),
                    converged: true,
                    method: "Brent"
                )
            }
            
            if abs(b - a) < config.tolerance {
                return NumericalSolution(
                    root: b,
                    iterations: iteration,
                    residual: abs(fb),
                    converged: true,
                    method: "Brent"
                )
            }
            
            // Ensure |f(a)| >= |f(b)|
            if abs(fa) < abs(fb) {
                swap(&a, &b)
                swap(&fa, &fb)
            }
            
            // Compute midpoint
            let m = 0.5 * (c - b)
            let tolerance1 = 2.0 * config.tolerance * max(abs(b), 1.0)
            
            // Check for convergence
            if abs(m) <= tolerance1 || fb == 0.0 {
                return NumericalSolution(
                    root: b,
                    iterations: iteration,
                    residual: abs(fb),
                    converged: true,
                    method: "Brent"
                )
            }
            
            var s: Double
            
            // Decide between interpolation and bisection
            if abs(e) >= tolerance1 && abs(fa) > abs(fb) {
                // Attempt inverse quadratic interpolation
                if a == c {
                    // Linear interpolation (secant)
                    s = fb / fa
                    let p = 2.0 * m * s
                    let q = 1.0 - s
                    s = b - p / q
                } else {
                    // Inverse quadratic interpolation
                    let q1 = fa / fc
                    let r = fb / fc
                    let s1 = fb / fa
                    let p = s1 * (2.0 * m * q1 * (q1 - r) - (b - a) * (r - 1.0))
                    let q2 = (q1 - 1.0) * (r - 1.0) * (s1 - 1.0)
                    s = b + p / q2
                }
                
                // Check if interpolation is acceptable
                let delta = abs(2.0 * tolerance1 * abs(b))
                let min1 = abs(s - b) - 0.5 * abs(e)
                let min2 = 0.75 * (c - b) - tolerance1
                
                if s < min(a, c) - delta || s > max(a, c) + delta ||
                    abs(s - b) >= 0.5 * abs(e) ||
                    min1 > 0 || min2 < 0 {
                    // Bisection step
                    e = m
                    d = e
                    s = b + m
                } else {
                    e = d
                    d = s - b
                }
            } else {
                // Bisection step
                e = m
                d = e
                s = b + m
            }
            
            // Update a to previous b
            a = b
            fa = fb
            
            // Update b
            if abs(d) > tolerance1 {
                b = b + d
            } else {
                b = b + (m > 0 ? tolerance1 : -tolerance1)
            }
            fb = function(b)
            
            // Update c to maintain bracket
            if (fb > 0 && fc > 0) || (fb < 0 && fc < 0) {
                c = a
                fc = fa
                e = b - a
                d = e
            }
        }
        
        return NumericalSolution(
            root: b,
            iterations: config.maxIterations,
            residual: abs(fb),
            converged: false,
            method: "Brent"
        )
    }
    
    // MARK: - Numerical Differentiation
    
    /// Computes numerical derivative using central difference
    static func numericalDerivative(
        of function: (Double) -> Double,
        at x: Double,
        h: Double = 1e-8
    ) -> Double {
        let fPlus = function(x + h)
        let fMinus = function(x - h)
        return (fPlus - fMinus) / (2 * h)
    }
    
    /// Computes numerical second derivative using central difference
    static func numericalSecondDerivative(
        of function: (Double) -> Double,
        at x: Double,
        h: Double = 1e-5
    ) -> Double {
        let fPlus = function(x + h)
        let fMid = function(x)
        let fMinus = function(x - h)
        return (fPlus - 2 * fMid + fMinus) / (h * h)
    }
    
    // MARK: - Bracket Finding
    
    /// Attempts to find a bracket [a, b] where f(a) and f(b) have opposite signs
    static func findBracket(
        function: (Double) -> Double,
        near guess: Double,
        maxExpansion: Int = 50
    ) -> (lower: Double, upper: Double)? {
        var a = guess
        var b = guess
        let factor = 1.6
        
        // Initial small bracket around guess
        if guess == 0 {
            a = -0.1
            b = 0.1
        } else {
            let delta = abs(guess) * 0.1
            a = guess - delta
            b = guess + delta
        }
        
        var fa = function(a)
        var fb = function(b)
        
        // Check if we already have a bracket
        if fa * fb < 0 {
            return (lower: min(a, b), upper: max(a, b))
        }
        
        // Expand bracket until we find sign change
        for _ in 0..<maxExpansion {
            // Expand toward the side with smaller |f|
            if abs(fa) < abs(fb) {
                a = a - factor * (b - a)
                fa = function(a)
            } else {
                b = b + factor * (b - a)
                fb = function(b)
            }
            
            // Check for bracket
            if fa * fb < 0 {
                return (lower: min(a, b), upper: max(a, b))
            }
            
            // Check for non-finite values
            if !fa.isFinite || !fb.isFinite {
                return nil
            }
        }
        
        return nil
    }
    
    // MARK: - Halley's Method (Higher-Order)
    
    /// Solves f(x) = 0 using Halley's method (cubic convergence)
    /// - Parameters:
    ///   - function: The function f(x)
    ///   - derivative: The first derivative f'(x)
    ///   - secondDerivative: The second derivative f''(x), or nil for numerical
    ///   - initialGuess: Starting point x₀
    ///   - config: Solver configuration
    static func halley(
        function: (Double) -> Double,
        derivative: ((Double) -> Double)? = nil,
        secondDerivative: ((Double) -> Double)? = nil,
        initialGuess: Double,
        config: NumericalSolverConfig = .default
    ) throws -> NumericalSolution {
        var x = initialGuess
        let startTime = Date()
        
        let fp = derivative ?? { x in
            numericalDerivative(of: function, at: x, h: config.derivativeStep)
        }
        
        let fpp = secondDerivative ?? { x in
            numericalSecondDerivative(of: function, at: x, h: sqrt(config.derivativeStep))
        }
        
        for iteration in 1...config.maxIterations {
            // Check for timeout
            if Date().timeIntervalSince(startTime) > config.timeout {
                throw CalculatorError.timeout
            }
            
            let fx = function(x)
            let fpx = fp(x)
            let fppx = fpp(x)
            
            // Check for convergence
            if abs(fx) < config.tolerance {
                return NumericalSolution(
                    root: x,
                    iterations: iteration,
                    residual: abs(fx),
                    converged: true,
                    method: "Halley"
                )
            }
            
            // Check for zero derivative
            guard abs(fpx) > 1e-15 else {
                throw CalculatorError.mathError("Halley: derivative is zero")
            }
            
            // Halley's formula: x - f(x) / [f'(x) - f(x)*f''(x)/(2*f'(x))]
            let denominator = fpx - (fx * fppx) / (2 * fpx)
            
            guard abs(denominator) > 1e-15 else {
                // Fall back to Newton step
                x = x - fx / fpx
                continue
            }
            
            let dx = fx / denominator
            x = x - dx
            
            // Check for convergence by step size
            if abs(dx) < config.tolerance {
                return NumericalSolution(
                    root: x,
                    iterations: iteration,
                    residual: abs(function(x)),
                    converged: true,
                    method: "Halley"
                )
            }
        }
        
        return NumericalSolution(
            root: x,
            iterations: config.maxIterations,
            residual: abs(function(x)),
            converged: false,
            method: "Halley"
        )
    }
    
    // MARK: - Fixed Point Iteration
    
    /// Solves x = g(x) using fixed point iteration
    /// - Parameters:
    ///   - g: The iteration function g(x)
    ///   - initialGuess: Starting point x₀
    ///   - config: Solver configuration
    static func fixedPoint(
        g: (Double) -> Double,
        initialGuess: Double,
        config: NumericalSolverConfig = .default
    ) throws -> NumericalSolution {
        var x = initialGuess
        let startTime = Date()
        
        for iteration in 1...config.maxIterations {
            // Check for timeout
            if Date().timeIntervalSince(startTime) > config.timeout {
                throw CalculatorError.timeout
            }
            
            let xNext = g(x)
            
            // Check for non-finite
            guard xNext.isFinite else {
                throw CalculatorError.mathError("Fixed point: iteration produced non-finite value")
            }
            
            let residual = abs(xNext - x)
            
            // Check for convergence
            if residual < config.tolerance {
                return NumericalSolution(
                    root: xNext,
                    iterations: iteration,
                    residual: residual,
                    converged: true,
                    method: "Fixed Point"
                )
            }
            
            x = xNext
        }
        
        return NumericalSolution(
            root: x,
            iterations: config.maxIterations,
            residual: abs(g(x) - x),
            converged: false,
            method: "Fixed Point"
        )
    }
    
    // MARK: - Automatic Method Selection
    
    /// Automatically selects and applies the best numerical method
    /// - Parameters:
    ///   - function: The function f(x)
    ///   - derivative: Optional derivative f'(x)
    ///   - initialGuess: Starting point or hint
    ///   - config: Solver configuration
    static func solve(
        function: (Double) -> Double,
        derivative: ((Double) -> Double)? = nil,
        initialGuess: Double,
        config: NumericalSolverConfig = .default
    ) throws -> NumericalSolution {
        // Try to find a bracket first
        if let bracket = findBracket(function: function, near: initialGuess) {
            // Use Brent's method if bracket found (most robust)
            do {
                return try brent(
                    function: function,
                    lower: bracket.lower,
                    upper: bracket.upper,
                    config: config
                )
            } catch {
                // Fall through to Newton-Raphson
            }
        }
        
        // Try Newton-Raphson
        do {
            return try newtonRaphson(
                function: function,
                derivative: derivative,
                initialGuess: initialGuess,
                config: config
            )
        } catch {
            // Fall through to Secant
        }
        
        // Last resort: Secant method with perturbed initial guesses
        let x0 = initialGuess
        let x1 = initialGuess + 0.1 * (abs(initialGuess) + 1)
        
        return try secant(
            function: function,
            x0: x0,
            x1: x1,
            config: config
        )
    }
}
