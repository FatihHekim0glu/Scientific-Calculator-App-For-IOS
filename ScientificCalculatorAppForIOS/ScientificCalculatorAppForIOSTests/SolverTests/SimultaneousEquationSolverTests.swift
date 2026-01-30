import XCTest
@testable import ScientificCalculatorAppForIOS

final class SimultaneousEquationSolverTests: XCTestCase {
    
    // MARK: - 2×2 System Tests
    
    func test_2x2_UniqueSolution_SimpleSystem() throws {
        // x + y = 5, x - y = 1 → x = 3, y = 2
        let result = try SimultaneousEquationSolver.solve2x2(
            a1: 1, b1: 1, c1: 5,
            a2: 1, b2: -1, c2: 1
        )
        
        if case .unique(let values) = result {
            XCTAssertEqual(values[0], 3, accuracy: 1e-10)
            XCTAssertEqual(values[1], 2, accuracy: 1e-10)
        } else {
            XCTFail("Expected unique solution")
        }
    }
    
    func test_2x2_UniqueSolution_WithNegatives() throws {
        // 2x - 3y = -4, 5x + y = 7 → x = 1, y = 2
        let result = try SimultaneousEquationSolver.solve2x2(
            a1: 2, b1: -3, c1: -4,
            a2: 5, b2: 1, c2: 7
        )
        
        if case .unique(let values) = result {
            XCTAssertEqual(values[0], 1, accuracy: 1e-10)
            XCTAssertEqual(values[1], 2, accuracy: 1e-10)
        } else {
            XCTFail("Expected unique solution")
        }
    }
    
    func test_2x2_UniqueSolution_WithDecimals() throws {
        // 0.5x + 0.25y = 1.25, x + y = 3 → x = 1, y = 2
        let result = try SimultaneousEquationSolver.solve2x2(
            a1: 0.5, b1: 0.25, c1: 1.25,
            a2: 1, b2: 1, c2: 3
        )
        
        if case .unique(let values) = result {
            XCTAssertEqual(values[0], 1, accuracy: 1e-10)
            XCTAssertEqual(values[1], 2, accuracy: 1e-10)
        } else {
            XCTFail("Expected unique solution")
        }
    }
    
    func test_2x2_NoSolution_ParallelLines() throws {
        // x + y = 1, x + y = 2 (parallel lines)
        let result = try SimultaneousEquationSolver.solve2x2(
            a1: 1, b1: 1, c1: 1,
            a2: 1, b2: 1, c2: 2
        )
        
        XCTAssertEqual(result, .noSolution)
    }
    
    func test_2x2_NoSolution_ParallelLinesScaled() throws {
        // x + y = 1, 2x + 2y = 5 (parallel)
        let result = try SimultaneousEquationSolver.solve2x2(
            a1: 1, b1: 1, c1: 1,
            a2: 2, b2: 2, c2: 5
        )
        
        XCTAssertEqual(result, .noSolution)
    }
    
    func test_2x2_InfiniteSolutions_SameLine() throws {
        // x + y = 2, 2x + 2y = 4 (same line)
        let result = try SimultaneousEquationSolver.solve2x2(
            a1: 1, b1: 1, c1: 2,
            a2: 2, b2: 2, c2: 4
        )
        
        if case .infiniteSolutions = result {
            // Pass
        } else {
            XCTFail("Expected infinite solutions")
        }
    }
    
    // MARK: - 3×3 System Tests
    
    func test_3x3_UniqueSolution() throws {
        // x + y + z = 6, x - y + z = 2, 2x + y - z = 1 → x = 1, y = 2, z = 3
        let result = try SimultaneousEquationSolver.solve3x3(
            a1: 1, b1: 1, c1: 1, d1: 6,
            a2: 1, b2: -1, c2: 1, d2: 2,
            a3: 2, b3: 1, c3: -1, d3: 1
        )
        
        if case .unique(let values) = result {
            XCTAssertEqual(values[0], 1, accuracy: 1e-10)
            XCTAssertEqual(values[1], 2, accuracy: 1e-10)
            XCTAssertEqual(values[2], 3, accuracy: 1e-10)
        } else {
            XCTFail("Expected unique solution")
        }
    }
    
