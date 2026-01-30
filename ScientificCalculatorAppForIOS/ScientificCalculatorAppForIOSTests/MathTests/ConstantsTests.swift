import XCTest
@testable import ScientificCalculatorAppForIOS

final class ConstantsTests: XCTestCase {
    
    // MARK: - Fundamental Constants Value Tests
    
    func test_SpeedOfLight_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.speedOfLight.value, 299_792_458, accuracy: 1)
    }
    
    func test_PlanckConstant_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.planckConstant.value, 6.62607015e-34, accuracy: 1e-43)
    }
    
    func test_ReducedPlanck_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.reducedPlanck.value, 1.054571817e-34, accuracy: 1e-43)
    }
    
    func test_ElementaryCharge_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.elementaryCharge.value, 1.602176634e-19, accuracy: 1e-28)
    }
    
    func test_Avogadro_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.avogadro.value, 6.02214076e23, accuracy: 1e14)
    }
    
    func test_Boltzmann_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.boltzmann.value, 1.380649e-23, accuracy: 1e-32)
    }
    
    func test_GravitationalConstant_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.gravitationalConstant.value, 6.67430e-11, accuracy: 1e-16)
    }
    
    func test_GasConstant_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.gasConstant.value, 8.314462618, accuracy: 1e-9)
    }
    
    // MARK: - Particle Mass Value Tests
    
    func test_ElectronMass_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.electronMass.value, 9.1093837015e-31, accuracy: 1e-40)
    }
    
    func test_ProtonMass_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.protonMass.value, 1.67262192369e-27, accuracy: 1e-37)
    }
    
    func test_NeutronMass_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.neutronMass.value, 1.67492749804e-27, accuracy: 1e-37)
    }
    
    func test_AtomicMassUnit_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.atomicMassUnit.value, 1.66053906660e-27, accuracy: 1e-37)
    }
    
    // MARK: - Electromagnetic Constants Value Tests
    
    func test_VacuumPermittivity_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.vacuumPermittivity.value, 8.8541878128e-12, accuracy: 1e-21)
    }
    
    func test_VacuumPermeability_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.vacuumPermeability.value, 1.25663706212e-6, accuracy: 1e-16)
    }
    
    // MARK: - Other Constants Value Tests
    
    func test_StefanBoltzmann_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.stefanBoltzmann.value, 5.670374419e-8, accuracy: 1e-17)
    }
    
    func test_StandardGravity_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.standardGravity.value, 9.80665, accuracy: 1e-10)
    }
    
    func test_StandardAtmosphere_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.standardAtmosphere.value, 101325, accuracy: 1)
    }
    
    func test_AbsoluteZero_HasCorrectValue() {
        XCTAssertEqual(ScientificConstant.absoluteZero.value, -273.15, accuracy: 0.01)
    }
    
    // MARK: - Display Symbol Tests
    
    func test_SpeedOfLight_DisplaySymbol() {
        XCTAssertEqual(ScientificConstant.speedOfLight.displaySymbol, "c")
    }
    
    func test_ReducedPlanck_DisplaySymbol() {
        XCTAssertEqual(ScientificConstant.reducedPlanck.displaySymbol, "ℏ")
    }
    
    func test_Avogadro_DisplaySymbol() {
        XCTAssertEqual(ScientificConstant.avogadro.displaySymbol, "Nₐ")
    }
    
    func test_ElectronMass_DisplaySymbol() {
        XCTAssertEqual(ScientificConstant.electronMass.displaySymbol, "mₑ")
    }
    
    func test_VacuumPermittivity_DisplaySymbol() {
        XCTAssertEqual(ScientificConstant.vacuumPermittivity.displaySymbol, "ε₀")
    }
    
    func test_VacuumPermeability_DisplaySymbol() {
        XCTAssertEqual(ScientificConstant.vacuumPermeability.displaySymbol, "μ₀")
    }
    
    func test_StefanBoltzmann_DisplaySymbol() {
        XCTAssertEqual(ScientificConstant.stefanBoltzmann.displaySymbol, "σ")
    }
    
    // MARK: - Unit Tests
    
    func test_SpeedOfLight_Unit() {
        XCTAssertEqual(ScientificConstant.speedOfLight.unit, "m/s")
    }
    
    func test_PlanckConstant_Unit() {
        XCTAssertEqual(ScientificConstant.planckConstant.unit, "J·s")
    }
    
    func test_ElementaryCharge_Unit() {
        XCTAssertEqual(ScientificConstant.elementaryCharge.unit, "C")
    }
    
    func test_Avogadro_Unit() {
        XCTAssertEqual(ScientificConstant.avogadro.unit, "mol⁻¹")
    }
    
    func test_ElectronMass_Unit() {
        XCTAssertEqual(ScientificConstant.electronMass.unit, "kg")
    }
    
    func test_VacuumPermittivity_Unit() {
        XCTAssertEqual(ScientificConstant.vacuumPermittivity.unit, "F/m")
    }
    
    func test_StandardAtmosphere_Unit() {
        XCTAssertEqual(ScientificConstant.standardAtmosphere.unit, "Pa")
    }
    
    // MARK: - Display Name Tests
    
    func test_SpeedOfLight_DisplayName() {
        XCTAssertEqual(ScientificConstant.speedOfLight.displayName, "Speed of Light")
    }
    
    func test_PlanckConstant_DisplayName() {
        XCTAssertEqual(ScientificConstant.planckConstant.displayName, "Planck Constant")
    }
    
    func test_GravitationalConstant_DisplayName() {
        XCTAssertEqual(ScientificConstant.gravitationalConstant.displayName, "Gravitational Constant")
    }
    
    func test_StefanBoltzmann_DisplayName() {
        XCTAssertEqual(ScientificConstant.stefanBoltzmann.displayName, "Stefan-Boltzmann Constant")
    }
    
    // MARK: - ConstantsManager Tests
    
    func test_AllConstants_ContainsAllCases() {
        XCTAssertEqual(ConstantsManager.allConstants.count, ScientificConstant.allCases.count)
    }
    
    func test_ConstantByName_ReturnsCorrectConstant() {
        let constant = ConstantsManager.constant(named: "c")
        XCTAssertEqual(constant, .speedOfLight)
    }
    
    func test_ConstantByName_CaseInsensitive() {
        let constant1 = ConstantsManager.constant(named: "Na")
        let constant2 = ConstantsManager.constant(named: "na")
        let constant3 = ConstantsManager.constant(named: "NA")
        
        XCTAssertEqual(constant1, .avogadro)
        XCTAssertEqual(constant2, .avogadro)
        XCTAssertEqual(constant3, .avogadro)
    }
    
    func test_ConstantByName_InvalidName_ReturnsNil() {
        let constant = ConstantsManager.constant(named: "invalid")
        XCTAssertNil(constant)
    }
    
    func test_ValueByName_ReturnsCorrectValue() {
        let value = ConstantsManager.value(named: "c")
        XCTAssertEqual(value, 299_792_458, accuracy: 1)
    }
    
    func test_ValueByName_InvalidName_ReturnsNil() {
        let value = ConstantsManager.value(named: "invalid")
        XCTAssertNil(value)
    }
    
    func test_CategorizedConstants_ContainsAllCategories() {
        let categories = ConstantsManager.categorizedConstants
        
        XCTAssertNotNil(categories["Fundamental"])
        XCTAssertNotNil(categories["Particle Masses"])
        XCTAssertNotNil(categories["Electromagnetic"])
        XCTAssertNotNil(categories["Other"])
    }
    
    func test_CategorizedConstants_FundamentalCategory_ContainsExpectedConstants() {
        let fundamental = ConstantsManager.categorizedConstants["Fundamental"]!
        
        XCTAssertTrue(fundamental.contains(.speedOfLight))
        XCTAssertTrue(fundamental.contains(.planckConstant))
        XCTAssertTrue(fundamental.contains(.avogadro))
        XCTAssertTrue(fundamental.contains(.boltzmann))
    }
    
    func test_CategorizedConstants_ParticleMassesCategory_ContainsExpectedConstants() {
        let particleMasses = ConstantsManager.categorizedConstants["Particle Masses"]!
        
        XCTAssertTrue(particleMasses.contains(.electronMass))
        XCTAssertTrue(particleMasses.contains(.protonMass))
        XCTAssertTrue(particleMasses.contains(.neutronMass))
        XCTAssertTrue(particleMasses.contains(.atomicMassUnit))
    }
    
    func test_CategoryOrder_ContainsAllCategories() {
        XCTAssertEqual(ConstantsManager.categoryOrder.count, 4)
        XCTAssertTrue(ConstantsManager.categoryOrder.contains("Fundamental"))
        XCTAssertTrue(ConstantsManager.categoryOrder.contains("Particle Masses"))
        XCTAssertTrue(ConstantsManager.categoryOrder.contains("Electromagnetic"))
        XCTAssertTrue(ConstantsManager.categoryOrder.contains("Other"))
    }
    
    // MARK: - Raw Value Tests
    
    func test_AllConstants_HaveUniqueRawValues() {
        let rawValues = ScientificConstant.allCases.map { $0.rawValue }
        let uniqueRawValues = Set(rawValues)
        XCTAssertEqual(rawValues.count, uniqueRawValues.count)
    }
    
    // MARK: - Physical Relationship Tests
    
    func test_ReducedPlanck_EqualsHDividedBy2Pi() {
        let h = ScientificConstant.planckConstant.value
        let hbar = ScientificConstant.reducedPlanck.value
        let expectedHbar = h / (2 * .pi)
        
        XCTAssertEqual(hbar, expectedHbar, accuracy: 1e-44)
    }
    
    func test_ProtonMass_GreaterThanElectronMass() {
        let mp = ScientificConstant.protonMass.value
        let me = ScientificConstant.electronMass.value
        
        XCTAssertGreaterThan(mp, me)
        XCTAssertGreaterThan(mp / me, 1800) // Proton is about 1836 times heavier
    }
    
    func test_NeutronMass_GreaterThanProtonMass() {
        let mn = ScientificConstant.neutronMass.value
        let mp = ScientificConstant.protonMass.value
        
        XCTAssertGreaterThan(mn, mp)
    }
}
