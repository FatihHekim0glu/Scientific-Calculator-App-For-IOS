import Foundation
import SwiftUI

// MARK: - AngleUnit

/// Angle unit for trigonometric calculations
enum AngleUnit: String, CaseIterable, Codable {
    case degrees = "DEG"
    case radians = "RAD"
    case gradians = "GRAD"
    
    /// Conversion factor to radians
    var toRadiansFactor: Double {
        switch self {
        case .degrees: return .pi / 180.0
        case .radians: return 1.0
        case .gradians: return .pi / 200.0
        }
    }
    
    /// Converts value to radians
    func toRadians(_ value: Double) -> Double {
        value * toRadiansFactor
    }
    
    /// Converts radians to this unit
    func fromRadians(_ radians: Double) -> Double {
        radians / toRadiansFactor
    }
    
    /// Display symbol
    var symbol: String { rawValue }
}

// MARK: - NumberFormat

/// Number display format
enum NumberFormat: Codable, Equatable {
    case norm1           // Normal 1: scientific for |x| < 10^-2 or |x| >= 10^10
    case norm2           // Normal 2: scientific for |x| < 10^-9 or |x| >= 10^10
    case fix(Int)        // Fixed decimal places (0-9)
    case sci(Int)        // Scientific notation (0-9 sig figs)
    case eng             // Engineering notation (exponent multiple of 3)
    
    var displayName: String {
        switch self {
        case .norm1: return "Norm1"
        case .norm2: return "Norm2"
        case .fix(let n): return "Fix\(n)"
        case .sci(let n): return "Sci\(n)"
        case .eng: return "Eng"
        }
    }
    
    /// Formats a number according to this format
    func format(_ value: Double) -> String {
        guard value.isFinite else {
            if value.isNaN { return "Error" }
            return value > 0 ? "∞" : "-∞"
        }
        
        switch self {
        case .norm1:
            let absVal = abs(value)
            if absVal == 0 { return "0" }
            if absVal < 1e-2 || absVal >= 1e10 {
                return formatScientific(value, significantDigits: 10)
            }
            return formatNormal(value)
            
        case .norm2:
            let absVal = abs(value)
            if absVal == 0 { return "0" }
            if absVal < 1e-9 || absVal >= 1e10 {
                return formatScientific(value, significantDigits: 10)
            }
            return formatNormal(value)
            
        case .fix(let places):
            return String(format: "%.\(places)f", value)
            
        case .sci(let digits):
            return formatScientific(value, significantDigits: digits)
            
        case .eng:
            return formatEngineering(value)
        }
    }
    
    private func formatNormal(_ value: Double) -> String {
        if value == floor(value) && abs(value) < 1e10 {
            return String(format: "%.0f", value)
        }
        let formatted = String(format: "%.10g", value)
        return formatted
    }
    
    private func formatScientific(_ value: Double, significantDigits: Int) -> String {
        guard value != 0 else { return "0" }
        let exponent = floor(log10(abs(value)))
        let mantissa = value / pow(10, exponent)
        let format = "%.\(max(0, significantDigits - 1))f×10^%.0f"
        return String(format: format, mantissa, exponent)
    }
    
    private func formatEngineering(_ value: Double) -> String {
        guard value != 0 else { return "0" }
        var exponent = floor(log10(abs(value)))
        // Round exponent down to multiple of 3
        exponent = floor(exponent / 3) * 3
        let mantissa = value / pow(10, exponent)
        if exponent == 0 {
            return String(format: "%.6g", mantissa)
        }
        return String(format: "%.6g×10^%.0f", mantissa, exponent)
    }
}

// MARK: - FractionFormat

/// Fraction display format
enum FractionFormat: String, CaseIterable, Codable {
    case improper = "d/c"      // Improper fraction: 5/3
    case mixed = "ab/c"        // Mixed number: 1 2/3
    case decimal = "Decimal"   // Decimal: 1.666...
    
    var displayName: String { rawValue }
}

// MARK: - ComplexFormat

/// Complex number display format
enum ComplexFormat: String, CaseIterable, Codable {
    case rectangular = "a+bi"   // Rectangular: 3+4i
    case polar = "r∠θ"          // Polar: 5∠53.13°
    
    var displayName: String { rawValue }
}

// MARK: - ThemeMode

/// App theme mode
enum ThemeMode: String, CaseIterable, Codable {
    case light = "Light"
    case dark = "Dark"
    case system = "Auto"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - FontSizePreference

/// Font size preference
enum FontSizePreference: String, CaseIterable, Codable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var scaleFactor: CGFloat {
        switch self {
        case .small: return 0.85
        case .medium: return 1.0
        case .large: return 1.2
        }
    }
}

// MARK: - CalculatorSettings

