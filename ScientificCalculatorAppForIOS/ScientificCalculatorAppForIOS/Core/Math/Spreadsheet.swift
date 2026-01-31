import Foundation

// MARK: - CellReference

/// Reference to a spreadsheet cell (e.g., A1, B2)
struct CellReference: Hashable, CustomStringConvertible {
    /// Column (0 = A, 1 = B, etc.)
    let column: Int
    
    /// Row (0-indexed internally, displayed as 1-indexed)
    let row: Int
    
    /// Maximum column index (A-E = 0-4)
    static let maxColumn = 4
    
    /// Maximum row index (1-45 = 0-44)
    static let maxRow = 44
    
    /// Column letters
    static let columnLetters = ["A", "B", "C", "D", "E"]
    
    /// Creates a cell reference from column and row indices
    init(column: Int, row: Int) throws {
        guard column >= 0 && column <= Self.maxColumn else {
            throw CalculatorError.rangeError("Column out of range (A-E)")
        }
        guard row >= 0 && row <= Self.maxRow else {
            throw CalculatorError.rangeError("Row out of range (1-45)")
        }
        self.column = column
        self.row = row
    }
    
    /// Parses a cell reference from string (e.g., "A1", "B12")
    init(string: String) throws {
        let s = string.uppercased().trimmingCharacters(in: .whitespaces)
        guard s.count >= 2 else {
            throw CalculatorError.syntaxError("Invalid cell reference: \(string)")
        }
        
        guard let colChar = s.first,
              let colIndex = Self.columnLetters.firstIndex(of: String(colChar)) else {
            throw CalculatorError.syntaxError("Invalid column: \(string)")
        }
        
        guard let rowNum = Int(s.dropFirst()), rowNum >= 1, rowNum <= 45 else {
            throw CalculatorError.syntaxError("Invalid row: \(string)")
        }
        
        self.column = colIndex
        self.row = rowNum - 1
    }
    
    /// String representation (e.g., "A1")
    var description: String {
        "\(Self.columnLetters[column])\(row + 1)"
    }
    
    /// Column letter
    var columnLetter: String {
        Self.columnLetters[column]
    }
    
    /// Display row number (1-indexed)
    var displayRow: Int {
        row + 1
    }
}

// MARK: - CellRange

/// Range of cells (e.g., A1:A10)
struct CellRange: Hashable {
    let start: CellReference
    let end: CellReference
    
    /// Parses a range from string (e.g., "A1:A10")
    init(string: String) throws {
        let parts = string.uppercased().split(separator: ":")
        guard parts.count == 2 else {
            throw CalculatorError.syntaxError("Invalid range: \(string)")
        }
        
        start = try CellReference(string: String(parts[0]))
        end = try CellReference(string: String(parts[1]))
    }
    
    init(start: CellReference, end: CellReference) {
        self.start = start
        self.end = end
    }
    
    /// All cells in this range
    var cells: [CellReference] {
        var result: [CellReference] = []
        let minCol = min(start.column, end.column)
        let maxCol = max(start.column, end.column)
        let minRow = min(start.row, end.row)
        let maxRow = max(start.row, end.row)
        
        for col in minCol...maxCol {
            for row in minRow...maxRow {
                if let ref = try? CellReference(column: col, row: row) {
                    result.append(ref)
                }
            }
        }
        return result
    }
    
    /// Number of cells in range
    var count: Int {
        let cols = abs(end.column - start.column) + 1
        let rows = abs(end.row - start.row) + 1
        return cols * rows
    }
}

// MARK: - CellContent

/// Content of a spreadsheet cell
enum CellContent: Equatable {
    /// Empty cell
    case empty
    
    /// Numeric value
    case number(Double)
    
    /// Text string
    case text(String)
    
    /// Formula (stored as original string)
    case formula(String)
    
    /// Error state
    case error(String)
    
    /// Whether this cell contains a formula
    var isFormula: Bool {
        if case .formula = self { return true }
        return false
    }
    
    /// Raw display string (formula shows =formula)
    var rawString: String {
        switch self {
        case .empty: return ""
        case .number(let n): return formatNumber(n)
        case .text(let s): return s
        case .formula(let f): return "=\(f)"
        case .error(let e): return "#\(e)"
        }
    }
    
    private func formatNumber(_ n: Double) -> String {
        if n == floor(n) && abs(n) < 1e10 {
            return String(format: "%.0f", n)
        }
        return String(format: "%.10g", n)
    }
}

// MARK: - Cell

