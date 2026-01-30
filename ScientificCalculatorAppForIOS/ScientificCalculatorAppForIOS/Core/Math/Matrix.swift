import Foundation

// MARK: - Matrix

/// Represents a matrix of real numbers with dimensions up to 4×4
struct Matrix: Equatable {
    
    // MARK: - Properties
    
    /// Number of rows
    let rows: Int
    
    /// Number of columns
    let cols: Int
    
    /// Matrix elements stored in row-major order
    private var elements: [[Double]]
    
    /// Maximum allowed dimension
    static let maxDimension = 4
    
    /// Epsilon for floating-point comparisons
    private static let epsilon = 1e-15
    
    // MARK: - Computed Properties
    
    /// Returns true if the matrix is square
    var isSquare: Bool { rows == cols }
    
    /// Returns true if the matrix is empty (0×0)
    var isEmpty: Bool { rows == 0 || cols == 0 }
    
    /// Returns the total number of elements
    var count: Int { rows * cols }
    
    /// Returns true if the matrix is diagonal
    var isDiagonal: Bool {
        guard isSquare else { return false }
        for i in 0..<rows {
            for j in 0..<cols {
                if i != j && abs(elements[i][j]) > Matrix.epsilon {
                    return false
                }
            }
        }
        return true
    }
    
