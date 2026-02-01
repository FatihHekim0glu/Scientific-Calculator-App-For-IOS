import Foundation
import SwiftUI

/// App color theme
struct ColorTheme {
    
    // MARK: - Semantic Colors
    
    /// Primary accent color
    let accent: Color
    
    /// Background colors
    let background: Color
    let secondaryBackground: Color
    let tertiaryBackground: Color
    
    /// Text colors
    let primaryText: Color
    let secondaryText: Color
    let tertiaryText: Color
    
    /// Button colors by category
    let numberButton: ButtonColors
    let operatorButton: ButtonColors
    let functionButton: ButtonColors
    let memoryButton: ButtonColors
    let specialButton: ButtonColors
    let equalsButton: ButtonColors
    let clearButton: ButtonColors
    
    /// Status colors
    let success: Color
    let warning: Color
    let error: Color
    
    /// Display colors
    let displayBackground: Color
    let displayText: Color
    let displaySecondaryText: Color
    let cursorColor: Color
    
    // MARK: - Button Colors Struct
    
    struct ButtonColors {
        let background: Color
        let foreground: Color
        let pressedBackground: Color
        let border: Color?
        
        init(
            background: Color,
            foreground: Color,
            pressedBackground: Color? = nil,
            border: Color? = nil
        ) {
            self.background = background
            self.foreground = foreground
            self.pressedBackground = pressedBackground ?? background.opacity(0.8)
            self.border = border
        }
    }
}

// MARK: - Predefined Themes

extension ColorTheme {
    
    /// Light theme
    static let light = ColorTheme(
        accent: Color(hex: "#007AFF"),
        
        background: Color(hex: "#F2F2F7"),
        secondaryBackground: Color(hex: "#FFFFFF"),
        tertiaryBackground: Color(hex: "#E5E5EA"),
        
        primaryText: Color(hex: "#000000"),
        secondaryText: Color(hex: "#3C3C43").opacity(0.6),
        tertiaryText: Color(hex: "#3C3C43").opacity(0.3),
        
        numberButton: ButtonColors(
            background: Color(hex: "#FFFFFF"),
            foreground: Color(hex: "#000000"),
            border: Color(hex: "#E5E5EA")
        ),
        operatorButton: ButtonColors(
            background: Color(hex: "#FF9500"),
            foreground: Color(hex: "#FFFFFF")
        ),
        functionButton: ButtonColors(
            background: Color(hex: "#D1D1D6"),
            foreground: Color(hex: "#000000")
        ),
        memoryButton: ButtonColors(
            background: Color(hex: "#34C759"),
            foreground: Color(hex: "#FFFFFF")
        ),
        specialButton: ButtonColors(
            background: Color(hex: "#5856D6"),
            foreground: Color(hex: "#FFFFFF")
        ),
        equalsButton: ButtonColors(
            background: Color(hex: "#007AFF"),
            foreground: Color(hex: "#FFFFFF")
        ),
        clearButton: ButtonColors(
            background: Color(hex: "#FF3B30"),
            foreground: Color(hex: "#FFFFFF")
        ),
        
        success: Color(hex: "#34C759"),
        warning: Color(hex: "#FF9500"),
        error: Color(hex: "#FF3B30"),
        
        displayBackground: Color(hex: "#FFFFFF"),
        displayText: Color(hex: "#000000"),
        displaySecondaryText: Color(hex: "#8E8E93"),
        cursorColor: Color(hex: "#007AFF")
    )
    
