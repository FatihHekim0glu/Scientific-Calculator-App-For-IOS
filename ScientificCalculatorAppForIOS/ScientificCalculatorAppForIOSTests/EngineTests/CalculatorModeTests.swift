import XCTest
@testable import ScientificCalculatorAppForIOS

final class CalculatorModeTests: XCTestCase {
    
    var modeManager: ModeManager!
    
    override func setUp() {
        super.setUp()
        modeManager = ModeManager()
        modeManager.resetAllStates()
    }
    
    override func tearDown() {
        modeManager = nil
        super.tearDown()
    }
    
    // MARK: - CalculatorMode Enum Tests
    
    func test_CalculatorMode_AllCases_Exist() {
        let allModes = CalculatorMode.allCases
        
        XCTAssertTrue(allModes.contains(.calculate))
        XCTAssertTrue(allModes.contains(.complex))
        XCTAssertTrue(allModes.contains(.baseN))
        XCTAssertTrue(allModes.contains(.matrix))
        XCTAssertTrue(allModes.contains(.vector))
    }
    
    func test_CalculatorMode_DisplayName() {
        XCTAssertEqual(CalculatorMode.calculate.displayName, "Calculate")
        XCTAssertEqual(CalculatorMode.complex.displayName, "Complex")
        XCTAssertEqual(CalculatorMode.baseN.displayName, "Base-N")
        XCTAssertEqual(CalculatorMode.matrix.displayName, "Matrix")
        XCTAssertEqual(CalculatorMode.vector.displayName, "Vector")
    }
    
    func test_CalculatorMode_ShortName() {
        XCTAssertEqual(CalculatorMode.calculate.shortName, "CALC")
        XCTAssertEqual(CalculatorMode.complex.shortName, "CMPLX")
        XCTAssertEqual(CalculatorMode.baseN.shortName, "BASE")
        XCTAssertEqual(CalculatorMode.matrix.shortName, "MAT")
        XCTAssertEqual(CalculatorMode.vector.shortName, "VCT")
    }
    
    func test_CalculatorMode_IconName() {
        XCTAssertFalse(CalculatorMode.calculate.iconName.isEmpty)
        XCTAssertFalse(CalculatorMode.complex.iconName.isEmpty)
        XCTAssertFalse(CalculatorMode.baseN.iconName.isEmpty)
    }
    
    func test_CalculatorMode_SupportsComplex() {
        XCTAssertTrue(CalculatorMode.calculate.supportsComplex)
        XCTAssertTrue(CalculatorMode.complex.supportsComplex)
        XCTAssertFalse(CalculatorMode.baseN.supportsComplex)
        XCTAssertFalse(CalculatorMode.matrix.supportsComplex)
    }
    
    func test_CalculatorMode_IsSpecialMode() {
        XCTAssertFalse(CalculatorMode.calculate.isSpecialMode)
        XCTAssertTrue(CalculatorMode.complex.isSpecialMode)
        XCTAssertTrue(CalculatorMode.baseN.isSpecialMode)
        XCTAssertTrue(CalculatorMode.matrix.isSpecialMode)
        XCTAssertTrue(CalculatorMode.vector.isSpecialMode)
    }
    
    func test_CalculatorMode_Identifiable() {
        XCTAssertEqual(CalculatorMode.calculate.id, "Calculate")
        XCTAssertEqual(CalculatorMode.complex.id, "Complex")
    }
    
    // MARK: - Mode Switching Tests
    
    func test_InitialMode_IsCalculate() {
        XCTAssertEqual(modeManager.currentMode, .calculate)
    }
    
    func test_SwitchTo_ChangesMode() {
        modeManager.switchTo(.complex)
        XCTAssertEqual(modeManager.currentMode, .complex)
        
        modeManager.switchTo(.baseN)
        XCTAssertEqual(modeManager.currentMode, .baseN)
    }
    
    func test_ReturnToCalculate_SwitchesToCalculate() {
        modeManager.switchTo(.matrix)
        XCTAssertEqual(modeManager.currentMode, .matrix)
        
        modeManager.returnToCalculate()
        XCTAssertEqual(modeManager.currentMode, .calculate)
    }
    
    // MARK: - Mode Properties Tests
    
    func test_IsComplexMode_InComplexMode_ReturnsTrue() {
        modeManager.switchTo(.complex)
        XCTAssertTrue(modeManager.isComplexMode)
    }
    
