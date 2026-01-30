import Foundation

// MARK: - Vector

/// Represents a 2D or 3D vector
struct Vector: Equatable, Hashable {
    
    // MARK: - Properties
    
    /// Vector components
    let components: [Double]
    
    /// Number of dimensions (2 or 3)
    var dimension: Int { components.count }
    
    /// X component (first)
    var x: Double { components[0] }
    
    /// Y component (second)
    var y: Double { components.count > 1 ? components[1] : 0 }
    
    /// Z component (third, 3D only)
    var z: Double { components.count > 2 ? components[2] : 0 }
    
    // MARK: - Computed Properties
    
    /// Magnitude (length) of the vector: |v| = √(x² + y² + z²)
    var magnitude: Double {
        sqrt(components.reduce(0) { $0 + $1 * $1 })
    }
    
    /// Squared magnitude (avoids sqrt for comparisons)
    var magnitudeSquared: Double {
        components.reduce(0) { $0 + $1 * $1 }
    }
    
    /// Returns true if this is a zero vector
    var isZero: Bool {
        components.allSatisfy { abs($0) < 1e-15 }
    }
    
    /// Returns true if this is a 2D vector
    var is2D: Bool { dimension == 2 }
    
    /// Returns true if this is a 3D vector
    var is3D: Bool { dimension == 3 }
    
    /// Returns true if this is a unit vector (magnitude ≈ 1)
    var isUnit: Bool {
        abs(magnitude - 1.0) < 1e-10
    }
    
    // MARK: - Initialization
    
    /// Creates a 2D vector
    init(x: Double, y: Double) {
        self.components = [x, y]
    }
    
    /// Creates a 3D vector
    init(x: Double, y: Double, z: Double) {
        self.components = [x, y, z]
    }
    
    /// Creates a vector from an array of components
    /// - Throws: CalculatorError if not 2 or 3 components
    init(_ components: [Double]) throws {
        guard components.count == 2 || components.count == 3 else {
            throw CalculatorError.dimensionMismatch("Vector must have 2 or 3 components, got \(components.count)")
        }
        self.components = components
    }
    
    // MARK: - Common Vectors
    
    /// 2D zero vector
    static let zero2D = Vector(x: 0, y: 0)
    
    /// 3D zero vector
    static let zero3D = Vector(x: 0, y: 0, z: 0)
    
    /// 2D unit vector along x-axis
    static let unitX2D = Vector(x: 1, y: 0)
    
    /// 2D unit vector along y-axis
    static let unitY2D = Vector(x: 0, y: 1)
    
    /// 3D unit vector along x-axis
    static let unitX = Vector(x: 1, y: 0, z: 0)
    
    /// 3D unit vector along y-axis
    static let unitY = Vector(x: 0, y: 1, z: 0)
    
    /// 3D unit vector along z-axis
    static let unitZ = Vector(x: 0, y: 0, z: 1)
}

// MARK: - Arithmetic Operations

extension Vector {
    
    /// Vector addition (component-wise)
    static func + (lhs: Vector, rhs: Vector) throws -> Vector {
        guard lhs.dimension == rhs.dimension else {
            throw CalculatorError.dimensionMismatch(
                "Cannot add vectors of dimension \(lhs.dimension) and \(rhs.dimension)"
            )
        }
        
        let resultComponents = zip(lhs.components, rhs.components).map { $0 + $1 }
        return try Vector(resultComponents)
    }
    
    /// Vector subtraction (component-wise)
    static func - (lhs: Vector, rhs: Vector) throws -> Vector {
        guard lhs.dimension == rhs.dimension else {
            throw CalculatorError.dimensionMismatch(
                "Cannot subtract vectors of dimension \(lhs.dimension) and \(rhs.dimension)"
            )
        }
        
        let resultComponents = zip(lhs.components, rhs.components).map { $0 - $1 }
        return try Vector(resultComponents)
    }
    
    /// Scalar multiplication (scalar on left)
    static func * (scalar: Double, vector: Vector) -> Vector {
        let resultComponents = vector.components.map { $0 * scalar }
        return try! Vector(resultComponents)
    }
    
    /// Scalar multiplication (scalar on right)
    static func * (vector: Vector, scalar: Double) -> Vector {
        return scalar * vector
    }
    
    /// Scalar division
    /// - Throws: CalculatorError.divisionByZero if scalar is zero
    static func / (vector: Vector, scalar: Double) throws -> Vector {
        guard abs(scalar) >= 1e-15 else {
            throw CalculatorError.divisionByZero
        }
        
        let resultComponents = vector.components.map { $0 / scalar }
        return try Vector(resultComponents)
    }
    
