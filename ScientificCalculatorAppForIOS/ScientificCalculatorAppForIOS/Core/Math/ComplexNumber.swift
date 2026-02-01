import Foundation

// MARK: - ComplexNumber

/// Represents a complex number in the form a + bi
struct ComplexNumber: Equatable, Hashable {
    
    // MARK: - Properties
    
    /// Real part of the complex number
    let real: Double
    
    /// Imaginary part of the complex number
    let imaginary: Double
    
    /// Epsilon for zero comparisons
    private static let epsilon: Double = 1e-15
    
    // MARK: - Polar Form Properties
    
    /// Magnitude (absolute value) |z| = √(a² + b²)
    var magnitude: Double {
        sqrt(real * real + imaginary * imaginary)
    }
    
    /// Argument (angle) in radians, range (-π, π]
    var argument: Double {
        atan2(imaginary, real)
    }
    
    /// Returns true if this is a real number (imaginary part is zero)
    var isReal: Bool {
        abs(imaginary) < Self.epsilon
    }
    
    /// Returns true if this is a pure imaginary number
    var isPureImaginary: Bool {
        abs(real) < Self.epsilon && abs(imaginary) >= Self.epsilon
    }
    
    /// Returns true if this is zero
    var isZero: Bool {
        abs(real) < Self.epsilon && abs(imaginary) < Self.epsilon
    }
    
    // MARK: - Initialization
    
    /// Creates a complex number from rectangular form (a + bi)
    init(real: Double, imaginary: Double = 0) {
        self.real = real
        self.imaginary = imaginary
    }
    
    /// Creates a complex number from a real number
    init(_ real: Double) {
        self.real = real
        self.imaginary = 0
    }
    
    /// Creates a complex number from polar form (r∠θ)
    static func fromPolar(r: Double, theta: Double) -> ComplexNumber {
        let real = r * Foundation.cos(theta)
        let imaginary = r * Foundation.sin(theta)
        return ComplexNumber(real: real, imaginary: imaginary)
    }
    
    // MARK: - Common Values
    
    /// Zero: 0 + 0i
    static let zero = ComplexNumber(real: 0, imaginary: 0)
    
    /// One: 1 + 0i
    static let one = ComplexNumber(real: 1, imaginary: 0)
    
    /// Imaginary unit: 0 + 1i
    static let i = ComplexNumber(real: 0, imaginary: 1)
    
    // MARK: - Equatable with Epsilon Tolerance
    
    static func == (lhs: ComplexNumber, rhs: ComplexNumber) -> Bool {
        abs(lhs.real - rhs.real) < epsilon && abs(lhs.imaginary - rhs.imaginary) < epsilon
    }
}

// MARK: - Arithmetic Operations

extension ComplexNumber {
    
    // MARK: - Basic Arithmetic
    
    /// Addition: (a+bi) + (c+di) = (a+c) + (b+d)i
    static func + (lhs: ComplexNumber, rhs: ComplexNumber) -> ComplexNumber {
        ComplexNumber(
            real: lhs.real + rhs.real,
            imaginary: lhs.imaginary + rhs.imaginary
        )
    }
    
    /// Subtraction: (a+bi) - (c+di) = (a-c) + (b-d)i
    static func - (lhs: ComplexNumber, rhs: ComplexNumber) -> ComplexNumber {
        ComplexNumber(
            real: lhs.real - rhs.real,
            imaginary: lhs.imaginary - rhs.imaginary
        )
    }
    
    /// Multiplication: (a+bi) × (c+di) = (ac-bd) + (ad+bc)i
    static func * (lhs: ComplexNumber, rhs: ComplexNumber) -> ComplexNumber {
        ComplexNumber(
            real: lhs.real * rhs.real - lhs.imaginary * rhs.imaginary,
            imaginary: lhs.real * rhs.imaginary + lhs.imaginary * rhs.real
        )
    }
    
    /// Division: (a+bi) ÷ (c+di) = [(ac+bd) + (bc-ad)i] / (c²+d²)
    static func / (lhs: ComplexNumber, rhs: ComplexNumber) throws -> ComplexNumber {
        let denominator = rhs.real * rhs.real + rhs.imaginary * rhs.imaginary
        
        guard denominator > epsilon else {
            throw CalculatorError.divisionByZero
        }
        
        let realPart = (lhs.real * rhs.real + lhs.imaginary * rhs.imaginary) / denominator
        let imagPart = (lhs.imaginary * rhs.real - lhs.real * rhs.imaginary) / denominator
        
        return ComplexNumber(real: realPart, imaginary: imagPart)
    }
    
