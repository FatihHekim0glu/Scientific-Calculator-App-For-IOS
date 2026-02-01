import Foundation

// MARK: - NumberBase

/// Supported number bases for Base-N mode
enum NumberBase: Int, CaseIterable, Identifiable {
    case binary = 2
    case octal = 8
    case decimal = 10
    case hexadecimal = 16
    
    var id: Int { rawValue }
    
    /// Display name for UI
    var name: String {
        switch self {
        case .binary: return "BIN"
        case .octal: return "OCT"
        case .decimal: return "DEC"
        case .hexadecimal: return "HEX"
        }
    }
    
    /// Full display name
    var fullName: String {
        switch self {
        case .binary: return "Binary"
        case .octal: return "Octal"
        case .decimal: return "Decimal"
        case .hexadecimal: return "Hexadecimal"
        }
    }
    
    /// Valid digit characters for this base
    var validDigits: String {
        switch self {
        case .binary: return "01"
        case .octal: return "01234567"
        case .decimal: return "0123456789"
        case .hexadecimal: return "0123456789ABCDEFabcdef"
        }
    }
    
    /// Prefix used for number literals
    var prefix: String {
        switch self {
        case .binary: return "0b"
        case .octal: return "0o"
        case .decimal: return ""
        case .hexadecimal: return "0x"
        }
    }
    
    /// Number of bits needed per digit
    var bitsPerDigit: Int {
        switch self {
        case .binary: return 1
        case .octal: return 3
        case .decimal: return 0  // Not applicable
        case .hexadecimal: return 4
        }
    }
    
    /// Maximum digits typically displayed for this base (32-bit)
    var maxDisplayDigits: Int {
        switch self {
        case .binary: return 32
        case .octal: return 11
        case .decimal: return 10
        case .hexadecimal: return 8
        }
    }
    
    /// Creates a NumberBase from its name string
    static func fromName(_ name: String) -> NumberBase? {
        let lowercased = name.lowercased()
        switch lowercased {
        case "bin", "binary": return .binary
        case "oct", "octal": return .octal
        case "dec", "decimal": return .decimal
        case "hex", "hexadecimal": return .hexadecimal
        default: return nil
        }
    }
}

// MARK: - BaseNNumber

/// Represents a number in Base-N mode (32-bit signed integer)
struct BaseNNumber: Equatable, Hashable {
    
    // MARK: - Properties
    
    /// The numeric value as 32-bit signed integer
    let value: Int32
    
    /// The display base
    let base: NumberBase
    
    /// Valid range for 32-bit signed integer
    static let minValue: Int32 = Int32.min  // -2147483648
    static let maxValue: Int32 = Int32.max  // 2147483647
    
    // MARK: - Initialization
    
    /// Creates a BaseNNumber from an Int32 value
    init(_ value: Int32, base: NumberBase = .decimal) {
        self.value = value
        self.base = base
    }
    
    /// Creates a BaseNNumber from an Int value
    /// - Throws: CalculatorError.overflow if out of 32-bit range
    init(_ value: Int, base: NumberBase = .decimal) throws {
        guard value >= Int(Int32.min) && value <= Int(Int32.max) else {
            throw CalculatorError.overflow
        }
        self.value = Int32(value)
        self.base = base
    }
    
    /// Creates a BaseNNumber from a Double (truncates to Int32)
    /// - Throws: CalculatorError.overflow if out of 32-bit range
    init(_ value: Double, base: NumberBase = .decimal) throws {
        guard value >= Double(Int32.min) && value <= Double(Int32.max) else {
            throw CalculatorError.overflow
        }
        self.value = Int32(value)
        self.base = base
    }
    
    /// Parses a string in the specified base
    /// Returns nil if the string contains invalid characters
    init?(string: String, base: NumberBase) {
        guard let parsed = try? BaseNArithmetic.parse(string, base: base) else {
            return nil
        }
        self.value = parsed
        self.base = base
    }
    
    // MARK: - Conversion
    
    /// Returns this number displayed in a different base
    func convert(to newBase: NumberBase) -> BaseNNumber {
        BaseNNumber(value, base: newBase)
    }
    
    /// Returns string representation in the current base
    func toString() -> String {
        BaseNArithmetic.format(value, base: base)
    }
    
    /// Returns string representation in specified base
    func toString(in base: NumberBase, minDigits: Int = 0) -> String {
        BaseNArithmetic.format(value, base: base, minDigits: minDigits)
    }
    
    /// Returns string with base prefix
    func toStringWithPrefix() -> String {
        base.prefix + toString()
    }
    
    /// Returns as Double for use with calculator engine
    var doubleValue: Double {
        Double(value)
    }
    
    /// Returns the unsigned representation
    var unsignedValue: UInt32 {
        UInt32(bitPattern: value)
    }
}