/// A spreadsheet cell with content and computed value
struct Cell: Equatable {
    /// Cell content (what user entered)
    var content: CellContent
    
    /// Computed value (result of formula evaluation)
    var computedValue: Double?
    
    /// Error from formula evaluation
    var evaluationError: String?
    
    /// Display value
    var displayValue: String {
        if let error = evaluationError {
            return "#\(error)"
        }
        if let value = computedValue {
            return formatNumber(value)
        }
        switch content {
        case .empty: return ""
        case .number(let n): return formatNumber(n)
        case .text(let s): return s
        case .formula: return "#VALUE"
        case .error(let e): return "#\(e)"
        }
    }
    
    private func formatNumber(_ n: Double) -> String {
        if n == floor(n) && abs(n) < 1e10 {
            return String(format: "%.0f", n)
        }
        return String(format: "%.10g", n)
    }
}

// MARK: - SpreadsheetFunction

/// Spreadsheet functions
enum SpreadsheetFunction: String, CaseIterable {
    case sum = "SUM"
    case average = "AVERAGE"
    case mean = "MEAN"
    case min = "MIN"
    case max = "MAX"
    case count = "COUNT"
    
    /// Evaluates the function on a range of values
    func evaluate(_ values: [Double]) -> Double {
        switch self {
        case .sum:
            return values.reduce(0, +)
        case .average, .mean:
            guard !values.isEmpty else { return 0 }
            return values.reduce(0, +) / Double(values.count)
        case .min:
            return values.min() ?? 0
        case .max:
            return values.max() ?? 0
        case .count:
            return Double(values.count)
        }
    }
}

// MARK: - Spreadsheet

/// Spreadsheet data model with formula evaluation
class Spreadsheet {
    
    // MARK: - Grid
    
    /// Number of columns (A-E)
    static let columns = 5
    
    /// Number of rows (1-45)
    static let rows = 45
    
    /// Cell storage [row][column]
    private var cells: [[Cell]]
    
    // MARK: - Initialization
    
    init() {
        cells = Array(
            repeating: Array(repeating: Cell(content: .empty, computedValue: nil, evaluationError: nil),
                            count: Self.columns),
            count: Self.rows
        )
    }
    
    // MARK: - Cell Access
    
    /// Gets cell at reference
    func cell(at ref: CellReference) -> Cell {
        cells[ref.row][ref.column]
    }
    
    /// Gets cell value (computed or raw number)
    func value(at ref: CellReference) -> Double? {
        let c = cell(at: ref)
        if let computed = c.computedValue {
            return computed
        }
        if case .number(let n) = c.content {
            return n
        }
        return nil
    }
    
    /// Sets cell content and recalculates
    func setCell(at ref: CellReference, content: String) {
        let parsed = parseContent(content)
        cells[ref.row][ref.column].content = parsed
        recalculate()
    }
    
    /// Clears a cell
    func clearCell(at ref: CellReference) {
        cells[ref.row][ref.column] = Cell(content: .empty, computedValue: nil, evaluationError: nil)
        recalculate()
    }
    
    /// Clears a range of cells
    func clearRange(_ range: CellRange) {
        for cellRef in range.cells {
            cells[cellRef.row][cellRef.column] = Cell(content: .empty, computedValue: nil, evaluationError: nil)
        }
        recalculate()
    }
    
    /// Clears all cells
    func clearAll() {
        for row in 0..<Self.rows {
            for col in 0..<Self.columns {
                cells[row][col] = Cell(content: .empty, computedValue: nil, evaluationError: nil)
            }
        }
    }
    
    // MARK: - Content Parsing
    
    /// Parses cell content from string
    private func parseContent(_ input: String) -> CellContent {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        
        if trimmed.isEmpty {
            return .empty
        }
        
        // Formula starts with =
        if trimmed.hasPrefix("=") {
            return .formula(String(trimmed.dropFirst()))
        }
        
        // Try to parse as number
        if let number = Double(trimmed) {
            return .number(number)
        }
        
        // Otherwise it's text
        return .text(trimmed)
    }
    
    // MARK: - Formula Evaluation
    
    /// Recalculates all formulas
    func recalculate() {
        // Simple approach: iterate until no changes (handles dependencies)
        var changed = true
        var iterations = 0
        let maxIterations = 100
        
        while changed && iterations < maxIterations {
            changed = false
            iterations += 1
            
            for row in 0..<Self.rows {
                for col in 0..<Self.columns {
                    if case .formula(let formula) = cells[row][col].content {
                        let oldValue = cells[row][col].computedValue
                        let (value, error) = evaluateFormula(formula)
                        cells[row][col].computedValue = value
                        cells[row][col].evaluationError = error
                        
                        if value != oldValue {
                            changed = true
                        }
                    } else if case .number(let n) = cells[row][col].content {
                        cells[row][col].computedValue = n
                        cells[row][col].evaluationError = nil
                    } else {
                        cells[row][col].computedValue = nil
                        cells[row][col].evaluationError = nil
                    }
                }
            }
        }
    }
    