    /// Scalar multiplication (scalar on left)
    static func * (scalar: Double, complex: ComplexNumber) -> ComplexNumber {
        ComplexNumber(
            real: scalar * complex.real,
            imaginary: scalar * complex.imaginary
        )
    }
    
    /// Scalar multiplication (scalar on right)
    static func * (complex: ComplexNumber, scalar: Double) -> ComplexNumber {
        ComplexNumber(
            real: complex.real * scalar,
            imaginary: complex.imaginary * scalar
        )
    }
    
    /// Scalar division
    static func / (complex: ComplexNumber, scalar: Double) throws -> ComplexNumber {
        guard abs(scalar) > epsilon else {
            throw CalculatorError.divisionByZero
        }
        return ComplexNumber(
            real: complex.real / scalar,
            imaginary: complex.imaginary / scalar
        )
    }
    
    /// Negation
    static prefix func - (complex: ComplexNumber) -> ComplexNumber {
        ComplexNumber(real: -complex.real, imaginary: -complex.imaginary)
    }
}

// MARK: - Complex Functions

extension ComplexNumber {
    
    // MARK: - Complex Functions
    
    /// Complex conjugate: conj(a+bi) = a - bi
    func conjugate() -> ComplexNumber {
        ComplexNumber(real: real, imaginary: -imaginary)
    }
    
    /// Reciprocal: 1/z = conj(z) / |z|²
    func reciprocal() throws -> ComplexNumber {
        let magnitudeSquared = real * real + imaginary * imaginary
        
        guard magnitudeSquared > Self.epsilon else {
            throw CalculatorError.divisionByZero
        }
        
        return ComplexNumber(
            real: real / magnitudeSquared,
            imaginary: -imaginary / magnitudeSquared
        )
    }
    
    /// Integer power using De Moivre's theorem
    /// z^n = r^n × (cos(nθ) + i·sin(nθ))
    func power(_ n: Int) -> ComplexNumber {
        if n == 0 {
            return ComplexNumber.one
        }
        
        if n < 0 {
            guard let reciprocal = try? self.reciprocal() else {
                return ComplexNumber.zero
            }
            return reciprocal.power(-n)
        }
        
        let r = magnitude
        let theta = argument
        
        let newR = Foundation.pow(r, Double(n))
        let newTheta = theta * Double(n)
        
        return ComplexNumber.fromPolar(r: newR, theta: newTheta)
    }
    
    /// Real power (may return complex result)
    func power(_ x: Double) -> ComplexNumber {
        if isZero {
            return x > 0 ? ComplexNumber.zero : ComplexNumber.zero
        }
        
        let r = magnitude
        let theta = argument
        
        let newR = Foundation.pow(r, x)
        let newTheta = theta * x
        
        return ComplexNumber.fromPolar(r: newR, theta: newTheta)
    }
    
    /// Principal square root
    /// √z = √r × (cos(θ/2) + i·sin(θ/2))
    func squareRoot() -> ComplexNumber {
        let r = magnitude
        let theta = argument
        
        let sqrtR = sqrt(r)
        let halfTheta = theta / 2.0
        
        return ComplexNumber.fromPolar(r: sqrtR, theta: halfTheta)
    }
    
    /// Natural exponential: e^z = e^a × (cos(b) + i·sin(b))
    func exp() -> ComplexNumber {
        let expReal = Foundation.exp(real)
        return ComplexNumber(
            real: expReal * Foundation.cos(imaginary),
            imaginary: expReal * Foundation.sin(imaginary)
        )
    }
    
    /// Natural logarithm: ln(z) = ln|z| + i·arg(z)
    func ln() throws -> ComplexNumber {
        guard !isZero else {
            throw CalculatorError.domainError("Logarithm of zero is undefined")
        }
        
        return ComplexNumber(
            real: Foundation.log(magnitude),
            imaginary: argument
        )
    }
    
    /// Complex sine: sin(z) = sin(a)cosh(b) + i·cos(a)sinh(b)
    func sin() -> ComplexNumber {
        ComplexNumber(
            real: Foundation.sin(real) * Foundation.cosh(imaginary),
            imaginary: Foundation.cos(real) * Foundation.sinh(imaginary)
        )
    }
    
