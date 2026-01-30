import Foundation
import SwiftUI

// MARK: - Calculator Modes

/// Calculator operating modes
enum CalculatorMode: String, CaseIterable, Identifiable {
    case calculate = "Calculate"
    case complex = "Complex"
    case baseN = "Base-N"
    case matrix = "Matrix"
    case vector = "Vector"
    case statistics = "Statistics"
    case distribution = "Distribution"
    case table = "Table"
    case equation = "Equation"
    case inequality = "Inequality"
    case ratio = "Ratio"
    case spreadsheet = "Spreadsheet"
    
    var id: String { rawValue }
    
    /// Display name for UI
    var displayName: String { rawValue }
    
    /// Short name for status bar
    var shortName: String {
        switch self {
        case .calculate: return "CALC"
        case .complex: return "CMPLX"
        case .baseN: return "BASE"
        case .matrix: return "MAT"
        case .vector: return "VCT"
        case .statistics: return "STAT"
        case .distribution: return "DIST"
        case .table: return "TABLE"
        case .equation: return "EQN"
        case .inequality: return "INEQ"
        case .ratio: return "RATIO"
        case .spreadsheet: return "SPREAD"
        }
    }
    
    /// Icon for mode selector
    var iconName: String {
        switch self {
        case .calculate: return "function"
        case .complex: return "number.circle"
        case .baseN: return "01.square"
        case .matrix: return "square.grid.3x3"
        case .vector: return "arrow.up.right"
        case .statistics: return "chart.bar"
        case .distribution: return "chart.line.uptrend.xyaxis"
        case .table: return "tablecells"
        case .equation: return "x.squareroot"
        case .inequality: return "lessthan"
        case .ratio: return "divide"
        case .spreadsheet: return "tablecells.badge.ellipsis"
        }
    }
    
    /// Whether this mode supports complex numbers
    var supportsComplex: Bool {
        self == .calculate || self == .complex
    }
    
    /// Whether this mode is for special data types
    var isSpecialMode: Bool {
        switch self {
        case .complex, .baseN, .matrix, .vector:
            return true
        default:
            return false
        }
    }
}

// MARK: - Matrix Reference

/// Reference to a stored matrix (MatA, MatB, MatC, MatD)
enum MatrixRef: String, CaseIterable, Identifiable {
    case matA = "MatA"
    case matB = "MatB"
    case matC = "MatC"
    case matD = "MatD"
    
    var id: String { rawValue }
    
    /// Display name
    var displayName: String { rawValue }
    
    /// Short name for buttons
    var shortName: String {
        switch self {
        case .matA: return "A"
        case .matB: return "B"
        case .matC: return "C"
        case .matD: return "D"
        }
    }
    
    /// Alternative names for matrices (MatrixA, etc.)
    static func fromAlternative(_ name: String) -> MatrixRef? {
        let lowercased = name.lowercased()
        if lowercased.hasPrefix("mat") || lowercased.hasPrefix("matrix") {
            guard let lastChar = lowercased.last else { return nil }
            switch lastChar {
            case "a": return .matA
            case "b": return .matB
            case "c": return .matC
            case "d": return .matD
            default: return nil
            }
        }
        return nil
    }
}

// MARK: - Vector Reference

/// Reference to a stored vector (VctA, VctB, VctC, VctD)
enum VectorRef: String, CaseIterable, Identifiable {
    case vctA = "VctA"
    case vctB = "VctB"
    case vctC = "VctC"
    case vctD = "VctD"
    
    var id: String { rawValue }
    
    /// Display name
    var displayName: String { rawValue }
    
    /// Short name for buttons
    var shortName: String {
        switch self {
        case .vctA: return "A"
        case .vctB: return "B"
        case .vctC: return "C"
        case .vctD: return "D"
        }
    }
    
    /// Alternative names for vectors (VecA, VecB, etc.)
    static func fromAlternative(_ name: String) -> VectorRef? {
        let lowercased = name.lowercased()
        if lowercased.hasPrefix("vec") || lowercased.hasPrefix("vct") {
            guard let lastChar = lowercased.last else { return nil }
            switch lastChar {
            case "a": return .vctA
            case "b": return .vctB
            case "c": return .vctC
            case "d": return .vctD
            default: return nil
            }
        }
        return nil
    }
}