    /// Returns true if the matrix is symmetric (A = Aᵀ)
    var isSymmetric: Bool {
        guard isSquare else { return false }
        for i in 0..<rows {
            for j in (i + 1)..<cols {
                if abs(elements[i][j] - elements[j][i]) > Matrix.epsilon {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: - Initialization
    
    /// Creates a matrix with specified dimensions and elements
    init(rows: Int, cols: Int, elements: [[Double]]) throws {
        guard rows > 0 && cols > 0 else {
            throw CalculatorError.dimensionMismatch("Matrix dimensions must be positive")
        }
        guard rows <= Matrix.maxDimension && cols <= Matrix.maxDimension else {
            throw CalculatorError.dimensionMismatch("Matrix dimensions cannot exceed \(Matrix.maxDimension)×\(Matrix.maxDimension)")
        }
        guard elements.count == rows else {
            throw CalculatorError.dimensionMismatch("Element rows (\(elements.count)) doesn't match specified rows (\(rows))")
        }
        for (index, row) in elements.enumerated() {
            guard row.count == cols else {
                throw CalculatorError.dimensionMismatch("Row \(index) has \(row.count) elements, expected \(cols)")
            }
        }
        
        self.rows = rows
        self.cols = cols
        self.elements = elements
    }
    
    /// Creates a matrix from a 2D array (infers dimensions)
    init(_ elements: [[Double]]) throws {
        guard !elements.isEmpty && !elements[0].isEmpty else {
            throw CalculatorError.dimensionMismatch("Matrix cannot be empty")
        }
        
        let rows = elements.count
        let cols = elements[0].count
        
        try self.init(rows: rows, cols: cols, elements: elements)
    }
    
    /// Creates a zero matrix of specified dimensions
    static func zero(rows: Int, cols: Int) throws -> Matrix {
        guard rows > 0 && cols > 0 else {
            throw CalculatorError.dimensionMismatch("Matrix dimensions must be positive")
        }
        guard rows <= maxDimension && cols <= maxDimension else {
            throw CalculatorError.dimensionMismatch("Matrix dimensions cannot exceed \(maxDimension)×\(maxDimension)")
        }
        
        let elements = Array(repeating: Array(repeating: 0.0, count: cols), count: rows)
        return try Matrix(rows: rows, cols: cols, elements: elements)
    }
    
    /// Creates an identity matrix of specified size
    static func identity(size: Int) throws -> Matrix {
        guard size > 0 else {
            throw CalculatorError.dimensionMismatch("Identity matrix size must be positive")
        }
        guard size <= maxDimension else {
            throw CalculatorError.dimensionMismatch("Identity matrix size cannot exceed \(maxDimension)")
        }
        
        var elements = Array(repeating: Array(repeating: 0.0, count: size), count: size)
        for i in 0..<size {
            elements[i][i] = 1.0
        }
        return try Matrix(rows: size, cols: size, elements: elements)
    }
    
    // MARK: - Subscript Access
    
    /// Access element at (row, col) - zero-indexed
    subscript(row: Int, col: Int) -> Double {
        get {
            precondition(row >= 0 && row < rows && col >= 0 && col < cols, "Index out of bounds")
            return elements[row][col]
        }
        set {
            precondition(row >= 0 && row < rows && col >= 0 && col < cols, "Index out of bounds")
            elements[row][col] = newValue
        }
    }
    
    /// Access entire row
    subscript(row row: Int) -> [Double] {
        get {
            precondition(row >= 0 && row < rows, "Row index out of bounds")
            return elements[row]
        }
        set {
            precondition(row >= 0 && row < rows, "Row index out of bounds")
            precondition(newValue.count == cols, "Row length mismatch")
            elements[row] = newValue
        }
    }
    
    /// Access entire column
    subscript(col col: Int) -> [Double] {
        get {
            precondition(col >= 0 && col < cols, "Column index out of bounds")
            return elements.map { $0[col] }
        }
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        guard lhs.rows == rhs.rows && lhs.cols == rhs.cols else { return false }
        for i in 0..<lhs.rows {
            for j in 0..<lhs.cols {
                if abs(lhs.elements[i][j] - rhs.elements[i][j]) > epsilon {
                    return false
                }
            }
        }
        return true
    }
}

// MARK: - Arithmetic Operations

extension Matrix {
    
    /// Matrix addition (requires same dimensions)
    static func + (lhs: Matrix, rhs: Matrix) throws -> Matrix {
        guard lhs.rows == rhs.rows && lhs.cols == rhs.cols else {
            throw CalculatorError.dimensionMismatch("Cannot add \(lhs.rows)×\(lhs.cols) and \(rhs.rows)×\(rhs.cols) matrices")
        }
        
        var result = lhs.elements
        for i in 0..<lhs.rows {
            for j in 0..<lhs.cols {
                result[i][j] += rhs.elements[i][j]
            }
        }
        return try Matrix(rows: lhs.rows, cols: lhs.cols, elements: result)
    }
    
    /// Matrix subtraction (requires same dimensions)
    static func - (lhs: Matrix, rhs: Matrix) throws -> Matrix {
        guard lhs.rows == rhs.rows && lhs.cols == rhs.cols else {
            throw CalculatorError.dimensionMismatch("Cannot subtract \(rhs.rows)×\(rhs.cols) from \(lhs.rows)×\(lhs.cols) matrix")
        }
        
        var result = lhs.elements
        for i in 0..<lhs.rows {
            for j in 0..<lhs.cols {
                result[i][j] -= rhs.elements[i][j]
            }
        }
        return try Matrix(rows: lhs.rows, cols: lhs.cols, elements: result)
    }
    
    /// Matrix multiplication (requires lhs.cols == rhs.rows)
    static func * (lhs: Matrix, rhs: Matrix) throws -> Matrix {
        guard lhs.cols == rhs.rows else {
            throw CalculatorError.dimensionMismatch("Cannot multiply \(lhs.rows)×\(lhs.cols) by \(rhs.rows)×\(rhs.cols)")
        }
        
        var result = Array(repeating: Array(repeating: 0.0, count: rhs.cols), count: lhs.rows)
        
        for i in 0..<lhs.rows {
            for j in 0..<rhs.cols {
                var sum = 0.0
                for k in 0..<lhs.cols {
                    sum += lhs.elements[i][k] * rhs.elements[k][j]
                }
                result[i][j] = sum
            }
        }
        
        return try Matrix(rows: lhs.rows, cols: rhs.cols, elements: result)
    }
    
    /// Scalar multiplication (scalar on left)
    static func * (scalar: Double, matrix: Matrix) -> Matrix {
        var result = matrix.elements
        for i in 0..<matrix.rows {
            for j in 0..<matrix.cols {
                result[i][j] *= scalar
            }
        }
        return try! Matrix(rows: matrix.rows, cols: matrix.cols, elements: result)
    }
    
    /// Scalar multiplication (scalar on right)
    static func * (matrix: Matrix, scalar: Double) -> Matrix {
        return scalar * matrix
    }
    
    /// Scalar division
    static func / (matrix: Matrix, scalar: Double) throws -> Matrix {
        guard abs(scalar) > Matrix.epsilon else {
            throw CalculatorError.divisionByZero
        }
        return (1.0 / scalar) * matrix
    }
    
    /// Negation
    static prefix func - (matrix: Matrix) -> Matrix {
        return (-1.0) * matrix
    }
}

// MARK: - Matrix Functions

extension Matrix {
    
    /// Transpose: swap rows and columns
    var transpose: Matrix {
        var result = Array(repeating: Array(repeating: 0.0, count: rows), count: cols)
        for i in 0..<rows {
            for j in 0..<cols {
                result[j][i] = elements[i][j]
            }
        }
        return try! Matrix(rows: cols, cols: rows, elements: result)
    }
    
    /// Determinant (only for square matrices)
    func determinant() throws -> Double {
        guard isSquare else {
            throw CalculatorError.dimensionMismatch("Determinant requires square matrix")
        }
        
        switch rows {
        case 1:
            return elements[0][0]
        case 2:
            return elements[0][0] * elements[1][1] - elements[0][1] * elements[1][0]
        case 3:
            return determinant3x3()
        default:
            return try luDeterminant()
        }
    }
    
    /// 3×3 determinant using Sarrus' rule
    private func determinant3x3() -> Double {
        let a = elements[0][0], b = elements[0][1], c = elements[0][2]
        let d = elements[1][0], e = elements[1][1], f = elements[1][2]
        let g = elements[2][0], h = elements[2][1], i = elements[2][2]
        
        return a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)
    }
    
    /// Determinant using LU decomposition with partial pivoting
    private func luDeterminant() throws -> Double {
        var a = elements
        let n = rows
        var det = 1.0
        var swaps = 0
        
        for k in 0..<n {
            // Find pivot
            var maxVal = abs(a[k][k])
            var maxRow = k
            
            for i in (k + 1)..<n {
                if abs(a[i][k]) > maxVal {
                    maxVal = abs(a[i][k])
                    maxRow = i
                }
            }
            
            // Swap rows if necessary
            if maxRow != k {
                let temp = a[k]
                a[k] = a[maxRow]
                a[maxRow] = temp
                swaps += 1
            }
            
            // Check for singular matrix
            if abs(a[k][k]) < Matrix.epsilon {
                return 0.0
            }
            
            det *= a[k][k]
            
            // Eliminate
            for i in (k + 1)..<n {
                let factor = a[i][k] / a[k][k]
                for j in k..<n {
                    a[i][j] -= factor * a[k][j]
                }
            }
        }
        
        // Account for row swaps
        if swaps % 2 == 1 {
            det = -det
        }
        
        return det
    }
    
    /// Inverse matrix using Gauss-Jordan elimination with partial pivoting
    func inverse() throws -> Matrix {
        guard isSquare else {
            throw CalculatorError.dimensionMismatch("Inverse requires square matrix")
        }
        
        let det = try determinant()
        guard abs(det) > Matrix.epsilon else {
            throw CalculatorError.mathError("Matrix is singular (determinant = 0)")
        }
        
        let n = rows
        
        // Create augmented matrix [A|I]
        var augmented = Array(repeating: Array(repeating: 0.0, count: 2 * n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                augmented[i][j] = elements[i][j]
            }
            augmented[i][n + i] = 1.0
        }
        
        // Gauss-Jordan elimination
        for k in 0..<n {
            // Find pivot
            var maxVal = abs(augmented[k][k])
            var maxRow = k
            
            for i in (k + 1)..<n {
                if abs(augmented[i][k]) > maxVal {
                    maxVal = abs(augmented[i][k])
                    maxRow = i
                }
            }
            
            // Swap rows
            if maxRow != k {
                let temp = augmented[k]
                augmented[k] = augmented[maxRow]
                augmented[maxRow] = temp
            }
            
            // Scale pivot row
            let pivot = augmented[k][k]
            for j in 0..<(2 * n) {
                augmented[k][j] /= pivot
            }
            
            // Eliminate column
            for i in 0..<n {
                if i != k {
                    let factor = augmented[i][k]
                    for j in 0..<(2 * n) {
                        augmented[i][j] -= factor * augmented[k][j]
                    }
                }
            }
        }
        
        // Extract inverse from right side
        var result = Array(repeating: Array(repeating: 0.0, count: n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                result[i][j] = augmented[i][n + j]
            }
        }
        
        return try Matrix(rows: n, cols: n, elements: result)
    }
    
    /// Matrix power (only for square matrices, n ≥ 0)
    func power(_ n: Int) throws -> Matrix {
        guard isSquare else {
            throw CalculatorError.dimensionMismatch("Matrix power requires square matrix")
        }
        guard n >= 0 else {
            throw CalculatorError.mathError("Matrix power must be non-negative")
        }
        
        if n == 0 {
            return try Matrix.identity(size: rows)
        }
        
        if n == 1 {
            return self
        }
        
        // Binary exponentiation for efficiency
        var result = try Matrix.identity(size: rows)
        var base = self
        var exp = n
        
        while exp > 0 {
            if exp % 2 == 1 {
                result = try result * base
            }
            base = try base * base
            exp /= 2
        }
        
        return result
    }
    
    /// Trace (sum of diagonal elements, square matrices only)
    func trace() throws -> Double {
        guard isSquare else {
            throw CalculatorError.dimensionMismatch("Trace requires square matrix")
        }
        
        var sum = 0.0
        for i in 0..<rows {
            sum += elements[i][i]
        }
        return sum
    }
}

// MARK: - Matrix Analysis

extension Matrix {
    
    /// Returns the rank of the matrix
    func rank() -> Int {
        let rref = reducedRowEchelonForm()
        var rankCount = 0
        
        for i in 0..<rref.rows {
            var isZeroRow = true
            for j in 0..<rref.cols {
                if abs(rref.elements[i][j]) > Matrix.epsilon {
                    isZeroRow = false
                    break
                }
            }
            if !isZeroRow {
                rankCount += 1
            }
        }
        
        return rankCount
    }
    
    /// Returns true if the matrix is singular (determinant ≈ 0)
    func isSingular() throws -> Bool {
        guard isSquare else {
            throw CalculatorError.dimensionMismatch("Singularity check requires square matrix")
        }
        
        let det = try determinant()
        return abs(det) < Matrix.epsilon
    }
    
    /// Returns the row echelon form
    func rowEchelonForm() -> Matrix {
        var a = elements
        let m = rows
        let n = cols
        
        var pivotRow = 0
        
        for col in 0..<n {
            if pivotRow >= m { break }
            
            // Find pivot
            var maxVal = abs(a[pivotRow][col])
            var maxRow = pivotRow
            
            for row in (pivotRow + 1)..<m {
                if abs(a[row][col]) > maxVal {
                    maxVal = abs(a[row][col])
                    maxRow = row
                }
            }
            
            if maxVal < Matrix.epsilon {
                continue
            }
            
            // Swap rows
            if maxRow != pivotRow {
                let temp = a[pivotRow]
                a[pivotRow] = a[maxRow]
                a[maxRow] = temp
            }
            
            // Eliminate below
            for row in (pivotRow + 1)..<m {
                let factor = a[row][col] / a[pivotRow][col]
                a[row][col] = 0.0
                for j in (col + 1)..<n {
                    a[row][j] -= factor * a[pivotRow][j]
                }
            }
            
            pivotRow += 1
        }
        
        return try! Matrix(rows: m, cols: n, elements: a)
    }
    
    /// Returns the reduced row echelon form (RREF)
    func reducedRowEchelonForm() -> Matrix {
        var a = elements
        let m = rows
        let n = cols
        
        var pivotRow = 0
        var pivotCols: [Int] = []
        
        // Forward elimination
        for col in 0..<n {
            if pivotRow >= m { break }
            
            // Find pivot
            var maxVal = abs(a[pivotRow][col])
            var maxRow = pivotRow
            
            for row in (pivotRow + 1)..<m {
                if abs(a[row][col]) > maxVal {
                    maxVal = abs(a[row][col])
                    maxRow = row
                }
            }
            
            if maxVal < Matrix.epsilon {
                continue
            }
            
            // Swap rows
            if maxRow != pivotRow {
                let temp = a[pivotRow]
                a[pivotRow] = a[maxRow]
                a[maxRow] = temp
            }
            
            // Scale pivot row
            let pivot = a[pivotRow][col]
            for j in 0..<n {
                a[pivotRow][j] /= pivot
            }
            
            // Eliminate in column
            for row in 0..<m {
                if row != pivotRow && abs(a[row][col]) > Matrix.epsilon {
                    let factor = a[row][col]
                    for j in 0..<n {
                        a[row][j] -= factor * a[pivotRow][j]
                    }
                }
            }
            
            pivotCols.append(col)
            pivotRow += 1
        }
        
        return try! Matrix(rows: m, cols: n, elements: a)
    }
}

// MARK: - CustomStringConvertible

extension Matrix: CustomStringConvertible {
    
    /// Returns a formatted string representation
    var description: String {
        return description(decimalPlaces: 6)
    }
    
    /// Returns a formatted string with specified decimal places
    func description(decimalPlaces: Int) -> String {
        var lines: [String] = []
        
        for i in 0..<rows {
            let rowStr = elements[i].map { value -> String in
                if abs(value) < Matrix.epsilon {
                    return "0"
                }
                if abs(value - value.rounded()) < Matrix.epsilon {
                    return String(format: "%.0f", value)
                }
                return String(format: "%.\(decimalPlaces)g", value)
            }.joined(separator: "\t")
            
            lines.append("[\(rowStr)]")
        }
        
        return lines.joined(separator: "\n")
    }
}

// MARK: - Hashable

extension Matrix: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rows)
        hasher.combine(cols)
        for row in elements {
            for element in row {
                hasher.combine(element)
            }
        }
    }
}
