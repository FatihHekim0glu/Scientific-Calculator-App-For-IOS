import SwiftUI

// MARK: - SettingsView

/// Main settings view
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var settings = SettingsManager.shared
    @State private var showResetConfirmation = false
    @State private var showClearHistoryConfirmation = false
    @State private var showClearMemoryConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                calculationSettingsSection
                displaySettingsSection
                accessibilitySection
                dataManagementSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Calculation Settings
    
    private var calculationSettingsSection: some View {
        Section {
            // Angle Unit
            Picker("Angle Unit", selection: Binding(
                get: { settings.settings.angleUnit },
                set: { settings.setAngleUnit($0) }
            )) {
                ForEach(AngleUnit.allCases, id: \.self) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
            
            // Number Format
            NavigationLink {
                NumberFormatPicker(
                    selection: Binding(
                        get: { settings.settings.numberFormat },
                        set: { settings.setNumberFormat($0) }
                    )
                )
            } label: {
                HStack {
                    Text("Number Format")
                    Spacer()
                    Text(settings.settings.numberFormat.displayName)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Fraction Format
            Picker("Fraction Display", selection: Binding(
                get: { settings.settings.fractionFormat },
                set: { settings.setFractionFormat($0) }
            )) {
                ForEach(FractionFormat.allCases, id: \.self) { format in
                    Text(format.displayName).tag(format)
                }
            }
            
            // Complex Format
            Picker("Complex Numbers", selection: Binding(
                get: { settings.settings.complexFormat },
                set: { settings.setComplexFormat($0) }
            )) {
                ForEach(ComplexFormat.allCases, id: \.self) { format in
                    Text(format.displayName).tag(format)
                }
            }
            
            // Equation Solutions
            Picker("Equation Solutions", selection: Binding(
                get: { settings.settings.equationSolutions },
                set: { settings.setEquationSolutions($0) }
            )) {
                ForEach(CalculatorSettings.EquationSolutionType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            
            // Decimal Separator
            Picker("Decimal Point", selection: Binding(
                get: { settings.settings.decimalSeparator },
                set: { settings.setDecimalSeparator($0) }
            )) {
                ForEach(CalculatorSettings.DecimalSeparator.allCases, id: \.self) { sep in
                    Text(sep.rawValue == "." ? "Dot (.)" : "Comma (,)").tag(sep)
                }
            }
            
            // Thousands Separator
            Toggle("Thousands Separator", isOn: Binding(
                get: { settings.settings.thousandsSeparator },
                set: { settings.setThousandsSeparator($0) }
            ))
            
        } header: {
            Text("Calculation")
        } footer: {
            Text("These settings affect how calculations are performed and displayed.")
        }
    }
    
    // MARK: - Display Settings
    
    private var displaySettingsSection: some View {
        Section {
            // Theme
            Picker("Theme", selection: Binding(
                get: { settings.settings.theme },
                set: { settings.setTheme($0) }
            )) {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            
            // Accent Color
            NavigationLink {
                AccentColorPicker(
                    selectedHex: Binding(
                        get: { settings.settings.accentColorHex },
                        set: { settings.setAccentColor($0) }
                    )
                )
            } label: {
                HStack {
                    Text("Accent Color")
                    Spacer()
                    Circle()
                        .fill(Color(hex: settings.settings.accentColorHex))
                        .frame(width: 24, height: 24)
                }
            }
            
            // Font Size
            Picker("Font Size", selection: Binding(
                get: { settings.settings.fontSize },
                set: { settings.setFontSize($0) }
            )) {
                ForEach(FontSizePreference.allCases, id: \.self) { size in
                    Text(size.rawValue).tag(size)
                }
            }
            
            // Haptic Feedback
            Toggle("Haptic Feedback", isOn: Binding(
                get: { settings.settings.hapticFeedback },
                set: { settings.setHapticFeedback($0) }
            ))
            
            // Sound
            Toggle("Sound", isOn: Binding(
                get: { settings.settings.soundEnabled },
                set: { settings.setSoundEnabled($0) }
            ))
            
        } header: {
            Text("Display")
        }
    }
    
    // MARK: - Accessibility
    
    private var accessibilitySection: some View {
        Section {
            Toggle("Reduce Motion", isOn: Binding(
                get: { settings.settings.reduceMotion },
                set: { settings.setReduceMotion($0) }
            ))
            
            Toggle("Bold Text", isOn: Binding(
                get: { settings.settings.boldText },
                set: { settings.setBoldText($0) }
            ))
        } header: {
            Text("Accessibility")
        } footer: {
            Text("These settings complement system accessibility options.")
        }
    }
    
    // MARK: - Data Management
    
    private var dataManagementSection: some View {
        Section {
            Button(role: .destructive) {
                showClearMemoryConfirmation = true
            } label: {
                Label("Clear Memory", systemImage: "memorychip")
            }
            .confirmationDialog(
                "Clear Memory?",
                isPresented: $showClearMemoryConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Memory", role: .destructive) {
                    MemoryManager.shared.resetAll()
                    HapticsService.shared.warning()
                }
            } message: {
                Text("This will clear all stored variables (A-F, M, Ans).")
            }
            
            Button(role: .destructive) {
                showClearHistoryConfirmation = true
            } label: {
                Label("Clear History", systemImage: "clock.arrow.circlepath")
            }
            .confirmationDialog(
                "Clear History?",
                isPresented: $showClearHistoryConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All History", role: .destructive) {
                    HistoryManager.shared.clearAll()
                    HapticsService.shared.warning()
                }
            } message: {
                Text("This will delete all calculation history. This cannot be undone.")
            }
            
            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                Label("Reset All Settings", systemImage: "arrow.counterclockwise")
            }
            .confirmationDialog(
                "Reset All Settings?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset to Defaults", role: .destructive) {
                    settings.resetToDefaults()
                    HapticsService.shared.warning()
                }
            } message: {
                Text("This will reset all settings to their default values.")
            }
            
        } header: {
            Text("Data Management")
        }
    }
    
    // MARK: - About
    
    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("Build")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                    .foregroundStyle(.secondary)
            }
            
            Link(destination: URL(string: "https://example.com/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            
            Link(destination: URL(string: "https://example.com/terms")!) {
                Label("Terms of Service", systemImage: "doc.text")
            }
            
        } header: {
            Text("About")
        }
    }
}