    /// Dark theme
    static let dark = ColorTheme(
        accent: Color(hex: "#0A84FF"),
        
        background: Color(hex: "#000000"),
        secondaryBackground: Color(hex: "#1C1C1E"),
        tertiaryBackground: Color(hex: "#2C2C2E"),
        
        primaryText: Color(hex: "#FFFFFF"),
        secondaryText: Color(hex: "#EBEBF5").opacity(0.6),
        tertiaryText: Color(hex: "#EBEBF5").opacity(0.3),
        
        numberButton: ButtonColors(
            background: Color(hex: "#333333"),
            foreground: Color(hex: "#FFFFFF")
        ),
        operatorButton: ButtonColors(
            background: Color(hex: "#FF9F0A"),
            foreground: Color(hex: "#FFFFFF")
        ),
        functionButton: ButtonColors(
            background: Color(hex: "#505050"),
            foreground: Color(hex: "#FFFFFF")
        ),
        memoryButton: ButtonColors(
            background: Color(hex: "#30D158"),
            foreground: Color(hex: "#FFFFFF")
        ),
        specialButton: ButtonColors(
            background: Color(hex: "#5E5CE6"),
            foreground: Color(hex: "#FFFFFF")
        ),
        equalsButton: ButtonColors(
            background: Color(hex: "#0A84FF"),
            foreground: Color(hex: "#FFFFFF")
        ),
        clearButton: ButtonColors(
            background: Color(hex: "#FF453A"),
            foreground: Color(hex: "#FFFFFF")
        ),
        
        success: Color(hex: "#30D158"),
        warning: Color(hex: "#FF9F0A"),
        error: Color(hex: "#FF453A"),
        
        displayBackground: Color(hex: "#1C1C1E"),
        displayText: Color(hex: "#FFFFFF"),
        displaySecondaryText: Color(hex: "#8E8E93"),
        cursorColor: Color(hex: "#0A84FF")
    )
    
    /// Returns theme for current color scheme
    static func forScheme(_ scheme: ColorScheme?) -> ColorTheme {
        switch scheme {
        case .dark:
            return .dark
        default:
            return .light
        }
    }
}

// MARK: - Theme Manager

@Observable
class ThemeManager {
    
    // MARK: - Singleton
    
    static let shared = ThemeManager()
    
    // MARK: - Properties
    
    /// Current theme
    private(set) var currentTheme: ColorTheme = .light
    
    /// Custom accent color (if set)
    var customAccentColor: Color? {
        didSet {
            updateTheme()
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        updateTheme()
    }
    
    // MARK: - Update Theme
    
    /// Updates theme based on settings and color scheme
    func updateForColorScheme(_ scheme: ColorScheme) {
        let settings = SettingsManager.shared.settings
        
        switch settings.theme {
        case .light:
            currentTheme = .light
        case .dark:
            currentTheme = .dark
        case .system:
            currentTheme = ColorTheme.forScheme(scheme)
        }
        
        // Apply custom accent if set
        if let accentHex = customAccentColor {
            currentTheme = currentTheme.withAccent(accentHex)
        } else if !settings.accentColorHex.isEmpty {
            currentTheme = currentTheme.withAccent(Color(hex: settings.accentColorHex))
        }
    }
    
    private func updateTheme() {
        // Will be called when accent changes
    }
}

// MARK: - Theme Extension

extension ColorTheme {
    /// Creates a copy with a different accent color
    func withAccent(_ accent: Color) -> ColorTheme {
        ColorTheme(
            accent: accent,
            background: background,
            secondaryBackground: secondaryBackground,
            tertiaryBackground: tertiaryBackground,
            primaryText: primaryText,
            secondaryText: secondaryText,
            tertiaryText: tertiaryText,
            numberButton: numberButton,
            operatorButton: operatorButton,
            functionButton: functionButton,
            memoryButton: memoryButton,
            specialButton: specialButton,
            equalsButton: ButtonColors(
                background: accent,
                foreground: equalsButton.foreground
            ),
            clearButton: clearButton,
            success: success,
            warning: warning,
            error: error,
            displayBackground: displayBackground,
            displayText: displayText,
            displaySecondaryText: displaySecondaryText,
            cursorColor: accent
        )
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Converts color to hex string
    var hexString: String {
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }
        
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Environment Key

struct ThemeKey: EnvironmentKey {
    static let defaultValue: ColorTheme = .light
}

extension EnvironmentValues {
    var theme: ColorTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    /// Applies current theme to environment
    func withTheme(_ theme: ColorTheme) -> some View {
        self.environment(\.theme, theme)
    }
}
