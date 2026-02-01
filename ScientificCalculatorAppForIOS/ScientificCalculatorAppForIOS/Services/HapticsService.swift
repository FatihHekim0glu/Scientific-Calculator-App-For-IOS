import Foundation
import UIKit
import CoreHaptics

/// Service for haptic feedback
class HapticsService {
    
    // MARK: - Singleton
    
    static let shared = HapticsService()
    
    // MARK: - Properties
    
    /// Whether haptics are enabled (respects settings)
    var isEnabled: Bool {
        SettingsManager.shared.settings.hapticFeedback
    }
    
    /// Core Haptics engine
    private var engine: CHHapticEngine?
    
    /// Whether device supports haptics
    private(set) var supportsHaptics: Bool = false
    
    // MARK: - Initialization
    
    private init() {
        setupHaptics()
    }
    
    private func setupHaptics() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        
        guard supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Handle engine reset
            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
            
            // Handle engine stopped
            engine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
            }
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    // MARK: - Basic Haptics
    
    /// Light impact feedback (for button taps)
    func lightImpact() {
        guard isEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Medium impact feedback (for significant actions)
    func mediumImpact() {
        guard isEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Heavy impact feedback (for major actions)
    func heavyImpact() {
        guard isEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Soft impact (for subtle feedback)
    func softImpact() {
        guard isEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Rigid impact (for firm feedback)
    func rigidImpact() {
        guard isEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Notification Haptics
    
    /// Success notification
    func success() {
        guard isEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Warning notification
    func warning() {
        guard isEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Error notification
    func error() {
        guard isEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Selection Haptics
    
    /// Selection changed (for pickers, sliders)
    func selectionChanged() {
        guard isEnabled else { return }
        
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // MARK: - Calculator-Specific Haptics
    
    /// Button press feedback
    func buttonPress() {
        lightImpact()
    }
    
    /// Operator button press (slightly stronger)
    func operatorPress() {
        mediumImpact()
    }
    
    /// Equals/Execute press (distinct feel)
    func executePress() {
        rigidImpact()
    }
    
    /// Clear/Delete press
    func clearPress() {
        softImpact()
    }
    
    /// Calculation complete with result
    func calculationComplete() {
        success()
    }
    
    /// Calculation error
    func calculationError() {
        error()
    }
    
    /// Mode changed
    func modeChanged() {
        selectionChanged()
    }
    
    /// Memory stored/recalled
    func memoryAction() {
        mediumImpact()
    }
    
    // MARK: - Custom Patterns
    
    /// Double tap pattern
    func doubleTap() {
        guard isEnabled, supportsHaptics, let engine = engine else {
            // Fallback to basic haptics
            lightImpact()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.lightImpact()
            }
            return
        }
        
        do {
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
            
            let tap1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [sharpness, intensity],
                relativeTime: 0
            )
            let tap2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [sharpness, intensity],
                relativeTime: 0.1
            )
            
            let pattern = try CHHapticPattern(events: [tap1, tap2], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            // Fallback
            lightImpact()
        }
    }
    
    /// Confirmation pattern (success with flourish)
    func confirmation() {
        guard isEnabled, supportsHaptics, let engine = engine else {
            success()
            return
        }
        
        do {
            let intensity1 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let intensity2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            
            let event1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity1, sharpness],
                relativeTime: 0
            )
            let event2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity2, sharpness],
                relativeTime: 0.15
            )
            
            let pattern = try CHHapticPattern(events: [event1, event2], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            success()
        }
    }
    
    /// Error pattern (warning pulse)
    func errorPattern() {
        guard isEnabled, supportsHaptics, let engine = engine else {
            error()
            return
        }
        
        do {
            var events: [CHHapticEvent] = []
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            
            for i in 0..<3 {
                let intensity = CHHapticEventParameter(
                    parameterID: .hapticIntensity,
                    value: Float(1.0 - Double(i) * 0.2)
                )
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: Double(i) * 0.1
                )
                events.append(event)
            }
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            error()
        }
    }
    
    // MARK: - Cleanup
    
    /// Stop the haptic engine (call when app goes to background)
    func stopEngine() {
        engine?.stop()
    }
    
    /// Restart the haptic engine (call when app becomes active)
    func restartEngine() {
        guard supportsHaptics else { return }
        
        do {
            try engine?.start()
        } catch {
            print("Failed to restart haptic engine: \(error)")
        }
    }
}
