import Foundation

// MARK: - Integration Result

/// Result of numerical integration
struct IntegrationResult: Equatable {
    /// The computed integral value
    let value: Double
    
    /// Estimated error
    let estimatedError: Double
    
    /// Number of function evaluations
    let evaluations: Int
    
    /// Whether the computation converged
    let converged: Bool
}

// MARK: - Derivative Result

/// Result of numerical differentiation
struct DerivativeResult: Equatable {
    /// The derivative value f'(a)
    let value: Double
    
    /// Estimated error
    let estimatedError: Double
    
    /// Order of derivative (1 for first derivative)
    let order: Int
}

// MARK: - Numerical Calculus

/// Numerical calculus operations: integration, differentiation, summation, product
struct NumericalCalculus {
    
    // MARK: - Definite Integration
    
    /// Computes definite integral ∫[a,b] f(x) dx using adaptive Simpson's rule
    static func integrate(
        _ function: (Double) -> Double,
        from a: Double,
        to b: Double,
        tolerance: Double = 1e-10,
        maxDepth: Int = 50
    ) throws -> IntegrationResult {
        var evaluations = 0
        
        func simpson(_ a: Double, _ b: Double, _ fa: Double, _ fb: Double, _ fm: Double) -> Double {
            return (b - a) / 6 * (fa + 4 * fm + fb)
        }
        
        func adaptiveSimpson(
            _ a: Double, _ b: Double,
            _ fa: Double, _ fb: Double, _ fm: Double,
            _ whole: Double, _ tol: Double, _ depth: Int
        ) -> (value: Double, error: Double) {
            let m = (a + b) / 2
            let lm = (a + m) / 2
            let rm = (m + b) / 2
            
            let flm = function(lm)
            let frm = function(rm)
            evaluations += 2
            
            let left = simpson(a, m, fa, fm, flm)
            let right = simpson(m, b, fm, fb, frm)
            let delta = left + right - whole
            
            if depth <= 0 || abs(delta) <= 15 * tol {
                return (left + right + delta / 15, abs(delta) / 15)
            }
            
            let leftResult = adaptiveSimpson(a, m, fa, fm, flm, left, tol / 2, depth - 1)
            let rightResult = adaptiveSimpson(m, b, fm, fb, frm, right, tol / 2, depth - 1)
            
            return (leftResult.value + rightResult.value, leftResult.error + rightResult.error)
        }
        
        guard a.isFinite && b.isFinite else {
            throw CalculatorError.domainError("Integration bounds must be finite")
        }
        
        guard a < b else {
            if a == b {
                return IntegrationResult(value: 0, estimatedError: 0, evaluations: 0, converged: true)
            }
            let result = try integrate(function, from: b, to: a, tolerance: tolerance, maxDepth: maxDepth)
            return IntegrationResult(
                value: -result.value,
                estimatedError: result.estimatedError,
                evaluations: result.evaluations,
                converged: result.converged
            )
        }
        
        let fa = function(a)
        let fb = function(b)
        let fm = function((a + b) / 2)
        evaluations = 3
        
        guard fa.isFinite && fb.isFinite && fm.isFinite else {
            throw CalculatorError.mathError("Function is undefined at some point in the interval")
        }
        
        let whole = simpson(a, b, fa, fb, fm)
        let result = adaptiveSimpson(a, b, fa, fb, fm, whole, tolerance, maxDepth)
        
        return IntegrationResult(
            value: result.value,
            estimatedError: result.error,
            evaluations: evaluations,
            converged: result.error < tolerance
        )
    }
    
    /// Computes definite integral using basic Simpson's rule (non-adaptive)
    static func simpsonIntegrate(
        _ function: (Double) -> Double,
        from a: Double,
        to b: Double,
        n: Int = 1000
    ) throws -> Double {
        guard a.isFinite && b.isFinite else {
            throw CalculatorError.domainError("Integration bounds must be finite")
        }
        
        var intervals = n
        if intervals % 2 != 0 {
            intervals += 1
        }
        
        guard intervals >= 2 else {
            throw CalculatorError.invalidInput("Number of intervals must be at least 2")
        }
        
        let h = (b - a) / Double(intervals)
        var sum = function(a) + function(b)
        
        for i in 1..<intervals {
            let x = a + Double(i) * h
            let fx = function(x)
            guard fx.isFinite else {
                throw CalculatorError.mathError("Function is undefined at x = \(x)")
            }
            if i % 2 == 0 {
                sum += 2 * fx
            } else {
                sum += 4 * fx
            }
        }
        
        return sum * h / 3
    }
    