    /// Complex cosine: cos(z) = cos(a)cosh(b) - i·sin(a)sinh(b)
    func cos() -> ComplexNumber {
        ComplexNumber(
            real: Foundation.cos(real) * Foundation.cosh(imaginary),
            imaginary: -Foundation.sin(real) * Foundation.sinh(imaginary)
        )
    }
    
    /// Complex tangent: tan(z) = sin(z) / cos(z)
    func tan() throws -> ComplexNumber {
        let sinZ = self.sin()
        let cosZ = self.cos()
        
        guard !cosZ.isZero else {
            throw CalculatorError.domainError("Tangent undefined (cosine is zero)")
        }
        
        return try sinZ / cosZ
    }
    
    /// Complex hyperbolic sine: sinh(z) = sinh(a)cos(b) + i·cosh(a)sin(b)
    func complexSinh() -> ComplexNumber {
        ComplexNumber(
            real: Foundation.sinh(real) * Foundation.cos(imaginary),
            imaginary: Foundation.cosh(real) * Foundation.sin(imaginary)
        )
    }
    
    /// Complex hyperbolic cosine: cosh(z) = cosh(a)cos(b) + i·sinh(a)sin(b)
    func complexCosh() -> ComplexNumber {
        ComplexNumber(
            real: Foundation.cosh(real) * Foundation.cos(imaginary),
            imaginary: Foundation.sinh(real) * Foundation.sin(imaginary)
        )
    }
    
    /// Complex hyperbolic tangent: tanh(z) = sinh(z) / cosh(z)
    func tanh() throws -> ComplexNumber {
        let sinhZ = self.complexSinh()
        let coshZ = self.complexCosh()
        
        guard !coshZ.isZero else {
            throw CalculatorError.domainError("Hyperbolic tangent undefined")
        }
        
        return try sinhZ / coshZ
    }
}

// MARK: - Display and Conversion

extension ComplexNumber: CustomStringConvertible {
    
    /// Rectangular form string: "a + bi" or "a - bi"
    var description: String {
        if isZero {
            return "0"
        }
        
        if isReal {
            return formatNumber(real)
        }
        
        if isPureImaginary {
            if abs(imaginary - 1) < Self.epsilon {
                return "i"
            } else if abs(imaginary + 1) < Self.epsilon {
                return "-i"
            }
            return "\(formatNumber(imaginary))i"
        }
        
        let realStr = formatNumber(real)
        let absImaginary = abs(imaginary)
        
        if abs(absImaginary - 1) < Self.epsilon {
            if imaginary > 0 {
                return "\(realStr) + i"
            } else {
                return "\(realStr) - i"
            }
        }
        
        if imaginary > 0 {
            return "\(realStr) + \(formatNumber(absImaginary))i"
        } else {
            return "\(realStr) - \(formatNumber(absImaginary))i"
        }
    }
    
    /// Polar form string: "r∠θ" where θ is in specified angle mode
    func polarDescription(angleMode: AngleMode) -> String {
        let r = magnitude
        let thetaRadians = argument
        
        let theta: Double
        let unit: String
        
        switch angleMode {
        case .degrees:
            theta = thetaRadians * 180.0 / .pi
            unit = "°"
        case .radians:
            theta = thetaRadians
            unit = " rad"
        case .gradians:
            theta = thetaRadians * 200.0 / .pi
            unit = " gon"
        }
        
        return "\(formatNumber(r))∠\(formatNumber(theta))\(unit)"
    }
    
    /// Returns the real part as Double (for converting real results)
    func toDouble() -> Double? {
        if isReal {
            return real
        }
        return nil
    }
    
    /// Formats a number for display, removing unnecessary decimal places
    private func formatNumber(_ value: Double) -> String {
        if value == floor(value) && abs(value) < 1e10 {
            return String(format: "%.0f", value)
        }
        
        let formatted = String(format: "%.10g", value)
        return formatted
    }
}

// MARK: - Parsing

extension ComplexNumber {
    