// MARK: - BaseNNumber Arithmetic Operations

extension BaseNNumber {
    
    // MARK: - Basic Arithmetic (wrapping)
    
    /// Addition with 32-bit wraparound
    static func + (lhs: BaseNNumber, rhs: BaseNNumber) -> BaseNNumber {
        let result = lhs.value &+ rhs.value
        return BaseNNumber(result, base: lhs.base)
    }
    
    /// Subtraction with 32-bit wraparound
    static func - (lhs: BaseNNumber, rhs: BaseNNumber) -> BaseNNumber {
        let result = lhs.value &- rhs.value
        return BaseNNumber(result, base: lhs.base)
    }
    
    /// Multiplication with 32-bit wraparound
    static func * (lhs: BaseNNumber, rhs: BaseNNumber) -> BaseNNumber {
        let result = lhs.value &* rhs.value
        return BaseNNumber(result, base: lhs.base)
    }
    
    /// Integer division
    /// - Throws: CalculatorError.divisionByZero if rhs is zero
    static func / (lhs: BaseNNumber, rhs: BaseNNumber) throws -> BaseNNumber {
        guard rhs.value != 0 else {
            throw CalculatorError.divisionByZero
        }
        let result = lhs.value / rhs.value
        return BaseNNumber(result, base: lhs.base)
    }
    
    /// Remainder/modulo
    /// - Throws: CalculatorError.divisionByZero if rhs is zero
    static func % (lhs: BaseNNumber, rhs: BaseNNumber) throws -> BaseNNumber {
        guard rhs.value != 0 else {
            throw CalculatorError.divisionByZero
        }
        let result = lhs.value % rhs.value
        return BaseNNumber(result, base: lhs.base)
    }
    
    /// Negation (two's complement)
    static prefix func - (number: BaseNNumber) -> BaseNNumber {
        let result = -number.value
        return BaseNNumber(result, base: number.base)
    }
}

// MARK: - BaseNNumber Bitwise Operations

extension BaseNNumber {
    
    // MARK: - Bitwise Operations
    
    /// Bitwise AND
    static func & (lhs: BaseNNumber, rhs: BaseNNumber) -> BaseNNumber {
        let result = lhs.value & rhs.value
        return BaseNNumber(result, base: lhs.base)
    }
    
    /// Bitwise OR
    static func | (lhs: BaseNNumber, rhs: BaseNNumber) -> BaseNNumber {
        let result = lhs.value | rhs.value
        return BaseNNumber(result, base: lhs.base)
    }
    
    /// Bitwise XOR
    static func ^ (lhs: BaseNNumber, rhs: BaseNNumber) -> BaseNNumber {
        let result = lhs.value ^ rhs.value
        return BaseNNumber(result, base: lhs.base)
    }
    
    /// Bitwise XNOR (NOT XOR)
    static func xnor(_ lhs: BaseNNumber, _ rhs: BaseNNumber) -> BaseNNumber {
        let result = ~(lhs.value ^ rhs.value)
        return BaseNNumber(result, base: lhs.base)
    }
    
    /// Bitwise NOT (one's complement)
    static prefix func ~ (number: BaseNNumber) -> BaseNNumber {
        let result = ~number.value
        return BaseNNumber(result, base: number.base)
    }
    
    /// Left shift
    static func << (lhs: BaseNNumber, rhs: Int) -> BaseNNumber {
        let shiftAmount = Swift.min(Swift.max(rhs, 0), 31)
        let result = lhs.value << shiftAmount
        return BaseNNumber(result, base: lhs.base)
    }
    
    /// Right shift (arithmetic, preserves sign)
    static func >> (lhs: BaseNNumber, rhs: Int) -> BaseNNumber {
        let shiftAmount = Swift.min(Swift.max(rhs, 0), 31)
        let result = lhs.value >> shiftAmount
        return BaseNNumber(result, base: lhs.base)
    }
    
    /// Logical right shift (zeros fill from left)
    func logicalRightShift(_ count: Int) -> BaseNNumber {
        let shiftAmount = Swift.min(Swift.max(count, 0), 31)
        let unsigned = UInt32(bitPattern: value)
        let result = unsigned >> shiftAmount
        return BaseNNumber(Int32(bitPattern: result), base: base)
    }
    
    /// Rotate left
    func rotateLeft(_ count: Int) -> BaseNNumber {
        let shiftAmount = count % 32
        let unsigned = UInt32(bitPattern: value)
        let result = (unsigned << shiftAmount) | (unsigned >> (32 - shiftAmount))
        return BaseNNumber(Int32(bitPattern: result), base: base)
    }
    
    /// Rotate right
    func rotateRight(_ count: Int) -> BaseNNumber {
        let shiftAmount = count % 32
        let unsigned = UInt32(bitPattern: value)
        let result = (unsigned >> shiftAmount) | (unsigned << (32 - shiftAmount))
        return BaseNNumber(Int32(bitPattern: result), base: base)
    }
}