    /// Integrates an expression AST
    static func integrateExpression(
        _ expression: ASTNode,
        variable: String,
        from a: Double,
        to b: Double,
        context: EvaluationContext,
        tolerance: Double = 1e-10
    ) throws -> IntegrationResult {
        let function: (Double) -> Double = { x in
            var ctx = context
            ctx.variables[variable] = x
            var evaluator = Evaluator(context: ctx)
            
            do {
                let result = try evaluator.evaluate(expression)
                return result.doubleValue ?? .nan
            } catch {
                return .nan
            }
        }
        
        return try integrate(function, from: a, to: b, tolerance: tolerance)
    }
    
    // MARK: - Numerical Differentiation
    
    /// Computes derivative f'(a) using central difference
    static func differentiate(
        _ function: (Double) -> Double,
        at a: Double,
        h: Double? = nil
    ) -> DerivativeResult {
        let eps = Double.ulpOfOne
        let optimalH = h ?? pow(eps, 1.0 / 3.0) * max(1, abs(a))
        
        let fp = function(a + optimalH)
        let fm = function(a - optimalH)
        let derivative = (fp - fm) / (2 * optimalH)
        
        let errorEstimate = optimalH * optimalH * abs(derivative) + eps * max(abs(fp), abs(fm)) / optimalH
        
        return DerivativeResult(value: derivative, estimatedError: errorEstimate, order: 1)
    }
    
    /// Computes second derivative f''(a)
    static func secondDerivative(
        _ function: (Double) -> Double,
        at a: Double,
        h: Double? = nil
    ) -> DerivativeResult {
        let eps = Double.ulpOfOne
        let optimalH = h ?? pow(eps, 1.0 / 4.0) * max(1, abs(a))
        
        let fc = function(a)
        let fp = function(a + optimalH)
        let fm = function(a - optimalH)
        let secondDeriv = (fp - 2 * fc + fm) / (optimalH * optimalH)
        
        let errorEstimate = pow(optimalH, 2) * abs(secondDeriv) + eps * max(abs(fp), abs(fc), abs(fm)) / (optimalH * optimalH)
        
        return DerivativeResult(value: secondDeriv, estimatedError: errorEstimate, order: 2)
    }
    
    /// Differentiates an expression AST
    static func differentiateExpression(
        _ expression: ASTNode,
        variable: String,
        at a: Double,
        context: EvaluationContext
    ) throws -> DerivativeResult {
        let function: (Double) -> Double = { x in
            var ctx = context
            ctx.variables[variable] = x
            var evaluator = Evaluator(context: ctx)
            
            do {
                let result = try evaluator.evaluate(expression)
                return result.doubleValue ?? .nan
            } catch {
                return .nan
            }
        }
        
        let result = differentiate(function, at: a)
        
        guard result.value.isFinite else {
            throw CalculatorError.mathError("Derivative undefined at x = \(a)")
        }
        
        return result
    }
    
    // MARK: - Summation (Σ)
    
    /// Computes Σ f(x) for x = start to end (integer steps)
    static func summation(
        _ function: (Double) -> Double,
        from start: Int,
        to end: Int
    ) throws -> Double {
        guard start <= end else {
            throw CalculatorError.invalidInput("Start must be ≤ end for summation")
        }
        
        guard end - start < 10_000_000 else {
            throw CalculatorError.domainError("Summation range too large (max 10 million terms)")
        }
        
        var sum = 0.0
        for i in start...end {
            let value = function(Double(i))
            guard value.isFinite else {
                throw CalculatorError.mathError("Function undefined at x = \(i)")
            }
            sum += value
        }
        
        return sum
    }
    
    /// Computes summation of an expression AST
    static func summationExpression(
        _ expression: ASTNode,
        variable: String,
        from start: Int,
        to end: Int,
        context: EvaluationContext
    ) throws -> Double {
        let function: (Double) -> Double = { x in
            var ctx = context
            ctx.variables[variable] = x
            var evaluator = Evaluator(context: ctx)
            
            do {
                let result = try evaluator.evaluate(expression)
                return result.doubleValue ?? .nan
            } catch {
                return .nan
            }
        }
        
        return try summation(function, from: start, to: end)
    }
    
