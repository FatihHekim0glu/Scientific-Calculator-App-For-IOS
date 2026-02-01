import XCTest
@testable import ScientificCalculatorAppForIOS

final class SettingsManagerTests: XCTestCase {
    
    // MARK: - Angle Unit Tests
    
    func test_AngleUnit_ToRadians_Degrees() {
        let degrees = AngleUnit.degrees
        XCTAssertEqual(degrees.toRadians(180), .pi, accuracy: 1e-10)
        XCTAssertEqual(degrees.toRadians(90), .pi / 2, accuracy: 1e-10)
        XCTAssertEqual(degrees.toRadians(0), 0, accuracy: 1e-10)
        XCTAssertEqual(degrees.toRadians(360), 2 * .pi, accuracy: 1e-10)
        XCTAssertEqual(degrees.toRadians(45), .pi / 4, accuracy: 1e-10)
    }
    
    func test_AngleUnit_ToRadians_Radians() {
        let radians = AngleUnit.radians
        XCTAssertEqual(radians.toRadians(.pi), .pi, accuracy: 1e-10)
        XCTAssertEqual(radians.toRadians(1), 1, accuracy: 1e-10)
        XCTAssertEqual(radians.toRadians(0), 0, accuracy: 1e-10)
        XCTAssertEqual(radians.toRadians(2 * .pi), 2 * .pi, accuracy: 1e-10)
    }
    
    func test_AngleUnit_ToRadians_Gradians() {
        let gradians = AngleUnit.gradians
        XCTAssertEqual(gradians.toRadians(200), .pi, accuracy: 1e-10)
        XCTAssertEqual(gradians.toRadians(100), .pi / 2, accuracy: 1e-10)
        XCTAssertEqual(gradians.toRadians(0), 0, accuracy: 1e-10)
        XCTAssertEqual(gradians.toRadians(400), 2 * .pi, accuracy: 1e-10)
    }
    
    func test_AngleUnit_FromRadians_Degrees() {
        let degrees = AngleUnit.degrees
        XCTAssertEqual(degrees.fromRadians(.pi), 180, accuracy: 1e-10)
        XCTAssertEqual(degrees.fromRadians(.pi / 2), 90, accuracy: 1e-10)
        XCTAssertEqual(degrees.fromRadians(0), 0, accuracy: 1e-10)
    }
    
    func test_AngleUnit_FromRadians_Radians() {
        let radians = AngleUnit.radians
        XCTAssertEqual(radians.fromRadians(.pi), .pi, accuracy: 1e-10)
        XCTAssertEqual(radians.fromRadians(1), 1, accuracy: 1e-10)
    }
    
    func test_AngleUnit_FromRadians_Gradians() {
        let gradians = AngleUnit.gradians
        XCTAssertEqual(gradians.fromRadians(.pi), 200, accuracy: 1e-10)
        XCTAssertEqual(gradians.fromRadians(.pi / 2), 100, accuracy: 1e-10)
    }
    
    func test_AngleUnit_Symbol() {
        XCTAssertEqual(AngleUnit.degrees.symbol, "DEG")
        XCTAssertEqual(AngleUnit.radians.symbol, "RAD")
        XCTAssertEqual(AngleUnit.gradians.symbol, "GRAD")
    }
    
    func test_AngleUnit_AllCases() {
        XCTAssertEqual(AngleUnit.allCases.count, 3)
        XCTAssertTrue(AngleUnit.allCases.contains(.degrees))
        XCTAssertTrue(AngleUnit.allCases.contains(.radians))
        XCTAssertTrue(AngleUnit.allCases.contains(.gradians))
    }
    
    // MARK: - Number Format Tests
    
    func test_NumberFormat_Norm1_SmallNumber() {
        let format = NumberFormat.norm1
        let result = format.format(0.001)
        XCTAssertTrue(result.contains("10^"))
    }
    
    func test_NumberFormat_Norm1_NormalNumber() {
        let format = NumberFormat.norm1
        let result = format.format(123.456)
        XCTAssertFalse(result.contains("10^"))
    }
    