    func test_IsComplexMode_InOtherMode_ReturnsFalse() {
        modeManager.switchTo(.calculate)
        XCTAssertFalse(modeManager.isComplexMode)
    }
    
    func test_IsBaseNMode_InBaseNMode_ReturnsTrue() {
        modeManager.switchTo(.baseN)
        XCTAssertTrue(modeManager.isBaseNMode)
    }
    
    func test_IsBaseNMode_InOtherMode_ReturnsFalse() {
        modeManager.switchTo(.calculate)
        XCTAssertFalse(modeManager.isBaseNMode)
    }
    
    func test_IsMatrixMode_InMatrixMode_ReturnsTrue() {
        modeManager.switchTo(.matrix)
        XCTAssertTrue(modeManager.isMatrixMode)
    }
    
    func test_IsVectorMode_InVectorMode_ReturnsTrue() {
        modeManager.switchTo(.vector)
        XCTAssertTrue(modeManager.isVectorMode)
    }
    
    func test_IsStandardMode_InCalculateMode_ReturnsTrue() {
        modeManager.switchTo(.calculate)
        XCTAssertTrue(modeManager.isStandardMode)
    }
    
    func test_IsActive_CurrentMode_ReturnsTrue() {
        modeManager.switchTo(.complex)
        XCTAssertTrue(modeManager.isActive(.complex))
        XCTAssertFalse(modeManager.isActive(.calculate))
    }
    
    // MARK: - Complex Mode State Tests
    
    func test_ComplexState_DefaultIsRectangular() {
        XCTAssertEqual(modeManager.complexState.displayFormat, .rectangular)
    }
    
    func test_ComplexState_CanChangeToPolar() {
        modeManager.complexState.displayFormat = .polar
        XCTAssertEqual(modeManager.complexState.displayFormat, .polar)
    }
    
    func test_ComplexState_Reset_RestoresDefault() {
        modeManager.complexState.displayFormat = .polar
        modeManager.complexState.reset()
        XCTAssertEqual(modeManager.complexState.displayFormat, .rectangular)
    }
    
    func test_ComplexDisplayFormat_DisplayName() {
        XCTAssertEqual(ComplexModeState.ComplexDisplayFormat.rectangular.displayName, "Rectangular")
        XCTAssertEqual(ComplexModeState.ComplexDisplayFormat.polar.displayName, "Polar")
    }
    
    // MARK: - Base-N Mode State Tests
    
    func test_BaseNState_DefaultIsDecimal() {
        XCTAssertEqual(modeManager.baseNState.currentBase, .decimal)
    }
    
    func test_BaseNState_DefaultWordSize_Is32() {
        XCTAssertEqual(modeManager.baseNState.wordSize, .thirtyTwo)
    }
    
    func test_BaseNState_CanChangeBase() {
        modeManager.baseNState.currentBase = .binary
        XCTAssertEqual(modeManager.baseNState.currentBase, .binary)
        
        modeManager.baseNState.currentBase = .hexadecimal
        XCTAssertEqual(modeManager.baseNState.currentBase, .hexadecimal)
    }
    
    func test_BaseNState_ShowLeadingZeros_DefaultFalse() {
        XCTAssertFalse(modeManager.baseNState.showLeadingZeros)
    }
    
    func test_BaseNState_Reset_RestoresDefaults() {
        modeManager.baseNState.currentBase = .binary
        modeManager.baseNState.showLeadingZeros = true
        modeManager.baseNState.wordSize = .eight
        
        modeManager.baseNState.reset()
        
        XCTAssertEqual(modeManager.baseNState.currentBase, .decimal)
        XCTAssertFalse(modeManager.baseNState.showLeadingZeros)
        XCTAssertEqual(modeManager.baseNState.wordSize, .thirtyTwo)
    }
    
    func test_WordSize_MaxValues() {
        XCTAssertEqual(BaseNModeState.WordSize.eight.maxUnsigned, 255)
        XCTAssertEqual(BaseNModeState.WordSize.sixteen.maxUnsigned, 65535)
        XCTAssertEqual(BaseNModeState.WordSize.thirtyTwo.maxUnsigned, UInt32.max)
    }
    
    func test_WordSize_SignedRange() {
        XCTAssertEqual(BaseNModeState.WordSize.eight.minSigned, -128)
        XCTAssertEqual(BaseNModeState.WordSize.eight.maxSigned, 127)
    }
    
