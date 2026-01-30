import Foundation

// MARK: - AngleMode

/// Angle measurement modes for the calculator
enum AngleMode: String, CaseIterable, Identifiable {
    case degrees = "DEG"
    case radians = "RAD"
    case gradians = "GRAD"
    
    var id: String { rawValue }
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .degrees: return "Degrees"
        case .radians: return "Radians"
        case .gradians: return "Gradians"
        }
    }
    
    /// Converts radians to the current angle mode
    func fromRadians(_ radians: Double) -> Double {
        switch self {
        case .degrees:
            return radians * 180.0 / .pi
        case .radians:
            return radians
        case .gradians:
            return radians * 200.0 / .pi
        }
    }
    
    /// Converts from current angle mode to radians
    func toRadians(_ value: Double) -> Double {
        switch self {
        case .degrees:
            return value * .pi / 180.0
        case .radians:
            return value
        case .gradians:
            return value * .pi / 200.0
        }
    }
}

// MARK: - DMS (Degrees, Minutes, Seconds)

/// Represents an angle in degrees, minutes, seconds format
struct DMS: Equatable {
    let degrees: Int
    let minutes: Int
    let seconds: Double
    let isNegative: Bool
    
    // MARK: - Initialization
    
    init(degrees: Int, minutes: Int, seconds: Double, isNegative: Bool = false) {
        self.degrees = abs(degrees)
        self.minutes = abs(minutes)
        self.seconds = abs(seconds)
        self.isNegative = isNegative
    }
    
    /// Creates DMS from decimal degrees
    init(decimalDegrees: Double) {
        let isNeg = decimalDegrees < 0
        let absValue = abs(decimalDegrees)
        
        let deg = Int(absValue)
        let minDecimal = (absValue - Double(deg)) * 60.0
        let min = Int(minDecimal)
        let sec = (minDecimal - Double(min)) * 60.0
        
        self.degrees = deg
        self.minutes = min
        self.seconds = sec
        self.isNegative = isNeg
    }
    
    // MARK: - Conversion
    
    /// Converts to decimal degrees
    var decimalDegrees: Double {
        let value = Double(degrees) + Double(minutes) / 60.0 + seconds / 3600.0
        return isNegative ? -value : value
    }
    
    // MARK: - Formatting
    
    /// String representation: 45°30'15.5" or -45°30'15.5"
    var formatted: String {
        let sign = isNegative ? "-" : ""
        let secFormatted = seconds.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", seconds)
            : String(format: "%.2f", seconds)
        return "\(sign)\(degrees)°\(minutes)'\(secFormatted)\""
    }
}

// MARK: - Angle Conversions

/// Static methods for angle unit conversions
struct AngleConversions {
    
    // MARK: - Unit Conversions
    
    /// Degrees to radians
    static func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    
    /// Radians to degrees
    static func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
    
    /// Degrees to gradians
    static func degreesToGradians(_ degrees: Double) -> Double {
        return degrees * 10.0 / 9.0
    }
    
    /// Gradians to degrees
    static func gradiansToDegrees(_ gradians: Double) -> Double {
        return gradians * 9.0 / 10.0
    }
    
    /// Radians to gradians
    static func radiansToGradians(_ radians: Double) -> Double {
        return radians * 200.0 / .pi
    }
    
    /// Gradians to radians
    static func gradiansToRadians(_ gradians: Double) -> Double {
        return gradians * .pi / 200.0
    }
    
    // MARK: - DMS Conversions
    
    /// Decimal degrees to DMS
    static func decimalToDMS(_ decimal: Double) -> DMS {
        return DMS(decimalDegrees: decimal)
    }
    
    /// DMS to decimal degrees
    /// - Parameters:
    ///   - degrees: Degrees component (sign determines overall sign)
    ///   - minutes: Minutes component (always positive)
    ///   - seconds: Seconds component (always positive)
    /// - Returns: Decimal degrees representation
    static func dmsToDecimal(degrees: Double, minutes: Double, seconds: Double) -> Double {
        let isNegative = degrees < 0
        let absDegrees = abs(degrees)
        let value = absDegrees + minutes / 60.0 + seconds / 3600.0
        return isNegative ? -value : value
    }
    