    /// Parses a complex number from string
    /// Supports formats: "3+4i", "3-4i", "5i", "3", "2∠45°"
    static func parse(_ string: String) throws -> ComplexNumber {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else {
            throw CalculatorError.syntaxError("Empty complex number string")
        }
        
        // Check for polar format: "r∠θ" or "r∠θ°"
        if let angleIndex = trimmed.firstIndex(of: "∠") {
            return try parsePolar(trimmed, angleIndex: angleIndex)
        }
        
        // Check for pure imaginary "i" or "-i"
        if trimmed == "i" {
            return ComplexNumber.i
        }
        if trimmed == "-i" {
            return -ComplexNumber.i
        }
        
        // Check for pure imaginary like "5i" or "-3.14i"
        if trimmed.hasSuffix("i") {
            let numberPart = String(trimmed.dropLast())
            if let imagValue = Double(numberPart) {
                return ComplexNumber(real: 0, imaginary: imagValue)
            }
        }
        
        // Try to parse as rectangular form "a+bi" or "a-bi"
        if let result = parseRectangular(trimmed) {
            return result
        }
        
        // Try to parse as a simple real number
        if let realValue = Double(trimmed) {
            return ComplexNumber(realValue)
        }
        
        throw CalculatorError.syntaxError("Invalid complex number format: \(string)")
    }
    
    /// Parses polar format "r∠θ" or "r∠θ°"
    private static func parsePolar(_ string: String, angleIndex: String.Index) throws -> ComplexNumber {
        let rString = String(string[..<angleIndex]).trimmingCharacters(in: .whitespaces)
        var thetaString = String(string[string.index(after: angleIndex)...]).trimmingCharacters(in: .whitespaces)
        
        guard let r = Double(rString) else {
            throw CalculatorError.syntaxError("Invalid magnitude in polar form")
        }
        
        var angleInRadians = true
        
        // Check for degree symbol
        if thetaString.hasSuffix("°") {
            thetaString = String(thetaString.dropLast())
            angleInRadians = false
        } else if thetaString.hasSuffix("rad") {
            thetaString = String(thetaString.dropLast(3)).trimmingCharacters(in: .whitespaces)
            angleInRadians = true
        } else if thetaString.hasSuffix("gon") || thetaString.hasSuffix("grad") {
            let suffix = thetaString.hasSuffix("grad") ? 4 : 3
            thetaString = String(thetaString.dropLast(suffix)).trimmingCharacters(in: .whitespaces)
            if let theta = Double(thetaString) {
                let thetaRadians = theta * .pi / 200.0
                return ComplexNumber.fromPolar(r: r, theta: thetaRadians)
            }
        }
        
        guard let theta = Double(thetaString) else {
            throw CalculatorError.syntaxError("Invalid angle in polar form")
        }
        
        let thetaRadians = angleInRadians ? theta : (theta * .pi / 180.0)
        return ComplexNumber.fromPolar(r: r, theta: thetaRadians)
    }
    
    /// Parses rectangular form "a+bi" or "a-bi"
    private static func parseRectangular(_ string: String) -> ComplexNumber? {
        let str = string
        var realPart: Double = 0
        var imagPart: Double = 0
        
        // Find the last + or - that isn't at the start (and isn't part of an exponent)
        var lastOpIndex: String.Index?
        var isAddition = true
        var index = str.startIndex
        var previousChar: Character?
        
        while index < str.endIndex {
            let char = str[index]
            
            if (char == "+" || char == "-") && index != str.startIndex {
                let prevChar = previousChar ?? " "
                if prevChar != "e" && prevChar != "E" {
                    lastOpIndex = index
                    isAddition = (char == "+")
                }
            }
            
            previousChar = char
            index = str.index(after: index)
        }
        
        guard let opIndex = lastOpIndex else {
            return nil
        }
        
        let realStr = String(str[..<opIndex]).trimmingCharacters(in: .whitespaces)
        var imagStr = String(str[str.index(after: opIndex)...]).trimmingCharacters(in: .whitespaces)
        
        guard imagStr.hasSuffix("i") else {
            return nil
        }
        
        imagStr = String(imagStr.dropLast()).trimmingCharacters(in: .whitespaces)
        
        if imagStr.isEmpty {
            imagStr = "1"
        }
        
        guard let real = Double(realStr) else {
            return nil
        }
        
        guard let imag = Double(imagStr) else {
            return nil
        }
        
        realPart = real
        imagPart = isAddition ? imag : -imag
        
        return ComplexNumber(real: realPart, imaginary: imagPart)
    }
}

