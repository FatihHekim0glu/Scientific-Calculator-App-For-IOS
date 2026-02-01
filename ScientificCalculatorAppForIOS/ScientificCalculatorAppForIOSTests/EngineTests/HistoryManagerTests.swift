import XCTest
@testable import ScientificCalculatorAppForIOS

final class HistoryManagerTests: XCTestCase {
    
    // MARK: - History Entry Tests
    
    func test_HistoryEntry_Initialization() {
        let entry = HistoryEntry(
            expression: "2+2",
            result: "4",
            mode: "Calculate"
        )
        
        XCTAssertEqual(entry.expression, "2+2")
        XCTAssertEqual(entry.result, "4")
        XCTAssertEqual(entry.mode, "Calculate")
        XCTAssertFalse(entry.isError)
        XCTAssertNil(entry.notes)
    }
    
    func test_HistoryEntry_WithError() {
        let entry = HistoryEntry(
            expression: "1/0",
            result: "Math ERROR",
            isError: true
        )
        
        XCTAssertTrue(entry.isError)
        XCTAssertEqual(entry.result, "Math ERROR")
    }
    
    func test_HistoryEntry_WithNotes() {
        let entry = HistoryEntry(
            expression: "sin(30)",
            result: "0.5",
            notes: "Test note"
        )
        
        XCTAssertEqual(entry.notes, "Test note")
    }
    
    func test_HistoryEntry_DefaultMode() {
        let entry = HistoryEntry(
            expression: "2+2",
            result: "4"
        )
        
        XCTAssertEqual(entry.mode, "Calculate")
    }
    
    func test_HistoryEntry_UniqueID() {
        let entry1 = HistoryEntry(expression: "2+2", result: "4")
        let entry2 = HistoryEntry(expression: "2+2", result: "4")
        
        XCTAssertNotEqual(entry1.id, entry2.id)
    }
    
    func test_HistoryEntry_Codable() throws {
        let entry = HistoryEntry(
            expression: "sin(30)",
            result: "0.5",
            notes: "Test note"
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(entry)
        let decoded = try decoder.decode(HistoryEntry.self, from: data)
        
        XCTAssertEqual(entry.expression, decoded.expression)
        XCTAssertEqual(entry.result, decoded.result)
        XCTAssertEqual(entry.notes, decoded.notes)
        XCTAssertEqual(entry.id, decoded.id)
        XCTAssertEqual(entry.mode, decoded.mode)
        XCTAssertEqual(entry.isError, decoded.isError)
    }
    
    func test_HistoryEntry_FormattedTime() {
        let entry = HistoryEntry(
            expression: "2+2",
            result: "4",
            timestamp: Date()
        )
        
        XCTAssertFalse(entry.formattedTime.isEmpty)
    }
    
    func test_HistoryEntry_FormattedDate() {
        let entry = HistoryEntry(
            expression: "2+2",
            result: "4",
            timestamp: Date()
        )
        
        XCTAssertFalse(entry.formattedDate.isEmpty)
    }
    
    func test_HistoryEntry_Equatable() {
        let id = UUID()
        let timestamp = Date()
        
        let entry1 = HistoryEntry(
            id: id,
            expression: "2+2",
            result: "4",
            timestamp: timestamp
        )
        let entry2 = HistoryEntry(
            id: id,
            expression: "2+2",
            result: "4",
            timestamp: timestamp
        )
        
        XCTAssertEqual(entry1, entry2)
    }
    
    // MARK: - History Filter Tests
    
    func test_HistoryFilter_All() {
        let entries = createTestEntries()
        let filtered = HistoryFilter.all.filter(entries)
        
        XCTAssertEqual(filtered.count, entries.count)
    }
    
    func test_HistoryFilter_ErrorsOnly() {
        let entries = createTestEntries()
        let filtered = HistoryFilter.errors.filter(entries)
        
        XCTAssertTrue(filtered.allSatisfy { $0.isError })
        XCTAssertEqual(filtered.count, 2)
    }
    
    func test_HistoryFilter_SuccessfulOnly() {
        let entries = createTestEntries()
        let filtered = HistoryFilter.successful.filter(entries)
        
        XCTAssertTrue(filtered.allSatisfy { !$0.isError })
        XCTAssertEqual(filtered.count, 2)
    }
    
    func test_HistoryFilter_Today() {
        let entries = [
            HistoryEntry(expression: "2+2", result: "4", timestamp: Date()),
            HistoryEntry(expression: "3+3", result: "6", timestamp: Date().addingTimeInterval(-86400 * 2))
        ]
        
        let filtered = HistoryFilter.today.filter(entries)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.expression, "2+2")
    }
    
