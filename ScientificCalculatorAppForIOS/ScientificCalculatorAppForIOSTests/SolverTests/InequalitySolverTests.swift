import XCTest
@testable import ScientificCalculatorAppForIOS

final class InequalitySolverTests: XCTestCase {
    
    // MARK: - Quadratic Inequality Tests - Less Than
    
    func test_Quadratic_LessThan_TwoRoots() throws {
        // x² - 4 < 0 → (-2, 2)
        let result = try InequalitySolver.solveQuadratic(
            a: 1, b: 0, c: -4,
            comparison: .lessThan
        )
        
        XCTAssertEqual(result.criticalPoints.count, 2)
        XCTAssertEqual(result.intervals.count, 1)
        
        let interval = result.intervals[0]
        XCTAssertEqual(interval.lower!, -2, accuracy: 1e-10)
        XCTAssertEqual(interval.upper!, 2, accuracy: 1e-10)
        XCTAssertFalse(interval.lowerInclusive)
        XCTAssertFalse(interval.upperInclusive)
    }
    
    func test_Quadratic_LessThan_NoSolution() throws {
        // x² + 1 < 0 → ∅ (never negative)
        let result = try InequalitySolver.solveQuadratic(
            a: 1, b: 0, c: 1,
            comparison: .lessThan
        )
        
        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(result.notation, "∅")
    }
    
    func test_Quadratic_LessThan_NegativeLeading() throws {
        // -x² + 4 < 0 → (-∞, -2) ∪ (2, ∞)
        let result = try InequalitySolver.solveQuadratic(
            a: -1, b: 0, c: 4,
            comparison: .lessThan
        )
        
        XCTAssertEqual(result.intervals.count, 2)
        
        // First interval: (-∞, -2)
        XCTAssertNil(result.intervals[0].lower)
        XCTAssertEqual(result.intervals[0].upper!, -2, accuracy: 1e-10)
        
        // Second interval: (2, ∞)
        XCTAssertEqual(result.intervals[1].lower!, 2, accuracy: 1e-10)
        XCTAssertNil(result.intervals[1].upper)
    }
    
    // MARK: - Quadratic Inequality Tests - Greater Than
    
    func test_Quadratic_GreaterThan_TwoRoots() throws {
        // x² - 4 > 0 → (-∞, -2) ∪ (2, ∞)
        let result = try InequalitySolver.solveQuadratic(
            a: 1, b: 0, c: -4,
            comparison: .greaterThan
        )
        
        XCTAssertEqual(result.intervals.count, 2)
        
        // First interval: (-∞, -2)
        XCTAssertNil(result.intervals[0].lower)
        XCTAssertEqual(result.intervals[0].upper!, -2, accuracy: 1e-10)
        XCTAssertFalse(result.intervals[0].upperInclusive)
        
        // Second interval: (2, ∞)
        XCTAssertEqual(result.intervals[1].lower!, 2, accuracy: 1e-10)
        XCTAssertNil(result.intervals[1].upper)
        XCTAssertFalse(result.intervals[1].lowerInclusive)
    }
    
    func test_Quadratic_GreaterThan_AllReals() throws {
        // x² + 1 > 0 → ℝ (always positive)
        let result = try InequalitySolver.solveQuadratic(
            a: 1, b: 0, c: 1,
            comparison: .greaterThan
        )
        
        XCTAssertTrue(result.isAllReals)
        XCTAssertEqual(result.notation, "ℝ")
    }
    
    // MARK: - Quadratic Inequality Tests - Less Than Or Equal
    
    func test_Quadratic_LessThanOrEqual_IncludesRoots() throws {
        // x² - 4 ≤ 0 → [-2, 2]
        let result = try InequalitySolver.solveQuadratic(
            a: 1, b: 0, c: -4,
            comparison: .lessThanOrEqual
        )
        
        XCTAssertEqual(result.intervals.count, 1)
        
        let interval = result.intervals[0]
        XCTAssertEqual(interval.lower!, -2, accuracy: 1e-10)
        XCTAssertEqual(interval.upper!, 2, accuracy: 1e-10)
        XCTAssertTrue(interval.lowerInclusive)
        XCTAssertTrue(interval.upperInclusive)
    }
    
