import Foundation

/// A single calculation history entry
struct HistoryEntry: Identifiable, Codable, Equatable {
    let id: UUID
    
    /// The input expression as entered
    let expression: String
    
    /// The calculated result as string
    let result: String
    
    /// Timestamp of calculation
    let timestamp: Date
    
    /// Calculator mode at time of calculation
    let mode: String
    
    /// Whether result was an error
    let isError: Bool
    
    /// Optional notes/tags
    var notes: String?
    
    /// Formatted timestamp for display
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    /// Formatted date only
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: timestamp)
    }
    
    init(
        id: UUID = UUID(),
        expression: String,
        result: String,
        timestamp: Date = Date(),
        mode: String = "Calculate",
        isError: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.expression = expression
        self.result = result
        self.timestamp = timestamp
        self.mode = mode
        self.isError = isError
        self.notes = notes
    }
}

/// Filter options for history
enum HistoryFilter: String, CaseIterable {
    case all = "All"
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case errors = "Errors Only"
    case successful = "Successful Only"
    
    /// Filters entries based on this filter
    func filter(_ entries: [HistoryEntry]) -> [HistoryEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .all:
            return entries
            
        case .today:
            return entries.filter { calendar.isDateInToday($0.timestamp) }
            
        case .thisWeek:
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else {
                return entries
            }
            return entries.filter { $0.timestamp >= weekAgo }
            
        case .thisMonth:
            guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) else {
                return entries
            }
            return entries.filter { $0.timestamp >= monthAgo }
            
        case .errors:
            return entries.filter { $0.isError }
            
        case .successful:
            return entries.filter { !$0.isError }
        }
    }
}

/// Manages calculation history with persistence
@Observable
class HistoryManager {
    
    // MARK: - Singleton
    
    static let shared = HistoryManager()
    
    // MARK: - Properties
    
    /// All history entries (newest first)
    private(set) var entries: [HistoryEntry] = []
    
    /// Maximum number of entries to store
    let maxEntries: Int = 500
    
    /// Current filter
    var filter: HistoryFilter = .all
    
    /// Search query
    var searchQuery: String = ""
    
    // MARK: - Computed Properties
    
    /// Filtered entries based on current filter and search
    var filteredEntries: [HistoryEntry] {
        var result = filter.filter(entries)
        
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter {
                $0.expression.lowercased().contains(query) ||
                $0.result.lowercased().contains(query) ||
                ($0.notes?.lowercased().contains(query) ?? false)
            }
        }
        