    func test_NumberFormat_Norm1_LargeNumber() {
        let format = NumberFormat.norm1
        let result = format.format(1e11)
        XCTAssertTrue(result.contains("10^"))
    }
    
    func test_NumberFormat_Norm1_Zero() {
        let format = NumberFormat.norm1
        XCTAssertEqual(format.format(0), "0")
    }
    
    func test_NumberFormat_Norm2_SmallNumber() {
        let format = NumberFormat.norm2
        let result = format.format(0.001)
        XCTAssertFalse(result.contains("10^"))
    }
    
    func test_NumberFormat_Norm2_VerySmallNumber() {
        let format = NumberFormat.norm2
        let result = format.format(1e-10)
        XCTAssertTrue(result.contains("10^"))
    }
    
    func test_NumberFormat_Fix_DecimalPlaces() {
        let format0 = NumberFormat.fix(0)
        XCTAssertEqual(format0.format(3.14159), "3")
        
        let format2 = NumberFormat.fix(2)
        XCTAssertEqual(format2.format(3.14159), "3.14")
        XCTAssertEqual(format2.format(1.0), "1.00")
        
        let format4 = NumberFormat.fix(4)
        XCTAssertEqual(format4.format(3.14159), "3.1416")
    }
    
    func test_NumberFormat_Sci_Scientific() {
        let format = NumberFormat.sci(3)
        let result = format.format(1234.5)
        XCTAssertTrue(result.contains("10^"))
    }
    
    func test_NumberFormat_Sci_Zero() {
        let format = NumberFormat.sci(3)
        XCTAssertEqual(format.format(0), "0")
    }
    
    func test_NumberFormat_Eng_MultipleOf3() {
        let format = NumberFormat.eng
        let result = format.format(1500)
        XCTAssertTrue(result.contains("10^3") || !result.contains("10^"))
    }
    
    func test_NumberFormat_Eng_Zero() {
        let format = NumberFormat.eng
        XCTAssertEqual(format.format(0), "0")
    }
    
    func test_NumberFormat_HandlesInfinity() {
        let format = NumberFormat.norm1
        XCTAssertEqual(format.format(.infinity), "∞")
        XCTAssertEqual(format.format(-.infinity), "-∞")
    }
    
    func test_NumberFormat_HandlesNaN() {
        let format = NumberFormat.norm1
        XCTAssertEqual(format.format(.nan), "Error")
    }
    
    func test_NumberFormat_DisplayName() {
        XCTAssertEqual(NumberFormat.norm1.displayName, "Norm1")
        XCTAssertEqual(NumberFormat.norm2.displayName, "Norm2")
        XCTAssertEqual(NumberFormat.fix(3).displayName, "Fix3")
        XCTAssertEqual(NumberFormat.sci(5).displayName, "Sci5")
        XCTAssertEqual(NumberFormat.eng.displayName, "Eng")
    }
    
    // MARK: - Fraction Format Tests
    
    func test_FractionFormat_DisplayName() {
        XCTAssertEqual(FractionFormat.improper.displayName, "d/c")
        XCTAssertEqual(FractionFormat.mixed.displayName, "ab/c")
        XCTAssertEqual(FractionFormat.decimal.displayName, "Decimal")
    }
    
    func test_FractionFormat_AllCases() {
        XCTAssertEqual(FractionFormat.allCases.count, 3)
    }
    
    // MARK: - Complex Format Tests
    
    func test_ComplexFormat_DisplayName() {
        XCTAssertEqual(ComplexFormat.rectangular.displayName, "a+bi")
        XCTAssertEqual(ComplexFormat.polar.displayName, "r∠θ")
    }
    
    func test_ComplexFormat_AllCases() {
        XCTAssertEqual(ComplexFormat.allCases.count, 2)
    }
    
    // MARK: - Theme Mode Tests
    
    func test_ThemeMode_ColorScheme() {
        XCTAssertEqual(ThemeMode.light.colorScheme, .light)
        XCTAssertEqual(ThemeMode.dark.colorScheme, .dark)
        XCTAssertNil(ThemeMode.system.colorScheme)
    }
    
