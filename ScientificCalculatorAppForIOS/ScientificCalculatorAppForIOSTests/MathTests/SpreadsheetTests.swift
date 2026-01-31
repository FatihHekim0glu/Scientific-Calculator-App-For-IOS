import XCTest
@testable import ScientificCalculatorAppForIOS

final class SpreadsheetTests: XCTestCase {
    var spreadsheet: Spreadsheet!
    
    override func setUp() {
        super.setUp()
        spreadsheet = Spreadsheet()
    }
    
    override func tearDown() {
        spreadsheet = nil
        super.tearDown()
    }
    
    // MARK: - CellReference Parse Tests
    
    func test_CellReference_ParseA1() throws {
        let ref = try CellReference(string: "A1")
        XCTAssertEqual(ref.column, 0)
        XCTAssertEqual(ref.row, 0)
    }
    
    func test_CellReference_ParseB12() throws {
        let ref = try CellReference(string: "B12")
        XCTAssertEqual(ref.column, 1)
        XCTAssertEqual(ref.row, 11)
    }
    
    func test_CellReference_ParseE45() throws {
        let ref = try CellReference(string: "E45")
        XCTAssertEqual(ref.column, 4)
        XCTAssertEqual(ref.row, 44)
    }
    
    func test_CellReference_ParseLowercase() throws {
        let ref = try CellReference(string: "c10")
        XCTAssertEqual(ref.column, 2)
        XCTAssertEqual(ref.row, 9)
    }
    
    func test_CellReference_ParseWithWhitespace() throws {
        let ref = try CellReference(string: "  D5  ")
        XCTAssertEqual(ref.column, 3)
        XCTAssertEqual(ref.row, 4)
    }
    