    func test_Quadratic_LessThanOrEqual_TouchesZero() throws {
        // x² ≤ 0 → x = 0 only
        let result = try InequalitySolver.solveQuadratic(
            a: 1, b: 0, c: 0,
            comparison: .lessThanOrEqual
        )
        
        // Should have point solution at x = 0
        XCTAssertFalse(result.isEmpty)
    }
    
    // MARK: - Quadratic Inequality Tests - Greater Than Or Equal
    
    func test_Quadratic_GreaterThanOrEqual_IncludesRoots() throws {
        // x² - 4 ≥ 0 → (-∞, -2] ∪ [2, ∞)
        let result = try InequalitySolver.solveQuadratic(
            a: 1, b: 0, c: -4,
            comparison: .greaterThanOrEqual
        )
        
        XCTAssertEqual(result.intervals.count, 2)
        
        // First interval: (-∞, -2]
        XCTAssertTrue(result.intervals[0].upperInclusive)
        
        // Second interval: [2, ∞)
        XCTAssertTrue(result.intervals[1].lowerInclusive)
    }
    
    func test_Quadratic_GreaterThanOrEqual_AllReals() throws {
        // x² ≥ 0 → ℝ (always ≥ 0)
        let result = try InequalitySolver.solveQuadratic(
            a: 1, b: 0, c: 0,
            comparison: .greaterThanOrEqual
        )
        
        XCTAssertTrue(result.isAllReals)
    }
    
    // MARK: - Quadratic Tests - No Real Roots
    