    func test_ThemeMode_RawValue() {
        XCTAssertEqual(ThemeMode.light.rawValue, "Light")
        XCTAssertEqual(ThemeMode.dark.rawValue, "Dark")
        XCTAssertEqual(ThemeMode.system.rawValue, "Auto")
    }
    
    // MARK: - Font Size Preference Tests
    
    func test_FontSizePreference_ScaleFactor() {
        XCTAssertEqual(FontSizePreference.small.scaleFactor, 0.85)
        XCTAssertEqual(FontSizePreference.medium.scaleFactor, 1.0)
        XCTAssertEqual(FontSizePreference.large.scaleFactor, 1.2)
    }
    
    func test_FontSizePreference_RawValue() {
        XCTAssertEqual(FontSizePreference.small.rawValue, "Small")
        XCTAssertEqual(FontSizePreference.medium.rawValue, "Medium")
        XCTAssertEqual(FontSizePreference.large.rawValue, "Large")
    }
    
    // MARK: - Calculator Settings Tests
    
    func test_Settings_DefaultValues() {
        let settings = CalculatorSettings()
        XCTAssertEqual(settings.angleUnit, .degrees)
        XCTAssertEqual(settings.numberFormat, .norm1)
        XCTAssertEqual(settings.fractionFormat, .improper)
        XCTAssertEqual(settings.complexFormat, .rectangular)
        XCTAssertEqual(settings.equationSolutions, .realAndComplex)
        XCTAssertEqual(settings.decimalSeparator, .dot)
        XCTAssertFalse(settings.thousandsSeparator)
        XCTAssertEqual(settings.theme, .system)
        XCTAssertEqual(settings.accentColorHex, "#007AFF")
        XCTAssertEqual(settings.fontSize, .medium)
        XCTAssertTrue(settings.hapticFeedback)
        XCTAssertFalse(settings.soundEnabled)
        XCTAssertFalse(settings.reduceMotion)
        XCTAssertFalse(settings.boldText)
    }
    
    func test_Settings_Encoding() throws {
        let settings = CalculatorSettings()
        let encoder = JSONEncoder()
        let data = try encoder.encode(settings)
        XCTAssertFalse(data.isEmpty)
    }
    
    func test_Settings_Decoding() throws {
        let original = CalculatorSettings()
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(CalculatorSettings.self, from: data)
        
        XCTAssertEqual(original, decoded)
    }
    
    func test_Settings_Equality() {
        let settings1 = CalculatorSettings()
        var settings2 = CalculatorSettings()
        
        XCTAssertEqual(settings1, settings2)
        
        settings2.angleUnit = .radians
        XCTAssertNotEqual(settings1, settings2)
    }
    
    func test_Settings_EquationSolutionType_AllCases() {
        XCTAssertEqual(CalculatorSettings.EquationSolutionType.allCases.count, 2)
        XCTAssertTrue(CalculatorSettings.EquationSolutionType.allCases.contains(.realOnly))
        XCTAssertTrue(CalculatorSettings.EquationSolutionType.allCases.contains(.realAndComplex))
    }
    
    func test_Settings_DecimalSeparator_AllCases() {
        XCTAssertEqual(CalculatorSettings.DecimalSeparator.allCases.count, 2)
        XCTAssertTrue(CalculatorSettings.DecimalSeparator.allCases.contains(.dot))
        XCTAssertTrue(CalculatorSettings.DecimalSeparator.allCases.contains(.comma))
    }
    
    // MARK: - Settings Manager Tests
    
    func test_SettingsManager_Singleton() {
        let manager1 = SettingsManager.shared
        let manager2 = SettingsManager.shared
        XCTAssertTrue(manager1 === manager2)
    }
    
    func test_SettingsManager_ResetToDefaults() {
        let manager = SettingsManager.shared
        
        manager.setAngleUnit(.radians)
        manager.setTheme(.dark)
        
        manager.resetToDefaults()
        
        XCTAssertEqual(manager.settings.angleUnit, .degrees)
        XCTAssertEqual(manager.settings.theme, .system)
    }
    