// MARK: - BaseNNumber Comparison

extension BaseNNumber: Comparable {
    static func < (lhs: BaseNNumber, rhs: BaseNNumber) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - BaseNNumber Display

extension BaseNNumber: CustomStringConvertible {
    var description: String {
        "\(base.name): \(toString())"
    }
}

// MARK: - BaseNArithmetic Utility

/// Utility functions for Base-N operations
struct BaseNArithmetic {
    
    // MARK: - Conversion Functions
    
    /// Converts a string from one base to another
    static func convert(_ string: String, from sourceBase: NumberBase, to targetBase: NumberBase) throws -> String {
        let value = try parse(string, base: sourceBase)
        return format(value, base: targetBase)
    }
    
    /// Parses a number string in any base to Int32
    static func parse(_ string: String, base: NumberBase) throws -> Int32 {
        var trimmed = string.trimmingCharacters(in: .whitespaces)
        
        // Handle empty input
        guard !trimmed.isEmpty else {
            throw CalculatorError.syntaxError("Empty input")
        }
        
        // Remove base prefix if present
        let upperTrimmed = trimmed.uppercased()
        if upperTrimmed.hasPrefix("0B") && base == .binary {
            trimmed = String(trimmed.dropFirst(2))
        } else if upperTrimmed.hasPrefix("0O") && base == .octal {
            trimmed = String(trimmed.dropFirst(2))
        } else if upperTrimmed.hasPrefix("0X") && base == .hexadecimal {
            trimmed = String(trimmed.dropFirst(2))
        }
        
        // Handle empty after prefix removal
        guard !trimmed.isEmpty else {
            throw CalculatorError.syntaxError("No digits after prefix")
        }
        
        // Handle negative sign for decimal
        var isNegative = false
        if base == .decimal && trimmed.hasPrefix("-") {
            isNegative = true
            trimmed = String(trimmed.dropFirst())
        }
        
        // Validate digits
        let normalizedInput = trimmed.uppercased()
        guard isValid(normalizedInput, for: base) else {
            throw CalculatorError.syntaxError("Invalid digits for \(base.name)")
        }
        
        // Parse based on base type
        if base == .decimal {
            // For decimal, parse directly as signed
            guard let intValue = Int32(trimmed) else {
                throw CalculatorError.overflow
            }
            return isNegative ? -intValue : intValue
        } else {
            // For other bases, parse as unsigned then convert
            guard let unsigned = UInt32(normalizedInput, radix: base.rawValue) else {
                throw CalculatorError.overflow
            }
            return Int32(bitPattern: unsigned)
        }
    }
    
    /// Formats an Int32 as string in specified base
    static func format(_ value: Int32, base: NumberBase, minDigits: Int = 0) -> String {
        var result: String
        
        switch base {
        case .binary:
            let unsigned = UInt32(bitPattern: value)
            result = String(unsigned, radix: 2)
            
        case .octal:
            let unsigned = UInt32(bitPattern: value)
            result = String(unsigned, radix: 8)
            
        case .decimal:
            // Keep sign for decimal display
            result = String(value)
            
        case .hexadecimal:
            let unsigned = UInt32(bitPattern: value)
            result = String(unsigned, radix: 16).uppercased()
        }
        
        // Pad with leading zeros if needed (not for negative decimal)
        if base != .decimal || value >= 0 {
            if result.count < minDigits {
                result = String(repeating: "0", count: minDigits - result.count) + result
            }
        }
        
        return result
    }
    
    /// Formats with grouped digits for readability
    static func formatGrouped(_ value: Int32, base: NumberBase, groupSize: Int = 4) -> String {
        let raw = format(value, base: base)
        
        // Don't group decimal numbers
        if base == .decimal {
            return raw
        }
        
        // Group from right to left
        var result = ""
        var count = 0
        for char in raw.reversed() {
            if count > 0 && count % groupSize == 0 {
                result = " " + result
            }
            result = String(char) + result
            count += 1
        }
        
        return result
    }
    
    // MARK: - Validation
    
    /// Checks if a string is valid for the given base
    static func isValid(_ string: String, for base: NumberBase) -> Bool {
        let validChars = CharacterSet(charactersIn: base.validDigits)
        return string.uppercased().unicodeScalars.allSatisfy { validChars.contains($0) }
    }
    
    /// Returns the detected base from a prefixed string
    static func detectBase(_ string: String) -> NumberBase? {
        let upper = string.uppercased()
        if upper.hasPrefix("0B") {
            return .binary
        } else if upper.hasPrefix("0O") {
            return .octal
        } else if upper.hasPrefix("0X") {
            return .hexadecimal
        }
        return nil
    }
    