    func test_3x3_UniqueSolution_FromClassicProblem() throws {
        // 2x - y + z = 3, x + 2y - z = -1, 3x + y + 2z = 10 → x = 1, y = -1, z = 3
        let result = try SimultaneousEquationSolver.solve3x3(
            a1: 2, b1: -1, c1: 1, d1: 3,
            a2: 1, b2: 2, c2: -1, d2: -1,
            a3: 3, b3: 1, c3: 2, d3: 10
        )
        
        if case .unique(let values) = result {
            XCTAssertEqual(values[0], 1, accuracy: 1e-8)
            XCTAssertEqual(values[1], -1, accuracy: 1e-8)
            XCTAssertEqual(values[2], 3, accuracy: 1e-8)
        } else {
            XCTFail("Expected unique solution")
        }
    }
    
    func test_3x3_NoSolution_Inconsistent() throws {
        // x + y + z = 1, x + y + z = 2, x + 2y + z = 3
        let result = try SimultaneousEquationSolver.solve3x3(
            a1: 1, b1: 1, c1: 1, d1: 1,
            a2: 1, b2: 1, c2: 1, d2: 2,
            a3: 1, b3: 2, c3: 1, d3: 3
        )
        
        XCTAssertEqual(result, .noSolution)
    }
    
    func test_3x3_InfiniteSolutions_Dependent() throws {
        // x + y + z = 6, 2x + 2y + 2z = 12, x - y + z = 2
        let result = try SimultaneousEquationSolver.solve3x3(
            a1: 1, b1: 1, c1: 1, d1: 6,
            a2: 2, b2: 2, c2: 2, d2: 12,
            a3: 1, b3: -1, c3: 1, d3: 2
        )
        
        if case .infiniteSolutions = result {
            // Pass
        } else {
            XCTFail("Expected infinite solutions, got \(result)")
        }
    }
    
    // MARK: - 4×4 System Tests
    
    func test_4x4_UniqueSolution() throws {
        // Simple 4×4 system with known solution x=1, y=2, z=3, w=4
        let result = try SimultaneousEquationSolver.solve4x4(
            row1: (1, 1, 1, 1, 10),    // x + y + z + w = 10
            row2: (1, -1, 1, -1, -2),  // x - y + z - w = -2
            row3: (2, 1, -1, 1, 3),    // 2x + y - z + w = 3
            row4: (1, 2, 1, -1, 2)     // x + 2y + z - w = 2
        )
        
        if case .unique(let values) = result {
            XCTAssertEqual(values[0], 1, accuracy: 1e-8)
            XCTAssertEqual(values[1], 2, accuracy: 1e-8)
            XCTAssertEqual(values[2], 3, accuracy: 1e-8)
            XCTAssertEqual(values[3], 4, accuracy: 1e-8)
        } else {
            XCTFail("Expected unique solution")
        }
    }
    
    // MARK: - General Solve Method Tests
    