    /// Negation
    static prefix func - (vector: Vector) -> Vector {
        return -1.0 * vector
    }
}

// MARK: - Vector Products

extension Vector {
    
    /// Dot product: A · B = Σ(aᵢ × bᵢ)
    /// - Throws: CalculatorError if dimensions don't match
    static func dot(_ a: Vector, _ b: Vector) throws -> Double {
        guard a.dimension == b.dimension else {
            throw CalculatorError.dimensionMismatch(
                "Cannot compute dot product of vectors with dimension \(a.dimension) and \(b.dimension)"
            )
        }
        
        return zip(a.components, b.components).reduce(0) { $0 + $1.0 * $1.1 }
    }
    
    /// Cross product (3D only): A × B = (a₂b₃−a₃b₂, a₃b₁−a₁b₃, a₁b₂−a₂b₁)
    /// - Throws: CalculatorError if either vector is not 3D
    static func cross(_ a: Vector, _ b: Vector) throws -> Vector {
        guard a.is3D && b.is3D else {
            throw CalculatorError.domainError(
                "Cross product requires 3D vectors, got \(a.dimension)D and \(b.dimension)D"
            )
        }
        
        let x = a.y * b.z - a.z * b.y
        let y = a.z * b.x - a.x * b.z
        let z = a.x * b.y - a.y * b.x
        
        return Vector(x: x, y: y, z: z)
    }
}

// MARK: - Vector Functions

extension Vector {
    
    /// Returns the unit vector (normalized)
    /// - Throws: CalculatorError.divisionByZero if zero vector
    func normalized() throws -> Vector {
        let mag = magnitude
        guard mag >= 1e-15 else {
            throw CalculatorError.divisionByZero
        }
        
        return try self / mag
    }
    
    /// Angle between two vectors in radians
    /// angle = acos((A·B)/(|A||B|))
    /// - Throws: CalculatorError if dimensions don't match or either is zero vector
    static func angle(_ a: Vector, _ b: Vector) throws -> Double {
        guard a.dimension == b.dimension else {
            throw CalculatorError.dimensionMismatch(
                "Cannot compute angle between vectors of dimension \(a.dimension) and \(b.dimension)"
            )
        }
        
        let magA = a.magnitude
        let magB = b.magnitude
        
        guard magA >= 1e-15 && magB >= 1e-15 else {
            throw CalculatorError.divisionByZero
        }
        
        let dotProduct = try dot(a, b)
        var cosAngle = dotProduct / (magA * magB)
        
        // Clamp to [-1, 1] to handle floating-point errors
        cosAngle = max(-1.0, min(1.0, cosAngle))
        
        return acos(cosAngle)
    }
    
    /// Angle between two vectors in specified angle mode
    /// - Parameters:
    ///   - a: First vector
    ///   - b: Second vector
    ///   - angleMode: The angle mode for the result
    /// - Returns: Angle in the specified mode
    static func angle(_ a: Vector, _ b: Vector, angleMode: AngleMode) throws -> Double {
        let radians = try angle(a, b)
        return angleMode.fromRadians(radians)
    }
    
    /// Projects this vector onto another vector
    /// proj_b(a) = (a·b / |b|²) × b
    /// - Throws: CalculatorError if dimensions don't match or other is zero vector
    func project(onto other: Vector) throws -> Vector {
        guard dimension == other.dimension else {
            throw CalculatorError.dimensionMismatch(
                "Cannot project vector of dimension \(dimension) onto vector of dimension \(other.dimension)"
            )
        }
        
        let otherMagSquared = other.magnitudeSquared
        guard otherMagSquared >= 1e-15 else {
            throw CalculatorError.divisionByZero
        }
        
        let dotProduct = try Vector.dot(self, other)
        let scalar = dotProduct / otherMagSquared
        
        return scalar * other
    }
    
    /// Returns the component of this vector perpendicular to another
    /// reject_b(a) = a - proj_b(a)
    /// - Throws: CalculatorError if dimensions don't match or other is zero vector
    func reject(from other: Vector) throws -> Vector {
        let projection = try project(onto: other)
        return try self - projection
    }
    
    /// Distance between two points (vectors from origin)
    /// distance = |a - b|
    /// - Throws: CalculatorError if dimensions don't match
    static func distance(_ a: Vector, _ b: Vector) throws -> Double {
        let difference = try a - b
        return difference.magnitude
    }
    