    /// Parses a string with automatic base detection
    static func parseWithAutoDetect(_ string: String) throws -> (value: Int32, base: NumberBase) {
        if let detectedBase = detectBase(string) {
            let value = try parse(string, base: detectedBase)
            return (value, detectedBase)
        } else {
            let value = try parse(string, base: .decimal)
            return (value, .decimal)
        }
    }
    
    // MARK: - Bitwise Function Versions
    
    /// AND operation
    static func and(_ a: Int32, _ b: Int32) -> Int32 {
        a & b
    }
    
    /// OR operation
    static func or(_ a: Int32, _ b: Int32) -> Int32 {
        a | b
    }
    
    /// XOR operation
    static func xor(_ a: Int32, _ b: Int32) -> Int32 {
        a ^ b
    }
    
    /// XNOR operation (NOT XOR)
    static func xnor(_ a: Int32, _ b: Int32) -> Int32 {
        ~(a ^ b)
    }
    
    /// NOT operation (one's complement)
    static func not(_ a: Int32) -> Int32 {
        ~a
    }
    
    /// NEG operation (two's complement negation)
    static func neg(_ a: Int32) -> Int32 {
        -a
    }
    
    /// Left shift
    static func leftShift(_ a: Int32, by count: Int) -> Int32 {
        let shiftAmount = Swift.min(Swift.max(count, 0), 31)
        return a << shiftAmount
    }
    
    /// Arithmetic right shift (preserves sign)
    static func rightShift(_ a: Int32, by count: Int) -> Int32 {
        let shiftAmount = Swift.min(Swift.max(count, 0), 31)
        return a >> shiftAmount
    }
    
    /// Logical right shift (zeros fill)
    static func logicalRightShift(_ a: Int32, by count: Int) -> Int32 {
        let shiftAmount = Swift.min(Swift.max(count, 0), 31)
        let unsigned = UInt32(bitPattern: a)
        return Int32(bitPattern: unsigned >> shiftAmount)
    }
    
    // MARK: - Bit Manipulation
    
    /// Returns the number of set bits (population count)
    static func popCount(_ a: Int32) -> Int {
        a.nonzeroBitCount
    }
    
    /// Returns the position of the highest set bit (0-indexed, -1 if zero)
    static func highestBit(_ a: Int32) -> Int {
        guard a != 0 else { return -1 }
        return 31 - a.leadingZeroBitCount
    }
    
    /// Returns the position of the lowest set bit (0-indexed, -1 if zero)
    static func lowestBit(_ a: Int32) -> Int {
        guard a != 0 else { return -1 }
        return a.trailingZeroBitCount
    }
    
    /// Tests if a specific bit is set
    static func testBit(_ a: Int32, bit: Int) -> Bool {
        guard bit >= 0 && bit < 32 else { return false }
        return (a & (1 << bit)) != 0
    }
    
    /// Sets a specific bit
    static func setBit(_ a: Int32, bit: Int) -> Int32 {
        guard bit >= 0 && bit < 32 else { return a }
        return a | (1 << bit)
    }
    
    /// Clears a specific bit
    static func clearBit(_ a: Int32, bit: Int) -> Int32 {
        guard bit >= 0 && bit < 32 else { return a }
        return a & ~(1 << bit)
    }
    
    /// Toggles a specific bit
    static func toggleBit(_ a: Int32, bit: Int) -> Int32 {
        guard bit >= 0 && bit < 32 else { return a }
        return a ^ (1 << bit)
    }
    
    /// Reverses all bits
    static func reverseBits(_ a: Int32) -> Int32 {
        var value = UInt32(bitPattern: a)
        var result: UInt32 = 0
        for _ in 0..<32 {
            result = (result << 1) | (value & 1)
            value >>= 1
        }
        return Int32(bitPattern: result)
    }
    
    // MARK: - Byte Operations
    
    /// Swaps the byte order (endianness)
    static func byteSwap(_ a: Int32) -> Int32 {
        Int32(bitPattern: UInt32(bitPattern: a).byteSwapped)
    }
    
    /// Extracts a byte at the given position (0 = least significant)
    static func getByte(_ a: Int32, at position: Int) -> UInt8 {
        guard position >= 0 && position < 4 else { return 0 }
        return UInt8(truncatingIfNeeded: UInt32(bitPattern: a) >> (position * 8))
    }
}

// MARK: - BaseNNumber Common Values

extension BaseNNumber {
    /// Zero value
    static let zero = BaseNNumber(Int32(0))
    
    /// One value
    static let one = BaseNNumber(Int32(1))
    
    /// All bits set (0xFFFFFFFF / -1)
    static let allOnes = BaseNNumber(Int32(-1))
    
    /// Maximum positive value
    static let maximum = BaseNNumber(Int32.max)
    
    /// Minimum value (most negative)
    static let minimum = BaseNNumber(Int32.min)
}
