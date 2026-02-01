import Foundation
import SwiftUI
import UIKit

/// Service for accessibility features
@Observable
class AccessibilityService {
    
    // MARK: - Singleton
    
    static let shared = AccessibilityService()
    
    // MARK: - System Accessibility States
    
    /// Whether VoiceOver is running
    var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }
    
    /// Whether reduce motion is enabled
    var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled || SettingsManager.shared.settings.reduceMotion
    }
    
    /// Whether bold text is enabled
    var isBoldTextEnabled: Bool {
        UIAccessibility.isBoldTextEnabled || SettingsManager.shared.settings.boldText
    }
    
    /// Whether reduce transparency is enabled
    var isReduceTransparencyEnabled: Bool {
        UIAccessibility.isReduceTransparencyEnabled
    }
    
    /// Whether larger accessibility sizes are enabled
    var isLargerTextEnabled: Bool {
        UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
    }
    
    /// Current content size category
    var contentSizeCategory: UIContentSizeCategory {
        UIApplication.shared.preferredContentSizeCategory
    }
    
    // MARK: - Initialization
    
    private init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.accessibilityStatusChanged()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.accessibilityStatusChanged()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.boldTextStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.accessibilityStatusChanged()
        }
    }
    
    private func accessibilityStatusChanged() {
        // Trigger UI updates
    }
    
    // MARK: - VoiceOver Labels
    
    /// Creates an accessibility label for a number button
    func labelForNumber(_ number: Int) -> String {
        return "\(number)"
    }
    
    /// Creates an accessibility label for an operator
    func labelForOperator(_ op: String) -> String {
        switch op {
        case "+": return "plus"
        case "−", "-": return "minus"
        case "×", "*": return "times"
        case "÷", "/": return "divided by"
        case "^": return "to the power of"
        case "√": return "square root"
        case "∛": return "cube root"
        case "!": return "factorial"
        case "%": return "percent"
        case "(": return "open parenthesis"
        case ")": return "close parenthesis"
        case "=": return "equals"
        case "π": return "pi"
        case "e": return "euler's number"
        case "i": return "imaginary unit"
        default: return op
        }
    }
    
    /// Creates an accessibility label for a function
    func labelForFunction(_ function: String) -> String {
        switch function.lowercased() {
        case "sin": return "sine"
        case "cos": return "cosine"
        case "tan": return "tangent"
        case "asin", "sin⁻¹": return "arc sine"
        case "acos", "cos⁻¹": return "arc cosine"
        case "atan", "tan⁻¹": return "arc tangent"
        case "sinh": return "hyperbolic sine"
        case "cosh": return "hyperbolic cosine"
        case "tanh": return "hyperbolic tangent"
        case "asinh", "sinh⁻¹": return "inverse hyperbolic sine"
        case "acosh", "cosh⁻¹": return "inverse hyperbolic cosine"
        case "atanh", "tanh⁻¹": return "inverse hyperbolic tangent"
        case "log": return "logarithm base 10"
        case "ln": return "natural logarithm"
        case "exp": return "e to the power"
        case "abs": return "absolute value"
        case "floor": return "floor"
        case "ceil": return "ceiling"
        case "round": return "round"
        case "npr": return "permutations"
        case "ncr": return "combinations"
        case "gcd": return "greatest common divisor"
        case "lcm": return "least common multiple"
        default: return function
        }
    }
    
    /// Creates an accessibility label for a mode
    func labelForMode(_ mode: String) -> String {
        switch mode.lowercased() {
        case "calculate": return "Scientific Calculator mode"
        case "complex": return "Complex Number mode"
        case "matrix": return "Matrix mode"
        case "vector": return "Vector mode"
        case "statistics": return "Statistics mode"
        case "distribution": return "Probability Distribution mode"
        case "base-n", "basen": return "Base N mode for number conversions"
        case "equation": return "Equation Solver mode"
        case "inequality": return "Inequality Solver mode"
        case "table": return "Function Table mode"
        case "ratio": return "Ratio and Proportion mode"
        case "spreadsheet": return "Spreadsheet mode"
        default: return "\(mode) mode"
        }
    }
    
    /// Creates an accessibility label for an expression
    func labelForExpression(_ expression: String) -> String {
        var result = expression
        
        // Replace operators with words
        result = result.replacingOccurrences(of: "+", with: " plus ")
        result = result.replacingOccurrences(of: "-", with: " minus ")
        result = result.replacingOccurrences(of: "−", with: " minus ")
        result = result.replacingOccurrences(of: "*", with: " times ")
        result = result.replacingOccurrences(of: "×", with: " times ")
        result = result.replacingOccurrences(of: "/", with: " divided by ")
        result = result.replacingOccurrences(of: "÷", with: " divided by ")
        result = result.replacingOccurrences(of: "^", with: " to the power of ")
        result = result.replacingOccurrences(of: "√", with: " square root of ")
        result = result.replacingOccurrences(of: "(", with: " open parenthesis ")
        result = result.replacingOccurrences(of: ")", with: " close parenthesis ")
        result = result.replacingOccurrences(of: "π", with: " pi ")
        
        // Clean up whitespace
        result = result.replacingOccurrences(of: "  ", with: " ")
        
        return result.trimmingCharacters(in: .whitespaces)
    }
    
    /// Creates an accessibility label for a result
    func labelForResult(_ result: String, isError: Bool) -> String {
        if isError {
            return "Error: \(result)"
        }
        
        var spoken = result
        
        // Handle scientific notation
        if spoken.contains("×10^") {
            spoken = spoken.replacingOccurrences(of: "×10^", with: " times 10 to the power of ")
        }
        if spoken.contains("e+") || spoken.contains("E+") {
            spoken = spoken.replacingOccurrences(of: "e+", with: " times 10 to the power of ")
            spoken = spoken.replacingOccurrences(of: "E+", with: " times 10 to the power of ")
        }
        if spoken.contains("e-") || spoken.contains("E-") {
            spoken = spoken.replacingOccurrences(of: "e-", with: " times 10 to the power of negative ")
            spoken = spoken.replacingOccurrences(of: "E-", with: " times 10 to the power of negative ")
        }
        
        // Handle complex numbers
        if spoken.contains("i") && !spoken.contains("in") {
            spoken = spoken.replacingOccurrences(of: "i", with: " i ")
        }
        
        // Handle fractions
        if spoken.contains("/") {
            spoken = spoken.replacingOccurrences(of: "/", with: " over ")
        }
        
        return "Result: \(spoken)"
    }
    
    // MARK: - Announcements
    
    /// Announces a message via VoiceOver
    func announce(_ message: String, delay: TimeInterval = 0.1) {
        guard isVoiceOverRunning else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
    
    /// Announces calculation result
    func announceResult(_ result: String, isError: Bool) {
        let message = labelForResult(result, isError: isError)
        announce(message)
    }
    
    /// Announces mode change
    func announceModeChange(_ mode: String) {
        let message = "Switched to \(labelForMode(mode))"
        announce(message)
    }
    
    /// Announces screen change
    func announceScreenChange() {
        guard isVoiceOverRunning else { return }
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }
    
    /// Announces layout change
    func announceLayoutChange(_ element: Any? = nil) {
        guard isVoiceOverRunning else { return }
        UIAccessibility.post(notification: .layoutChanged, argument: element)
    }
    
    // MARK: - Font Scaling
    
    /// Returns scaled font based on accessibility settings
    func scaledFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        // Apply user's font size preference
        let scaleFactor = SettingsManager.shared.settings.fontSize.scaleFactor
        let scaledSize = size * scaleFactor
        
        // Apply bold if needed
        let finalWeight = isBoldTextEnabled ? .bold : weight
        
        return UIFont.systemFont(ofSize: scaledSize, weight: finalWeight)
    }
    
    /// Returns monospaced font for numbers
    func monospacedFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let scaleFactor = SettingsManager.shared.settings.fontSize.scaleFactor
        let scaledSize = size * scaleFactor
        let finalWeight = isBoldTextEnabled ? .bold : weight
        
        return UIFont.monospacedDigitSystemFont(ofSize: scaledSize, weight: finalWeight)
    }
    
    // MARK: - Animation
    
    /// Returns appropriate animation duration respecting reduce motion
    var animationDuration: Double {
        isReduceMotionEnabled ? 0 : 0.3
    }
    
    /// Returns appropriate animation
    func animation(_ animation: Animation = .default) -> Animation? {
        isReduceMotionEnabled ? nil : animation
    }
}

// MARK: - SwiftUI Extensions

extension View {
    /// Adds accessibility label for calculator buttons
    func calculatorButtonAccessibility(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = .isButton
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
    
    /// Adds accessibility for expression display
    func expressionAccessibility(_ expression: String) -> some View {
        let service = AccessibilityService.shared
        return self
            .accessibilityLabel(service.labelForExpression(expression))
            .accessibilityHint("Current expression")
    }
    
    /// Adds accessibility for result display
    func resultAccessibility(_ result: String, isError: Bool) -> some View {
        let service = AccessibilityService.shared
        return self
            .accessibilityLabel(service.labelForResult(result, isError: isError))
    }
    
    /// Conditionally applies animation based on reduce motion
    func accessibleAnimation<V: Equatable>(_ animation: Animation? = .default, value: V) -> some View {
        self.animation(
            AccessibilityService.shared.isReduceMotionEnabled ? nil : animation,
            value: value
        )
    }
}