// MARK: - Number Format Picker

struct NumberFormatPicker: View {
    @Binding var selection: NumberFormat
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section {
                FormatRow(title: "Normal 1", subtitle: "Scientific for very small/large", format: .norm1, selection: $selection)
                FormatRow(title: "Normal 2", subtitle: "More decimal places before scientific", format: .norm2, selection: $selection)
            }
            
            Section("Fixed Decimal Places") {
                ForEach(0...9, id: \.self) { places in
                    FormatRow(title: "Fix \(places)", subtitle: "\(places) decimal places", format: .fix(places), selection: $selection)
                }
            }
            
            Section("Scientific Notation") {
                ForEach(0...9, id: \.self) { digits in
                    FormatRow(title: "Sci \(digits)", subtitle: "\(digits) significant figures", format: .sci(digits), selection: $selection)
                }
            }
            
            Section {
                FormatRow(title: "Engineering", subtitle: "Exponents in multiples of 3", format: .eng, selection: $selection)
            }
        }
        .navigationTitle("Number Format")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Format Row

struct FormatRow: View {
    let title: String
    let subtitle: String
    let format: NumberFormat
    @Binding var selection: NumberFormat
    
    var body: some View {
        Button {
            selection = format
            HapticsService.shared.selectionChanged()
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if selection == format {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                }
            }
        }
    }
}

// MARK: - Accent Color Picker

struct AccentColorPicker: View {
    @Binding var selectedHex: String
    
    private let colors: [(name: String, hex: String)] = [
        ("Blue", "#007AFF"),
        ("Purple", "#5856D6"),
        ("Pink", "#FF2D55"),
        ("Red", "#FF3B30"),
        ("Orange", "#FF9500"),
        ("Yellow", "#FFCC00"),
        ("Green", "#34C759"),
        ("Teal", "#5AC8FA"),
        ("Indigo", "#5E5CE6"),
        ("Mint", "#00C7BE"),
        ("Cyan", "#32ADE6"),
        ("Brown", "#A2845E"),
    ]
    
    var body: some View {
        List {
            ForEach(colors, id: \.hex) { color in
                Button {
                    selectedHex = color.hex
                    HapticsService.shared.selectionChanged()
                } label: {
                    HStack {
                        Circle()
                            .fill(Color(hex: color.hex))
                            .frame(width: 30, height: 30)
                        
                        Text(color.name)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if selectedHex == color.hex {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
        .navigationTitle("Accent Color")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
