import Foundation
import SwiftUI

/// Manages spreadsheet mode state
@Observable
class SpreadsheetMode {
    
    // MARK: - Spreadsheet Data
    
    /// The spreadsheet model
    private(set) var spreadsheet = Spreadsheet()
    
    // MARK: - Selection State
    
    /// Currently selected cell
    var selectedCell: CellReference? = nil
    
    /// Selection range (for copy/paste/clear)
    var selectionRange: CellRange? = nil
    
    /// Clipboard content
    private var clipboard: (content: CellContent, sourceRef: CellReference)? = nil
    
    // MARK: - Edit State
    
    /// Whether currently editing a cell
    var isEditing: Bool = false
    
    /// Current edit text
    var editText: String = ""
    
    // MARK: - Display Options
    
    /// Whether to show formulas instead of values
    var showFormulas: Bool = false
    
    /// Column widths (for UI)
    var columnWidths: [CGFloat] = Array(repeating: 80, count: Spreadsheet.columns)
    
    // MARK: - Cell Operations
    
    /// Selects a cell
    func selectCell(_ ref: CellReference) {
        selectedCell = ref
        selectionRange = nil
        isEditing = false
        editText = spreadsheet.cell(at: ref).content.rawString
    }
    
    /// Starts editing the selected cell
    func startEditing() {
        guard let ref = selectedCell else { return }
        isEditing = true
        editText = spreadsheet.cell(at: ref).content.rawString
    }
    
    /// Commits the current edit
    func commitEdit() {
        guard let ref = selectedCell else { return }
        spreadsheet.setCell(at: ref, content: editText)
        isEditing = false
    }
    
    /// Cancels the current edit
    func cancelEdit() {
        isEditing = false
        if let ref = selectedCell {
            editText = spreadsheet.cell(at: ref).content.rawString
        }
    }
    
    /// Sets cell content directly
    func setCell(_ ref: CellReference, content: String) {
        spreadsheet.setCell(at: ref, content: content)
    }
    
    /// Gets display value for a cell
    func displayValue(at ref: CellReference) -> String {
        let cell = spreadsheet.cell(at: ref)
        if showFormulas {
            return cell.content.rawString
        }
        return cell.displayValue
    }
    
    // MARK: - Navigation
    
    /// Moves selection by delta
    func moveSelection(rowDelta: Int, colDelta: Int) {
        guard let current = selectedCell else {
            // If nothing selected, select A1
            selectedCell = try? CellReference(column: 0, row: 0)
            return
        }
        
        let newCol = max(0, min(Spreadsheet.columns - 1, current.column + colDelta))
        let newRow = max(0, min(Spreadsheet.rows - 1, current.row + rowDelta))
        
        if let newRef = try? CellReference(column: newCol, row: newRow) {
            selectCell(newRef)
        }
    }
    
    /// Moves to next cell (right, then down)
    func moveToNext() {
        guard let current = selectedCell else { return }
        
        if current.column < Spreadsheet.columns - 1 {
            moveSelection(rowDelta: 0, colDelta: 1)
        } else if current.row < Spreadsheet.rows - 1 {
            if let newRef = try? CellReference(column: 0, row: current.row + 1) {
                selectCell(newRef)
            }
        }
    }
    
    // MARK: - Clipboard Operations
    
    /// Copies selected cell
    func copy() {
        guard let ref = selectedCell else { return }
        let cell = spreadsheet.cell(at: ref)
        clipboard = (cell.content, ref)
    }
    
    /// Cuts selected cell (copy + clear)
    func cut() {
        copy()
        clearSelected()
    }
    
    /// Pastes to selected cell
    func paste() {
        guard let ref = selectedCell,
              let clip = clipboard else { return }
        
        spreadsheet.copyCell(from: clip.sourceRef, to: ref)
    }
    
    /// Clears selected cell
    func clearSelected() {
        guard let ref = selectedCell else { return }
        spreadsheet.clearCell(at: ref)
        editText = ""
    }
    
    /// Clears selection range
    func clearRange() {
        if let range = selectionRange {
            spreadsheet.clearRange(range)
        } else if let ref = selectedCell {
            spreadsheet.clearCell(at: ref)
        }
        editText = ""
    }
    
    // MARK: - Range Selection
    
    /// Extends selection to create a range
    func extendSelection(to ref: CellReference) {
        guard let start = selectedCell else {
            selectCell(ref)
            return
        }
        selectionRange = CellRange(start: start, end: ref)
    }
    
    /// Whether a cell is in the current selection
    func isSelected(_ ref: CellReference) -> Bool {
        if let range = selectionRange {
            return range.cells.contains(ref)
        }
        return selectedCell == ref
    }
    
    // MARK: - Reset
    
    /// Clears the entire spreadsheet
    func clearAll() {
        spreadsheet.clearAll()
        selectedCell = nil
        selectionRange = nil
        isEditing = false
        editText = ""
    }
    
    /// Resets to default state
    func reset() {
        spreadsheet = Spreadsheet()
        selectedCell = nil
        selectionRange = nil
        isEditing = false
        editText = ""
        showFormulas = false
        clipboard = nil
    }
    
    // MARK: - Export
    
    /// Exports spreadsheet as CSV
    func exportCSV() -> String {
        var csv = ""
        
        // Header row
        csv += CellReference.columnLetters.joined(separator: ",") + "\n"
        
        // Data rows
        for row in 0..<Spreadsheet.rows {
            var rowData: [String] = []
            for col in 0..<Spreadsheet.columns {
                if let ref = try? CellReference(column: col, row: row) {
                    let value = displayValue(at: ref)
                    // Escape commas and quotes
                    if value.contains(",") || value.contains("\"") {
                        rowData.append("\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\"")
                    } else {
                        rowData.append(value)
                    }
                }
            }
            csv += rowData.joined(separator: ",") + "\n"
        }
        
        return csv
    }
}