    func test_HistoryFilter_ThisWeek() {
        let entries = [
            HistoryEntry(expression: "2+2", result: "4", timestamp: Date()),
            HistoryEntry(expression: "3+3", result: "6", timestamp: Date().addingTimeInterval(-86400 * 3)),
            HistoryEntry(expression: "4+4", result: "8", timestamp: Date().addingTimeInterval(-86400 * 10))
        ]
        
        let filtered = HistoryFilter.thisWeek.filter(entries)
        XCTAssertEqual(filtered.count, 2)
    }
    
    func test_HistoryFilter_ThisMonth() {
        let entries = [
            HistoryEntry(expression: "2+2", result: "4", timestamp: Date()),
            HistoryEntry(expression: "3+3", result: "6", timestamp: Date().addingTimeInterval(-86400 * 15)),
            HistoryEntry(expression: "4+4", result: "8", timestamp: Date().addingTimeInterval(-86400 * 60))
        ]
        
        let filtered = HistoryFilter.thisMonth.filter(entries)
        XCTAssertEqual(filtered.count, 2)
    }
    
    func test_HistoryFilter_AllCases() {
        XCTAssertEqual(HistoryFilter.allCases.count, 6)
    }
    
    func test_HistoryFilter_RawValues() {
        XCTAssertEqual(HistoryFilter.all.rawValue, "All")
        XCTAssertEqual(HistoryFilter.today.rawValue, "Today")
        XCTAssertEqual(HistoryFilter.thisWeek.rawValue, "This Week")
        XCTAssertEqual(HistoryFilter.thisMonth.rawValue, "This Month")
        XCTAssertEqual(HistoryFilter.errors.rawValue, "Errors Only")
        XCTAssertEqual(HistoryFilter.successful.rawValue, "Successful Only")
    }
    
    // MARK: - History Manager Tests
    
    func test_HistoryManager_Singleton() {
        let manager1 = HistoryManager.shared
        let manager2 = HistoryManager.shared
        XCTAssertTrue(manager1 === manager2)
    }
    
    func test_HistoryManager_MaxEntries() {
        let manager = HistoryManager.shared
        XCTAssertEqual(manager.maxEntries, 500)
    }
    
    func test_HistoryManager_AddEntry() {
        let manager = HistoryManager.shared
        let initialCount = manager.totalCount
        
        manager.addEntry(expression: "test_add", result: "result")
        
        XCTAssertEqual(manager.totalCount, initialCount + 1)
        XCTAssertEqual(manager.entries.first?.expression, "test_add")
        
        manager.deleteEntry(manager.entries.first!)
    }
    
    func test_HistoryManager_AddPrebuiltEntry() {
        let manager = HistoryManager.shared
        let entry = HistoryEntry(expression: "prebuilt", result: "test")
        let initialCount = manager.totalCount
        
        manager.addEntry(entry)
        
        XCTAssertEqual(manager.totalCount, initialCount + 1)
        XCTAssertEqual(manager.entries.first?.id, entry.id)
        
        manager.deleteEntry(entry)
    }
    
    func test_HistoryManager_DeleteEntry() {
        let manager = HistoryManager.shared
        manager.addEntry(expression: "to_delete", result: "test")
        let entry = manager.entries.first!
        let countAfterAdd = manager.totalCount
        
        manager.deleteEntry(entry)
        
        XCTAssertEqual(manager.totalCount, countAfterAdd - 1)
    }
    
