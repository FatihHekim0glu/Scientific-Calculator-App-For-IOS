import Foundation
import SwiftUI

// MARK: - TableRow

/// Represents a single row in the function table
struct TableRow: Identifiable, Equatable {
    let id = UUID()
    
    /// X value
    let x: Double
    
    /// f(X) value (nil if error)
    let fx: Double?
    
    /// g(X) value (nil if error or no g function)
    let gx: Double?
    
    /// Error message for f(x) if any
    let fError: String?
    
    /// Error message for g(x) if any
    let gError: String?
    
    static func == (lhs: TableRow, rhs: TableRow) -> Bool {
        lhs.x == rhs.x &&
        lhs.fx == rhs.fx &&
        lhs.gx == rhs.gx &&
        lhs.fError == rhs.fError &&
        lhs.gError == rhs.gError
    }
}

// MARK: - TableConfiguration

/// Configuration for table generation
struct TableConfiguration: Equatable {
    /// f(x) expression as string
    var fExpression: String = "x"
    
    /// g(x) expression as string (optional)
    var gExpression: String = ""
    
    /// Start value
    var start: Double = 0
    
    /// End value
    var end: Double = 10
    
    /// Step size
    var step: Double = 1
    
    /// Whether g(x) is enabled
    var gEnabled: Bool = false
    
    /// Variable name (default "x")
    var variable: String = "x"
    
    /// Maximum number of rows
    static let maxRows = 1000
    
    /// Validates the configuration
    func validate() throws {
        guard !fExpression.isEmpty else {
            throw CalculatorError.invalidInput("f(x) expression cannot be empty")
        }
        guard step > 0 else {
            throw CalculatorError.invalidInput("Step must be positive")
        }
        let rowCount = Int((end - start) / step) + 1
        guard rowCount <= Self.maxRows else {
            throw CalculatorError.invalidInput("Too many rows (max \(Self.maxRows))")
        }
        guard rowCount > 0 else {
            throw CalculatorError.invalidInput("End must be greater than start")
        }
    }
    
    /// Number of rows that will be generated
    var rowCount: Int {
        max(0, Int((end - start) / step) + 1)
    }
}

// MARK: - TableMode

/// Manages function table mode state
@Observable
class TableMode {
    
    // MARK: - Configuration
    
    /// Table configuration
    var config = TableConfiguration()
    
    // MARK: - Parsed Expressions
    
    /// Parsed AST for f(x)
    private var fAST: ASTNode?
    
    /// Parsed AST for g(x)
    private var gAST: ASTNode?
    
    // MARK: - Results
    
    /// Generated table rows
    private(set) var rows: [TableRow] = []
    
    /// Whether table is currently being generated
    private(set) var isGenerating: Bool = false
    
    /// Error message if generation failed
    private(set) var errorMessage: String?
    
    // MARK: - Evaluation Context
    
    /// Context for expression evaluation
    var context = EvaluationContext()
    
    // MARK: - Table Generation
    
    /// Generates the table with current configuration
    func generateTable() {
        errorMessage = nil
        rows = []
        
        do {
            try config.validate()
            
            // Parse f(x)
            var lexer = Lexer(input: config.fExpression)
            let fTokens = try lexer.tokenize()
            var parser = Parser(tokens: fTokens)
            fAST = try parser.parse()
            
            // Parse g(x) if enabled
            if config.gEnabled && !config.gExpression.isEmpty {
                var gLexer = Lexer(input: config.gExpression)
                let gTokens = try gLexer.tokenize()
                var gParser = Parser(tokens: gTokens)
                gAST = try gParser.parse()
            } else {
                gAST = nil
            }
            
            // Generate rows
            isGenerating = true
            rows = generateRows()
            isGenerating = false
            
        } catch let error as CalculatorError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Generates table rows
    private func generateRows() -> [TableRow] {
        var result: [TableRow] = []
        var x = config.start
        
        while x <= config.end + config.step / 2 {
            let row = evaluateRow(at: x)
            result.append(row)
            x += config.step
        }
        
        return result
    }
    
    /// Evaluates f(x) and g(x) at a single x value
    private func evaluateRow(at x: Double) -> TableRow {
        var ctx = context
        ctx.variables[config.variable] = x
        var evaluator = Evaluator(context: ctx)
        
        // Evaluate f(x)
        var fx: Double? = nil
        var fError: String? = nil
        if let fNode = fAST {
            do {
                let result = try evaluator.evaluate(fNode)
                fx = result.doubleValue
            } catch let error as CalculatorError {
                fError = error.localizedDescription
            } catch {
                fError = error.localizedDescription
            }
        }
        
        // Evaluate g(x)
        var gx: Double? = nil
        var gError: String? = nil
        if let gNode = gAST {
            do {
                let result = try evaluator.evaluate(gNode)
                gx = result.doubleValue
            } catch let error as CalculatorError {
                gError = error.localizedDescription
            } catch {
                gError = error.localizedDescription
            }
        }
        
        return TableRow(x: x, fx: fx, gx: gx, fError: fError, gError: gError)
    }
    
    // MARK: - Quick Access
    
    /// Sets f(x) expression
    func setFExpression(_ expression: String) {
        config.fExpression = expression
    }
    
    /// Sets g(x) expression
    func setGExpression(_ expression: String) {
        config.gExpression = expression
        config.gEnabled = !expression.isEmpty
    }
    
    /// Sets range (start, end, step)
    func setRange(start: Double, end: Double, step: Double) {
        config.start = start
        config.end = end
        config.step = step
    }
    
    // MARK: - Reset
    
    /// Resets to default state
    func reset() {
        config = TableConfiguration()
        rows = []
        fAST = nil
        gAST = nil
        errorMessage = nil
    }
    
    // MARK: - Export
    
    /// Exports table as CSV string
    func exportCSV() -> String {
        var csv = config.gEnabled ? "X,f(X),g(X)\n" : "X,f(X)\n"
        
        for row in rows {
            let fStr = row.fx.map { formatNumber($0) } ?? "Error"
            if config.gEnabled {
                let gStr = row.gx.map { formatNumber($0) } ?? "Error"
                csv += "\(formatNumber(row.x)),\(fStr),\(gStr)\n"
            } else {
                csv += "\(formatNumber(row.x)),\(fStr)\n"
            }
        }
        
        return csv
    }
    
    // MARK: - Private Helpers
    
    /// Formats a number for display
    private func formatNumber(_ value: Double) -> String {
        if value == floor(value) && abs(value) < 1e10 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.10g", value)
    }
}