    /// Returns a 3D vector by promoting a 2D vector (z = 0)
    func to3D() -> Vector {
        if is3D {
            return self
        }
        return Vector(x: x, y: y, z: 0)
    }
    
    /// Returns the 2D projection (drops z component)
    func to2D() -> Vector {
        return Vector(x: x, y: y)
    }
    
    /// Scalar triple product: a · (b × c)
    /// Returns the signed volume of the parallelepiped
    /// - Throws: CalculatorError if vectors are not all 3D
    static func scalarTripleProduct(_ a: Vector, _ b: Vector, _ c: Vector) throws -> Double {
        let crossBC = try cross(b, c)
        return try dot(a, crossBC)
    }
    
    /// Vector triple product: a × (b × c)
    /// - Throws: CalculatorError if vectors are not all 3D
    static func vectorTripleProduct(_ a: Vector, _ b: Vector, _ c: Vector) throws -> Vector {
        let crossBC = try cross(b, c)
        return try cross(a, crossBC)
    }
    
    /// Returns the component of this vector in the direction of a unit vector
    /// - Parameter direction: A unit vector (will be normalized if not)
    func component(along direction: Vector) throws -> Double {
        let unitDirection = try direction.normalized()
        return try Vector.dot(self, unitDirection)
    }
    
    /// Linearly interpolates between two vectors
    /// - Parameters:
    ///   - from: Start vector
    ///   - to: End vector
    ///   - t: Interpolation factor (0 = from, 1 = to)
    /// - Returns: Interpolated vector
    static func lerp(from: Vector, to: Vector, t: Double) throws -> Vector {
        guard from.dimension == to.dimension else {
            throw CalculatorError.dimensionMismatch(
                "Cannot interpolate between vectors of dimension \(from.dimension) and \(to.dimension)"
            )
        }
        
        let oneMinusT = 1.0 - t
        return try (oneMinusT * from) + (t * to)
    }
    
    /// Reflects this vector about a normal
    /// reflect = v - 2(v·n)n
    /// - Parameter normal: The normal vector (should be unit length)
    func reflect(about normal: Vector) throws -> Vector {
        guard dimension == normal.dimension else {
            throw CalculatorError.dimensionMismatch(
                "Cannot reflect vector of dimension \(dimension) about normal of dimension \(normal.dimension)"
            )
        }
        
        let unitNormal = try normal.normalized()
        let dotProduct = try Vector.dot(self, unitNormal)
        return try self - (2.0 * dotProduct * unitNormal)
    }
}

// MARK: - Comparison

extension Vector {
    
    /// Checks if two vectors are approximately equal within a tolerance
    func isApproximatelyEqual(to other: Vector, tolerance: Double = 1e-10) -> Bool {
        guard dimension == other.dimension else {
            return false
        }
        
        for (a, b) in zip(components, other.components) {
            if abs(a - b) > tolerance {
                return false
            }
        }
        return true
    }
    
    /// Checks if two vectors are parallel (same or opposite direction)
    func isParallel(to other: Vector) throws -> Bool {
        guard dimension == other.dimension else {
            return false
        }
        
        if isZero || other.isZero {
            return true
        }
        
        if is3D && other.is3D {
            let crossProduct = try Vector.cross(self, other)
            return crossProduct.isZero
        }
        
        // For 2D: a×b = a₁b₂ - a₂b₁ (z-component of 3D cross product)
        let crossZ = x * other.y - y * other.x
        return abs(crossZ) < 1e-10
    }
    
    /// Checks if two vectors are perpendicular
    func isPerpendicular(to other: Vector) throws -> Bool {
        if isZero || other.isZero {
            return true
        }
        
        let dotProduct = try Vector.dot(self, other)
        return abs(dotProduct) < 1e-10
    }
}

// MARK: - CustomStringConvertible

extension Vector: CustomStringConvertible {
    
    /// Returns a formatted string: "(x, y)" or "(x, y, z)"
    var description: String {
        let formatted = components.map { formatComponent($0) }
        return "(" + formatted.joined(separator: ", ") + ")"
    }
    
    /// Returns a formatted string with specified decimal places
    func description(decimalPlaces: Int) -> String {
        let formatted = components.map { component in
            if abs(component - round(component)) < 1e-10 {
                return String(format: "%.0f", component)
            }
            return String(format: "%.\(decimalPlaces)f", component)
        }
        return "(" + formatted.joined(separator: ", ") + ")"
    }
    