    func test_Quadratic_NoRealRoots_AlwaysPositive_LessThan() throws {
        // x² + 2x + 5 < 0 → ∅ (discriminant < 0, always positive)
        let result = try InequalitySolver.solveQuadratic(
            a: 1, b: 2, c: 5,
            comparison: .lessThan
        )
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_Quadratic_NoRealRoots_AlwaysPositive_GreaterThan() throws {
        // x² + 2x + 5 > 0 → ℝ (discriminant < 0, always positive)
        let result = try InequalitySolver.solveQuadratic(
            a: 1, b: 2, c: 5,
            comparison: .greaterThan
        )
        
        XCTAssertTrue(result.isAllReals)
    }
    
    func test_Quadratic_NoRealRoots_AlwaysNegative_LessThan() throws {
        // -x² - 1 < 0 → ℝ (always negative)
        let result = try InequalitySolver.solveQuadratic(
            a: -1, b: 0, c: -1,
            comparison: .lessThan
        )
        
        XCTAssertTrue(result.isAllReals)
    }
    
    // MARK: - Cubic Inequality Tests
    
    func test_Cubic_ThreeRoots_LessThan() throws {
        // (x-1)(x-2)(x-3) = x³ - 6x² + 11x - 6 < 0
        // Solution: (-∞, 1) ∪ (2, 3)
        let result = try InequalitySolver.solveCubic(
            a: 1, b: -6, c: 11, d: -6,
            comparison: .lessThan
        )
        
        XCTAssertEqual(result.criticalPoints.count, 3)
        XCTAssertEqual(result.intervals.count, 2)
    }
    
    func test_Cubic_ThreeRoots_GreaterThan() throws {
        // (x-1)(x-2)(x-3) = x³ - 6x² + 11x - 6 > 0
        // Solution: (1, 2) ∪ (3, ∞)
        let result = try InequalitySolver.solveCubic(
            a: 1, b: -6, c: 11, d: -6,
            comparison: .greaterThan
        )
        
        XCTAssertEqual(result.criticalPoints.count, 3)
        XCTAssertEqual(result.intervals.count, 2)
    }
    
    func test_Cubic_OneRealRoot() throws {
        // x³ + 1 > 0 → x > -1
        let result = try InequalitySolver.solveCubic(
            a: 1, b: 0, c: 0, d: 1,
            comparison: .greaterThan
        )
        
        XCTAssertEqual(result.criticalPoints.count, 1)
        XCTAssertEqual(result.criticalPoints[0], -1, accuracy: 1e-8)
        XCTAssertEqual(result.intervals.count, 1)
        XCTAssertEqual(result.intervals[0].lower!, -1, accuracy: 1e-8)
        XCTAssertNil(result.intervals[0].upper)
    }
    
    // MARK: - Quartic Inequality Tests
    
    func test_Quartic_FourRoots() throws {
        // (x-1)(x-2)(x-3)(x-4) > 0
        let result = try InequalitySolver.solveQuartic(
            a: 1, b: -10, c: 35, d: -50, e: 24,
            comparison: .greaterThan
        )
        
        XCTAssertEqual(result.criticalPoints.count, 4)
        // Should have 3 intervals: (-∞, 1), (2, 3), (4, ∞)
        XCTAssertEqual(result.intervals.count, 3)
    }
    
    func test_Quartic_Biquadratic_LessThan() throws {
        // x⁴ - 5x² + 4 < 0 → (-2, -1) ∪ (1, 2)
        let result = try InequalitySolver.solveQuartic(
            a: 1, b: 0, c: -5, d: 0, e: 4,
            comparison: .lessThan
        )
        
        XCTAssertEqual(result.criticalPoints.count, 4)
        XCTAssertEqual(result.intervals.count, 2)
    }
    
    // MARK: - Linear Inequality Tests
    
    func test_Linear_LessThan() throws {
        // 2x - 4 < 0 → x < 2
        let result = try InequalitySolver.solve(
            coefficients: [2, -4],
            comparison: .lessThan
        )
        
        XCTAssertEqual(result.criticalPoints.count, 1)
        XCTAssertEqual(result.criticalPoints[0], 2, accuracy: 1e-10)
        XCTAssertEqual(result.intervals.count, 1)
        XCTAssertNil(result.intervals[0].lower)
        XCTAssertEqual(result.intervals[0].upper!, 2, accuracy: 1e-10)
        XCTAssertFalse(result.intervals[0].upperInclusive)
    }
    
    func test_Linear_GreaterThan() throws {
        // 2x - 4 > 0 → x > 2
        let result = try InequalitySolver.solve(
            coefficients: [2, -4],
            comparison: .greaterThan
        )
        
        XCTAssertEqual(result.intervals.count, 1)
        XCTAssertEqual(result.intervals[0].lower!, 2, accuracy: 1e-10)
        XCTAssertNil(result.intervals[0].upper)
    }
    
    func test_Linear_NegativeSlope() throws {
        // -x + 2 < 0 → x > 2
        let result = try InequalitySolver.solve(
            coefficients: [-1, 2],
            comparison: .lessThan
        )
        
        XCTAssertEqual(result.intervals.count, 1)
        XCTAssertEqual(result.intervals[0].lower!, 2, accuracy: 1e-10)
        XCTAssertNil(result.intervals[0].upper)
    }
    
    // MARK: - Constant Inequality Tests
    
    func test_Constant_Positive_LessThan() throws {
        // 5 < 0 → ∅
        let result = try InequalitySolver.solve(
            coefficients: [5],
            comparison: .lessThan
        )
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_Constant_Positive_GreaterThan() throws {
        // 5 > 0 → ℝ
        let result = try InequalitySolver.solve(
            coefficients: [5],
            comparison: .greaterThan
        )
        
        XCTAssertTrue(result.isAllReals)
    }
    
    func test_Constant_Negative_LessThan() throws {
        // -5 < 0 → ℝ
        let result = try InequalitySolver.solve(
            coefficients: [-5],
            comparison: .lessThan
        )
        
        XCTAssertTrue(result.isAllReals)
    }
    
    func test_Constant_Zero_LessThanOrEqual() throws {
        // 0 ≤ 0 → ℝ
        let result = try InequalitySolver.solve(
            coefficients: [0],
            comparison: .lessThanOrEqual
        )
        
        XCTAssertTrue(result.isAllReals)
    }
    
    // MARK: - Interval Tests
    
    func test_Interval_Notation_Bounded() {
        let interval = Interval(lower: 1, upper: 5, lowerInclusive: true, upperInclusive: false)
        XCTAssertEqual(interval.description, "[1, 5)")
    }
    
    func test_Interval_Notation_Unbounded_Left() {
        let interval = Interval(lower: nil, upper: 5, lowerInclusive: false, upperInclusive: true)
        XCTAssertEqual(interval.description, "(-∞, 5]")
    }
    
    func test_Interval_Notation_Unbounded_Right() {
        let interval = Interval(lower: 3, upper: nil, lowerInclusive: true, upperInclusive: false)
        XCTAssertEqual(interval.description, "[3, ∞)")
    }
    
    func test_Interval_Notation_AllReals() {
        let interval = Interval.allReals
        XCTAssertEqual(interval.description, "(-∞, ∞)")
    }
    
    func test_Interval_Contains_Interior() {
        let interval = Interval(lower: 1, upper: 5, lowerInclusive: true, upperInclusive: false)
        XCTAssertTrue(interval.contains(1))
        XCTAssertTrue(interval.contains(3))
        XCTAssertFalse(interval.contains(5))
        XCTAssertFalse(interval.contains(0))
        XCTAssertFalse(interval.contains(6))
    }
    
    func test_Interval_Contains_WithInclusion() {
        let interval = Interval(lower: 1, upper: 5, lowerInclusive: false, upperInclusive: true)
        XCTAssertFalse(interval.contains(1))
        XCTAssertTrue(interval.contains(5))
    }
    
    func test_Interval_Contains_Unbounded() {
        let interval = Interval(lower: nil, upper: 5, lowerInclusive: false, upperInclusive: false)
        XCTAssertTrue(interval.contains(-1000))
        XCTAssertTrue(interval.contains(0))
        XCTAssertFalse(interval.contains(5))
        XCTAssertFalse(interval.contains(10))
    }
    
    func test_Interval_IsEmpty_Invalid() {
        let interval = Interval(lower: 5, upper: 1, lowerInclusive: false, upperInclusive: false)
        XCTAssertTrue(interval.isEmpty)
    }
    
    func test_Interval_IsEmpty_SinglePoint_NotInclusive() {
        let interval = Interval(lower: 3, upper: 3, lowerInclusive: false, upperInclusive: false)
        XCTAssertTrue(interval.isEmpty)
    }
    
    func test_Interval_IsNotEmpty_SinglePoint_Inclusive() {
        let interval = Interval(lower: 3, upper: 3, lowerInclusive: true, upperInclusive: true)
        XCTAssertFalse(interval.isEmpty)
        XCTAssertTrue(interval.contains(3))
    }
    
    func test_Interval_IsAllReals() {
        XCTAssertTrue(Interval.allReals.isAllReals)
        XCTAssertFalse(Interval(lower: 0, upper: nil, lowerInclusive: false, upperInclusive: false).isAllReals)
    }
    
    func test_Interval_StaticConstructors() {
        let lessThan = Interval.lessThan(5)
        XCTAssertNil(lessThan.lower)
        XCTAssertEqual(lessThan.upper, 5)
        XCTAssertFalse(lessThan.upperInclusive)
        
        let lessThanOrEqual = Interval.lessThanOrEqual(5)
        XCTAssertTrue(lessThanOrEqual.upperInclusive)
        
        let greaterThan = Interval.greaterThan(3)
        XCTAssertEqual(greaterThan.lower, 3)
        XCTAssertNil(greaterThan.upper)
        XCTAssertFalse(greaterThan.lowerInclusive)
        
        let greaterThanOrEqual = Interval.greaterThanOrEqual(3)
        XCTAssertTrue(greaterThanOrEqual.lowerInclusive)
        
        let open = Interval.open(1, 5)
        XCTAssertFalse(open.lowerInclusive)
        XCTAssertFalse(open.upperInclusive)
        
        let closed = Interval.closed(1, 5)
        XCTAssertTrue(closed.lowerInclusive)
        XCTAssertTrue(closed.upperInclusive)
    }
    
    // MARK: - ComparisonOperator Tests
    
    func test_ComparisonOperator_IncludesEquality() {
        XCTAssertFalse(ComparisonOperator.lessThan.includesEquality)
        XCTAssertTrue(ComparisonOperator.lessThanOrEqual.includesEquality)
        XCTAssertFalse(ComparisonOperator.greaterThan.includesEquality)
        XCTAssertTrue(ComparisonOperator.greaterThanOrEqual.includesEquality)
    }
    
    func test_ComparisonOperator_Opposite() {
        XCTAssertEqual(ComparisonOperator.lessThan.opposite, .greaterThan)
        XCTAssertEqual(ComparisonOperator.lessThanOrEqual.opposite, .greaterThanOrEqual)
        XCTAssertEqual(ComparisonOperator.greaterThan.opposite, .lessThan)
        XCTAssertEqual(ComparisonOperator.greaterThanOrEqual.opposite, .lessThanOrEqual)
    }
    
    func test_ComparisonOperator_RawValue() {
        XCTAssertEqual(ComparisonOperator.lessThan.rawValue, "<")
        XCTAssertEqual(ComparisonOperator.lessThanOrEqual.rawValue, "≤")
        XCTAssertEqual(ComparisonOperator.greaterThan.rawValue, ">")
        XCTAssertEqual(ComparisonOperator.greaterThanOrEqual.rawValue, "≥")
    }
    
    // MARK: - InequalitySolution Tests
    
    func test_InequalitySolution_Notation_MultipleIntervals() throws {
        // x² - 4 > 0 → (-∞, -2) ∪ (2, ∞)
        let result = try InequalitySolver.solveQuadratic(
            a: 1, b: 0, c: -4,
            comparison: .greaterThan
        )
        
        XCTAssertTrue(result.notation.contains("∪"))
    }
    
    func test_InequalitySolution_Notation_Empty() {
        let solution = InequalitySolution(criticalPoints: [], intervals: [])
        XCTAssertEqual(solution.notation, "∅")
    }
    
    func test_InequalitySolution_Notation_AllReals() {
        let solution = InequalitySolution(criticalPoints: [], intervals: [.allReals])
        XCTAssertEqual(solution.notation, "ℝ")
    }
    
    // MARK: - Edge Cases
    
    func test_Solve_EmptyCoefficients_ThrowsError() {
        XCTAssertThrowsError(try InequalitySolver.solve(coefficients: [], comparison: .lessThan)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Solve_LeadingZeros_RemovesAndSolves() throws {
        // [0, 0, 1, -4] represents x - 4, should solve as linear
        let result = try InequalitySolver.solve(
            coefficients: [0, 0, 1, -4],
            comparison: .lessThan
        )
        
        XCTAssertEqual(result.criticalPoints.count, 1)
        XCTAssertEqual(result.criticalPoints[0], 4, accuracy: 1e-10)
    }
    
    func test_Solve_RepeatedRoot() throws {
        // (x - 2)² > 0 → x ≠ 2, i.e., (-∞, 2) ∪ (2, ∞)
        // x² - 4x + 4 > 0
        let result = try InequalitySolver.solveQuadratic(
            a: 1, b: -4, c: 4,
            comparison: .greaterThan
        )
        
        // Should exclude only x = 2
        XCTAssertEqual(result.intervals.count, 2)
    }
    
    func test_Solve_LargeCoefficients() throws {
        // 1e6 * x² - 4e6 = 0 → x = ±2
        let result = try InequalitySolver.solveQuadratic(
            a: 1e6, b: 0, c: -4e6,
            comparison: .lessThan
        )
        
        XCTAssertEqual(result.intervals.count, 1)
        XCTAssertEqual(result.intervals[0].lower!, -2, accuracy: 1e-6)
        XCTAssertEqual(result.intervals[0].upper!, 2, accuracy: 1e-6)
    }
    
    func test_Solve_SmallCoefficients() throws {
        // 1e-6 * x² - 4e-6 = 0 → x = ±2
        let result = try InequalitySolver.solveQuadratic(
            a: 1e-6, b: 0, c: -4e-6,
            comparison: .lessThan
        )
        
        XCTAssertEqual(result.intervals.count, 1)
        XCTAssertEqual(result.intervals[0].lower!, -2, accuracy: 1e-6)
        XCTAssertEqual(result.intervals[0].upper!, 2, accuracy: 1e-6)
    }
}