// MARK: - Mode State Protocol

/// Protocol for mode-specific state
protocol ModeState {
    /// Resets the mode state to defaults
    mutating func reset()
}

// MARK: - Complex Mode State

/// State for Complex mode
struct ComplexModeState: ModeState {
    /// Display format: rectangular (a+bi) or polar (r∠θ)
    var displayFormat: ComplexDisplayFormat = .rectangular
    
    /// Complex display format options
    enum ComplexDisplayFormat: String, CaseIterable, Identifiable {
        case rectangular = "a+bi"
        case polar = "r∠θ"
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .rectangular: return "Rectangular"
            case .polar: return "Polar"
            }
        }
    }
    
    mutating func reset() {
        displayFormat = .rectangular
    }
}

// MARK: - Base-N Mode State

/// State for Base-N mode
struct BaseNModeState: ModeState {
    /// Current number base
    var currentBase: NumberBase = .decimal
    
    /// Show leading zeros
    var showLeadingZeros: Bool = false
    
    /// Word size (8, 16, or 32 bits)
    var wordSize: WordSize = .thirtyTwo
    
    /// Available word sizes
    enum WordSize: Int, CaseIterable, Identifiable {
        case eight = 8
        case sixteen = 16
        case thirtyTwo = 32
        
        var id: Int { rawValue }
        
        var displayName: String {
            "\(rawValue)-bit"
        }
        
        /// Maximum value for unsigned representation
        var maxUnsigned: UInt32 {
            switch self {
            case .eight: return UInt32(UInt8.max)
            case .sixteen: return UInt32(UInt16.max)
            case .thirtyTwo: return UInt32.max
            }
        }
        
        /// Minimum value for signed representation
        var minSigned: Int32 {
            switch self {
            case .eight: return Int32(Int8.min)
            case .sixteen: return Int32(Int16.min)
            case .thirtyTwo: return Int32.min
            }
        }
        
        /// Maximum value for signed representation
        var maxSigned: Int32 {
            switch self {
            case .eight: return Int32(Int8.max)
            case .sixteen: return Int32(Int16.max)
            case .thirtyTwo: return Int32.max
            }
        }
    }
    
    mutating func reset() {
        currentBase = .decimal
        showLeadingZeros = false
        wordSize = .thirtyTwo
    }
}

// MARK: - Matrix Mode State

/// State for Matrix mode
struct MatrixModeState: ModeState {
    /// Stored matrix dimensions (rows, cols) for each reference
    var matrixDimensions: [MatrixRef: (rows: Int, cols: Int)] = [:]
    
    /// Stored matrix elements for each reference
    var matrixElements: [MatrixRef: [[Double]]] = [:]
    
    /// Currently selected matrix for editing
    var selectedMatrix: MatrixRef = .matA
    
    mutating func reset() {
        matrixDimensions = [:]
        matrixElements = [:]
        selectedMatrix = .matA
    }
    
    /// Gets the dimensions of a matrix
    func getDimensions(_ ref: MatrixRef) -> (rows: Int, cols: Int)? {
        matrixDimensions[ref]
    }
    
    /// Gets the elements of a matrix
    func getElements(_ ref: MatrixRef) -> [[Double]]? {
        matrixElements[ref]
    }
    
    /// Stores a matrix
    mutating func setMatrix(_ ref: MatrixRef, rows: Int, cols: Int, elements: [[Double]]) {
        matrixDimensions[ref] = (rows, cols)
        matrixElements[ref] = elements
    }
    
    /// Clears a specific matrix
    mutating func clearMatrix(_ ref: MatrixRef) {
        matrixDimensions.removeValue(forKey: ref)
        matrixElements.removeValue(forKey: ref)
    }
    
    /// Returns true if a matrix is defined
    func hasMatrix(_ ref: MatrixRef) -> Bool {
        matrixElements[ref] != nil
    }
}

// MARK: - Vector Mode State

/// State for Vector mode
struct VectorModeState: ModeState {
    /// Stored vector components for each reference
    var vectorComponents: [VectorRef: [Double]] = [:]
    
    /// Currently selected vector for editing
    var selectedVector: VectorRef = .vctA
    
    mutating func reset() {
        vectorComponents = [:]
        selectedVector = .vctA
    }
    
