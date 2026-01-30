import Foundation

// MARK: - SystemSolution

/// Result of solving a system of linear equations
enum SystemSolution: Equatable {
    /// Unique solution with values for each unknown
    case unique([Double])
    
    /// No solution exists (inconsistent system)
    case noSolution
    
    /// Infinitely many solutions (dependent system)
    case infiniteSolutions(String)
    
    /// Whether this is a unique solution
    var isUnique: Bool {
        if case .unique = self { return true }
        return false
    }
    
    /// Gets the solution values if unique
    var values: [Double]? {
        if case .unique(let vals) = self { return vals }
        return nil
    }
}

// MARK: - SimultaneousEquationSolver

/// Solves systems of linear equations using Gaussian elimination with partial pivoting
struct SimultaneousEquationSolver {
    
    private static let epsilon: Double = 1e-15
    
    // MARK: - Main Solver
    
    /// Solves a system of n linear equations with n unknowns
    /// - Parameters:
    ///   - coefficients: Matrix of coefficients (n×n)
    ///   - constants: Right-hand side values (n elements)
    /// - Returns: Solution type with values or status
    static func solve(coefficients: [[Double]], constants: [Double]) throws -> SystemSolution {
        let n = coefficients.count
        
        guard n >= 2 && n <= 4 else {
            throw CalculatorError.invalidInput("System must have 2-4 equations")
        }
        guard constants.count == n else {
            throw CalculatorError.invalidInput("Number of constants must match number of equations")
        }
        for row in coefficients {
            guard row.count == n else {
                throw CalculatorError.invalidInput("Coefficient matrix must be square")
            }
        }
        
        let augmented = createAugmentedMatrix(coefficients: coefficients, constants: constants)
        let reduced = gaussianElimination(augmented)
        return backSubstitution(reduced)
    }
    
    /// Solves a 2×2 system: a₁x + b₁y = c₁, a₂x + b₂y = c₂
    static func solve2x2(
        a1: Double, b1: Double, c1: Double,
        a2: Double, b2: Double, c2: Double
    ) throws -> SystemSolution {
        let coefficients = [
            [a1, b1],
            [a2, b2]
        ]
        let constants = [c1, c2]
        return try solve(coefficients: coefficients, constants: constants)
    }
    
    /// Solves a 3×3 system
    static func solve3x3(
        a1: Double, b1: Double, c1: Double, d1: Double,
        a2: Double, b2: Double, c2: Double, d2: Double,
        a3: Double, b3: Double, c3: Double, d3: Double
    ) throws -> SystemSolution {
        let coefficients = [
            [a1, b1, c1],
            [a2, b2, c2],
            [a3, b3, c3]
        ]
        let constants = [d1, d2, d3]
        return try solve(coefficients: coefficients, constants: constants)
    }
    
    /// Solves a 4×4 system
    static func solve4x4(
        row1: (Double, Double, Double, Double, Double),
        row2: (Double, Double, Double, Double, Double),
        row3: (Double, Double, Double, Double, Double),
        row4: (Double, Double, Double, Double, Double)
    ) throws -> SystemSolution {
        let coefficients = [
            [row1.0, row1.1, row1.2, row1.3],
            [row2.0, row2.1, row2.2, row2.3],
            [row3.0, row3.1, row3.2, row3.3],
            [row4.0, row4.1, row4.2, row4.3]
        ]
        let constants = [row1.4, row2.4, row3.4, row4.4]
        return try solve(coefficients: coefficients, constants: constants)
    }
    
    // MARK: - Gaussian Elimination with Partial Pivoting
    
    /// Performs Gaussian elimination with partial pivoting
    private static func gaussianElimination(_ augmented: [[Double]]) -> [[Double]] {
        var matrix = augmented
        let n = matrix.count
        let m = matrix[0].count
        
        for col in 0..<min(n, m - 1) {
            let pivotRow = findPivotRow(matrix, column: col, startRow: col)
            
            if pivotRow != col {
                swapRows(&matrix, row1: col, row2: pivotRow)
            }
            
            if abs(matrix[col][col]) < epsilon {
                continue
            }
            
            for row in (col + 1)..<n {
                let factor = matrix[row][col] / matrix[col][col]
                for j in col..<m {
                    matrix[row][j] -= factor * matrix[col][j]
                }
                matrix[row][col] = 0
            }
        }
        
        return matrix
    }
    
    /// Back substitution to find solution from row echelon form
    private static func backSubstitution(_ matrix: [[Double]]) -> SystemSolution {
        let n = matrix.count
        
        for row in matrix {
            let coeffs = Array(row.dropLast())
            let constant = row.last!
            if coeffs.allSatisfy({ abs($0) < epsilon }) && abs(constant) > epsilon {
                return .noSolution
            }
        }
        
        let zeroRows = matrix.filter { row in
            row.allSatisfy { abs($0) < epsilon }
        }
        if !zeroRows.isEmpty {
            return .infiniteSolutions("System has infinitely many solutions (dependent equations)")
        }
        
        var pivotCount = 0
        for i in 0..<n {
            if i < matrix[i].count - 1 && abs(matrix[i][i]) > epsilon {
                pivotCount += 1
            }
        }
        if pivotCount < n {
            return .infiniteSolutions("System has infinitely many solutions (rank deficient)")
        }
        
        var solution = [Double](repeating: 0, count: n)
        
        for i in stride(from: n - 1, through: 0, by: -1) {
            var sum = matrix[i][n]
            for j in (i + 1)..<n {
                sum -= matrix[i][j] * solution[j]
            }
            
            if abs(matrix[i][i]) < epsilon {
                return .infiniteSolutions("System has infinitely many solutions")
            }
            
            solution[i] = sum / matrix[i][i]
        }
        
        return .unique(solution)
    }
    
    // MARK: - Matrix Operations
    
    /// Creates augmented matrix [A|b]
    private static func createAugmentedMatrix(coefficients: [[Double]], constants: [Double]) -> [[Double]] {
        var augmented: [[Double]] = []
        for (i, row) in coefficients.enumerated() {
            var augmentedRow = row
            augmentedRow.append(constants[i])
            augmented.append(augmentedRow)
        }
        return augmented
    }
    
    /// Swaps two rows in a matrix
    private static func swapRows(_ matrix: inout [[Double]], row1: Int, row2: Int) {
        let temp = matrix[row1]
        matrix[row1] = matrix[row2]
        matrix[row2] = temp
    }
    
    /// Finds the pivot row (row with largest absolute value in column)
    private static func findPivotRow(_ matrix: [[Double]], column: Int, startRow: Int) -> Int {
        var maxRow = startRow
        var maxValue = abs(matrix[startRow][column])
        
        for row in (startRow + 1)..<matrix.count {
            let value = abs(matrix[row][column])
            if value > maxValue {
                maxValue = value
                maxRow = row
            }
        }
        
        return maxRow
    }
    
    // MARK: - Determinant (for 2x2 and 3x3)
    
    /// Computes determinant of 2x2 matrix
    private static func determinant2x2(_ matrix: [[Double]]) -> Double {
        return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]
    }
    
    /// Computes determinant of 3x3 matrix using rule of Sarrus
    private static func determinant3x3(_ matrix: [[Double]]) -> Double {
        let a = matrix[0][0], b = matrix[0][1], c = matrix[0][2]
        let d = matrix[1][0], e = matrix[1][1], f = matrix[1][2]
        let g = matrix[2][0], h = matrix[2][1], i = matrix[2][2]
        
        return a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)
    }
}
