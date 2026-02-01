import Foundation
import SwiftUI

// MARK: - UserDefaults Keys

private enum MemoryKeys {
    static let independentMemory = "calc_memory_M"
    static let lastAnswer = "calc_memory_Ans"
    static let previousAnswer = "calc_memory_PreAns"
    static let variables = "calc_memory_variables"
}

// MARK: - MemoryManager

/// Manages calculator memory including M, Ans, PreAns, and variables A-F
@Observable
class MemoryManager {
    
    // MARK: - Singleton
    
    static let shared = MemoryManager()
    
    // MARK: - Memory Storage
    
    /// Independent memory (M)
    private(set) var independentMemory: Double = 0
    
    /// Last answer (Ans)
    private(set) var lastAnswer: Double = 0
    
    /// Previous answer (PreAns) - the answer before last
    private(set) var previousAnswer: Double = 0
    
    /// Variable storage (A-F)
    private(set) var variables: [String: Double] = [
        "A": 0, "B": 0, "C": 0, "D": 0, "E": 0, "F": 0
    ]
    
    /// Returns true if independent memory has a non-zero value
    var hasMemoryValue: Bool {
        independentMemory != 0
    }
    
    // MARK: - Validation
    
    /// Valid variable names
    static let validVariableNames = Set(["A", "B", "C", "D", "E", "F"])
    
    /// Checks if a variable name is valid
    static func isValidVariableName(_ name: String) -> Bool {
        validVariableNames.contains(name.uppercased())
    }
    
    // MARK: - Initialization
    
    private init() {
        loadState()
    }
    
    // MARK: - Independent Memory Operations (M)
    
    /// Adds value to independent memory (M+)
    func memoryAdd(_ value: Double) {
        independentMemory += value
        saveState()
    }
    
    /// Subtracts value from independent memory (M-)
    func memorySubtract(_ value: Double) {
        independentMemory -= value
        saveState()
    }
    
    /// Recalls independent memory value (MR)
    func memoryRecall() -> Double {
        return independentMemory
    }
    
    /// Clears independent memory to zero (MC)
    func memoryClear() {
        independentMemory = 0
        saveState()
    }
    
    /// Stores value directly to independent memory
    func memoryStore(_ value: Double) {
        independentMemory = value
        saveState()
    }
    
    // MARK: - Answer Management
    
    /// Stores a new answer, shifting previous answer
    func storeAnswer(_ value: Double) {
        previousAnswer = lastAnswer
        lastAnswer = value
        saveState()
    }
    
    /// Gets the last answer (Ans)
    func getLastAnswer() -> Double {
        return lastAnswer
    }
    
    /// Gets the previous answer (PreAns)
    func getPreviousAnswer() -> Double {
        return previousAnswer
    }
    
    // MARK: - Variable Operations
    
    /// Stores a value in a variable (A-F)
    /// - Throws: CalculatorError if variable name is invalid
    func storeVariable(_ name: String, value: Double) throws {
        let upperName = name.uppercased()
        guard MemoryManager.isValidVariableName(upperName) else {
            throw CalculatorError.invalidInput("Invalid variable name: \(name). Valid names are A-F.")
        }
        variables[upperName] = value
        saveState()
    }
    
    /// Recalls a variable value
    /// - Throws: CalculatorError if variable name is invalid
    func recallVariable(_ name: String) throws -> Double {
        let upperName = name.uppercased()
        guard MemoryManager.isValidVariableName(upperName) else {
            throw CalculatorError.invalidInput("Invalid variable name: \(name). Valid names are A-F.")
        }
        return variables[upperName] ?? 0
    }
    
    /// Clears a specific variable to zero
    func clearVariable(_ name: String) {
        let upperName = name.uppercased()
        if MemoryManager.isValidVariableName(upperName) {
            variables[upperName] = 0
            saveState()
        }
    }
    
    /// Clears all variables to zero
    func clearAllVariables() {
        for key in MemoryManager.validVariableNames {
            variables[key] = 0
        }
        saveState()
    }
    
    // MARK: - Reset
    
    /// Resets all memory (M, Ans, PreAns, A-F)
    func resetAll() {
        independentMemory = 0
        lastAnswer = 0
        previousAnswer = 0
        for key in MemoryManager.validVariableNames {
            variables[key] = 0
        }
        saveState()
    }
    
    // MARK: - Persistence
    
    /// Saves memory state to UserDefaults
    func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(independentMemory, forKey: MemoryKeys.independentMemory)
        defaults.set(lastAnswer, forKey: MemoryKeys.lastAnswer)
        defaults.set(previousAnswer, forKey: MemoryKeys.previousAnswer)
        defaults.set(variables, forKey: MemoryKeys.variables)
    }
    
    /// Loads memory state from UserDefaults
    func loadState() {
        let defaults = UserDefaults.standard
        
        independentMemory = defaults.double(forKey: MemoryKeys.independentMemory)
        lastAnswer = defaults.double(forKey: MemoryKeys.lastAnswer)
        previousAnswer = defaults.double(forKey: MemoryKeys.previousAnswer)
        
        if let savedVariables = defaults.dictionary(forKey: MemoryKeys.variables) as? [String: Double] {
            for (key, value) in savedVariables {
                if MemoryManager.isValidVariableName(key) {
                    variables[key.uppercased()] = value
                }
            }
        }
    }
}