    /// Parse DMS from encoded format (e.g., 45.3015 = 45°30'15")
    /// The encoding format is: DD.MMSSss where DD = degrees, MM = minutes, SS = seconds, ss = fractional seconds
    static func parseDMSEncoded(_ encoded: Double) -> DMS {
        let isNegative = encoded < 0
        let absValue = abs(encoded)
        
        let degrees = Int(absValue)
        let fractional = absValue - Double(degrees)
        
        let minutesPart = fractional * 100
        let minutes = Int(minutesPart)
        
        let secondsPart = (minutesPart - Double(minutes)) * 100
        
        return DMS(degrees: degrees, minutes: minutes, seconds: secondsPart, isNegative: isNegative)
    }
    
    /// Encode DMS to format (45°30'15" = 45.3015)
    static func encodeDMS(_ dms: DMS) -> Double {
        let encoded = Double(dms.degrees) + Double(dms.minutes) / 100.0 + dms.seconds / 10000.0
        return dms.isNegative ? -encoded : encoded
    }
    
    // MARK: - Normalization
    
    /// Normalizes an angle to the range [0, 360) degrees
    static func normalizeDegrees(_ degrees: Double) -> Double {
        var result = degrees.truncatingRemainder(dividingBy: 360.0)
        if result < 0 {
            result += 360.0
        }
        return result
    }
    
    /// Normalizes an angle to the range [0, 2π) radians
    static func normalizeRadians(_ radians: Double) -> Double {
        var result = radians.truncatingRemainder(dividingBy: 2.0 * .pi)
        if result < 0 {
            result += 2.0 * .pi
        }
        return result
    }
    
    /// Normalizes an angle to the range [0, 400) gradians
    static func normalizeGradians(_ gradians: Double) -> Double {
        var result = gradians.truncatingRemainder(dividingBy: 400.0)
        if result < 0 {
            result += 400.0
        }
        return result
    }
}

// MARK: - Coordinate Conversions

/// Coordinate system conversions between rectangular and polar forms
struct CoordinateConversions {
    
    /// Result of polar conversion
    struct PolarResult: Equatable {
        let r: Double       // Magnitude
        let theta: Double   // Angle (in the specified angle mode)
    }
    
    /// Result of rectangular conversion
    struct RectangularResult: Equatable {
        let x: Double
        let y: Double
    }
    
    /// Rectangular (x, y) to polar (r, θ)
    /// - Parameters:
    ///   - x: X coordinate
    ///   - y: Y coordinate
    ///   - angleMode: Current angle mode for theta output
    /// - Returns: Polar coordinates with r (magnitude) and theta (angle in specified mode)
    static func rectangularToPolar(x: Double, y: Double, angleMode: AngleMode) -> PolarResult {
        let r = sqrt(x * x + y * y)
        
        // Handle special cases
        if x == 0 && y == 0 {
            return PolarResult(r: 0, theta: 0)
        }
        
        // atan2 returns radians in range (-π, π]
        let thetaRadians = atan2(y, x)
        
        // Convert to the appropriate angle mode
        let theta: Double
        switch angleMode {
        case .degrees:
            theta = AngleConversions.radiansToDegrees(thetaRadians)
        case .radians:
            theta = thetaRadians
        case .gradians:
            theta = AngleConversions.radiansToGradians(thetaRadians)
        }
        
        return PolarResult(r: r, theta: theta)
    }
    
    /// Polar (r, θ) to rectangular (x, y)
    /// - Parameters:
    ///   - r: Magnitude
    ///   - theta: Angle in the specified mode
    ///   - angleMode: Angle mode of theta input
    /// - Returns: Rectangular coordinates (x, y)
    static func polarToRectangular(r: Double, theta: Double, angleMode: AngleMode) -> RectangularResult {
        // Convert theta to radians
        let thetaRadians: Double
        switch angleMode {
        case .degrees:
            thetaRadians = AngleConversions.degreesToRadians(theta)
        case .radians:
            thetaRadians = theta
        case .gradians:
            thetaRadians = AngleConversions.gradiansToRadians(theta)
        }
        
        let x = r * cos(thetaRadians)
        let y = r * sin(thetaRadians)
        
        return RectangularResult(x: x, y: y)
    }
}