    func test_CurrentBase_Accessor() {
        modeManager.currentBase = .hexadecimal
        XCTAssertEqual(modeManager.currentBase, .hexadecimal)
        XCTAssertEqual(modeManager.baseNState.currentBase, .hexadecimal)
    }
    
    // MARK: - Matrix Mode State Tests
    
    func test_MatrixState_InitiallyEmpty() {
        XCTAssertNil(modeManager.matrixState.getElements(.matA))
        XCTAssertNil(modeManager.matrixState.getDimensions(.matA))
    }
    
    func test_MatrixState_DefaultSelectedMatrix() {
        XCTAssertEqual(modeManager.matrixState.selectedMatrix, .matA)
    }
    
    func test_MatrixState_SetAndGetMatrix() {
        let elements: [[Double]] = [[1, 2], [3, 4]]
        modeManager.matrixState.setMatrix(.matA, rows: 2, cols: 2, elements: elements)
        
        XCTAssertTrue(modeManager.matrixState.hasMatrix(.matA))
        XCTAssertEqual(modeManager.matrixState.getElements(.matA), elements)
        XCTAssertEqual(modeManager.matrixState.getDimensions(.matA)?.rows, 2)
        XCTAssertEqual(modeManager.matrixState.getDimensions(.matA)?.cols, 2)
    }
    
    func test_MatrixState_ClearMatrix() {
        modeManager.matrixState.setMatrix(.matA, rows: 2, cols: 2, elements: [[1, 2], [3, 4]])
        XCTAssertTrue(modeManager.matrixState.hasMatrix(.matA))
        
        modeManager.matrixState.clearMatrix(.matA)
        XCTAssertFalse(modeManager.matrixState.hasMatrix(.matA))
    }
    
    func test_MatrixState_Reset_ClearsAll() {
        modeManager.matrixState.setMatrix(.matA, rows: 2, cols: 2, elements: [[1, 2], [3, 4]])
        modeManager.matrixState.setMatrix(.matB, rows: 2, cols: 2, elements: [[5, 6], [7, 8]])
        
        modeManager.matrixState.reset()
        
        XCTAssertFalse(modeManager.matrixState.hasMatrix(.matA))
        XCTAssertFalse(modeManager.matrixState.hasMatrix(.matB))
        XCTAssertEqual(modeManager.matrixState.selectedMatrix, .matA)
    }
    
    // MARK: - Vector Mode State Tests
    
    func test_VectorState_InitiallyEmpty() {
        XCTAssertNil(modeManager.vectorState.getComponents(.vctA))
    }
    
    func test_VectorState_DefaultSelectedVector() {
        XCTAssertEqual(modeManager.vectorState.selectedVector, .vctA)
    }
    
    func test_VectorState_SetAndGetVector() {
        let components: [Double] = [1, 2, 3]
        modeManager.vectorState.setVector(.vctA, components: components)
        
        XCTAssertTrue(modeManager.vectorState.hasVector(.vctA))
        XCTAssertEqual(modeManager.vectorState.getComponents(.vctA), components)
        XCTAssertEqual(modeManager.vectorState.getDimension(.vctA), 3)
    }
    
    func test_VectorState_ClearVector() {
        modeManager.vectorState.setVector(.vctA, components: [1, 2])
        XCTAssertTrue(modeManager.vectorState.hasVector(.vctA))
        
        modeManager.vectorState.clearVector(.vctA)
        XCTAssertFalse(modeManager.vectorState.hasVector(.vctA))
    }
    
    func test_VectorState_Reset_ClearsAll() {
        modeManager.vectorState.setVector(.vctA, components: [1, 2])
        modeManager.vectorState.setVector(.vctB, components: [3, 4])
        
        modeManager.vectorState.reset()
        
        XCTAssertFalse(modeManager.vectorState.hasVector(.vctA))
        XCTAssertFalse(modeManager.vectorState.hasVector(.vctB))
        XCTAssertEqual(modeManager.vectorState.selectedVector, .vctA)
    }
    
    // MARK: - Reset Tests
    
    func test_ResetAllStates_ClearsEverything() {
        // Set up some state
        modeManager.complexState.displayFormat = .polar
        modeManager.baseNState.currentBase = .binary
        modeManager.matrixState.setMatrix(.matA, rows: 2, cols: 2, elements: [[1, 2], [3, 4]])
        modeManager.vectorState.setVector(.vctA, components: [1, 2, 3])
        
        modeManager.resetAllStates()
        
        XCTAssertEqual(modeManager.complexState.displayFormat, .rectangular)
        XCTAssertEqual(modeManager.baseNState.currentBase, .decimal)
        XCTAssertFalse(modeManager.matrixState.hasMatrix(.matA))
        XCTAssertFalse(modeManager.vectorState.hasVector(.vctA))
    }
    