    func test_CellReference_InvalidColumn_ThrowsError() {
        XCTAssertThrowsError(try CellReference(string: "F1")) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntaxError")
                return
            }
        }
    }
    
    func test_CellReference_InvalidRow_ThrowsError() {
        XCTAssertThrowsError(try CellReference(string: "A46")) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntaxError")
                return
            }
        }
    }
    
    func test_CellReference_InvalidRow_Zero_ThrowsError() {
        XCTAssertThrowsError(try CellReference(string: "A0")) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntaxError")
                return
            }
        }
    }
    
    func test_CellReference_TooShort_ThrowsError() {
        XCTAssertThrowsError(try CellReference(string: "A")) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntaxError")
                return
            }
        }
    }
    
    // MARK: - CellReference Creation Tests
    
    func test_CellReference_CreateFromIndices() throws {
        let ref = try CellReference(column: 2, row: 4)
        XCTAssertEqual(ref.column, 2)
        XCTAssertEqual(ref.row, 4)
    }
    
    func test_CellReference_CreateInvalidColumn_ThrowsError() {
        XCTAssertThrowsError(try CellReference(column: 5, row: 0)) { error in
            guard case CalculatorError.rangeError = error else {
                XCTFail("Expected rangeError")
                return
            }
        }
    }
    
    func test_CellReference_CreateInvalidRow_ThrowsError() {
        XCTAssertThrowsError(try CellReference(column: 0, row: 45)) { error in
            guard case CalculatorError.rangeError = error else {
                XCTFail("Expected rangeError")
                return
            }
        }
    }
    
    func test_CellReference_CreateNegativeColumn_ThrowsError() {
        XCTAssertThrowsError(try CellReference(column: -1, row: 0)) { error in
            guard case CalculatorError.rangeError = error else {
                XCTFail("Expected rangeError")
                return
            }
        }
    }
    
    // MARK: - CellReference Property Tests
    
    func test_CellReference_Description() throws {
        let ref = try CellReference(column: 2, row: 4)
        XCTAssertEqual(ref.description, "C5")
    }
    
    func test_CellReference_ColumnLetter() throws {
        let ref = try CellReference(column: 3, row: 0)
        XCTAssertEqual(ref.columnLetter, "D")
    }
    
    func test_CellReference_DisplayRow() throws {
        let ref = try CellReference(column: 0, row: 9)
        XCTAssertEqual(ref.displayRow, 10)
    }
    
    func test_CellReference_Hashable() throws {
        let ref1 = try CellReference(string: "A1")
        let ref2 = try CellReference(string: "A1")
        let ref3 = try CellReference(string: "B1")
        
        XCTAssertEqual(ref1, ref2)
        XCTAssertNotEqual(ref1, ref3)
        
        var set = Set<CellReference>()
        set.insert(ref1)
        set.insert(ref2)
        XCTAssertEqual(set.count, 1)
    }
    
    // MARK: - CellRange Tests
    
    func test_CellRange_SingleColumn() throws {
        let range = try CellRange(string: "A1:A5")
        XCTAssertEqual(range.count, 5)
        XCTAssertEqual(range.cells.count, 5)
    }
    
    func test_CellRange_SingleRow() throws {
        let range = try CellRange(string: "A1:E1")
        XCTAssertEqual(range.count, 5)
    }
    
    func test_CellRange_Rectangle() throws {
        let range = try CellRange(string: "A1:C3")
        XCTAssertEqual(range.count, 9)
    }
    
    func test_CellRange_SingleCell() throws {
        let range = try CellRange(string: "B2:B2")
        XCTAssertEqual(range.count, 1)
    }
    
    func test_CellRange_ReversedOrder() throws {
        let range = try CellRange(string: "C3:A1")
        XCTAssertEqual(range.count, 9)
    }
    
    func test_CellRange_InvalidFormat_ThrowsError() {
        XCTAssertThrowsError(try CellRange(string: "A1A5")) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntaxError")
                return
            }
        }
    }
    
    func test_CellRange_CellsContainsCorrectReferences() throws {
        let range = try CellRange(string: "A1:B2")
        let cells = range.cells
        XCTAssertEqual(cells.count, 4)
    }
    
    // MARK: - CellContent Tests
    
    func test_CellContent_EmptyRawString() {
        let content = CellContent.empty
        XCTAssertEqual(content.rawString, "")
        XCTAssertFalse(content.isFormula)
    }
    
    func test_CellContent_NumberRawString() {
        let content = CellContent.number(42)
        XCTAssertEqual(content.rawString, "42")
    }
    
    func test_CellContent_NumberDecimalRawString() {
        let content = CellContent.number(3.14159)
        XCTAssertTrue(content.rawString.hasPrefix("3.14"))
    }
    
    func test_CellContent_TextRawString() {
        let content = CellContent.text("Hello")
        XCTAssertEqual(content.rawString, "Hello")
    }
    
    func test_CellContent_FormulaRawString() {
        let content = CellContent.formula("A1+B1")
        XCTAssertEqual(content.rawString, "=A1+B1")
        XCTAssertTrue(content.isFormula)
    }
    
    func test_CellContent_ErrorRawString() {
        let content = CellContent.error("DIV/0")
        XCTAssertEqual(content.rawString, "#DIV/0")
    }
    
    // MARK: - Cell Tests
    
    func test_Cell_DisplayValue_Number() {
        let cell = Cell(content: .number(42), computedValue: nil, evaluationError: nil)
        XCTAssertEqual(cell.displayValue, "42")
    }
    
    func test_Cell_DisplayValue_WithComputedValue() {
        let cell = Cell(content: .formula("A1+1"), computedValue: 10, evaluationError: nil)
        XCTAssertEqual(cell.displayValue, "10")
    }
    
    func test_Cell_DisplayValue_WithError() {
        let cell = Cell(content: .formula("A1/0"), computedValue: nil, evaluationError: "Division by zero")
        XCTAssertEqual(cell.displayValue, "#Division by zero")
    }
    
    func test_Cell_DisplayValue_Empty() {
        let cell = Cell(content: .empty, computedValue: nil, evaluationError: nil)
        XCTAssertEqual(cell.displayValue, "")
    }
    
    func test_Cell_DisplayValue_Text() {
        let cell = Cell(content: .text("Hello"), computedValue: nil, evaluationError: nil)
        XCTAssertEqual(cell.displayValue, "Hello")
    }
    
    // MARK: - SpreadsheetFunction Tests
    
    func test_SpreadsheetFunction_Sum() {
        let result = SpreadsheetFunction.sum.evaluate([1, 2, 3, 4, 5])
        XCTAssertEqual(result, 15)
    }
    
    func test_SpreadsheetFunction_Sum_Empty() {
        let result = SpreadsheetFunction.sum.evaluate([])
        XCTAssertEqual(result, 0)
    }
    
    func test_SpreadsheetFunction_Average() {
        let result = SpreadsheetFunction.average.evaluate([10, 20, 30])
        XCTAssertEqual(result, 20)
    }
    
    func test_SpreadsheetFunction_Average_Empty() {
        let result = SpreadsheetFunction.average.evaluate([])
        XCTAssertEqual(result, 0)
    }
    
    func test_SpreadsheetFunction_Mean() {
        let result = SpreadsheetFunction.mean.evaluate([10, 20, 30])
        XCTAssertEqual(result, 20)
    }
    
    func test_SpreadsheetFunction_Min() {
        let result = SpreadsheetFunction.min.evaluate([5, 2, 8, 1, 9])
        XCTAssertEqual(result, 1)
    }
    
    func test_SpreadsheetFunction_Min_Empty() {
        let result = SpreadsheetFunction.min.evaluate([])
        XCTAssertEqual(result, 0)
    }
    
    func test_SpreadsheetFunction_Max() {
        let result = SpreadsheetFunction.max.evaluate([5, 2, 8, 1, 9])
        XCTAssertEqual(result, 9)
    }
    
    func test_SpreadsheetFunction_Max_Empty() {
        let result = SpreadsheetFunction.max.evaluate([])
        XCTAssertEqual(result, 0)
    }
    
    func test_SpreadsheetFunction_Count() {
        let result = SpreadsheetFunction.count.evaluate([1, 2, 3, 4, 5])
        XCTAssertEqual(result, 5)
    }
    
    func test_SpreadsheetFunction_Count_Empty() {
        let result = SpreadsheetFunction.count.evaluate([])
        XCTAssertEqual(result, 0)
    }
    
    // MARK: - Spreadsheet Dimensions
    
    func test_Spreadsheet_Columns() {
        XCTAssertEqual(Spreadsheet.columns, 5)
    }
    
    func test_Spreadsheet_Rows() {
        XCTAssertEqual(Spreadsheet.rows, 45)
    }
    
    // MARK: - Basic Cell Operations
    
    func test_SetCell_Number() throws {
        let ref = try CellReference(string: "A1")
        spreadsheet.setCell(at: ref, content: "42")
        XCTAssertEqual(spreadsheet.value(at: ref), 42)
    }
    
    func test_SetCell_Decimal() throws {
        let ref = try CellReference(string: "A1")
        spreadsheet.setCell(at: ref, content: "3.14")
        XCTAssertEqual(spreadsheet.value(at: ref)!, 3.14, accuracy: 1e-10)
    }
    
    func test_SetCell_Negative() throws {
        let ref = try CellReference(string: "A1")
        spreadsheet.setCell(at: ref, content: "-100")
        XCTAssertEqual(spreadsheet.value(at: ref), -100)
    }
    
    func test_SetCell_Text() throws {
        let ref = try CellReference(string: "A1")
        spreadsheet.setCell(at: ref, content: "Hello")
        XCTAssertNil(spreadsheet.value(at: ref))
        
        let cell = spreadsheet.cell(at: ref)
        if case .text(let text) = cell.content {
            XCTAssertEqual(text, "Hello")
        } else {
            XCTFail("Expected text content")
        }
    }
    
    func test_SetCell_Empty() throws {
        let ref = try CellReference(string: "A1")
        spreadsheet.setCell(at: ref, content: "42")
        spreadsheet.setCell(at: ref, content: "")
        XCTAssertNil(spreadsheet.value(at: ref))
    }
    
    func test_SetCell_Whitespace() throws {
        let ref = try CellReference(string: "A1")
        spreadsheet.setCell(at: ref, content: "   ")
        XCTAssertNil(spreadsheet.value(at: ref))
    }
    
    func test_ClearCell() throws {
        let ref = try CellReference(string: "A1")
        spreadsheet.setCell(at: ref, content: "42")
        spreadsheet.clearCell(at: ref)
        XCTAssertNil(spreadsheet.value(at: ref))
    }
    
    func test_ClearRange() throws {
        let a1 = try CellReference(string: "A1")
        let a2 = try CellReference(string: "A2")
        let a3 = try CellReference(string: "A3")
        
        spreadsheet.setCell(at: a1, content: "1")
        spreadsheet.setCell(at: a2, content: "2")
        spreadsheet.setCell(at: a3, content: "3")
        
        let range = try CellRange(string: "A1:A3")
        spreadsheet.clearRange(range)
        
        XCTAssertNil(spreadsheet.value(at: a1))
        XCTAssertNil(spreadsheet.value(at: a2))
        XCTAssertNil(spreadsheet.value(at: a3))
    }
    
    func test_ClearAll() throws {
        let a1 = try CellReference(string: "A1")
        let e45 = try CellReference(string: "E45")
        
        spreadsheet.setCell(at: a1, content: "1")
        spreadsheet.setCell(at: e45, content: "999")
        
        spreadsheet.clearAll()
        
        XCTAssertNil(spreadsheet.value(at: a1))
        XCTAssertNil(spreadsheet.value(at: e45))
    }
    
    // MARK: - Formula Tests
    
    func test_Formula_SimpleReference() throws {
        let a1 = try CellReference(string: "A1")
        let b1 = try CellReference(string: "B1")
        
        spreadsheet.setCell(at: a1, content: "10")
        spreadsheet.setCell(at: b1, content: "=A1")
        
        XCTAssertEqual(spreadsheet.value(at: b1), 10)
    }
    
    func test_Formula_Addition() throws {
        let a1 = try CellReference(string: "A1")
        let b1 = try CellReference(string: "B1")
        let c1 = try CellReference(string: "C1")
        
        spreadsheet.setCell(at: a1, content: "5")
        spreadsheet.setCell(at: b1, content: "3")
        spreadsheet.setCell(at: c1, content: "=A1+B1")
        
        XCTAssertEqual(spreadsheet.value(at: c1), 8)
    }
    
    func test_Formula_Subtraction() throws {
        let a1 = try CellReference(string: "A1")
        let b1 = try CellReference(string: "B1")
        let c1 = try CellReference(string: "C1")
        
        spreadsheet.setCell(at: a1, content: "10")
        spreadsheet.setCell(at: b1, content: "3")
        spreadsheet.setCell(at: c1, content: "=A1-B1")
        
        XCTAssertEqual(spreadsheet.value(at: c1), 7)
    }
    
    func test_Formula_Multiplication() throws {
        let a1 = try CellReference(string: "A1")
        let b1 = try CellReference(string: "B1")
        
        spreadsheet.setCell(at: a1, content: "10")
        spreadsheet.setCell(at: b1, content: "=A1*2")
        
        XCTAssertEqual(spreadsheet.value(at: b1), 20)
    }
    
    func test_Formula_Division() throws {
        let a1 = try CellReference(string: "A1")
        let b1 = try CellReference(string: "B1")
        
        spreadsheet.setCell(at: a1, content: "20")
        spreadsheet.setCell(at: b1, content: "=A1/4")
        
        XCTAssertEqual(spreadsheet.value(at: b1), 5)
    }
    
    func test_Formula_ComplexExpression() throws {
        let a1 = try CellReference(string: "A1")
        let b1 = try CellReference(string: "B1")
        let c1 = try CellReference(string: "C1")
        
        spreadsheet.setCell(at: a1, content: "2")
        spreadsheet.setCell(at: b1, content: "3")
        spreadsheet.setCell(at: c1, content: "=A1*B1+A1")
        
        XCTAssertEqual(spreadsheet.value(at: c1), 8)
    }
    
    func test_Formula_SUM() throws {
        let a1 = try CellReference(string: "A1")
        let a2 = try CellReference(string: "A2")
        let a3 = try CellReference(string: "A3")
        let a4 = try CellReference(string: "A4")
        
        spreadsheet.setCell(at: a1, content: "1")
        spreadsheet.setCell(at: a2, content: "2")
        spreadsheet.setCell(at: a3, content: "3")
        spreadsheet.setCell(at: a4, content: "=SUM(A1:A3)")
        
        XCTAssertEqual(spreadsheet.value(at: a4), 6)
    }
    
    func test_Formula_AVERAGE() throws {
        let a1 = try CellReference(string: "A1")
        let a2 = try CellReference(string: "A2")
        let a3 = try CellReference(string: "A3")
        let a4 = try CellReference(string: "A4")
        
        spreadsheet.setCell(at: a1, content: "10")
        spreadsheet.setCell(at: a2, content: "20")
        spreadsheet.setCell(at: a3, content: "30")
        spreadsheet.setCell(at: a4, content: "=AVERAGE(A1:A3)")
        
        XCTAssertEqual(spreadsheet.value(at: a4), 20)
    }
    
    func test_Formula_MEAN() throws {
        let a1 = try CellReference(string: "A1")
        let a2 = try CellReference(string: "A2")
        let a3 = try CellReference(string: "A3")
        
        spreadsheet.setCell(at: a1, content: "10")
        spreadsheet.setCell(at: a2, content: "20")
        spreadsheet.setCell(at: a3, content: "=MEAN(A1:A2)")
        
        XCTAssertEqual(spreadsheet.value(at: a3), 15)
    }
    
    func test_Formula_MIN() throws {
        spreadsheet.setCell(at: try CellReference(string: "A1"), content: "5")
        spreadsheet.setCell(at: try CellReference(string: "A2"), content: "2")
        spreadsheet.setCell(at: try CellReference(string: "A3"), content: "8")
        spreadsheet.setCell(at: try CellReference(string: "A4"), content: "=MIN(A1:A3)")
        
        XCTAssertEqual(spreadsheet.value(at: try CellReference(string: "A4")), 2)
    }
    
    func test_Formula_MAX() throws {
        spreadsheet.setCell(at: try CellReference(string: "A1"), content: "5")
        spreadsheet.setCell(at: try CellReference(string: "A2"), content: "2")
        spreadsheet.setCell(at: try CellReference(string: "A3"), content: "8")
        spreadsheet.setCell(at: try CellReference(string: "A4"), content: "=MAX(A1:A3)")
        
        XCTAssertEqual(spreadsheet.value(at: try CellReference(string: "A4")), 8)
    }
    
    func test_Formula_COUNT() throws {
        spreadsheet.setCell(at: try CellReference(string: "A1"), content: "5")
        spreadsheet.setCell(at: try CellReference(string: "A2"), content: "2")
        spreadsheet.setCell(at: try CellReference(string: "A3"), content: "=COUNT(A1:A2)")
        
        XCTAssertEqual(spreadsheet.value(at: try CellReference(string: "A3")), 2)
    }
    
    func test_Formula_CaseInsensitive() throws {
        let a1 = try CellReference(string: "A1")
        let a2 = try CellReference(string: "A2")
        let a3 = try CellReference(string: "A3")
        
        spreadsheet.setCell(at: a1, content: "10")
        spreadsheet.setCell(at: a2, content: "20")
        spreadsheet.setCell(at: a3, content: "=sum(a1:a2)")
        
        XCTAssertEqual(spreadsheet.value(at: a3), 30)
    }
    
    // MARK: - Recalculation Tests
    
    func test_Recalculation_UpdatesDependents() throws {
        let a1 = try CellReference(string: "A1")
        let b1 = try CellReference(string: "B1")
        
        spreadsheet.setCell(at: a1, content: "10")
        spreadsheet.setCell(at: b1, content: "=A1*2")
        
        XCTAssertEqual(spreadsheet.value(at: b1), 20)
        
        spreadsheet.setCell(at: a1, content: "5")
        
        XCTAssertEqual(spreadsheet.value(at: b1), 10)
    }
    
    func test_Recalculation_ChainedDependencies() throws {
        let a1 = try CellReference(string: "A1")
        let b1 = try CellReference(string: "B1")
        let c1 = try CellReference(string: "C1")
        
        spreadsheet.setCell(at: a1, content: "5")
        spreadsheet.setCell(at: b1, content: "=A1*2")
        spreadsheet.setCell(at: c1, content: "=B1+3")
        
        XCTAssertEqual(spreadsheet.value(at: c1), 13)
        
        spreadsheet.setCell(at: a1, content: "10")
        
        XCTAssertEqual(spreadsheet.value(at: b1), 20)
        XCTAssertEqual(spreadsheet.value(at: c1), 23)
    }
    
    func test_Recalculation_SUM_UpdatesWhenSourceChanges() throws {
        let a1 = try CellReference(string: "A1")
        let a2 = try CellReference(string: "A2")
        let a3 = try CellReference(string: "A3")
        
        spreadsheet.setCell(at: a1, content: "1")
        spreadsheet.setCell(at: a2, content: "2")
        spreadsheet.setCell(at: a3, content: "=SUM(A1:A2)")
        
        XCTAssertEqual(spreadsheet.value(at: a3), 3)
        
        spreadsheet.setCell(at: a1, content: "10")
        
        XCTAssertEqual(spreadsheet.value(at: a3), 12)
    }
    
    // MARK: - Copy with Relative References Tests
    
    func test_CopyCell_SimpleValue() throws {
        let a1 = try CellReference(string: "A1")
        let b1 = try CellReference(string: "B1")
        
        spreadsheet.setCell(at: a1, content: "42")
        spreadsheet.copyCell(from: a1, to: b1)
        
        XCTAssertEqual(spreadsheet.value(at: b1), 42)
    }
    
    func test_CopyCell_AdjustsRowReferences() throws {
        let a1 = try CellReference(string: "A1")
        let a2 = try CellReference(string: "A2")
        let b1 = try CellReference(string: "B1")
        let b2 = try CellReference(string: "B2")
        
        spreadsheet.setCell(at: a1, content: "1")
        spreadsheet.setCell(at: a2, content: "2")
        spreadsheet.setCell(at: b1, content: "=A1*2")
        
        spreadsheet.copyCell(from: b1, to: b2)
        
        XCTAssertEqual(spreadsheet.value(at: b2), 4)
    }
    
    func test_CopyCell_AdjustsColumnReferences() throws {
        let a1 = try CellReference(string: "A1")
        let b1 = try CellReference(string: "B1")
        let a2 = try CellReference(string: "A2")
        let b2 = try CellReference(string: "B2")
        
        spreadsheet.setCell(at: a1, content: "5")
        spreadsheet.setCell(at: b1, content: "10")
        spreadsheet.setCell(at: a2, content: "=A1+1")
        
        spreadsheet.copyCell(from: a2, to: b2)
        
        XCTAssertEqual(spreadsheet.value(at: b2), 11)
    }
    
    func test_CopyCell_AdjustsBothRowAndColumn() throws {
        let a1 = try CellReference(string: "A1")
        let b2 = try CellReference(string: "B2")
        let c1 = try CellReference(string: "C1")
        let d2 = try CellReference(string: "D2")
        
        spreadsheet.setCell(at: a1, content: "1")
        spreadsheet.setCell(at: b2, content: "2")
        spreadsheet.setCell(at: c1, content: "=A1+B2")
        
        spreadsheet.copyCell(from: c1, to: d2)
        
        let d2Cell = spreadsheet.cell(at: d2)
        if case .formula(let formula) = d2Cell.content {
            XCTAssertTrue(formula.contains("B2") && formula.contains("C3"))
        }
    }
    
    // MARK: - Error Handling Tests
    
    func test_Formula_InvalidReference_ShowsError() throws {
        let a1 = try CellReference(string: "A1")
        let b1 = try CellReference(string: "B1")
        
        spreadsheet.setCell(at: b1, content: "=A1+1")
        
        let cell = spreadsheet.cell(at: b1)
        XCTAssertNotNil(cell.evaluationError)
    }
    
    func test_Formula_MissingParenthesis() throws {
        let a1 = try CellReference(string: "A1")
        spreadsheet.setCell(at: a1, content: "=SUM(A2:A3")
        
        let cell = spreadsheet.cell(at: a1)
        XCTAssertNotNil(cell.evaluationError)
    }
    
    // MARK: - Grid Bounds Tests
    
    func test_AllColumns_Accessible() throws {
        let columns = ["A", "B", "C", "D", "E"]
        for col in columns {
            let ref = try CellReference(string: "\(col)1")
            spreadsheet.setCell(at: ref, content: "test")
            XCTAssertNotNil(spreadsheet.cell(at: ref))
        }
    }
    
    func test_AllRows_Accessible() throws {
        for row in 1...45 {
            let ref = try CellReference(string: "A\(row)")
            spreadsheet.setCell(at: ref, content: "\(row)")
            XCTAssertEqual(spreadsheet.value(at: ref), Double(row))
        }
    }
    
    // MARK: - Cell Access Tests
    
    func test_Cell_ReturnsCorrectContent() throws {
        let ref = try CellReference(string: "B3")
        spreadsheet.setCell(at: ref, content: "test value")
        
        let cell = spreadsheet.cell(at: ref)
        if case .text(let text) = cell.content {
            XCTAssertEqual(text, "test value")
        } else {
            XCTFail("Expected text content")
        }
    }
    
    func test_Value_ReturnsNilForEmptyCell() throws {
        let ref = try CellReference(string: "C5")
        XCTAssertNil(spreadsheet.value(at: ref))
    }
    
    func test_Value_ReturnsNilForTextCell() throws {
        let ref = try CellReference(string: "C5")
        spreadsheet.setCell(at: ref, content: "Hello World")
        XCTAssertNil(spreadsheet.value(at: ref))
    }
    
    // MARK: - Formula with Empty Cells in Range
    
    func test_SUM_IgnoresEmptyCells() throws {
        let a1 = try CellReference(string: "A1")
        let a3 = try CellReference(string: "A3")
        let a4 = try CellReference(string: "A4")
        
        spreadsheet.setCell(at: a1, content: "10")
        spreadsheet.setCell(at: a3, content: "20")
        spreadsheet.setCell(at: a4, content: "=SUM(A1:A3)")
        
        XCTAssertEqual(spreadsheet.value(at: a4), 30)
    }
    
    func test_AVERAGE_OnlyCountsNonEmpty() throws {
        let a1 = try CellReference(string: "A1")
        let a3 = try CellReference(string: "A3")
        let a4 = try CellReference(string: "A4")
        
        spreadsheet.setCell(at: a1, content: "10")
        spreadsheet.setCell(at: a3, content: "20")
        spreadsheet.setCell(at: a4, content: "=AVERAGE(A1:A3)")
        
        XCTAssertEqual(spreadsheet.value(at: a4), 15)
    }
}