    // MARK: - Product (Π)
    
    /// Computes Π f(x) for x = start to end (integer steps)
    static func product(
        _ function: (Double) -> Double,
        from start: Int,
        to end: Int
    ) throws -> Double {
        guard start <= end else {
            throw CalculatorError.invalidInput("Start must be ≤ end for product")
        }
        
        guard end - start < 10_000_000 else {
            throw CalculatorError.domainError("Product range too large")
        }
        
        var result = 1.0
        for i in start...end {
            let value = function(Double(i))
            guard value.isFinite else {
                throw CalculatorError.mathError("Function undefined at x = \(i)")
            }
            result *= value
            
            if result == 0 {
                break
            }
            
            guard result.isFinite else {
                throw CalculatorError.overflow
            }
        }
        
        return result
    }
    
    /// Computes product of an expression AST
    static func productExpression(
        _ expression: ASTNode,
        variable: String,
        from start: Int,
        to end: Int,
        context: EvaluationContext
    ) throws -> Double {
        let function: (Double) -> Double = { x in
            var ctx = context
            ctx.variables[variable] = x
            var evaluator = Evaluator(context: ctx)
            
            do {
                let result = try evaluator.evaluate(expression)
                return result.doubleValue ?? .nan
            } catch {
                return .nan
            }
        }
        
        return try product(function, from: start, to: end)
    }
    
    // MARK: - Convenience Methods
    
    /// Computes Riemann sum (left endpoint) for approximation
    static func leftRiemannSum(
        _ function: (Double) -> Double,
        from a: Double,
        to b: Double,
        n: Int
    ) -> Double {
        let h = (b - a) / Double(n)
        var sum = 0.0
        for i in 0..<n {
            let x = a + Double(i) * h
            sum += function(x)
        }
        return sum * h
    }
    
    /// Computes Riemann sum (right endpoint) for approximation
    static func rightRiemannSum(
        _ function: (Double) -> Double,
        from a: Double,
        to b: Double,
        n: Int
    ) -> Double {
        let h = (b - a) / Double(n)
        var sum = 0.0
        for i in 1...n {
            let x = a + Double(i) * h
            sum += function(x)
        }
        return sum * h
    }
    
    /// Computes trapezoidal approximation
    static func trapezoidalSum(
        _ function: (Double) -> Double,
        from a: Double,
        to b: Double,
        n: Int
    ) -> Double {
        let h = (b - a) / Double(n)
        var sum = (function(a) + function(b)) / 2
        for i in 1..<n {
            let x = a + Double(i) * h
            sum += function(x)
        }
        return sum * h
    }
    
    /// Higher-order derivative using Richardson extrapolation
    static func nthDerivative(
        _ function: (Double) -> Double,
        at a: Double,
        order n: Int,
        h: Double? = nil
    ) throws -> DerivativeResult {
        guard n >= 1 && n <= 4 else {
            throw CalculatorError.invalidInput("Derivative order must be between 1 and 4")
        }
        
        let eps = Double.ulpOfOne
        let optimalH = h ?? pow(eps, 1.0 / Double(n + 2)) * max(1, abs(a))
        
        switch n {
        case 1:
            return differentiate(function, at: a, h: optimalH)
            
        case 2:
            return secondDerivative(function, at: a, h: optimalH)
            
        case 3:
            let fp1 = function(a + optimalH)
            let fp2 = function(a + 2 * optimalH)
            let fm1 = function(a - optimalH)
            let fm2 = function(a - 2 * optimalH)
            let derivative = (fp2 - 2 * fp1 + 2 * fm1 - fm2) / (2 * pow(optimalH, 3))
            return DerivativeResult(value: derivative, estimatedError: pow(optimalH, 2), order: 3)
            
        case 4:
            let fp1 = function(a + optimalH)
            let fp2 = function(a + 2 * optimalH)
            let fc = function(a)
            let fm1 = function(a - optimalH)
            let fm2 = function(a - 2 * optimalH)
            let derivative = (fp2 - 4 * fp1 + 6 * fc - 4 * fm1 + fm2) / pow(optimalH, 4)
            return DerivativeResult(value: derivative, estimatedError: pow(optimalH, 2), order: 4)
            
        default:
            throw CalculatorError.invalidInput("Derivative order must be between 1 and 4")
        }
    }
}