    func test_ResetCurrentModeState_OnlyResetsCurrent() {
        modeManager.complexState.displayFormat = .polar
        modeManager.baseNState.currentBase = .binary
        
        modeManager.switchTo(.complex)
        modeManager.resetCurrentModeState()
        
        // Complex state should be reset
        XCTAssertEqual(modeManager.complexState.displayFormat, .rectangular)
        // Base-N state should be unchanged
        XCTAssertEqual(modeManager.baseNState.currentBase, .binary)
    }
    
    // MARK: - MatrixRef Tests
    
    func test_MatrixRef_AllCases() {
        let refs = MatrixRef.allCases
        XCTAssertEqual(refs.count, 4)
        XCTAssertTrue(refs.contains(.matA))
        XCTAssertTrue(refs.contains(.matB))
        XCTAssertTrue(refs.contains(.matC))
        XCTAssertTrue(refs.contains(.matD))
    }
    
    func test_MatrixRef_DisplayName() {
        XCTAssertEqual(MatrixRef.matA.displayName, "MatA")
        XCTAssertEqual(MatrixRef.matB.displayName, "MatB")
    }
    
    func test_MatrixRef_ShortName() {
        XCTAssertEqual(MatrixRef.matA.shortName, "A")
        XCTAssertEqual(MatrixRef.matD.shortName, "D")
    }
    
    // MARK: - VectorRef Tests
    
    func test_VectorRef_AllCases() {
        let refs = VectorRef.allCases
        XCTAssertEqual(refs.count, 4)
        XCTAssertTrue(refs.contains(.vctA))
        XCTAssertTrue(refs.contains(.vctB))
        XCTAssertTrue(refs.contains(.vctC))
        XCTAssertTrue(refs.contains(.vctD))
    }
    
    func test_VectorRef_DisplayName() {
        XCTAssertEqual(VectorRef.vctA.displayName, "VctA")
        XCTAssertEqual(VectorRef.vctB.displayName, "VctB")
    }
    
    func test_VectorRef_ShortName() {
        XCTAssertEqual(VectorRef.vctA.shortName, "A")
        XCTAssertEqual(VectorRef.vctD.shortName, "D")
    }
    
    // MARK: - Button Layout Tests
    
    func test_CurrentModeButtonLayout_Calculate() {
        modeManager.switchTo(.calculate)
        XCTAssertEqual(modeManager.currentModeButtonLayout, .scientific)
    }
    
    func test_CurrentModeButtonLayout_Complex() {
        modeManager.switchTo(.complex)
        XCTAssertEqual(modeManager.currentModeButtonLayout, .complex)
    }
    
    func test_CurrentModeButtonLayout_BaseN() {
        modeManager.switchTo(.baseN)
        XCTAssertEqual(modeManager.currentModeButtonLayout, .baseN)
    }
    
    func test_CurrentModeButtonLayout_Matrix() {
        modeManager.switchTo(.matrix)
        XCTAssertEqual(modeManager.currentModeButtonLayout, .matrix)
    }
    
    func test_CurrentModeButtonLayout_Vector() {
        modeManager.switchTo(.vector)
        XCTAssertEqual(modeManager.currentModeButtonLayout, .vector)
    }
    
    // MARK: - Available Modes Tests
    
    func test_AvailableModes_ContainsAllModes() {
        let available = modeManager.availableModes
        XCTAssertEqual(available.count, CalculatorMode.allCases.count)
    }
    
    // MARK: - NumberBase Tests (from CalculatorMode.swift)
    
    func test_NumberBase_MaxDisplayDigits() {
        XCTAssertEqual(NumberBase.binary.maxDisplayDigits, 32)
        XCTAssertEqual(NumberBase.octal.maxDisplayDigits, 11)
        XCTAssertEqual(NumberBase.decimal.maxDisplayDigits, 10)
        XCTAssertEqual(NumberBase.hexadecimal.maxDisplayDigits, 8)
    }
    
    func test_NumberBase_Identifiable() {
        XCTAssertEqual(NumberBase.binary.id, 2)
        XCTAssertEqual(NumberBase.hexadecimal.id, 16)
    }
}
