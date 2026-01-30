import XCTest
@testable import ScientificCalculatorAppForIOS

final class MemoryManagerTests: XCTestCase {
    var memoryManager: MemoryManager!
    
    override func setUp() {
        super.setUp()
        memoryManager = MemoryManager()
        memoryManager.resetAll()
        
        // Clear UserDefaults for clean tests
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "calc_memory_M")
        defaults.removeObject(forKey: "calc_memory_Ans")
        defaults.removeObject(forKey: "calc_memory_PreAns")
        defaults.removeObject(forKey: "calc_memory_variables")
    }
    
    override func tearDown() {
        memoryManager.resetAll()
        memoryManager = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_InitialState_IndependentMemoryIsZero() {
        let manager = MemoryManager()
        manager.resetAll()
        XCTAssertEqual(manager.independentMemory, 0, accuracy: 1e-15)
    }
    
    func test_InitialState_LastAnswerIsZero() {
        let manager = MemoryManager()
        manager.resetAll()
        XCTAssertEqual(manager.lastAnswer, 0, accuracy: 1e-15)
    }
    
    func test_InitialState_PreviousAnswerIsZero() {
        let manager = MemoryManager()
        manager.resetAll()
        XCTAssertEqual(manager.previousAnswer, 0, accuracy: 1e-15)
    }
    
    func test_InitialState_VariablesAreZero() {
        let manager = MemoryManager()
        manager.resetAll()
        
        for variable in ["A", "B", "C", "D", "E", "F"] {
            XCTAssertEqual(manager.variables[variable], 0, accuracy: 1e-15)
        }
    }
    
    func test_InitialState_HasMemoryValue_IsFalse() {
        memoryManager.resetAll()
        XCTAssertFalse(memoryManager.hasMemoryValue)
    }
    
    // MARK: - Memory Add Tests
    
    func test_MemoryAdd_AddsToMemory() {
        memoryManager.memoryAdd(10)
        XCTAssertEqual(memoryManager.independentMemory, 10, accuracy: 1e-15)
    }
    
    func test_MemoryAdd_Accumulates() {
        memoryManager.memoryAdd(10)
        memoryManager.memoryAdd(5)
        XCTAssertEqual(memoryManager.independentMemory, 15, accuracy: 1e-15)
    }
    
    func test_MemoryAdd_NegativeValue() {
        memoryManager.memoryAdd(-5)
        XCTAssertEqual(memoryManager.independentMemory, -5, accuracy: 1e-15)
    }
    
    func test_MemoryAdd_Zero_NoChange() {
        memoryManager.memoryAdd(10)
        memoryManager.memoryAdd(0)
        XCTAssertEqual(memoryManager.independentMemory, 10, accuracy: 1e-15)
    }
    
    // MARK: - Memory Subtract Tests
    
    func test_MemorySubtract_SubtractsFromMemory() {
        memoryManager.memoryAdd(20)
        memoryManager.memorySubtract(5)
        XCTAssertEqual(memoryManager.independentMemory, 15, accuracy: 1e-15)
    }
    
    func test_MemorySubtract_CanGoNegative() {
        memoryManager.memorySubtract(10)
        XCTAssertEqual(memoryManager.independentMemory, -10, accuracy: 1e-15)
    }
    
    func test_MemorySubtract_NegativeValue_Adds() {
        memoryManager.memorySubtract(-5)
        XCTAssertEqual(memoryManager.independentMemory, 5, accuracy: 1e-15)
    }
    
    // MARK: - Memory Recall Tests
    
    func test_MemoryRecall_ReturnsStoredValue() {
        memoryManager.memoryAdd(42)
        let recalled = memoryManager.memoryRecall()
        XCTAssertEqual(recalled, 42, accuracy: 1e-15)
    }
    
    func test_MemoryRecall_AfterSubtract_ReturnsCorrectValue() {
        memoryManager.memoryAdd(50)
        memoryManager.memorySubtract(8)
        let recalled = memoryManager.memoryRecall()
        XCTAssertEqual(recalled, 42, accuracy: 1e-15)
    }
    
    func test_MemoryRecall_InitiallyZero() {
        let recalled = memoryManager.memoryRecall()
        XCTAssertEqual(recalled, 0, accuracy: 1e-15)
    }
    
    // MARK: - Memory Clear Tests
    
    func test_MemoryClear_ResetsToZero() {
        memoryManager.memoryAdd(100)
        memoryManager.memoryClear()
        XCTAssertEqual(memoryManager.independentMemory, 0, accuracy: 1e-15)
    }
    
    func test_MemoryClear_HasMemoryValue_BecomesFalse() {
        memoryManager.memoryAdd(50)
        XCTAssertTrue(memoryManager.hasMemoryValue)
        
        memoryManager.memoryClear()
        XCTAssertFalse(memoryManager.hasMemoryValue)
    }
    
    // MARK: - Memory Store Tests
    
    func test_MemoryStore_StoresValue() {
        memoryManager.memoryStore(99)
        XCTAssertEqual(memoryManager.independentMemory, 99, accuracy: 1e-15)
    }
    
    func test_MemoryStore_OverwritesPreviousValue() {
        memoryManager.memoryAdd(50)
        memoryManager.memoryStore(25)
        XCTAssertEqual(memoryManager.independentMemory, 25, accuracy: 1e-15)
    }
    
    // MARK: - HasMemoryValue Tests
    
    func test_HasMemoryValue_TrueWhenNonZero() {
        memoryManager.memoryAdd(1)
        XCTAssertTrue(memoryManager.hasMemoryValue)
    }
    
    func test_HasMemoryValue_TrueWhenNegative() {
        memoryManager.memoryAdd(-1)
        XCTAssertTrue(memoryManager.hasMemoryValue)
    }
    
    func test_HasMemoryValue_FalseWhenZero() {
        memoryManager.memoryAdd(10)
        memoryManager.memorySubtract(10)
        XCTAssertFalse(memoryManager.hasMemoryValue)
    }
    
    // MARK: - Store Answer Tests
    
    func test_StoreAnswer_UpdatesLastAnswer() {
        memoryManager.storeAnswer(42)
        XCTAssertEqual(memoryManager.lastAnswer, 42, accuracy: 1e-15)
    }
    
    func test_StoreAnswer_ShiftsToPreviousAnswer() {
        memoryManager.storeAnswer(10)
        memoryManager.storeAnswer(20)
        
        XCTAssertEqual(memoryManager.lastAnswer, 20, accuracy: 1e-15)
        XCTAssertEqual(memoryManager.previousAnswer, 10, accuracy: 1e-15)
    }
    
    func test_StoreAnswer_ThreeAnswers_OnlyKeepsLastTwo() {
        memoryManager.storeAnswer(10)
        memoryManager.storeAnswer(20)
        memoryManager.storeAnswer(30)
        
        XCTAssertEqual(memoryManager.lastAnswer, 30, accuracy: 1e-15)
        XCTAssertEqual(memoryManager.previousAnswer, 20, accuracy: 1e-15)
    }
    
    // MARK: - Get Answer Tests
    
    func test_GetLastAnswer_ReturnsCorrectValue() {
        memoryManager.storeAnswer(123)
        XCTAssertEqual(memoryManager.getLastAnswer(), 123, accuracy: 1e-15)
    }
    
    func test_GetPreviousAnswer_ReturnsCorrectValue() {
        memoryManager.storeAnswer(100)
        memoryManager.storeAnswer(200)
        XCTAssertEqual(memoryManager.getPreviousAnswer(), 100, accuracy: 1e-15)
    }
    
    func test_GetLastAnswer_InitiallyZero() {
        XCTAssertEqual(memoryManager.getLastAnswer(), 0, accuracy: 1e-15)
    }
    
    func test_GetPreviousAnswer_InitiallyZero() {
        XCTAssertEqual(memoryManager.getPreviousAnswer(), 0, accuracy: 1e-15)
    }
    
    // MARK: - Variable Store Tests
    
    func test_StoreVariable_ValidName_Stores() throws {
        try memoryManager.storeVariable("A", value: 42)
        XCTAssertEqual(memoryManager.variables["A"], 42, accuracy: 1e-15)
    }
    
    func test_StoreVariable_AllValidNames() throws {
        for (i, name) in ["A", "B", "C", "D", "E", "F"].enumerated() {
            try memoryManager.storeVariable(name, value: Double(i + 1))
            XCTAssertEqual(memoryManager.variables[name], Double(i + 1), accuracy: 1e-15)
        }
    }
    
    func test_StoreVariable_LowercaseName_Stores() throws {
        try memoryManager.storeVariable("a", value: 42)
        XCTAssertEqual(memoryManager.variables["A"], 42, accuracy: 1e-15)
    }
    
    func test_StoreVariable_InvalidName_ThrowsError() {
        XCTAssertThrowsError(try memoryManager.storeVariable("X", value: 42)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalid input error")
                return
            }
        }
    }
    
    func test_StoreVariable_InvalidName_G_ThrowsError() {
        XCTAssertThrowsError(try memoryManager.storeVariable("G", value: 42)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalid input error")
                return
            }
        }
    }
    
    func test_StoreVariable_NumberName_ThrowsError() {
        XCTAssertThrowsError(try memoryManager.storeVariable("1", value: 42)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalid input error")
                return
            }
        }
    }
    
    // MARK: - Variable Recall Tests
    
    func test_RecallVariable_ReturnsStoredValue() throws {
        try memoryManager.storeVariable("B", value: 99)
        let value = try memoryManager.recallVariable("B")
        XCTAssertEqual(value, 99, accuracy: 1e-15)
    }
    
    func test_RecallVariable_Lowercase_ReturnsStoredValue() throws {
        try memoryManager.storeVariable("C", value: 77)
        let value = try memoryManager.recallVariable("c")
        XCTAssertEqual(value, 77, accuracy: 1e-15)
    }
    
    func test_RecallVariable_NotSet_ReturnsZero() throws {
        let value = try memoryManager.recallVariable("D")
        XCTAssertEqual(value, 0, accuracy: 1e-15)
    }
    
    func test_RecallVariable_InvalidName_ThrowsError() {
        XCTAssertThrowsError(try memoryManager.recallVariable("X")) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalid input error")
                return
            }
        }
    }
    
    // MARK: - Clear Variable Tests
    
    func test_ClearVariable_ResetsToZero() throws {
        try memoryManager.storeVariable("E", value: 50)
        memoryManager.clearVariable("E")
        XCTAssertEqual(memoryManager.variables["E"], 0, accuracy: 1e-15)
    }
    
    func test_ClearVariable_Lowercase_ResetsToZero() throws {
        try memoryManager.storeVariable("F", value: 50)
        memoryManager.clearVariable("f")
        XCTAssertEqual(memoryManager.variables["F"], 0, accuracy: 1e-15)
    }
    
    func test_ClearVariable_InvalidName_NoEffect() {
        memoryManager.clearVariable("X")
        // Should not crash, just do nothing
    }
    
    // MARK: - Clear All Variables Tests
    
    func test_ClearAllVariables_ResetsAll() throws {
        try memoryManager.storeVariable("A", value: 1)
        try memoryManager.storeVariable("B", value: 2)
        try memoryManager.storeVariable("C", value: 3)
        
        memoryManager.clearAllVariables()
        
        for name in ["A", "B", "C", "D", "E", "F"] {
            XCTAssertEqual(memoryManager.variables[name], 0, accuracy: 1e-15)
        }
    }
    
    // MARK: - Reset All Tests
    
    func test_ResetAll_ClearsIndependentMemory() {
        memoryManager.memoryAdd(100)
        memoryManager.resetAll()
        XCTAssertEqual(memoryManager.independentMemory, 0, accuracy: 1e-15)
    }
    
    func test_ResetAll_ClearsAnswers() {
        memoryManager.storeAnswer(10)
        memoryManager.storeAnswer(20)
        memoryManager.resetAll()
        
        XCTAssertEqual(memoryManager.lastAnswer, 0, accuracy: 1e-15)
        XCTAssertEqual(memoryManager.previousAnswer, 0, accuracy: 1e-15)
    }
    
    func test_ResetAll_ClearsVariables() throws {
        try memoryManager.storeVariable("A", value: 100)
        try memoryManager.storeVariable("F", value: 200)
        memoryManager.resetAll()
        
        for name in ["A", "B", "C", "D", "E", "F"] {
            XCTAssertEqual(memoryManager.variables[name], 0, accuracy: 1e-15)
        }
    }
    
    // MARK: - Validation Tests
    
    func test_IsValidVariableName_ValidNames() {
        XCTAssertTrue(MemoryManager.isValidVariableName("A"))
        XCTAssertTrue(MemoryManager.isValidVariableName("B"))
        XCTAssertTrue(MemoryManager.isValidVariableName("C"))
        XCTAssertTrue(MemoryManager.isValidVariableName("D"))
        XCTAssertTrue(MemoryManager.isValidVariableName("E"))
        XCTAssertTrue(MemoryManager.isValidVariableName("F"))
    }
    
    func test_IsValidVariableName_LowercaseValid() {
        XCTAssertTrue(MemoryManager.isValidVariableName("a"))
        XCTAssertTrue(MemoryManager.isValidVariableName("f"))
    }
    
    func test_IsValidVariableName_InvalidNames() {
        XCTAssertFalse(MemoryManager.isValidVariableName("G"))
        XCTAssertFalse(MemoryManager.isValidVariableName("X"))
        XCTAssertFalse(MemoryManager.isValidVariableName("1"))
        XCTAssertFalse(MemoryManager.isValidVariableName(""))
        XCTAssertFalse(MemoryManager.isValidVariableName("AB"))
    }
    
    func test_ValidVariableNames_ContainsAToF() {
        let expected = Set(["A", "B", "C", "D", "E", "F"])
        XCTAssertEqual(MemoryManager.validVariableNames, expected)
    }
    
    // MARK: - Persistence Tests
    
    func test_SaveAndLoad_PreservesIndependentMemory() {
        memoryManager.memoryStore(42)
        memoryManager.saveState()
        
        let newManager = MemoryManager()
        newManager.loadState()
        
        XCTAssertEqual(newManager.independentMemory, 42, accuracy: 1e-15)
    }
    
    func test_SaveAndLoad_PreservesAnswers() {
        memoryManager.storeAnswer(100)
        memoryManager.storeAnswer(200)
        memoryManager.saveState()
        
        let newManager = MemoryManager()
        newManager.loadState()
        
        XCTAssertEqual(newManager.lastAnswer, 200, accuracy: 1e-15)
        XCTAssertEqual(newManager.previousAnswer, 100, accuracy: 1e-15)
    }
    
    func test_SaveAndLoad_PreservesVariables() throws {
        try memoryManager.storeVariable("A", value: 11)
        try memoryManager.storeVariable("F", value: 66)
        memoryManager.saveState()
        
        let newManager = MemoryManager()
        newManager.loadState()
        
        XCTAssertEqual(newManager.variables["A"], 11, accuracy: 1e-15)
        XCTAssertEqual(newManager.variables["F"], 66, accuracy: 1e-15)
    }
    
    // MARK: - Edge Case Tests
    
    func test_Memory_VeryLargeValue() {
        memoryManager.memoryStore(1e100)
        XCTAssertEqual(memoryManager.independentMemory, 1e100, accuracy: 1e85)
    }
    
    func test_Memory_VerySmallValue() {
        memoryManager.memoryStore(1e-100)
        XCTAssertEqual(memoryManager.independentMemory, 1e-100, accuracy: 1e-115)
    }
    
    func test_Memory_NegativeValue() {
        memoryManager.memoryStore(-42)
        XCTAssertEqual(memoryManager.independentMemory, -42, accuracy: 1e-15)
    }
    
    func test_Answer_NegativeValue() {
        memoryManager.storeAnswer(-99)
        XCTAssertEqual(memoryManager.getLastAnswer(), -99, accuracy: 1e-15)
    }
    
    func test_Variable_NegativeValue() throws {
        try memoryManager.storeVariable("A", value: -50)
        let value = try memoryManager.recallVariable("A")
        XCTAssertEqual(value, -50, accuracy: 1e-15)
    }
}
