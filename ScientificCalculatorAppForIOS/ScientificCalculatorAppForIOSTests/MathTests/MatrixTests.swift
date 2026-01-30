import XCTest
@testable import ScientificCalculatorAppForIOS

final class MatrixTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func test_Init_ValidDimensions_CreatesMatrix() throws {
        let m = try Matrix(rows: 2, cols: 2, elements: [[1, 2], [3, 4]])
        XCTAssertEqual(m.rows, 2)
        XCTAssertEqual(m.cols, 2)
    }
    
    func test_Init_From2DArray_InfersDimensions() throws {
        let m = try Matrix([[1, 2, 3], [4, 5, 6]])
        XCTAssertEqual(m.rows, 2)
        XCTAssertEqual(m.cols, 3)
    }
    
    func test_Init_ExceedsMaxDimension_ThrowsError() {
        XCTAssertThrowsError(try Matrix(rows: 5, cols: 5, elements: Array(repeating: Array(repeating: 0.0, count: 5), count: 5))) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_Init_MismatchedRows_ThrowsError() {
        XCTAssertThrowsError(try Matrix(rows: 3, cols: 2, elements: [[1, 2], [3, 4]])) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_Init_MismatchedCols_ThrowsError() {
        XCTAssertThrowsError(try Matrix(rows: 2, cols: 3, elements: [[1, 2], [3, 4]])) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_Init_EmptyMatrix_ThrowsError() {
        XCTAssertThrowsError(try Matrix([])) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_Zero_CreatesZeroMatrix() throws {
        let m = try Matrix.zero(rows: 2, cols: 3)
        
        XCTAssertEqual(m.rows, 2)
        XCTAssertEqual(m.cols, 3)
        for i in 0..<2 {
            for j in 0..<3 {
                XCTAssertEqual(m[i, j], 0.0, accuracy: 1e-15)
            }
        }
    }
    
    func test_Identity_CreatesIdentityMatrix() throws {
        let m = try Matrix.identity(size: 3)
        
        XCTAssertEqual(m.rows, 3)
        XCTAssertEqual(m.cols, 3)
        for i in 0..<3 {
            for j in 0..<3 {
                if i == j {
                    XCTAssertEqual(m[i, j], 1.0, accuracy: 1e-15)
                } else {
                    XCTAssertEqual(m[i, j], 0.0, accuracy: 1e-15)
                }
            }
        }
    }
    
    func test_Identity_Size0_ThrowsError() {
        XCTAssertThrowsError(try Matrix.identity(size: 0)) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_Identity_ExceedsMax_ThrowsError() {
        XCTAssertThrowsError(try Matrix.identity(size: 5)) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    // MARK: - Subscript Tests
    
    func test_Subscript_GetElement_ReturnsCorrectValue() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        
        XCTAssertEqual(m[0, 0], 1.0, accuracy: 1e-15)
        XCTAssertEqual(m[0, 1], 2.0, accuracy: 1e-15)
        XCTAssertEqual(m[1, 0], 3.0, accuracy: 1e-15)
        XCTAssertEqual(m[1, 1], 4.0, accuracy: 1e-15)
    }
    
    func test_Subscript_SetElement_UpdatesValue() throws {
        var m = try Matrix([[1, 2], [3, 4]])
        m[0, 1] = 10.0
        
        XCTAssertEqual(m[0, 1], 10.0, accuracy: 1e-15)
    }
    
    func test_SubscriptRow_ReturnsEntireRow() throws {
        let m = try Matrix([[1, 2, 3], [4, 5, 6]])
        let row = m[row: 0]
        
        XCTAssertEqual(row, [1.0, 2.0, 3.0])
    }
    
    func test_SubscriptRow_SetRow_UpdatesRow() throws {
        var m = try Matrix([[1, 2], [3, 4]])
        m[row: 1] = [10.0, 20.0]
        
        XCTAssertEqual(m[1, 0], 10.0, accuracy: 1e-15)
        XCTAssertEqual(m[1, 1], 20.0, accuracy: 1e-15)
    }
    
    func test_SubscriptCol_ReturnsEntireColumn() throws {
        let m = try Matrix([[1, 2], [3, 4], [5, 6]])
        let col = m[col: 1]
        
        XCTAssertEqual(col, [2.0, 4.0, 6.0])
    }
    
    // MARK: - Computed Properties Tests
    
    func test_IsSquare_SquareMatrix_ReturnsTrue() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        XCTAssertTrue(m.isSquare)
    }
    
    func test_IsSquare_Rectangular_ReturnsFalse() throws {
        let m = try Matrix([[1, 2, 3], [4, 5, 6]])
        XCTAssertFalse(m.isSquare)
    }
    
    func test_Count_ReturnsCorrectElementCount() throws {
        let m = try Matrix([[1, 2, 3], [4, 5, 6]])
        XCTAssertEqual(m.count, 6)
    }
    
    func test_IsDiagonal_DiagonalMatrix_ReturnsTrue() throws {
        let m = try Matrix([[1, 0, 0], [0, 2, 0], [0, 0, 3]])
        XCTAssertTrue(m.isDiagonal)
    }
    
    func test_IsDiagonal_NonDiagonal_ReturnsFalse() throws {
        let m = try Matrix([[1, 1], [0, 2]])
        XCTAssertFalse(m.isDiagonal)
    }
    
    func test_IsSymmetric_SymmetricMatrix_ReturnsTrue() throws {
        let m = try Matrix([[1, 2, 3], [2, 4, 5], [3, 5, 6]])
        XCTAssertTrue(m.isSymmetric)
    }
    
    func test_IsSymmetric_NonSymmetric_ReturnsFalse() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        XCTAssertFalse(m.isSymmetric)
    }
    
    // MARK: - Arithmetic Tests
    
    func test_Addition_SameDimensions_ReturnsSum() throws {
        let a = try Matrix([[1, 2], [3, 4]])
        let b = try Matrix([[5, 6], [7, 8]])
        let result = try a + b
        
        XCTAssertEqual(result[0, 0], 6.0, accuracy: 1e-15)
        XCTAssertEqual(result[0, 1], 8.0, accuracy: 1e-15)
        XCTAssertEqual(result[1, 0], 10.0, accuracy: 1e-15)
        XCTAssertEqual(result[1, 1], 12.0, accuracy: 1e-15)
    }
    
    func test_Addition_DifferentDimensions_ThrowsError() throws {
        let a = try Matrix([[1, 2], [3, 4]])
        let b = try Matrix([[1, 2, 3]])
        
        XCTAssertThrowsError(try a + b) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_Subtraction_SameDimensions_ReturnsDifference() throws {
        let a = try Matrix([[5, 6], [7, 8]])
        let b = try Matrix([[1, 2], [3, 4]])
        let result = try a - b
        
        XCTAssertEqual(result[0, 0], 4.0, accuracy: 1e-15)
        XCTAssertEqual(result[0, 1], 4.0, accuracy: 1e-15)
        XCTAssertEqual(result[1, 0], 4.0, accuracy: 1e-15)
        XCTAssertEqual(result[1, 1], 4.0, accuracy: 1e-15)
    }
    
    func test_Multiplication_CompatibleDimensions_ReturnsProduct() throws {
        let a = try Matrix([[1, 2], [3, 4]])
        let b = try Matrix([[5, 6], [7, 8]])
        let result = try a * b
        
        // [1*5+2*7, 1*6+2*8] = [19, 22]
        // [3*5+4*7, 3*6+4*8] = [43, 50]
        XCTAssertEqual(result[0, 0], 19.0, accuracy: 1e-15)
        XCTAssertEqual(result[0, 1], 22.0, accuracy: 1e-15)
        XCTAssertEqual(result[1, 0], 43.0, accuracy: 1e-15)
        XCTAssertEqual(result[1, 1], 50.0, accuracy: 1e-15)
    }
    
    func test_Multiplication_IncompatibleDimensions_ThrowsError() throws {
        let a = try Matrix([[1, 2], [3, 4]])
        let b = try Matrix([[1, 2, 3]])
        
        XCTAssertThrowsError(try a * b) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_Multiplication_NonSquareResult() throws {
        let a = try Matrix([[1, 2, 3], [4, 5, 6]])  // 2x3
        let b = try Matrix([[1, 2], [3, 4], [5, 6]])  // 3x2
        let result = try a * b  // 2x2
        
        XCTAssertEqual(result.rows, 2)
        XCTAssertEqual(result.cols, 2)
    }
    
    func test_ScalarMultiplication_Left_ReturnsScaled() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        let result = 2.0 * m
        
        XCTAssertEqual(result[0, 0], 2.0, accuracy: 1e-15)
        XCTAssertEqual(result[0, 1], 4.0, accuracy: 1e-15)
        XCTAssertEqual(result[1, 0], 6.0, accuracy: 1e-15)
        XCTAssertEqual(result[1, 1], 8.0, accuracy: 1e-15)
    }
    
    func test_ScalarMultiplication_Right_ReturnsScaled() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        let result = m * 0.5
        
        XCTAssertEqual(result[0, 0], 0.5, accuracy: 1e-15)
        XCTAssertEqual(result[0, 1], 1.0, accuracy: 1e-15)
    }
    
    func test_ScalarDivision_ReturnsScaled() throws {
        let m = try Matrix([[2, 4], [6, 8]])
        let result = try m / 2.0
        
        XCTAssertEqual(result[0, 0], 1.0, accuracy: 1e-15)
        XCTAssertEqual(result[0, 1], 2.0, accuracy: 1e-15)
    }
    
    func test_ScalarDivision_ByZero_ThrowsError() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        
        XCTAssertThrowsError(try m / 0.0) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_Negation_NegatesAllElements() throws {
        let m = try Matrix([[1, -2], [3, -4]])
        let result = -m
        
        XCTAssertEqual(result[0, 0], -1.0, accuracy: 1e-15)
        XCTAssertEqual(result[0, 1], 2.0, accuracy: 1e-15)
        XCTAssertEqual(result[1, 0], -3.0, accuracy: 1e-15)
        XCTAssertEqual(result[1, 1], 4.0, accuracy: 1e-15)
    }
    
    // MARK: - Matrix Operations Tests
    
    func test_Transpose_SwapsRowsAndColumns() throws {
        let m = try Matrix([[1, 2, 3], [4, 5, 6]])
        let t = m.transpose
        
        XCTAssertEqual(t.rows, 3)
        XCTAssertEqual(t.cols, 2)
        XCTAssertEqual(t[0, 0], 1.0, accuracy: 1e-15)
        XCTAssertEqual(t[0, 1], 4.0, accuracy: 1e-15)
        XCTAssertEqual(t[1, 0], 2.0, accuracy: 1e-15)
        XCTAssertEqual(t[2, 1], 6.0, accuracy: 1e-15)
    }
    
    func test_Transpose_SquareMatrix() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        let t = m.transpose
        
        XCTAssertEqual(t[0, 1], 3.0, accuracy: 1e-15)
        XCTAssertEqual(t[1, 0], 2.0, accuracy: 1e-15)
    }
    
    func test_Determinant_1x1_ReturnsElement() throws {
        let m = try Matrix([[5]])
        let det = try m.determinant()
        
        XCTAssertEqual(det, 5.0, accuracy: 1e-15)
    }
    
    func test_Determinant_2x2_ReturnsCorrectValue() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        let det = try m.determinant()
        
        // det = 1*4 - 2*3 = -2
        XCTAssertEqual(det, -2.0, accuracy: 1e-10)
    }
    
    func test_Determinant_3x3_ReturnsCorrectValue() throws {
        let m = try Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
        let det = try m.determinant()
        
        // This matrix is singular (rows are linearly dependent)
        XCTAssertEqual(det, 0.0, accuracy: 1e-10)
    }
    
    func test_Determinant_3x3_NonZero() throws {
        let m = try Matrix([[1, 2, 3], [0, 1, 4], [5, 6, 0]])
        let det = try m.determinant()
        
        // det = 1(0-24) - 2(0-20) + 3(0-5) = -24 + 40 - 15 = 1
        XCTAssertEqual(det, 1.0, accuracy: 1e-10)
    }
    
    func test_Determinant_NonSquare_ThrowsError() throws {
        let m = try Matrix([[1, 2, 3], [4, 5, 6]])
        
        XCTAssertThrowsError(try m.determinant()) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_Inverse_2x2_ReturnsCorrectInverse() throws {
        let m = try Matrix([[4, 7], [2, 6]])
        let inv = try m.inverse()
        let product = try m * inv
        
        // Product should be identity
        XCTAssertEqual(product[0, 0], 1.0, accuracy: 1e-10)
        XCTAssertEqual(product[0, 1], 0.0, accuracy: 1e-10)
        XCTAssertEqual(product[1, 0], 0.0, accuracy: 1e-10)
        XCTAssertEqual(product[1, 1], 1.0, accuracy: 1e-10)
    }
    
    func test_Inverse_Singular_ThrowsError() throws {
        let m = try Matrix([[1, 2], [2, 4]])  // det = 0
        
        XCTAssertThrowsError(try m.inverse()) { error in
            guard case CalculatorError.mathError = error else {
                XCTFail("Expected math error")
                return
            }
        }
    }
    
    func test_Inverse_NonSquare_ThrowsError() throws {
        let m = try Matrix([[1, 2, 3], [4, 5, 6]])
        
        XCTAssertThrowsError(try m.inverse()) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_Power_0_ReturnsIdentity() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        let result = try m.power(0)
        
        XCTAssertEqual(result[0, 0], 1.0, accuracy: 1e-10)
        XCTAssertEqual(result[0, 1], 0.0, accuracy: 1e-10)
        XCTAssertEqual(result[1, 0], 0.0, accuracy: 1e-10)
        XCTAssertEqual(result[1, 1], 1.0, accuracy: 1e-10)
    }
    
    func test_Power_1_ReturnsSelf() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        let result = try m.power(1)
        
        XCTAssertEqual(result, m)
    }
    
    func test_Power_2_ReturnsSquare() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        let result = try m.power(2)
        let expected = try m * m
        
        XCTAssertEqual(result, expected)
    }
    
    func test_Power_NegativeExponent_ThrowsError() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        
        XCTAssertThrowsError(try m.power(-1)) { error in
            guard case CalculatorError.mathError = error else {
                XCTFail("Expected math error")
                return
            }
        }
    }
    
    func test_Power_NonSquare_ThrowsError() throws {
        let m = try Matrix([[1, 2, 3], [4, 5, 6]])
        
        XCTAssertThrowsError(try m.power(2)) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_Trace_ReturnsSum_OfDiagonal() throws {
        let m = try Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
        let trace = try m.trace()
        
        // 1 + 5 + 9 = 15
        XCTAssertEqual(trace, 15.0, accuracy: 1e-15)
    }
    
    func test_Trace_NonSquare_ThrowsError() throws {
        let m = try Matrix([[1, 2, 3], [4, 5, 6]])
        
        XCTAssertThrowsError(try m.trace()) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    // MARK: - Matrix Analysis Tests
    
    func test_Rank_FullRank() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        XCTAssertEqual(m.rank(), 2)
    }
    
    func test_Rank_RankDeficient() throws {
        let m = try Matrix([[1, 2], [2, 4]])
        XCTAssertEqual(m.rank(), 1)
    }
    
    func test_IsSingular_ZeroDeterminant_ReturnsTrue() throws {
        let m = try Matrix([[1, 2], [2, 4]])
        XCTAssertTrue(try m.isSingular())
    }
    
    func test_IsSingular_NonZeroDeterminant_ReturnsFalse() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        XCTAssertFalse(try m.isSingular())
    }
    
    func test_RowEchelonForm_ProducesUpperTriangular() throws {
        let m = try Matrix([[2, 1, -1], [-3, -1, 2], [-2, 1, 2]])
        let ref = m.rowEchelonForm()
        
        // Below diagonal should be zeros
        XCTAssertEqual(ref[1, 0], 0.0, accuracy: 1e-10)
        XCTAssertEqual(ref[2, 0], 0.0, accuracy: 1e-10)
        XCTAssertEqual(ref[2, 1], 0.0, accuracy: 1e-10)
    }
    
    func test_ReducedRowEchelonForm_ProducesRREF() throws {
        let m = try Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
        let rref = m.reducedRowEchelonForm()
        
        // Check leading 1s
        XCTAssertEqual(rref[0, 0], 1.0, accuracy: 1e-10)
    }
    
    // MARK: - Identity Tests
    
    func test_Identity_TimesMatrix_ReturnsSameMatrix() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        let i = try Matrix.identity(size: 2)
        let result = try i * m
        
        XCTAssertEqual(result, m)
    }
    
    func test_Matrix_TimesIdentity_ReturnsSameMatrix() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        let i = try Matrix.identity(size: 2)
        let result = try m * i
        
        XCTAssertEqual(result, m)
    }
    
    func test_Matrix_TimesInverse_ReturnsIdentity() throws {
        let m = try Matrix([[4, 7], [2, 6]])
        let inv = try m.inverse()
        let product = try m * inv
        let identity = try Matrix.identity(size: 2)
        
        XCTAssertEqual(product, identity)
    }
    
    // MARK: - Description Tests
    
    func test_Description_FormatsMatrix() throws {
        let m = try Matrix([[1, 2], [3, 4]])
        let desc = m.description
        
        XCTAssertTrue(desc.contains("["))
        XCTAssertTrue(desc.contains("]"))
    }
    
    // MARK: - Equatable Tests
    
    func test_Equatable_SameMatrices_AreEqual() throws {
        let a = try Matrix([[1, 2], [3, 4]])
        let b = try Matrix([[1, 2], [3, 4]])
        
        XCTAssertEqual(a, b)
    }
    
    func test_Equatable_DifferentMatrices_AreNotEqual() throws {
        let a = try Matrix([[1, 2], [3, 4]])
        let b = try Matrix([[1, 2], [3, 5]])
        
        XCTAssertNotEqual(a, b)
    }
    
    func test_Equatable_DifferentDimensions_AreNotEqual() throws {
        let a = try Matrix([[1, 2], [3, 4]])
        let b = try Matrix([[1, 2, 3]])
        
        XCTAssertNotEqual(a, b)
    }
}