    /// Formats a single component for display
    private func formatComponent(_ value: Double) -> String {
        if abs(value) < 1e-15 {
            return "0"
        }
        if abs(value - round(value)) < 1e-10 {
            return String(format: "%.0f", value)
        }
        if abs(value) >= 1e7 || (abs(value) < 1e-4 && abs(value) > 0) {
            return String(format: "%.6e", value)
        }
        
        let formatted = String(format: "%.10f", value)
        return trimTrailingZeros(formatted)
    }
    
    /// Removes trailing zeros from a decimal string
    private func trimTrailingZeros(_ string: String) -> String {
        guard string.contains(".") else { return string }
        
        var result = string
        while result.hasSuffix("0") {
            result.removeLast()
        }
        if result.hasSuffix(".") {
            result.removeLast()
        }
        return result
    }
}

// MARK: - 2D Specific Operations

extension Vector {
    
    /// Returns the perpendicular 2D vector (rotated 90° counterclockwise)
    /// Only valid for 2D vectors
    func perpendicular2D() throws -> Vector {
        guard is2D else {
            throw CalculatorError.dimensionMismatch("perpendicular2D requires a 2D vector")
        }
        return Vector(x: -y, y: x)
    }
    
    /// Returns the angle of a 2D vector from the positive x-axis in radians
    /// Range: (-π, π]
    func angle2D() throws -> Double {
        guard is2D else {
            throw CalculatorError.dimensionMismatch("angle2D requires a 2D vector")
        }
        return atan2(y, x)
    }
    
    /// Returns the angle of a 2D vector in the specified angle mode
    func angle2D(angleMode: AngleMode) throws -> Double {
        let radians = try angle2D()
        return angleMode.fromRadians(radians)
    }
    
    /// Creates a 2D vector from polar coordinates
    /// - Parameters:
    ///   - magnitude: The length of the vector
    ///   - angle: The angle from positive x-axis in radians
    static func fromPolar(magnitude: Double, angle: Double) -> Vector {
        let x = magnitude * cos(angle)
        let y = magnitude * sin(angle)
        return Vector(x: x, y: y)
    }
    
    /// Creates a 2D vector from polar coordinates with specified angle mode
    static func fromPolar(magnitude: Double, angle: Double, angleMode: AngleMode) -> Vector {
        let radians = angleMode.toRadians(angle)
        return fromPolar(magnitude: magnitude, angle: radians)
    }
}

// MARK: - 3D Specific Operations

extension Vector {
    
    /// Returns spherical coordinates (r, θ, φ) for a 3D vector
    /// - r: radial distance
    /// - θ (theta): azimuthal angle in xy-plane from x-axis (radians)
    /// - φ (phi): polar angle from z-axis (radians)
    func toSpherical() throws -> (r: Double, theta: Double, phi: Double) {
        guard is3D else {
            throw CalculatorError.dimensionMismatch("toSpherical requires a 3D vector")
        }
        
        let r = magnitude
        if r < 1e-15 {
            return (r: 0, theta: 0, phi: 0)
        }
        
        let theta = atan2(y, x)
        let phi = acos(z / r)
        
        return (r: r, theta: theta, phi: phi)
    }
    
    /// Creates a 3D vector from spherical coordinates
    /// - Parameters:
    ///   - r: radial distance
    ///   - theta: azimuthal angle in xy-plane from x-axis (radians)
    ///   - phi: polar angle from z-axis (radians)
    static func fromSpherical(r: Double, theta: Double, phi: Double) -> Vector {
        let x = r * sin(phi) * cos(theta)
        let y = r * sin(phi) * sin(theta)
        let z = r * cos(phi)
        return Vector(x: x, y: y, z: z)
    }
    
    /// Returns cylindrical coordinates (ρ, φ, z) for a 3D vector
    /// - ρ (rho): radial distance in xy-plane
    /// - φ (phi): azimuthal angle from x-axis (radians)
    /// - z: height
    func toCylindrical() throws -> (rho: Double, phi: Double, z: Double) {
        guard is3D else {
            throw CalculatorError.dimensionMismatch("toCylindrical requires a 3D vector")
        }
        
        let rho = sqrt(x * x + y * y)
        let phi = atan2(y, x)
        
        return (rho: rho, phi: phi, z: z)
    }
    
    /// Creates a 3D vector from cylindrical coordinates
    /// - Parameters:
    ///   - rho: radial distance in xy-plane
    ///   - phi: azimuthal angle from x-axis (radians)
    ///   - z: height
    static func fromCylindrical(rho: Double, phi: Double, z: Double) -> Vector {
        let x = rho * cos(phi)
        let y = rho * sin(phi)
        return Vector(x: x, y: y, z: z)
    }
}