    func test_SettingsManager_SetAngleUnit() {
        let manager = SettingsManager.shared
        
        manager.setAngleUnit(.gradians)
        XCTAssertEqual(manager.settings.angleUnit, .gradians)
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetNumberFormat() {
        let manager = SettingsManager.shared
        
        manager.setNumberFormat(.fix(3))
        XCTAssertEqual(manager.settings.numberFormat, .fix(3))
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetFractionFormat() {
        let manager = SettingsManager.shared
        
        manager.setFractionFormat(.mixed)
        XCTAssertEqual(manager.settings.fractionFormat, .mixed)
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetComplexFormat() {
        let manager = SettingsManager.shared
        
        manager.setComplexFormat(.polar)
        XCTAssertEqual(manager.settings.complexFormat, .polar)
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetTheme() {
        let manager = SettingsManager.shared
        
        manager.setTheme(.dark)
        XCTAssertEqual(manager.settings.theme, .dark)
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetAccentColor() {
        let manager = SettingsManager.shared
        
        manager.setAccentColor("#FF0000")
        XCTAssertEqual(manager.settings.accentColorHex, "#FF0000")
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetFontSize() {
        let manager = SettingsManager.shared
        
        manager.setFontSize(.large)
        XCTAssertEqual(manager.settings.fontSize, .large)
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetHapticFeedback() {
        let manager = SettingsManager.shared
        
        manager.setHapticFeedback(false)
        XCTAssertFalse(manager.settings.hapticFeedback)
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetSoundEnabled() {
        let manager = SettingsManager.shared
        
        manager.setSoundEnabled(true)
        XCTAssertTrue(manager.settings.soundEnabled)
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetReduceMotion() {
        let manager = SettingsManager.shared
        
        manager.setReduceMotion(true)
        XCTAssertTrue(manager.settings.reduceMotion)
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetBoldText() {
        let manager = SettingsManager.shared
        
        manager.setBoldText(true)
        XCTAssertTrue(manager.settings.boldText)
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetDecimalSeparator() {
        let manager = SettingsManager.shared
        
        manager.setDecimalSeparator(.comma)
        XCTAssertEqual(manager.settings.decimalSeparator, .comma)
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetThousandsSeparator() {
        let manager = SettingsManager.shared
        
        manager.setThousandsSeparator(true)
        XCTAssertTrue(manager.settings.thousandsSeparator)
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_SetEquationSolutions() {
        let manager = SettingsManager.shared
        
        manager.setEquationSolutions(.realOnly)
        XCTAssertEqual(manager.settings.equationSolutions, .realOnly)
        
        manager.resetToDefaults()
    }
    
    // MARK: - Format Number Tests
    
    func test_SettingsManager_FormatNumber_Basic() {
        let manager = SettingsManager.shared
        manager.resetToDefaults()
        
        let result = manager.formatNumber(123.456)
        XCTAssertFalse(result.isEmpty)
    }
    
    func test_SettingsManager_FormatNumber_WithCommaSeparator() {
        let manager = SettingsManager.shared
        manager.setDecimalSeparator(.comma)
        
        let result = manager.formatNumber(123.456)
        XCTAssertTrue(result.contains(","))
        
        manager.resetToDefaults()
    }
    
    func test_SettingsManager_FormatNumber_WithThousandsSeparator() {
        let manager = SettingsManager.shared
        manager.setThousandsSeparator(true)
        manager.setNumberFormat(.fix(0))
        
        let result = manager.formatNumber(1234567)
        XCTAssertTrue(result.contains(" "))
        
        manager.resetToDefaults()
    }
    
    // MARK: - Angle Conversion Round Trip Tests
    
    func test_AngleUnit_RoundTrip_Degrees() {
        let degrees = AngleUnit.degrees
        let original: Double = 45
        let radians = degrees.toRadians(original)
        let back = degrees.fromRadians(radians)
        XCTAssertEqual(original, back, accuracy: 1e-10)
    }
    
    func test_AngleUnit_RoundTrip_Gradians() {
        let gradians = AngleUnit.gradians
        let original: Double = 50
        let radians = gradians.toRadians(original)
        let back = gradians.fromRadians(radians)
        XCTAssertEqual(original, back, accuracy: 1e-10)
    }
}
