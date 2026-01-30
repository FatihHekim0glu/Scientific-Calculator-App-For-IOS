import Foundation

// MARK: - Combinatorics

/// Combinatorial and number theory functions
struct Combinatorics {
    
    // MARK: - Permutations and Combinations
    
    /// Calculates n! (factorial)
    /// - Parameter n: Non-negative integer
    /// - Returns: n factorial
    /// - Throws: CalculatorError for invalid input or overflow
    static func factorial(_ n: Double) throws -> Double {
        guard isNonNegativeInteger(n) else {
            throw CalculatorError.domainError("Factorial requires non-negative integer")
        }
        
        let intN = Int(n)
        
        guard intN <= 170 else {
            throw CalculatorError.overflow
        }
        
        if intN == 0 || intN == 1 {
            return 1
        }
        
        var result: Double = 1
        for i in 2...intN {
            result *= Double(i)
            if result.isInfinite {
                throw CalculatorError.overflow
            }
        }
        
        return result
    }
    
    /// Calculates nPr (permutations)
    /// nPr = n! / (n-r)!
    /// - Parameters:
    ///   - n: Total items (non-negative integer)
    ///   - r: Items to arrange (non-negative integer, r ≤ n)
    /// - Returns: Number of permutations
    /// - Throws: CalculatorError for invalid input
    static func permutation(n: Double, r: Double) throws -> Double {
        guard isNonNegativeInteger(n), isNonNegativeInteger(r) else {
            throw CalculatorError.domainError("Permutation requires non-negative integers")
        }
        
        let intN = Int(n)
        let intR = Int(r)
        
        guard intR <= intN else {
            throw CalculatorError.domainError("r cannot be greater than n in nPr")
        }
        
        if intR == 0 {
            return 1
        }
        
        // Calculate n × (n-1) × ... × (n-r+1) directly to avoid overflow
        var result: Double = 1
        for i in 0..<intR {
            result *= Double(intN - i)
            if result.isInfinite {
                throw CalculatorError.overflow
            }
        }
        
        return result
    }
    
    /// Calculates nCr (combinations)
    /// nCr = n! / (r! × (n-r)!)
    /// - Parameters:
    ///   - n: Total items (non-negative integer)
    ///   - r: Items to choose (non-negative integer, r ≤ n)
    /// - Returns: Number of combinations
    /// - Throws: CalculatorError for invalid input
    static func combination(n: Double, r: Double) throws -> Double {
        guard isNonNegativeInteger(n), isNonNegativeInteger(r) else {
            throw CalculatorError.domainError("Combination requires non-negative integers")
        }
        
        let intN = Int(n)
        var intR = Int(r)
        
        guard intR <= intN else {
            throw CalculatorError.domainError("r cannot be greater than n in nCr")
        }
        
        // Use symmetry: nCr = nC(n-r) when r > n/2
        if intR > intN / 2 {
            intR = intN - intR
        }
        
        if intR == 0 {
            return 1
        }
        
        // Calculate using multiplicative formula to avoid overflow
        // nCr = (n × (n-1) × ... × (n-r+1)) / (r × (r-1) × ... × 1)
        var result: Double = 1
        for i in 0..<intR {
            result *= Double(intN - i)
            result /= Double(i + 1)
        }
        
        // Round to avoid floating-point errors for integer results
        return Foundation.round(result)
    }
    
    // MARK: - Number Theory
    
    /// Greatest Common Divisor using Euclidean algorithm
    /// - Parameters:
    ///   - a: First positive integer
    ///   - b: Second positive integer
    /// - Returns: GCD of a and b
    /// - Throws: CalculatorError if inputs are not positive integers
    static func gcd(_ a: Double, _ b: Double) throws -> Double {
        guard isPositiveInteger(a), isPositiveInteger(b) else {
            throw CalculatorError.domainError("GCD requires positive integers")
        }
        
        var x = Int(a)
        var y = Int(b)
        
        while y != 0 {
            let temp = y
            y = x % y
            x = temp
        }
        
        return Double(x)
    }
    
    /// Least Common Multiple
    /// LCM(a, b) = |a × b| / GCD(a, b)
    /// - Parameters:
    ///   - a: First positive integer
    ///   - b: Second positive integer
    /// - Returns: LCM of a and b
    /// - Throws: CalculatorError if inputs are not positive integers
    static func lcm(_ a: Double, _ b: Double) throws -> Double {
        guard isPositiveInteger(a), isPositiveInteger(b) else {
            throw CalculatorError.domainError("LCM requires positive integers")
        }
        
        let gcdValue = try gcd(a, b)
        let result = (a / gcdValue) * b
        
        if result.isInfinite {
            throw CalculatorError.overflow
        }
        
        return result
    }
    
    /// Modulo operation (remainder)
    /// Returns a mod b (always non-negative result matching mathematical definition)
    /// - Parameters:
    ///   - a: Dividend
    ///   - b: Divisor (non-zero)
    /// - Returns: a mod b (always non-negative)
    /// - Throws: CalculatorError.divisionByZero if b is zero
    static func mod(_ a: Double, _ b: Double) throws -> Double {
        guard b != 0 else {
            throw CalculatorError.divisionByZero
        }
        
        // Mathematical modulo: result is always non-negative
        // a mod b = a - b × floor(a/b)
        let result = a - b * Foundation.floor(a / b)
        
        return result
    }
    
    // MARK: - Validation Helpers
    
    /// Checks if a Double represents a non-negative integer
    private static func isNonNegativeInteger(_ value: Double) -> Bool {
        guard value >= 0 else { return false }
        guard value.isFinite else { return false }
        return value == Foundation.floor(value)
    }
    
    /// Checks if a Double represents a positive integer
    private static func isPositiveInteger(_ value: Double) -> Bool {
        guard value > 0 else { return false }
        guard value.isFinite else { return false }
        return value == Foundation.floor(value)
    }
}
