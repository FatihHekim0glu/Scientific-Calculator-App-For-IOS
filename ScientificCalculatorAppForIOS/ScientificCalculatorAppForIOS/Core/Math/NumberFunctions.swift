import Foundation

// MARK: - NumberFunctions

/// Number manipulation and utility functions
struct NumberFunctions {
    
    // MARK: - Part Extraction
    
    /// Returns the integer part of a number (truncates toward zero)
    /// Int(3.7) = 3, Int(-3.7) = -3
    static func integerPart(_ value: Double) -> Double {
        trunc(value)
    }
    
    /// Returns the fractional part of a number
    /// Frac(3.7) = 0.7, Frac(-3.7) = -0.7
    static func fractionalPart(_ value: Double) -> Double {
        value - trunc(value)
    }
    
    // MARK: - Rounding
    
    /// Rounds to specified number of decimal places
    /// - Parameters:
    ///   - value: Value to round
    ///   - places: Decimal places (0-9)
    static func round(_ value: Double, places: Int) -> Double {
        let clampedPlaces = max(0, min(places, 9))
        let multiplier = pow(10.0, Double(clampedPlaces))
        return Foundation.round(value * multiplier) / multiplier
    }
    
    /// Rounds to display precision (10 significant figures)
    static func roundToDisplayPrecision(_ value: Double) -> Double {
        guard value != 0, value.isFinite else { return value }
        
        let magnitude = floor(log10(Swift.abs(value)))
        let scale = pow(10.0, 9 - magnitude)
        return Foundation.round(value * scale) / scale
    }
    
    /// Floor function (rounds toward negative infinity)
    static func floor(_ value: Double) -> Double {
        Foundation.floor(value)
    }
    
    /// Ceiling function (rounds toward positive infinity)
    static func ceil(_ value: Double) -> Double {
        Foundation.ceil(value)
    }
    
    // MARK: - Random Numbers
    
    /// Returns a random number in [0, 1)
    static func random() -> Double {
        Double.random(in: 0..<1)
    }
    
    /// Returns a random integer in [min, max]
    /// - Throws: CalculatorError if min > max or inputs not integers
    static func randomInt(min: Double, max: Double) throws -> Double {
        guard isInteger(min), isInteger(max) else {
            throw CalculatorError.domainError("RanInt requires integer arguments")
        }
        
        guard min <= max else {
            throw CalculatorError.domainError("RanInt requires min ≤ max")
        }
        
        let minInt = Int(min)
        let maxInt = Int(max)
        
        return Double(Int.random(in: minInt...maxInt))
    }
    
    // MARK: - Sign and Absolute Value
    
    /// Returns the sign of a number: -1, 0, or 1
    static func sign(_ value: Double) -> Double {
        if value > 0 {
            return 1
        } else if value < 0 {
            return -1
        } else {
            return 0
        }
    }
    
    /// Returns absolute value
    static func abs(_ value: Double) -> Double {
        Swift.abs(value)
    }
    
    // MARK: - Power Functions
    
    /// Returns 10^x
    static func tenPow(_ x: Double) throws -> Double {
        guard x <= 308 else {
            throw CalculatorError.overflow
        }
        
        guard x >= -323 else {
            throw CalculatorError.underflow
        }
        
        let result = pow(10.0, x)
        
        if result.isInfinite {
            throw CalculatorError.overflow
        }
        
        return result
    }
    
    /// Returns x⁻¹ (reciprocal)
    /// - Throws: CalculatorError.divisionByZero if x is 0
    static func reciprocal(_ x: Double) throws -> Double {
        guard x != 0 else {
            throw CalculatorError.divisionByZero
        }
        
        return 1.0 / x
    }
    
    /// Returns x² (square)
    static func square(_ x: Double) throws -> Double {
        let result = x * x
        
        if result.isInfinite && x.isFinite {
            throw CalculatorError.overflow
        }
        
        return result
    }
    
    /// Returns x³ (cube)
    static func cube(_ x: Double) throws -> Double {
        let result = x * x * x
        
        if result.isInfinite && x.isFinite {
            throw CalculatorError.overflow
        }
        
        return result
    }
    
    /// Returns the nth root of x
    /// ⁿ√x where n is the index and x is the radicand
    /// - Throws: CalculatorError for invalid inputs (even root of negative)
    static func nthRoot(index n: Double, radicand x: Double) throws -> Double {
        guard n != 0 else {
            throw CalculatorError.domainError("Root index cannot be zero")
        }
        
        if x == 0 {
            return 0
        }
        
        if x > 0 {
            return pow(x, 1.0 / n)
        }
        
        // x is negative
        guard isOddInteger(n) else {
            throw CalculatorError.domainError("Even root of negative number is undefined")
        }
        
        // Odd root of negative number
        return -pow(Swift.abs(x), 1.0 / n)
    }
    
    /// Returns log base a of b
    /// logₐ(b) = ln(b) / ln(a)
    /// - Throws: CalculatorError for invalid inputs
    static func logBase(_ base: Double, of value: Double) throws -> Double {
        guard base > 0 else {
            throw CalculatorError.domainError("Logarithm base must be positive")
        }
        
        guard base != 1 else {
            throw CalculatorError.domainError("Logarithm base cannot be 1")
        }
        
        guard value > 0 else {
            throw CalculatorError.domainError("Logarithm argument must be positive")
        }
        
        return log(value) / log(base)
    }
    
    // MARK: - Percentage
    
    /// Converts a value to its percentage (divides by 100)
    /// 50% = 0.5
    static func percent(_ value: Double) -> Double {
        value / 100.0
    }
    
    // MARK: - Validation Helpers
    
    /// Checks if a Double represents an integer
    private static func isInteger(_ value: Double) -> Bool {
        value.isFinite && value == Foundation.round(value)
    }
    
    /// Checks if a Double represents an odd integer
    private static func isOddInteger(_ value: Double) -> Bool {
        isInteger(value) && Int(value) % 2 != 0
    }
}