    /// Evaluates a formula string
    private func evaluateFormula(_ formula: String) -> (Double?, String?) {
        do {
            let value = try parseAndEvaluate(formula)
            return (value, nil)
        } catch let error as CalculatorError {
            return (nil, error.localizedDescription)
        } catch {
            return (nil, error.localizedDescription)
        }
    }
    
    /// Parses and evaluates a formula
    private func parseAndEvaluate(_ formula: String) throws -> Double {
        // Handle spreadsheet functions: SUM(A1:A10), etc.
        let upperFormula = formula.uppercased()
        
        for fn in SpreadsheetFunction.allCases {
            if upperFormula.hasPrefix("\(fn.rawValue)(") {
                return try evaluateFunction(fn, formula: formula)
            }
        }
        
        // Handle cell references and basic arithmetic
        return try evaluateExpression(formula)
    }
    
    /// Evaluates a spreadsheet function
    private func evaluateFunction(_ fn: SpreadsheetFunction, formula: String) throws -> Double {
        // Extract range from SUM(A1:A10)
        let start = formula.index(formula.startIndex, offsetBy: fn.rawValue.count + 1)
        guard let end = formula.lastIndex(of: ")") else {
            throw CalculatorError.syntaxError("Missing closing parenthesis")
        }
        let rangeStr = String(formula[start..<end])
        
        // Parse range
        let range = try CellRange(string: rangeStr)
        
        // Get values
        let values = range.cells.compactMap { value(at: $0) }
        
        return fn.evaluate(values)
    }
    
    /// Evaluates an expression with cell references
    private func evaluateExpression(_ formula: String) throws -> Double {
        // Replace cell references with their values
        var expr = formula
        
        // Find and replace cell references (e.g., A1, B2)
        let pattern = "[A-E][0-9]+"
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(expr.startIndex..., in: expr)
        let matches = regex.matches(in: expr, options: [], range: range)
        
        // Replace in reverse order to preserve indices
        for match in matches.reversed() {
            if let swiftRange = Range(match.range, in: expr) {
                let refString = String(expr[swiftRange])
                let ref = try CellReference(string: refString)
                if let val = value(at: ref) {
                    expr.replaceSubrange(swiftRange, with: String(val))
                } else {
                    throw CalculatorError.invalidInput("Cell \(refString) has no numeric value")
                }
            }
        }
        
        // Now evaluate the numeric expression using the expression engine
        var lexer = Lexer(input: expr)
        let tokens = try lexer.tokenize()
        var parser = Parser(tokens: tokens)
        let ast = try parser.parse()
        var evaluator = Evaluator()
        let result = try evaluator.evaluate(ast)
        
        guard let doubleValue = result.doubleValue else {
            throw CalculatorError.mathError("Formula must evaluate to a number")
        }
        
        return doubleValue
    }
    
    // MARK: - Copy/Paste (relative references)
    
    /// Copies cell content with relative reference adjustment
    func copyCell(from source: CellReference, to dest: CellReference) {
        let sourceCell = cell(at: source)
        
        if case .formula(let formula) = sourceCell.content {
            // Adjust relative references
            let adjusted = adjustReferences(formula, rowDelta: dest.row - source.row, colDelta: dest.column - source.column)
            cells[dest.row][dest.column].content = .formula(adjusted)
        } else {
            cells[dest.row][dest.column].content = sourceCell.content
        }
        
        recalculate()
    }
    
    /// Adjusts cell references in a formula by delta
    private func adjustReferences(_ formula: String, rowDelta: Int, colDelta: Int) -> String {
        var result = formula
        let pattern = "[A-E][0-9]+"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return formula
        }
        
        let range = NSRange(result.startIndex..., in: result)
        let matches = regex.matches(in: result, options: [], range: range)
        
        for match in matches.reversed() {
            if let swiftRange = Range(match.range, in: result),
               let ref = try? CellReference(string: String(result[swiftRange])),
               let newRef = try? CellReference(column: ref.column + colDelta, row: ref.row + rowDelta) {
                result.replaceSubrange(swiftRange, with: newRef.description)
            }
        }
        
        return result
    }
}