    /// Gets a vector's components
    func getComponents(_ ref: VectorRef) -> [Double]? {
        vectorComponents[ref]
    }
    
    /// Gets the dimension of a vector
    func getDimension(_ ref: VectorRef) -> Int? {
        vectorComponents[ref]?.count
    }
    
    /// Stores a vector
    mutating func setVector(_ ref: VectorRef, components: [Double]) {
        vectorComponents[ref] = components
    }
    
    /// Clears a specific vector
    mutating func clearVector(_ ref: VectorRef) {
        vectorComponents.removeValue(forKey: ref)
    }
    
    /// Returns true if a vector is defined
    func hasVector(_ ref: VectorRef) -> Bool {
        vectorComponents[ref] != nil
    }
}

// MARK: - Mode Manager

/// Manages calculator modes and their states
@Observable
class ModeManager {
    
    // MARK: - Current Mode
    
    /// Currently active calculator mode
    private(set) var currentMode: CalculatorMode = .calculate
    
    // MARK: - Mode States
    
    /// Complex mode state
    var complexState = ComplexModeState()
    
    /// Base-N mode state
    var baseNState = BaseNModeState()
    
    /// Matrix mode state
    var matrixState = MatrixModeState()
    
    /// Vector mode state
    var vectorState = VectorModeState()
    
    // MARK: - Initialization
    
    init() {
        loadStates()
    }
    
    // MARK: - Mode Switching
    
    /// Switches to a new mode
    func switchTo(_ mode: CalculatorMode) {
        currentMode = mode
    }
    
    /// Returns to Calculate mode
    func returnToCalculate() {
        currentMode = .calculate
    }
    
    // MARK: - Mode Queries
    
    /// Whether the current mode uses complex arithmetic
    var isComplexMode: Bool {
        currentMode == .complex
    }
    
    /// Whether the current mode is Base-N
    var isBaseNMode: Bool {
        currentMode == .baseN
    }
    
    /// Whether the current mode is Matrix
    var isMatrixMode: Bool {
        currentMode == .matrix
    }
    
    /// Whether the current mode is Vector
    var isVectorMode: Bool {
        currentMode == .vector
    }
    
    /// Whether the current mode is a standard calculation mode
    var isStandardMode: Bool {
        currentMode == .calculate
    }
    
    /// Current number base (for Base-N mode)
    var currentBase: NumberBase {
        get { baseNState.currentBase }
        set { baseNState.currentBase = newValue }
    }
    
    // MARK: - Reset
    
    /// Resets all mode states
    func resetAllStates() {
        complexState.reset()
        baseNState.reset()
        matrixState.reset()
        vectorState.reset()
        saveStates()
    }
    
    /// Resets the current mode's state only
    func resetCurrentModeState() {
        switch currentMode {
        case .complex:
            complexState.reset()
        case .baseN:
            baseNState.reset()
        case .matrix:
            matrixState.reset()
        case .vector:
            vectorState.reset()
        default:
            break
        }
        saveStates()
    }
    
    // MARK: - Persistence Keys
    
    private enum PersistenceKey {
        static let complexDisplayFormat = "CalculatorMode.complex.displayFormat"
        static let baseNCurrentBase = "CalculatorMode.baseN.currentBase"
        static let baseNShowLeadingZeros = "CalculatorMode.baseN.showLeadingZeros"
        static let baseNWordSize = "CalculatorMode.baseN.wordSize"
        static let matrixData = "CalculatorMode.matrix.data"
        static let vectorData = "CalculatorMode.vector.data"
    }
    
    // MARK: - Persistence
    
    /// Saves mode states to UserDefaults
    func saveStates() {
        let defaults = UserDefaults.standard
        
        // Complex state
        defaults.set(complexState.displayFormat.rawValue, forKey: PersistenceKey.complexDisplayFormat)
        
        // Base-N state
        defaults.set(baseNState.currentBase.rawValue, forKey: PersistenceKey.baseNCurrentBase)
        defaults.set(baseNState.showLeadingZeros, forKey: PersistenceKey.baseNShowLeadingZeros)
        defaults.set(baseNState.wordSize.rawValue, forKey: PersistenceKey.baseNWordSize)
        
        // Matrix state (encode as JSON)
        if let matrixData = encodeMatrixState() {
            defaults.set(matrixData, forKey: PersistenceKey.matrixData)
        }
        
        // Vector state (encode as JSON)
        if let vectorData = encodeVectorState() {
            defaults.set(vectorData, forKey: PersistenceKey.vectorData)
        }
    }
    
