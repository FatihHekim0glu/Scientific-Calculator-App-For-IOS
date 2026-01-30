import Foundation

// MARK: - Scientific Constants

/// Scientific constants with their precise values (CODATA 2018)
enum ScientificConstant: String, CaseIterable {
    
    // MARK: Fundamental Constants
    
    /// Speed of light in vacuum (m/s)
    case speedOfLight = "c"
    
    /// Planck constant (J·s)
    case planckConstant = "h"
    
    /// Reduced Planck constant ℏ = h/2π (J·s)
    case reducedPlanck = "hbar"
    
    /// Elementary charge (C)
    case elementaryCharge = "qe"
    
    /// Avogadro constant (mol⁻¹)
    case avogadro = "Na"
    
    /// Boltzmann constant (J/K)
    case boltzmann = "k"
    
    /// Newtonian constant of gravitation (m³/(kg·s²))
    case gravitationalConstant = "G"
    
    /// Molar gas constant (J/(mol·K))
    case gasConstant = "R"
    
    // MARK: Particle Masses
    
    /// Electron mass (kg)
    case electronMass = "me"
    
    /// Proton mass (kg)
    case protonMass = "mp"
    
    /// Neutron mass (kg)
    case neutronMass = "mn"
    
    /// Atomic mass unit (kg)
    case atomicMassUnit = "u"
    
    // MARK: Electromagnetic Constants
    
    /// Vacuum electric permittivity (F/m)
    case vacuumPermittivity = "e0"
    
    /// Vacuum magnetic permeability (H/m)
    case vacuumPermeability = "u0"
    
    // MARK: Other Constants
    
    /// Stefan-Boltzmann constant (W/(m²·K⁴))
    case stefanBoltzmann = "sigma"
    
    /// Standard acceleration of gravity (m/s²)
    case standardGravity = "g0"
    
    /// Standard atmosphere (Pa)
    case standardAtmosphere = "atm"
    
    /// Absolute zero (°C)
    case absoluteZero = "T0"
    
    // MARK: - Computed Properties
    
    /// The precise value of the constant (CODATA 2018 recommended values)
    var value: Double {
        switch self {
        case .speedOfLight:
            return 299_792_458
        case .planckConstant:
            return 6.626_070_15e-34
        case .reducedPlanck:
            return 1.054_571_817e-34
        case .elementaryCharge:
            return 1.602_176_634e-19
        case .avogadro:
            return 6.022_140_76e23
        case .boltzmann:
            return 1.380_649e-23
        case .gravitationalConstant:
            return 6.674_30e-11
        case .gasConstant:
            return 8.314_462_618
        case .electronMass:
            return 9.109_383_7015e-31
        case .protonMass:
            return 1.672_621_923_69e-27
        case .neutronMass:
            return 1.674_927_498_04e-27
        case .atomicMassUnit:
            return 1.660_539_066_60e-27
        case .vacuumPermittivity:
            return 8.854_187_8128e-12
        case .vacuumPermeability:
            return 1.256_637_062_12e-6
        case .stefanBoltzmann:
            return 5.670_374_419e-8
        case .standardGravity:
            return 9.806_65
        case .standardAtmosphere:
            return 101_325
        case .absoluteZero:
            return -273.15
        }
    }
    
    /// Display symbol with proper formatting
    var displaySymbol: String {
        switch self {
        case .speedOfLight:
            return "c"
        case .planckConstant:
            return "h"
        case .reducedPlanck:
            return "ℏ"
        case .elementaryCharge:
            return "qₑ"
        case .avogadro:
            return "Nₐ"
        case .boltzmann:
            return "k"
        case .gravitationalConstant:
            return "G"
        case .gasConstant:
            return "R"
        case .electronMass:
            return "mₑ"
        case .protonMass:
            return "mₚ"
        case .neutronMass:
            return "mₙ"
        case .atomicMassUnit:
            return "u"
        case .vacuumPermittivity:
            return "ε₀"
        case .vacuumPermeability:
            return "μ₀"
        case .stefanBoltzmann:
            return "σ"
        case .standardGravity:
            return "g₀"
        case .standardAtmosphere:
            return "atm"
        case .absoluteZero:
            return "T₀"
        }
    }
    