    func test_Solve_ValidatesSquareMatrix() throws {
        let coefficients = [[1.0, 2.0], [3.0, 4.0, 5.0]]
        let constants = [1.0, 2.0]
        
        XCTAssertThrowsError(try SimultaneousEquationSolver.solve(coefficients: coefficients, constants: constants)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Solve_ValidatesDimensionMatch() throws {
        let coefficients = [[1.0, 2.0], [3.0, 4.0]]
        let constants = [1.0, 2.0, 3.0]
        
        XCTAssertThrowsError(try SimultaneousEquationSolver.solve(coefficients: coefficients, constants: constants)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Solve_ValidatesMinEquations() throws {
        let coefficients = [[1.0]]
        let constants = [1.0]
        
        XCTAssertThrowsError(try SimultaneousEquationSolver.solve(coefficients: coefficients, constants: constants)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Solve_ValidatesMaxEquations() throws {
        let coefficients = Array(repeating: Array(repeating: 1.0, count: 5), count: 5)
        let constants = Array(repeating: 1.0, count: 5)
        
        XCTAssertThrowsError(try SimultaneousEquationSolver.solve(coefficients: coefficients, constants: constants)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Solve_HandlesNearSingular() throws {
        // Nearly singular matrix (very small determinant)
        let epsilon = 1e-14
        let coefficients = [
            [1.0, 1.0],
            [1.0, 1.0 + epsilon]
        ]
        let constants = [2.0, 2.0 + epsilon]
        
        let result = try SimultaneousEquationSolver.solve(coefficients: coefficients, constants: constants)
        
        // Should either succeed with a unique solution or report infinite solutions
        switch result {
        case .unique(let values):
            XCTAssertEqual(values[0], 1.0, accuracy: 1e-5)
            XCTAssertEqual(values[1], 1.0, accuracy: 1e-5)
        case .infiniteSolutions:
            // Also acceptable for near-singular
            break
        case .noSolution:
            XCTFail("Should not be no solution for consistent system")
        }
    }
    
    // MARK: - SystemSolution Properties Tests
    
    func test_SystemSolution_IsUnique_True() {
        let solution = SystemSolution.unique([1.0, 2.0])
        XCTAssertTrue(solution.isUnique)
    }
    
    func test_SystemSolution_IsUnique_False_NoSolution() {
        let solution = SystemSolution.noSolution
        XCTAssertFalse(solution.isUnique)
    }
    
    func test_SystemSolution_IsUnique_False_InfiniteSolutions() {
        let solution = SystemSolution.infiniteSolutions("Test")
        XCTAssertFalse(solution.isUnique)
    }
    
    func test_SystemSolution_Values_ReturnsValuesForUnique() {
        let solution = SystemSolution.unique([1.0, 2.0, 3.0])
        XCTAssertEqual(solution.values, [1.0, 2.0, 3.0])
    }
    
    func test_SystemSolution_Values_ReturnsNilForNoSolution() {
        let solution = SystemSolution.noSolution
        XCTAssertNil(solution.values)
    }
    
    func test_SystemSolution_Values_ReturnsNilForInfinite() {
        let solution = SystemSolution.infiniteSolutions("Parameterized")
        XCTAssertNil(solution.values)
    }
    
    // MARK: - Edge Cases
    
    func test_Solve_WithZeroRow_Dependent() throws {
        // First row is all zeros (with zero constant)
        let coefficients = [
            [0.0, 0.0],
            [1.0, 1.0]
        ]
        let constants = [0.0, 2.0]
        
        let result = try SimultaneousEquationSolver.solve(coefficients: coefficients, constants: constants)
        
        if case .infiniteSolutions = result {
            // Pass
        } else {
            XCTFail("Expected infinite solutions for underdetermined system")
        }
    }
    
    func test_Solve_WithZeroRow_Inconsistent() throws {
        // First row is all zeros but constant is non-zero
        let coefficients = [
            [0.0, 0.0],
            [1.0, 1.0]
        ]
        let constants = [1.0, 2.0]  // 0 = 1 is inconsistent
        
        let result = try SimultaneousEquationSolver.solve(coefficients: coefficients, constants: constants)
        
        XCTAssertEqual(result, .noSolution)
    }
    
    func test_Solve_RequiresPivoting() throws {
        // System where first pivot is zero - requires row swap
        let coefficients = [
            [0.0, 1.0],
            [1.0, 1.0]
        ]
        let constants = [3.0, 5.0]  // y = 3, x = 2
        
        let result = try SimultaneousEquationSolver.solve(coefficients: coefficients, constants: constants)
        
        if case .unique(let values) = result {
            XCTAssertEqual(values[0], 2.0, accuracy: 1e-10)
            XCTAssertEqual(values[1], 3.0, accuracy: 1e-10)
        } else {
            XCTFail("Expected unique solution")
        }
    }
    
    func test_Solve_LargeCoefficients() throws {
        // System with large coefficients
        let coefficients = [
            [1e6, 2e6],
            [3e6, 4e6]
        ]
        let constants = [3e6, 7e6]  // x = 1, y = 1
        
        let result = try SimultaneousEquationSolver.solve(coefficients: coefficients, constants: constants)
        
        if case .unique(let values) = result {
            XCTAssertEqual(values[0], 1.0, accuracy: 1e-6)
            XCTAssertEqual(values[1], 1.0, accuracy: 1e-6)
        } else {
            XCTFail("Expected unique solution")
        }
    }
    
    func test_Solve_SmallCoefficients() throws {
        // System with small coefficients
        let coefficients = [
            [1e-6, 2e-6],
            [3e-6, 4e-6]
        ]
        let constants = [3e-6, 7e-6]  // x = 1, y = 1
        
        let result = try SimultaneousEquationSolver.solve(coefficients: coefficients, constants: constants)
        
        if case .unique(let values) = result {
            XCTAssertEqual(values[0], 1.0, accuracy: 1e-6)
            XCTAssertEqual(values[1], 1.0, accuracy: 1e-6)
        } else {
            XCTFail("Expected unique solution")
        }
    }
}