    /// Loads mode states from UserDefaults
    func loadStates() {
        let defaults = UserDefaults.standard
        
        // Complex state
        if let formatString = defaults.string(forKey: PersistenceKey.complexDisplayFormat),
           let format = ComplexModeState.ComplexDisplayFormat(rawValue: formatString) {
            complexState.displayFormat = format
        }
        
        // Base-N state
        if let baseValue = defaults.object(forKey: PersistenceKey.baseNCurrentBase) as? Int,
           let base = NumberBase(rawValue: baseValue) {
            baseNState.currentBase = base
        }
        baseNState.showLeadingZeros = defaults.bool(forKey: PersistenceKey.baseNShowLeadingZeros)
        if let wordSizeValue = defaults.object(forKey: PersistenceKey.baseNWordSize) as? Int,
           let wordSize = BaseNModeState.WordSize(rawValue: wordSizeValue) {
            baseNState.wordSize = wordSize
        }
        
        // Matrix state
        if let matrixData = defaults.data(forKey: PersistenceKey.matrixData) {
            decodeMatrixState(from: matrixData)
        }
        
        // Vector state
        if let vectorData = defaults.data(forKey: PersistenceKey.vectorData) {
            decodeVectorState(from: vectorData)
        }
    }
    
    // MARK: - Matrix Persistence Helpers
    
    private func encodeMatrixState() -> Data? {
        var encoded: [String: [String: Any]] = [:]
        
        for ref in MatrixRef.allCases {
            if let elements = matrixState.matrixElements[ref],
               let dims = matrixState.matrixDimensions[ref] {
                encoded[ref.rawValue] = [
                    "rows": dims.rows,
                    "cols": dims.cols,
                    "elements": elements
                ]
            }
        }
        
        return try? JSONSerialization.data(withJSONObject: encoded)
    }
    
    private func decodeMatrixState(from data: Data) {
        guard let decoded = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return
        }
        
        for (refString, matrixData) in decoded {
            guard let ref = MatrixRef(rawValue: refString),
                  let rows = matrixData["rows"] as? Int,
                  let cols = matrixData["cols"] as? Int,
                  let elements = matrixData["elements"] as? [[Double]] else {
                continue
            }
            matrixState.setMatrix(ref, rows: rows, cols: cols, elements: elements)
        }
    }
    
    // MARK: - Vector Persistence Helpers
    
    private func encodeVectorState() -> Data? {
        var encoded: [String: [Double]] = [:]
        
        for ref in VectorRef.allCases {
            if let components = vectorState.vectorComponents[ref] {
                encoded[ref.rawValue] = components
            }
        }
        
        return try? JSONSerialization.data(withJSONObject: encoded)
    }
    
    private func decodeVectorState(from data: Data) {
        guard let decoded = try? JSONSerialization.jsonObject(with: data) as? [String: [Double]] else {
            return
        }
        
        for (refString, components) in decoded {
            guard let ref = VectorRef(rawValue: refString) else {
                continue
            }
            vectorState.setVector(ref, components: components)
        }
    }
}

// MARK: - Mode Manager Extensions

extension ModeManager {
    
    /// Returns available modes for the mode selector
    var availableModes: [CalculatorMode] {
        CalculatorMode.allCases
    }
    
    /// Returns true if the given mode is currently active
    func isActive(_ mode: CalculatorMode) -> Bool {
        currentMode == mode
    }
    
    /// Returns the button layout appropriate for the current mode
    var currentModeButtonLayout: ModeButtonLayout {
        switch currentMode {
        case .calculate:
            return .scientific
        case .complex:
            return .complex
        case .baseN:
            return .baseN
        case .matrix:
            return .matrix
        case .vector:
            return .vector
        default:
            return .scientific
        }
    }
    
    /// Button layout types for different modes
    enum ModeButtonLayout {
        case scientific
        case complex
        case baseN
        case matrix
        case vector
    }
}