    /// Physical unit of the constant
    var unit: String {
        switch self {
        case .speedOfLight:
            return "m/s"
        case .planckConstant, .reducedPlanck:
            return "J·s"
        case .elementaryCharge:
            return "C"
        case .avogadro:
            return "mol⁻¹"
        case .boltzmann:
            return "J/K"
        case .gravitationalConstant:
            return "m³/(kg·s²)"
        case .gasConstant:
            return "J/(mol·K)"
        case .electronMass, .protonMass, .neutronMass, .atomicMassUnit:
            return "kg"
        case .vacuumPermittivity:
            return "F/m"
        case .vacuumPermeability:
            return "H/m"
        case .stefanBoltzmann:
            return "W/(m²·K⁴)"
        case .standardGravity:
            return "m/s²"
        case .standardAtmosphere:
            return "Pa"
        case .absoluteZero:
            return "°C"
        }
    }
    
    /// Human-readable name
    var displayName: String {
        switch self {
        case .speedOfLight:
            return "Speed of Light"
        case .planckConstant:
            return "Planck Constant"
        case .reducedPlanck:
            return "Reduced Planck Constant"
        case .elementaryCharge:
            return "Elementary Charge"
        case .avogadro:
            return "Avogadro Constant"
        case .boltzmann:
            return "Boltzmann Constant"
        case .gravitationalConstant:
            return "Gravitational Constant"
        case .gasConstant:
            return "Gas Constant"
        case .electronMass:
            return "Electron Mass"
        case .protonMass:
            return "Proton Mass"
        case .neutronMass:
            return "Neutron Mass"
        case .atomicMassUnit:
            return "Atomic Mass Unit"
        case .vacuumPermittivity:
            return "Vacuum Permittivity"
        case .vacuumPermeability:
            return "Vacuum Permeability"
        case .stefanBoltzmann:
            return "Stefan-Boltzmann Constant"
        case .standardGravity:
            return "Standard Gravity"
        case .standardAtmosphere:
            return "Standard Atmosphere"
        case .absoluteZero:
            return "Absolute Zero"
        }
    }
}

// MARK: - Constants Manager

/// Provides access to scientific constants
struct ConstantsManager {
    
    /// All available constants
    static let allConstants: [ScientificConstant] = ScientificConstant.allCases
    
    /// Get constant by raw value (case-insensitive)
    /// - Parameter name: The raw value identifier of the constant
    /// - Returns: The matching ScientificConstant, or nil if not found
    static func constant(named name: String) -> ScientificConstant? {
        let lowercased = name.lowercased()
        return ScientificConstant.allCases.first { $0.rawValue.lowercased() == lowercased }
    }
    
    /// Get value by name
    /// - Parameter name: The raw value identifier of the constant
    /// - Returns: The value of the constant, or nil if not found
    static func value(named name: String) -> Double? {
        constant(named: name)?.value
    }
    
    /// Constants grouped by category for UI display
    static var categorizedConstants: [String: [ScientificConstant]] {
        [
            "Fundamental": [
                .speedOfLight,
                .planckConstant,
                .reducedPlanck,
                .elementaryCharge,
                .avogadro,
                .boltzmann,
                .gravitationalConstant,
                .gasConstant
            ],
            "Particle Masses": [
                .electronMass,
                .protonMass,
                .neutronMass,
                .atomicMassUnit
            ],
            "Electromagnetic": [
                .vacuumPermittivity,
                .vacuumPermeability
            ],
            "Other": [
                .stefanBoltzmann,
                .standardGravity,
                .standardAtmosphere,
                .absoluteZero
            ]
        ]
    }
    
    /// Category names in display order
    static let categoryOrder: [String] = [
        "Fundamental",
        "Particle Masses",
        "Electromagnetic",
        "Other"
    ]
}
