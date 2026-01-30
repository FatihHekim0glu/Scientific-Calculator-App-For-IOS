import XCTest
@testable import ScientificCalculatorAppForIOS

final class VectorTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func test_Init_2D_CreatesTwoComponentVector() {
        let v = Vector(x: 3.0, y: 4.0)
        
        XCTAssertEqual(v.dimension, 2)
        XCTAssertEqual(v.x, 3.0, accuracy: 1e-15)
        XCTAssertEqual(v.y, 4.0, accuracy: 1e-15)
    }
    
    func test_Init_3D_CreatesThreeComponentVector() {
        let v = Vector(x: 1.0, y: 2.0, z: 3.0)
        
        XCTAssertEqual(v.dimension, 3)
        XCTAssertEqual(v.x, 1.0, accuracy: 1e-15)
        XCTAssertEqual(v.y, 2.0, accuracy: 1e-15)
        XCTAssertEqual(v.z, 3.0, accuracy: 1e-15)
    }
    
    func test_Init_FromArray_2D() throws {
        let v = try Vector([3.0, 4.0])
        
        XCTAssertEqual(v.dimension, 2)
        XCTAssertTrue(v.is2D)
    }
    
    func test_Init_FromArray_3D() throws {
        let v = try Vector([1.0, 2.0, 3.0])
        
        XCTAssertEqual(v.dimension, 3)
        XCTAssertTrue(v.is3D)
    }
    
    func test_Init_InvalidDimension_ThrowsError() {
        XCTAssertThrowsError(try Vector([1.0])) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_Init_FourComponents_ThrowsError() {
        XCTAssertThrowsError(try Vector([1.0, 2.0, 3.0, 4.0])) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    // MARK: - Property Tests
    
    func test_Magnitude_3_4_Returns5() {
        let v = Vector(x: 3.0, y: 4.0)
        XCTAssertEqual(v.magnitude, 5.0, accuracy: 1e-10)
    }
    
    func test_Magnitude_3_4_5_ReturnsCorrect() {
        let v = Vector(x: 3.0, y: 4.0, z: 0.0)
        XCTAssertEqual(v.magnitude, 5.0, accuracy: 1e-10)
    }
    
    func test_Magnitude_3D_ReturnsCorrect() {
        let v = Vector(x: 1.0, y: 2.0, z: 2.0)
        XCTAssertEqual(v.magnitude, 3.0, accuracy: 1e-10)
    }
    
    func test_MagnitudeSquared_AvoidsSqrt() {
        let v = Vector(x: 3.0, y: 4.0)
        XCTAssertEqual(v.magnitudeSquared, 25.0, accuracy: 1e-15)
    }
    
    func test_Dimension_2D_Returns2() {
        let v = Vector(x: 1.0, y: 2.0)
        XCTAssertEqual(v.dimension, 2)
    }
    
    func test_Dimension_3D_Returns3() {
        let v = Vector(x: 1.0, y: 2.0, z: 3.0)
        XCTAssertEqual(v.dimension, 3)
    }
    
    func test_IsZero_ZeroVector_ReturnsTrue() {
        let v = Vector(x: 0.0, y: 0.0)
        XCTAssertTrue(v.isZero)
    }
    
    func test_IsZero_NonZero_ReturnsFalse() {
        let v = Vector(x: 0.0, y: 0.001)
        XCTAssertFalse(v.isZero)
    }
    
    func test_Is2D_2DVector_ReturnsTrue() {
        let v = Vector(x: 1.0, y: 2.0)
        XCTAssertTrue(v.is2D)
        XCTAssertFalse(v.is3D)
    }
    
    func test_Is3D_3DVector_ReturnsTrue() {
        let v = Vector(x: 1.0, y: 2.0, z: 3.0)
        XCTAssertTrue(v.is3D)
        XCTAssertFalse(v.is2D)
    }
    
    func test_IsUnit_UnitVector_ReturnsTrue() {
        let v = Vector(x: 1.0, y: 0.0)
        XCTAssertTrue(v.isUnit)
    }
    
    func test_IsUnit_NonUnit_ReturnsFalse() {
        let v = Vector(x: 2.0, y: 0.0)
        XCTAssertFalse(v.isUnit)
    }
    
    // MARK: - Common Vectors Tests
    
    func test_Zero2D() {
        XCTAssertTrue(Vector.zero2D.isZero)
        XCTAssertTrue(Vector.zero2D.is2D)
    }
    
    func test_Zero3D() {
        XCTAssertTrue(Vector.zero3D.isZero)
        XCTAssertTrue(Vector.zero3D.is3D)
    }
    
    func test_UnitX() {
        XCTAssertEqual(Vector.unitX.x, 1.0, accuracy: 1e-15)
        XCTAssertEqual(Vector.unitX.y, 0.0, accuracy: 1e-15)
        XCTAssertEqual(Vector.unitX.z, 0.0, accuracy: 1e-15)
    }
    
    func test_UnitY() {
        XCTAssertEqual(Vector.unitY.x, 0.0, accuracy: 1e-15)
        XCTAssertEqual(Vector.unitY.y, 1.0, accuracy: 1e-15)
        XCTAssertEqual(Vector.unitY.z, 0.0, accuracy: 1e-15)
    }
    
    func test_UnitZ() {
        XCTAssertEqual(Vector.unitZ.x, 0.0, accuracy: 1e-15)
        XCTAssertEqual(Vector.unitZ.y, 0.0, accuracy: 1e-15)
        XCTAssertEqual(Vector.unitZ.z, 1.0, accuracy: 1e-15)
    }
    
    // MARK: - Arithmetic Tests
    
    func test_Addition_SameDimension_ReturnsSum() throws {
        let a = Vector(x: 1.0, y: 2.0)
        let b = Vector(x: 3.0, y: 4.0)
        let result = try a + b
        
        XCTAssertEqual(result.x, 4.0, accuracy: 1e-15)
        XCTAssertEqual(result.y, 6.0, accuracy: 1e-15)
    }
    
    func test_Addition_3D_ReturnsSum() throws {
        let a = Vector(x: 1.0, y: 2.0, z: 3.0)
        let b = Vector(x: 4.0, y: 5.0, z: 6.0)
        let result = try a + b
        
        XCTAssertEqual(result.x, 5.0, accuracy: 1e-15)
        XCTAssertEqual(result.y, 7.0, accuracy: 1e-15)
        XCTAssertEqual(result.z, 9.0, accuracy: 1e-15)
    }
    
    func test_Addition_DifferentDimension_ThrowsError() {
        let a = Vector(x: 1.0, y: 2.0)
        let b = Vector(x: 1.0, y: 2.0, z: 3.0)
        
        XCTAssertThrowsError(try a + b) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_Subtraction_ReturnsSubtraction() throws {
        let a = Vector(x: 5.0, y: 7.0)
        let b = Vector(x: 2.0, y: 3.0)
        let result = try a - b
        
        XCTAssertEqual(result.x, 3.0, accuracy: 1e-15)
        XCTAssertEqual(result.y, 4.0, accuracy: 1e-15)
    }
    
    func test_ScalarMultiplication_Left_ReturnsScaled() {
        let v = Vector(x: 2.0, y: 3.0)
        let result = 2.0 * v
        
        XCTAssertEqual(result.x, 4.0, accuracy: 1e-15)
        XCTAssertEqual(result.y, 6.0, accuracy: 1e-15)
    }
    
    func test_ScalarMultiplication_Right_ReturnsScaled() {
        let v = Vector(x: 2.0, y: 3.0)
        let result = v * 0.5
        
        XCTAssertEqual(result.x, 1.0, accuracy: 1e-15)
        XCTAssertEqual(result.y, 1.5, accuracy: 1e-15)
    }
    
    func test_ScalarDivision_ReturnsScaled() throws {
        let v = Vector(x: 4.0, y: 6.0)
        let result = try v / 2.0
        
        XCTAssertEqual(result.x, 2.0, accuracy: 1e-15)
        XCTAssertEqual(result.y, 3.0, accuracy: 1e-15)
    }
    
    func test_ScalarDivision_ByZero_ThrowsError() {
        let v = Vector(x: 1.0, y: 2.0)
        
        XCTAssertThrowsError(try v / 0.0) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_Negation_NegatesComponents() {
        let v = Vector(x: 1.0, y: -2.0)
        let result = -v
        
        XCTAssertEqual(result.x, -1.0, accuracy: 1e-15)
        XCTAssertEqual(result.y, 2.0, accuracy: 1e-15)
    }
    
    // MARK: - Vector Products
    
    func test_DotProduct_Perpendicular_ReturnsZero() throws {
        let a = Vector(x: 1.0, y: 0.0)
        let b = Vector(x: 0.0, y: 1.0)
        let result = try Vector.dot(a, b)
        
        XCTAssertEqual(result, 0.0, accuracy: 1e-15)
    }
    
    func test_DotProduct_Parallel_ReturnsMagnitudeProduct() throws {
        let a = Vector(x: 3.0, y: 0.0)
        let b = Vector(x: 4.0, y: 0.0)
        let result = try Vector.dot(a, b)
        
        XCTAssertEqual(result, 12.0, accuracy: 1e-15)
    }
    
    func test_DotProduct_General() throws {
        let a = Vector(x: 1.0, y: 2.0, z: 3.0)
        let b = Vector(x: 4.0, y: 5.0, z: 6.0)
        let result = try Vector.dot(a, b)
        
        // 1*4 + 2*5 + 3*6 = 4 + 10 + 18 = 32
        XCTAssertEqual(result, 32.0, accuracy: 1e-15)
    }
    
    func test_DotProduct_UnitVectors_ReturnsOne() throws {
        let a = Vector.unitX
        let result = try Vector.dot(a, a)
        
        XCTAssertEqual(result, 1.0, accuracy: 1e-15)
    }
    
    func test_DotProduct_DifferentDimensions_ThrowsError() {
        let a = Vector(x: 1.0, y: 2.0)
        let b = Vector(x: 1.0, y: 2.0, z: 3.0)
        
        XCTAssertThrowsError(try Vector.dot(a, b)) { error in
            guard case CalculatorError.dimensionMismatch = error else {
                XCTFail("Expected dimension mismatch error")
                return
            }
        }
    }
    
    func test_CrossProduct_ParallelVectors_ReturnsZero() throws {
        let a = Vector(x: 1.0, y: 0.0, z: 0.0)
        let b = Vector(x: 2.0, y: 0.0, z: 0.0)
        let result = try Vector.cross(a, b)
        
        XCTAssertTrue(result.isZero)
    }
    
    func test_CrossProduct_UnitVectors_ReturnsPerpendicularUnit() throws {
        let result = try Vector.cross(Vector.unitX, Vector.unitY)
        
        // i × j = k
        XCTAssertEqual(result.x, 0.0, accuracy: 1e-10)
        XCTAssertEqual(result.y, 0.0, accuracy: 1e-10)
        XCTAssertEqual(result.z, 1.0, accuracy: 1e-10)
    }
    
    func test_CrossProduct_General() throws {
        let a = Vector(x: 1.0, y: 2.0, z: 3.0)
        let b = Vector(x: 4.0, y: 5.0, z: 6.0)
        let result = try Vector.cross(a, b)
        
        // (2*6-3*5, 3*4-1*6, 1*5-2*4) = (-3, 6, -3)
        XCTAssertEqual(result.x, -3.0, accuracy: 1e-10)
        XCTAssertEqual(result.y, 6.0, accuracy: 1e-10)
        XCTAssertEqual(result.z, -3.0, accuracy: 1e-10)
    }
    
    func test_CrossProduct_2DVectors_ThrowsError() {
        let a = Vector(x: 1.0, y: 2.0)
        let b = Vector(x: 3.0, y: 4.0)
        
        XCTAssertThrowsError(try Vector.cross(a, b)) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_CrossProduct_Anticommutative() throws {
        let a = Vector(x: 1.0, y: 2.0, z: 3.0)
        let b = Vector(x: 4.0, y: 5.0, z: 6.0)
        let ab = try Vector.cross(a, b)
        let ba = try Vector.cross(b, a)
        
        // a × b = -(b × a)
        XCTAssertEqual(ab.x, -ba.x, accuracy: 1e-10)
        XCTAssertEqual(ab.y, -ba.y, accuracy: 1e-10)
        XCTAssertEqual(ab.z, -ba.z, accuracy: 1e-10)
    }
    
    // MARK: - Vector Functions
    
    func test_Normalized_ReturnsUnitVector() throws {
        let v = Vector(x: 3.0, y: 4.0)
        let n = try v.normalized()
        
        XCTAssertEqual(n.magnitude, 1.0, accuracy: 1e-10)
        XCTAssertEqual(n.x, 0.6, accuracy: 1e-10)
        XCTAssertEqual(n.y, 0.8, accuracy: 1e-10)
    }
    
    func test_Normalized_ZeroVector_ThrowsError() {
        XCTAssertThrowsError(try Vector.zero2D.normalized()) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_Angle_Perpendicular_Returns90Degrees() throws {
        let a = Vector(x: 1.0, y: 0.0)
        let b = Vector(x: 0.0, y: 1.0)
        let angle = try Vector.angle(a, b)
        
        XCTAssertEqual(angle, .pi / 2, accuracy: 1e-10)
    }
    
    func test_Angle_Parallel_ReturnsZero() throws {
        let a = Vector(x: 1.0, y: 0.0)
        let b = Vector(x: 2.0, y: 0.0)
        let angle = try Vector.angle(a, b)
        
        XCTAssertEqual(angle, 0.0, accuracy: 1e-10)
    }
    
    func test_Angle_Opposite_ReturnsPi() throws {
        let a = Vector(x: 1.0, y: 0.0)
        let b = Vector(x: -1.0, y: 0.0)
        let angle = try Vector.angle(a, b)
        
        XCTAssertEqual(angle, .pi, accuracy: 1e-10)
    }
    
    func test_Angle_WithAngleMode_ReturnsDegrees() throws {
        let a = Vector(x: 1.0, y: 0.0)
        let b = Vector(x: 0.0, y: 1.0)
        let angle = try Vector.angle(a, b, angleMode: .degrees)
        
        XCTAssertEqual(angle, 90.0, accuracy: 1e-10)
    }
    
    func test_Angle_ZeroVector_ThrowsError() {
        let a = Vector.zero2D
        let b = Vector(x: 1.0, y: 0.0)
        
        XCTAssertThrowsError(try Vector.angle(a, b)) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_Project_ReturnsCorrectProjection() throws {
        let a = Vector(x: 3.0, y: 4.0)
        let b = Vector(x: 1.0, y: 0.0)
        let proj = try a.project(onto: b)
        
        // Projection onto x-axis should be (3, 0)
        XCTAssertEqual(proj.x, 3.0, accuracy: 1e-10)
        XCTAssertEqual(proj.y, 0.0, accuracy: 1e-10)
    }
    
    func test_Project_OntoZeroVector_ThrowsError() {
        let a = Vector(x: 3.0, y: 4.0)
        
        XCTAssertThrowsError(try a.project(onto: Vector.zero2D)) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_Reject_ReturnsPerpendicularComponent() throws {
        let a = Vector(x: 3.0, y: 4.0)
        let b = Vector(x: 1.0, y: 0.0)
        let reject = try a.reject(from: b)
        
        // Component perpendicular to x-axis should be (0, 4)
        XCTAssertEqual(reject.x, 0.0, accuracy: 1e-10)
        XCTAssertEqual(reject.y, 4.0, accuracy: 1e-10)
    }
    
    func test_Distance_ReturnsCorrectDistance() throws {
        let a = Vector(x: 0.0, y: 0.0)
        let b = Vector(x: 3.0, y: 4.0)
        let dist = try Vector.distance(a, b)
        
        XCTAssertEqual(dist, 5.0, accuracy: 1e-10)
    }
    
    func test_To3D_Promotes2DVector() {
        let v = Vector(x: 1.0, y: 2.0)
        let v3d = v.to3D()
        
        XCTAssertTrue(v3d.is3D)
        XCTAssertEqual(v3d.x, 1.0, accuracy: 1e-15)
        XCTAssertEqual(v3d.y, 2.0, accuracy: 1e-15)
        XCTAssertEqual(v3d.z, 0.0, accuracy: 1e-15)
    }
    
    func test_To2D_Projects3DVector() {
        let v = Vector(x: 1.0, y: 2.0, z: 3.0)
        let v2d = v.to2D()
        
        XCTAssertTrue(v2d.is2D)
        XCTAssertEqual(v2d.x, 1.0, accuracy: 1e-15)
        XCTAssertEqual(v2d.y, 2.0, accuracy: 1e-15)
    }
    
    // MARK: - Comparison Tests
    
    func test_IsParallel_ParallelVectors_ReturnsTrue() throws {
        let a = Vector(x: 1.0, y: 2.0, z: 3.0)
        let b = Vector(x: 2.0, y: 4.0, z: 6.0)
        
        XCTAssertTrue(try a.isParallel(to: b))
    }
    
    func test_IsParallel_OppositeVectors_ReturnsTrue() throws {
        let a = Vector(x: 1.0, y: 2.0, z: 3.0)
        let b = Vector(x: -1.0, y: -2.0, z: -3.0)
        
        XCTAssertTrue(try a.isParallel(to: b))
    }
    
    func test_IsParallel_NonParallel_ReturnsFalse() throws {
        let a = Vector(x: 1.0, y: 0.0, z: 0.0)
        let b = Vector(x: 0.0, y: 1.0, z: 0.0)
        
        XCTAssertFalse(try a.isParallel(to: b))
    }
    
    func test_IsPerpendicular_PerpendicularVectors_ReturnsTrue() throws {
        let a = Vector(x: 1.0, y: 0.0)
        let b = Vector(x: 0.0, y: 1.0)
        
        XCTAssertTrue(try a.isPerpendicular(to: b))
    }
    
    func test_IsPerpendicular_NonPerpendicular_ReturnsFalse() throws {
        let a = Vector(x: 1.0, y: 1.0)
        let b = Vector(x: 1.0, y: 0.0)
        
        XCTAssertFalse(try a.isPerpendicular(to: b))
    }
    
    // MARK: - 2D Specific Tests
    
    func test_Perpendicular2D_Rotates90Degrees() throws {
        let v = Vector(x: 1.0, y: 0.0)
        let perp = try v.perpendicular2D()
        
        XCTAssertEqual(perp.x, 0.0, accuracy: 1e-10)
        XCTAssertEqual(perp.y, 1.0, accuracy: 1e-10)
    }
    
    func test_Angle2D_ReturnsCorrectAngle() throws {
        let v = Vector(x: 1.0, y: 1.0)
        let angle = try v.angle2D()
        
        XCTAssertEqual(angle, .pi / 4, accuracy: 1e-10)
    }
    
    func test_FromPolar_CreatesCorrectVector() {
        let v = Vector.fromPolar(magnitude: 5.0, angle: 0.927295218) // ~53.13 degrees
        
        XCTAssertEqual(v.x, 3.0, accuracy: 1e-5)
        XCTAssertEqual(v.y, 4.0, accuracy: 1e-5)
    }
    
    // MARK: - 3D Specific Tests
    
    func test_ToSpherical_ReturnsCorrectCoordinates() throws {
        let v = Vector(x: 0.0, y: 0.0, z: 1.0)
        let (r, theta, phi) = try v.toSpherical()
        
        XCTAssertEqual(r, 1.0, accuracy: 1e-10)
        XCTAssertEqual(phi, 0.0, accuracy: 1e-10)
    }
    
    func test_FromSpherical_CreatesCorrectVector() {
        let v = Vector.fromSpherical(r: 1.0, theta: 0.0, phi: .pi / 2)
        
        XCTAssertEqual(v.x, 1.0, accuracy: 1e-10)
        XCTAssertEqual(v.y, 0.0, accuracy: 1e-10)
        XCTAssertEqual(v.z, 0.0, accuracy: 1e-10)
    }
    
    func test_ToCylindrical_ReturnsCorrectCoordinates() throws {
        let v = Vector(x: 3.0, y: 4.0, z: 5.0)
        let (rho, phi, z) = try v.toCylindrical()
        
        XCTAssertEqual(rho, 5.0, accuracy: 1e-10)
        XCTAssertEqual(z, 5.0, accuracy: 1e-10)
    }
    
    // MARK: - Description Tests
    
    func test_Description_2D_FormatsCorrectly() {
        let v = Vector(x: 1.0, y: 2.0)
        let desc = v.description
        
        XCTAssertTrue(desc.hasPrefix("("))
        XCTAssertTrue(desc.hasSuffix(")"))
        XCTAssertTrue(desc.contains(","))
    }
    
    func test_Description_3D_FormatsCorrectly() {
        let v = Vector(x: 1.0, y: 2.0, z: 3.0)
        let desc = v.description
        
        XCTAssertTrue(desc.hasPrefix("("))
        XCTAssertTrue(desc.hasSuffix(")"))
    }
    
    // MARK: - Equatable Tests
    
    func test_Equatable_SameVectors_AreEqual() {
        let a = Vector(x: 1.0, y: 2.0, z: 3.0)
        let b = Vector(x: 1.0, y: 2.0, z: 3.0)
        
        XCTAssertEqual(a, b)
    }
    
    func test_Equatable_DifferentVectors_AreNotEqual() {
        let a = Vector(x: 1.0, y: 2.0)
        let b = Vector(x: 1.0, y: 3.0)
        
        XCTAssertNotEqual(a, b)
    }
    
    func test_Equatable_DifferentDimensions_AreNotEqual() {
        let a = Vector(x: 1.0, y: 2.0)
        let b = Vector(x: 1.0, y: 2.0, z: 0.0)
        
        XCTAssertNotEqual(a, b)
    }
    
    // MARK: - Triple Product Tests
    
    func test_ScalarTripleProduct_ReturnsVolume() throws {
        let a = Vector(x: 1.0, y: 0.0, z: 0.0)
        let b = Vector(x: 0.0, y: 1.0, z: 0.0)
        let c = Vector(x: 0.0, y: 0.0, z: 1.0)
        
        let volume = try Vector.scalarTripleProduct(a, b, c)
        XCTAssertEqual(volume, 1.0, accuracy: 1e-10)
    }
    
    // MARK: - Linear Interpolation Tests
    
    func test_Lerp_MidPoint_ReturnsAverage() throws {
        let a = Vector(x: 0.0, y: 0.0)
        let b = Vector(x: 10.0, y: 10.0)
        let mid = try Vector.lerp(from: a, to: b, t: 0.5)
        
        XCTAssertEqual(mid.x, 5.0, accuracy: 1e-10)
        XCTAssertEqual(mid.y, 5.0, accuracy: 1e-10)
    }
    
    func test_Lerp_t0_ReturnsFrom() throws {
        let a = Vector(x: 1.0, y: 2.0)
        let b = Vector(x: 10.0, y: 20.0)
        let result = try Vector.lerp(from: a, to: b, t: 0.0)
        
        XCTAssertEqual(result, a)
    }
    
    func test_Lerp_t1_ReturnsTo() throws {
        let a = Vector(x: 1.0, y: 2.0)
        let b = Vector(x: 10.0, y: 20.0)
        let result = try Vector.lerp(from: a, to: b, t: 1.0)
        
        XCTAssertEqual(result, b)
    }
}