    func test_HistoryManager_DeleteEntriesByIds() {
        let manager = HistoryManager.shared
        
        manager.addEntry(expression: "delete1", result: "1")
        manager.addEntry(expression: "delete2", result: "2")
        
        let idsToDelete = Set(manager.entries.prefix(2).map { $0.id })
        let countBeforeDelete = manager.totalCount
        
        manager.deleteEntries(ids: idsToDelete)
        
        XCTAssertEqual(manager.totalCount, countBeforeDelete - 2)
    }
    
    func test_HistoryManager_ClearAll() {
        let manager = HistoryManager.shared
        
        manager.addEntry(expression: "clear_test", result: "1")
        
        manager.clearAll()
        
        XCTAssertEqual(manager.totalCount, 0)
    }
    
    func test_HistoryManager_UpdateNotes() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "note_test", result: "1")
        let entryId = manager.entries.first!.id
        
        manager.updateNotes(for: entryId, notes: "Updated note")
        
        XCTAssertEqual(manager.entries.first?.notes, "Updated note")
        
        manager.clearAll()
    }
    
    func test_HistoryManager_FilteredEntries() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "success", result: "1", isError: false)
        manager.addEntry(expression: "error", result: "Error", isError: true)
        
        manager.filter = .errors
        XCTAssertEqual(manager.filteredEntries.count, 1)
        XCTAssertTrue(manager.filteredEntries.first?.isError ?? false)
        
        manager.filter = .successful
        XCTAssertEqual(manager.filteredEntries.count, 1)
        XCTAssertFalse(manager.filteredEntries.first?.isError ?? true)
        
        manager.filter = .all
        manager.clearAll()
    }
    
    func test_HistoryManager_SearchQuery() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "sin(30)", result: "0.5")
        manager.addEntry(expression: "cos(60)", result: "0.5")
        manager.addEntry(expression: "2+2", result: "4")
        
        manager.searchQuery = "sin"
        XCTAssertEqual(manager.filteredEntries.count, 1)
        XCTAssertEqual(manager.filteredEntries.first?.expression, "sin(30)")
        
        manager.searchQuery = "0.5"
        XCTAssertEqual(manager.filteredEntries.count, 2)
        
        manager.searchQuery = ""
        manager.clearAll()
    }
    
    func test_HistoryManager_TotalCount() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        XCTAssertEqual(manager.totalCount, 0)
        
        manager.addEntry(expression: "1", result: "1")
        manager.addEntry(expression: "2", result: "2")
        
        XCTAssertEqual(manager.totalCount, 2)
        
        manager.clearAll()
    }
    
    func test_HistoryManager_FilteredCount() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "1", result: "1", isError: false)
        manager.addEntry(expression: "2", result: "Error", isError: true)
        manager.addEntry(expression: "3", result: "3", isError: false)
        
        manager.filter = .all
        XCTAssertEqual(manager.filteredCount, 3)
        
        manager.filter = .errors
        XCTAssertEqual(manager.filteredCount, 1)
        
        manager.filter = .successful
        XCTAssertEqual(manager.filteredCount, 2)
        
        manager.filter = .all
        manager.clearAll()
    }
    
    // MARK: - Export Tests
    
    func test_Export_AsText() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "export_test", result: "result")
        
        let text = manager.exportAsText()
        XCTAssertTrue(text.contains("Calculation History"))
        XCTAssertTrue(text.contains("export_test"))
        XCTAssertTrue(text.contains("result"))
        XCTAssertTrue(text.contains("Total entries:"))
        
        manager.clearAll()
    }
    
    func test_Export_AsCSV() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "2+2", result: "4")
        
        let csv = manager.exportAsCSV()
        XCTAssertTrue(csv.contains("Timestamp,Mode,Expression,Result,Error,Notes"))
        XCTAssertTrue(csv.contains("2+2"))
        XCTAssertTrue(csv.contains("4"))
        
        manager.clearAll()
    }
    
    func test_Export_AsCSV_WithSpecialCharacters() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "test, with comma", result: "result")
        
        let csv = manager.exportAsCSV()
        XCTAssertTrue(csv.contains("\"test, with comma\""))
        
        manager.clearAll()
    }
    
    func test_Export_AsJSON() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "json_test", result: "result")
        
        let json = manager.exportAsJSON()
        XCTAssertNotNil(json)
        XCTAssertTrue(json!.contains("json_test"))
        XCTAssertTrue(json!.contains("result"))
        
        manager.clearAll()
    }
    
    func test_Export_AsJSON_ValidJSON() throws {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "test", result: "1")
        
        let json = manager.exportAsJSON()
        XCTAssertNotNil(json)
        
        let data = json!.data(using: .utf8)!
        let parsed = try JSONSerialization.jsonObject(with: data, options: [])
        XCTAssertTrue(parsed is [[String: Any]])
        
        manager.clearAll()
    }
    
    // MARK: - Statistics Tests
    
    func test_Statistics_Basic() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "1", result: "1", isError: false)
        manager.addEntry(expression: "2", result: "Error", isError: true)
        manager.addEntry(expression: "3", result: "3", isError: false)
        
        let stats = manager.getStatistics()
        
        XCTAssertEqual(stats.totalCalculations, 3)
        XCTAssertEqual(stats.successfulCalculations, 2)
        XCTAssertEqual(stats.errorCount, 1)
        
        manager.clearAll()
    }
    
    func test_Statistics_SuccessRate() {
        let stats = HistoryStatistics(
            totalCalculations: 100,
            successfulCalculations: 95,
            errorCount: 5,
            calculationsByMode: [:],
            oldestEntry: nil,
            newestEntry: nil
        )
        
        XCTAssertEqual(stats.successRate, 95.0, accuracy: 0.01)
    }
    
    func test_Statistics_ZeroTotal() {
        let stats = HistoryStatistics(
            totalCalculations: 0,
            successfulCalculations: 0,
            errorCount: 0,
            calculationsByMode: [:],
            oldestEntry: nil,
            newestEntry: nil
        )
        
        XCTAssertEqual(stats.successRate, 0)
    }
    
    func test_Statistics_CalculationsByMode() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "1", result: "1", mode: "Calculate")
        manager.addEntry(expression: "2", result: "2", mode: "Calculate")
        manager.addEntry(expression: "3", result: "3", mode: "Statistics")
        
        let stats = manager.getStatistics()
        
        XCTAssertEqual(stats.calculationsByMode["Calculate"], 2)
        XCTAssertEqual(stats.calculationsByMode["Statistics"], 1)
        
        manager.clearAll()
    }
    
    func test_Statistics_OldestNewestEntry() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "first", result: "1")
        Thread.sleep(forTimeInterval: 0.1)
        manager.addEntry(expression: "second", result: "2")
        
        let stats = manager.getStatistics()
        
        XCTAssertNotNil(stats.oldestEntry)
        XCTAssertNotNil(stats.newestEntry)
        XCTAssertTrue(stats.newestEntry! >= stats.oldestEntry!)
        
        manager.clearAll()
    }
    
    // MARK: - Grouped By Date Tests
    
    func test_GroupedByDate() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "1", result: "1")
        manager.addEntry(expression: "2", result: "2")
        
        let grouped = manager.groupedByDate
        XCTAssertFalse(grouped.isEmpty)
        XCTAssertEqual(grouped.first?.entries.count, 2)
        
        manager.clearAll()
    }
    
    // MARK: - Clear Filtered Tests
    
    func test_ClearFiltered() {
        let manager = HistoryManager.shared
        manager.clearAll()
        
        manager.addEntry(expression: "error1", result: "Error", isError: true)
        manager.addEntry(expression: "success", result: "1", isError: false)
        manager.addEntry(expression: "error2", result: "Error", isError: true)
        
        manager.filter = .errors
        manager.clearFiltered()
        
        manager.filter = .all
        XCTAssertEqual(manager.totalCount, 1)
        XCTAssertFalse(manager.entries.first?.isError ?? true)
        
        manager.clearAll()
    }
    
    // MARK: - Helpers
    
    private func createTestEntries() -> [HistoryEntry] {
        return [
            HistoryEntry(expression: "2+2", result: "4"),
            HistoryEntry(expression: "1/0", result: "Error", isError: true),
            HistoryEntry(expression: "sin(30)", result: "0.5"),
            HistoryEntry(expression: "sqrt(-1)", result: "Error", isError: true),
        ]
    }
}