/// All calculator settings
struct CalculatorSettings: Codable, Equatable {
    // Calculation settings
    var angleUnit: AngleUnit = .degrees
    var numberFormat: NumberFormat = .norm1
    var fractionFormat: FractionFormat = .improper
    var complexFormat: ComplexFormat = .rectangular
    var equationSolutions: EquationSolutionType = .realAndComplex
    var decimalSeparator: DecimalSeparator = .dot
    var thousandsSeparator: Bool = false
    
    // Display settings
    var theme: ThemeMode = .system
    var accentColorHex: String = "#007AFF"  // Default iOS blue
    var fontSize: FontSizePreference = .medium
    var hapticFeedback: Bool = true
    var soundEnabled: Bool = false
    
    // Accessibility
    var reduceMotion: Bool = false
    var boldText: Bool = false
    
    enum EquationSolutionType: String, Codable, CaseIterable {
        case realOnly = "Real Only"
        case realAndComplex = "Real + Complex"
    }
    
    enum DecimalSeparator: String, Codable, CaseIterable {
        case dot = "."
        case comma = ","
    }
}

// MARK: - SettingsManager

/// Manages calculator settings with persistence
@Observable
class SettingsManager {
    
    // MARK: - Singleton
    
    static let shared = SettingsManager()
    
    // MARK: - Settings
    
    private(set) var settings: CalculatorSettings {
        didSet {
            saveSettings()
        }
    }
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let settings = "com.calculator.settings"
    }
    
    // MARK: - Initialization
    
    private init() {
        self.settings = Self.loadSettings()
    }
    
    // MARK: - Persistence
    
    private static func loadSettings() -> CalculatorSettings {
        guard let data = UserDefaults.standard.data(forKey: Keys.settings),
              let settings = try? JSONDecoder().decode(CalculatorSettings.self, from: data) else {
            return CalculatorSettings()
        }
        return settings
    }
    
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: Keys.settings)
        }
    }
    
    // MARK: - Calculation Settings
    
    func setAngleUnit(_ unit: AngleUnit) {
        settings.angleUnit = unit
    }
    
    func setNumberFormat(_ format: NumberFormat) {
        settings.numberFormat = format
    }
    
    func setFractionFormat(_ format: FractionFormat) {
        settings.fractionFormat = format
    }
    
    func setComplexFormat(_ format: ComplexFormat) {
        settings.complexFormat = format
    }
    
    func setEquationSolutions(_ type: CalculatorSettings.EquationSolutionType) {
        settings.equationSolutions = type
    }
    
    func setDecimalSeparator(_ separator: CalculatorSettings.DecimalSeparator) {
        settings.decimalSeparator = separator
    }
    
    func setThousandsSeparator(_ enabled: Bool) {
        settings.thousandsSeparator = enabled
    }
    
    // MARK: - Display Settings
    
    func setTheme(_ theme: ThemeMode) {
        settings.theme = theme
    }
    
    func setAccentColor(_ hex: String) {
        settings.accentColorHex = hex
    }
    
    func setFontSize(_ size: FontSizePreference) {
        settings.fontSize = size
    }
    
    func setHapticFeedback(_ enabled: Bool) {
        settings.hapticFeedback = enabled
    }
    
    func setSoundEnabled(_ enabled: Bool) {
        settings.soundEnabled = enabled
    }
    
    // MARK: - Accessibility
    
    func setReduceMotion(_ enabled: Bool) {
        settings.reduceMotion = enabled
    }
    
    func setBoldText(_ enabled: Bool) {
        settings.boldText = enabled
    }
    
    // MARK: - Format Helpers
    
    /// Formats a number using current settings
    func formatNumber(_ value: Double) -> String {
        var result = settings.numberFormat.format(value)
        
        // Apply decimal separator
        if settings.decimalSeparator == .comma {
            result = result.replacingOccurrences(of: ".", with: ",")
        }
        
        // Apply thousands separator (basic implementation)
        if settings.thousandsSeparator {
            result = applyThousandsSeparator(result)
        }
        
        return result
    }
    
    private func applyThousandsSeparator(_ str: String) -> String {
        // Basic implementation - separate integer part with spaces
        let parts = str.split(separator: settings.decimalSeparator == .dot ? "." : ",", maxSplits: 1)
        guard let intPart = parts.first else { return str }
        
        var intStr = String(intPart)
        let isNegative = intStr.hasPrefix("-")
        if isNegative { intStr.removeFirst() }
        
        var result = ""
        for (i, char) in intStr.reversed().enumerated() {
            if i > 0 && i % 3 == 0 {
                result = " " + result
            }
            result = String(char) + result
        }
        
        if isNegative { result = "-" + result }
        
        if parts.count > 1 {
            let sep = settings.decimalSeparator == .dot ? "." : ","
            result += sep + parts[1]
        }
        
        return result
    }
    
    // MARK: - Reset
    
    /// Resets all settings to defaults
    func resetToDefaults() {
        settings = CalculatorSettings()
    }
}