        return result
    }
    
    /// Entries grouped by date
    var groupedByDate: [(date: String, entries: [HistoryEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            entry.formattedDate
        }
        
        return grouped.map { (date: $0.key, entries: $0.value) }
            .sorted { $0.entries.first?.timestamp ?? Date() > $1.entries.first?.timestamp ?? Date() }
    }
    
    /// Total count
    var totalCount: Int { entries.count }
    
    /// Filtered count
    var filteredCount: Int { filteredEntries.count }
    
    // MARK: - Storage
    
    private let storageKey = "com.calculator.history"
    private let fileManager = FileManager.default
    
    private var storageURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("calculation_history.json")
    }
    
    // MARK: - Initialization
    
    private init() {
        loadHistory()
    }
    
    // MARK: - Add Entry
    
    /// Adds a new history entry
    func addEntry(expression: String, result: String, mode: String = "Calculate", isError: Bool = false) {
        let entry = HistoryEntry(
            expression: expression,
            result: result,
            mode: mode,
            isError: isError
        )
        
        entries.insert(entry, at: 0)
        
        // Trim if over max
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
        
        saveHistory()
    }
    
    /// Adds a pre-built entry
    func addEntry(_ entry: HistoryEntry) {
        entries.insert(entry, at: 0)
        
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
        
        saveHistory()
    }
    
    // MARK: - Update Entry
    
    /// Updates notes for an entry
    func updateNotes(for id: UUID, notes: String?) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            entries[index].notes = notes
            saveHistory()
        }
    }
    
    // MARK: - Delete
    
    /// Deletes a single entry
    func deleteEntry(_ entry: HistoryEntry) {
        entries.removeAll { $0.id == entry.id }
        saveHistory()
    }
    
    /// Deletes entries by IDs
    func deleteEntries(ids: Set<UUID>) {
        entries.removeAll { ids.contains($0.id) }
        saveHistory()
    }
    
    /// Clears all history
    func clearAll() {
        entries = []
        saveHistory()
    }
    
    /// Clears filtered entries only
    func clearFiltered() {
        let filteredIds = Set(filteredEntries.map { $0.id })
        entries.removeAll { filteredIds.contains($0.id) }
        saveHistory()
    }
    
    // MARK: - Persistence
    
    private func loadHistory() {
        guard let url = storageURL,
              let data = try? Data(contentsOf: url),
              let loaded = try? JSONDecoder().decode([HistoryEntry].self, from: data) else {
            return
        }
        entries = loaded
    }
    
    private func saveHistory() {
        guard let url = storageURL,
              let data = try? JSONEncoder().encode(entries) else {
            return
        }
        try? data.write(to: url, options: .atomic)
    }
    
    // MARK: - Export
    
    /// Exports history as plain text
    func exportAsText() -> String {
        var text = "Calculation History\n"
        text += "Exported: \(Date().formatted())\n"
        text += String(repeating: "=", count: 50) + "\n\n"
        
        for entry in filteredEntries {
            text += "[\(entry.formattedTime)] (\(entry.mode))\n"
            text += "  \(entry.expression)\n"
            text += "  = \(entry.result)\n"
            if let notes = entry.notes, !notes.isEmpty {
                text += "  Note: \(notes)\n"
            }
            text += "\n"
        }
        
        text += String(repeating: "=", count: 50) + "\n"
        text += "Total entries: \(filteredEntries.count)\n"
        
        return text
    }
    
    /// Exports history as CSV
    func exportAsCSV() -> String {
        var csv = "Timestamp,Mode,Expression,Result,Error,Notes\n"
        
        for entry in filteredEntries {
            let timestamp = entry.timestamp.ISO8601Format()
            let mode = entry.mode.escapedCSV
            let expr = entry.expression.escapedCSV
            let result = entry.result.escapedCSV
            let error = entry.isError ? "Yes" : "No"
            let notes = (entry.notes ?? "").escapedCSV
            
            csv += "\(timestamp),\(mode),\(expr),\(result),\(error),\(notes)\n"
        }
        
        return csv
    }
    
    /// Exports history as JSON
    func exportAsJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(filteredEntries) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Statistics
    
    /// Returns usage statistics
    func getStatistics() -> HistoryStatistics {
        let total = entries.count
        let errors = entries.filter { $0.isError }.count
        let successful = total - errors
        
        let modes = Dictionary(grouping: entries) { $0.mode }
            .mapValues { $0.count }
        
        let oldest = entries.last?.timestamp
        let newest = entries.first?.timestamp
        
        return HistoryStatistics(
            totalCalculations: total,
            successfulCalculations: successful,
            errorCount: errors,
            calculationsByMode: modes,
            oldestEntry: oldest,
            newestEntry: newest
        )
    }
}

// MARK: - Statistics Struct

struct HistoryStatistics {
    let totalCalculations: Int
    let successfulCalculations: Int
    let errorCount: Int
    let calculationsByMode: [String: Int]
    let oldestEntry: Date?
    let newestEntry: Date?
    
    var successRate: Double {
        guard totalCalculations > 0 else { return 0 }
        return Double(successfulCalculations) / Double(totalCalculations) * 100
    }
}

// MARK: - String Extension

private extension String {
    var escapedCSV: String {
        if contains(",") || contains("\"") || contains("\n") {
            return "\"\(replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return self
    }
}
