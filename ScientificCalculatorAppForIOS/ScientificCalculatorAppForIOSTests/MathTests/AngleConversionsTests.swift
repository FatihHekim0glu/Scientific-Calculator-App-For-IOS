import XCTest
@testable import ScientificCalculatorAppForIOS

final class AngleConversionsTests: XCTestCase {
    
    // MARK: - Degrees to Radians Tests
    
    func test_DegreesToRadians_0_Returns0() {
        let result = AngleConversions.degreesToRadians(0)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    func test_DegreesToRadians_90_ReturnsPiOver2() {
        let result = AngleConversions.degreesToRadians(90)
        XCTAssertEqual(result, .pi / 2, accuracy: 1e-15)
    }
    
    func test_DegreesToRadians_180_ReturnsPi() {
        let result = AngleConversions.degreesToRadians(180)
        XCTAssertEqual(result, .pi, accuracy: 1e-15)
    }
    
    func test_DegreesToRadians_360_Returns2Pi() {
        let result = AngleConversions.degreesToRadians(360)
        XCTAssertEqual(result, 2 * .pi, accuracy: 1e-15)
    }
    
    func test_DegreesToRadians_Negative90_ReturnsNegativePiOver2() {
        let result = AngleConversions.degreesToRadians(-90)
        XCTAssertEqual(result, -.pi / 2, accuracy: 1e-15)
    }
    
    func test_DegreesToRadians_45_ReturnsPiOver4() {
        let result = AngleConversions.degreesToRadians(45)
        XCTAssertEqual(result, .pi / 4, accuracy: 1e-15)
    }
    
    // MARK: - Radians to Degrees Tests
    
    func test_RadiansToDegrees_0_Returns0() {
        let result = AngleConversions.radiansToDegrees(0)
        XCTAssertEqual(result, 0, accuracy: 1e-15)
    }
    
    func test_RadiansToDegrees_Pi_Returns180() {
        let result = AngleConversions.radiansToDegrees(.pi)
        XCTAssertEqual(result, 180, accuracy: 1e-10)
    }
    
    func test_RadiansToDegrees_PiOver2_Returns90() {
        let result = AngleConversions.radiansToDegrees(.pi / 2)
        XCTAssertEqual(result, 90, accuracy: 1e-10)
    }
    
    func test_RadiansToDegrees_2Pi_Returns360() {
        let result = AngleConversions.radiansToDegrees(2 * .pi)
        XCTAssertEqual(result, 360, accuracy: 1e-10)
    }
    
    func test_RadiansToDegrees_NegativePi_ReturnsNegative180() {
        let result = AngleConversions.radiansToDegrees(-.pi)
        XCTAssertEqual(result, -180, accuracy: 1e-10)
    }
    
    // MARK: - Degrees to Gradians Tests
    
    func test_DegreesToGradians_90_Returns100() {
        let result = AngleConversions.degreesToGradians(90)
        XCTAssertEqual(result, 100, accuracy: 1e-10)
    }
    
    func test_DegreesToGradians_180_Returns200() {
        let result = AngleConversions.degreesToGradians(180)
        XCTAssertEqual(result, 200, accuracy: 1e-10)
    }
    
    func test_DegreesToGradians_360_Returns400() {
        let result = AngleConversions.degreesToGradians(360)
        XCTAssertEqual(result, 400, accuracy: 1e-10)
    }
    
    func test_DegreesToGradians_45_Returns50() {
        let result = AngleConversions.degreesToGradians(45)
        XCTAssertEqual(result, 50, accuracy: 1e-10)
    }
    
    // MARK: - Gradians to Degrees Tests
    
    func test_GradiansToDegrees_100_Returns90() {
        let result = AngleConversions.gradiansToDegrees(100)
        XCTAssertEqual(result, 90, accuracy: 1e-10)
    }
    
    func test_GradiansToDegrees_200_Returns180() {
        let result = AngleConversions.gradiansToDegrees(200)
        XCTAssertEqual(result, 180, accuracy: 1e-10)
    }
    
    func test_GradiansToDegrees_400_Returns360() {
        let result = AngleConversions.gradiansToDegrees(400)
        XCTAssertEqual(result, 360, accuracy: 1e-10)
    }
    
    func test_GradiansToDegrees_50_Returns45() {
        let result = AngleConversions.gradiansToDegrees(50)
        XCTAssertEqual(result, 45, accuracy: 1e-10)
    }
    
    // MARK: - Radians to Gradians Tests
    
    func test_RadiansToGradians_Pi_Returns200() {
        let result = AngleConversions.radiansToGradians(.pi)
        XCTAssertEqual(result, 200, accuracy: 1e-10)
    }
    
    func test_RadiansToGradians_PiOver2_Returns100() {
        let result = AngleConversions.radiansToGradians(.pi / 2)
        XCTAssertEqual(result, 100, accuracy: 1e-10)
    }
    
    func test_RadiansToGradians_2Pi_Returns400() {
        let result = AngleConversions.radiansToGradians(2 * .pi)
        XCTAssertEqual(result, 400, accuracy: 1e-10)
    }
    
    // MARK: - Gradians to Radians Tests
    
    func test_GradiansToRadians_200_ReturnsPi() {
        let result = AngleConversions.gradiansToRadians(200)
        XCTAssertEqual(result, .pi, accuracy: 1e-10)
    }
    
    func test_GradiansToRadians_100_ReturnsPiOver2() {
        let result = AngleConversions.gradiansToRadians(100)
        XCTAssertEqual(result, .pi / 2, accuracy: 1e-10)
    }
    
    func test_GradiansToRadians_400_Returns2Pi() {
        let result = AngleConversions.gradiansToRadians(400)
        XCTAssertEqual(result, 2 * .pi, accuracy: 1e-10)
    }
    
    // MARK: - Roundtrip Conversion Tests
    
    func test_DegreesRoundtrip_RadiansAndBack() {
        let original = 45.0
        let radians = AngleConversions.degreesToRadians(original)
        let result = AngleConversions.radiansToDegrees(radians)
        XCTAssertEqual(result, original, accuracy: 1e-10)
    }
    
    func test_DegreesRoundtrip_GradiansAndBack() {
        let original = 45.0
        let gradians = AngleConversions.degreesToGradians(original)
        let result = AngleConversions.gradiansToDegrees(gradians)
        XCTAssertEqual(result, original, accuracy: 1e-10)
    }
    
    func test_RadiansRoundtrip_GradiansAndBack() {
        let original = Double.pi / 3
        let gradians = AngleConversions.radiansToGradians(original)
        let result = AngleConversions.gradiansToRadians(gradians)
        XCTAssertEqual(result, original, accuracy: 1e-10)
    }
    
    // MARK: - DMS Tests
    
    func test_DMS_Init_FromComponents() {
        let dms = DMS(degrees: 45, minutes: 30, seconds: 15)
        
        XCTAssertEqual(dms.degrees, 45)
        XCTAssertEqual(dms.minutes, 30)
        XCTAssertEqual(dms.seconds, 15, accuracy: 1e-10)
        XCTAssertFalse(dms.isNegative)
    }
    
    func test_DMS_Init_NegativeFlag() {
        let dms = DMS(degrees: 45, minutes: 30, seconds: 15, isNegative: true)
        
        XCTAssertEqual(dms.degrees, 45)
        XCTAssertTrue(dms.isNegative)
    }
    
    func test_DMS_Init_FromDecimalDegrees_Positive() {
        let dms = DMS(decimalDegrees: 45.5083333)
        
        XCTAssertEqual(dms.degrees, 45)
        XCTAssertEqual(dms.minutes, 30)
        XCTAssertEqual(dms.seconds, 30, accuracy: 0.1)
        XCTAssertFalse(dms.isNegative)
    }
    
    func test_DMS_Init_FromDecimalDegrees_Negative() {
        let dms = DMS(decimalDegrees: -45.5)
        
        XCTAssertEqual(dms.degrees, 45)
        XCTAssertEqual(dms.minutes, 30)
        XCTAssertTrue(dms.isNegative)
    }
    
    func test_DMS_DecimalDegrees_Positive() {
        let dms = DMS(degrees: 45, minutes: 30, seconds: 0)
        let decimal = dms.decimalDegrees
        
        XCTAssertEqual(decimal, 45.5, accuracy: 1e-10)
    }
    
    func test_DMS_DecimalDegrees_WithSeconds() {
        let dms = DMS(degrees: 45, minutes: 30, seconds: 30)
        let decimal = dms.decimalDegrees
        
        XCTAssertEqual(decimal, 45.5083333, accuracy: 1e-6)
    }
    
    func test_DMS_DecimalDegrees_Negative() {
        let dms = DMS(degrees: 45, minutes: 30, seconds: 0, isNegative: true)
        let decimal = dms.decimalDegrees
        
        XCTAssertEqual(decimal, -45.5, accuracy: 1e-10)
    }
    
    func test_DMS_Formatted_Positive() {
        let dms = DMS(degrees: 45, minutes: 30, seconds: 15)
        let formatted = dms.formatted
        
        XCTAssertEqual(formatted, "45°30'15\"")
    }
    
    func test_DMS_Formatted_Negative() {
        let dms = DMS(degrees: 45, minutes: 30, seconds: 15, isNegative: true)
        let formatted = dms.formatted
        
        XCTAssertEqual(formatted, "-45°30'15\"")
    }
    
    func test_DMS_Roundtrip() {
        let original = 123.456
        let dms = DMS(decimalDegrees: original)
        let result = dms.decimalDegrees
        
        XCTAssertEqual(result, original, accuracy: 1e-10)
    }
    
    // MARK: - AngleConversions DMS Tests
    
    func test_DecimalToDMS_Works() {
        let dms = AngleConversions.decimalToDMS(45.5)
        
        XCTAssertEqual(dms.degrees, 45)
        XCTAssertEqual(dms.minutes, 30)
        XCTAssertEqual(dms.seconds, 0, accuracy: 0.1)
    }
    
    func test_DMSToDecimal_Works() {
        let result = AngleConversions.dmsToDecimal(degrees: 45, minutes: 30, seconds: 0)
        XCTAssertEqual(result, 45.5, accuracy: 1e-10)
    }
    
    func test_DMSToDecimal_NegativeDegrees() {
        let result = AngleConversions.dmsToDecimal(degrees: -45, minutes: 30, seconds: 0)
        XCTAssertEqual(result, -45.5, accuracy: 1e-10)
    }
    
    func test_ParseDMSEncoded_45_3015() {
        // 45.3015 represents 45°30'15"
        let dms = AngleConversions.parseDMSEncoded(45.3015)
        
        XCTAssertEqual(dms.degrees, 45)
        XCTAssertEqual(dms.minutes, 30)
        XCTAssertEqual(dms.seconds, 15, accuracy: 0.1)
    }
    
    func test_ParseDMSEncoded_Negative() {
        let dms = AngleConversions.parseDMSEncoded(-45.3015)
        
        XCTAssertEqual(dms.degrees, 45)
        XCTAssertEqual(dms.minutes, 30)
        XCTAssertTrue(dms.isNegative)
    }
    
    func test_EncodeDMS_Works() {
        let dms = DMS(degrees: 45, minutes: 30, seconds: 15)
        let encoded = AngleConversions.encodeDMS(dms)
        
        XCTAssertEqual(encoded, 45.3015, accuracy: 1e-4)
    }
    
    func test_EncodeDMS_Negative() {
        let dms = DMS(degrees: 45, minutes: 30, seconds: 15, isNegative: true)
        let encoded = AngleConversions.encodeDMS(dms)
        
        XCTAssertEqual(encoded, -45.3015, accuracy: 1e-4)
    }
    
    func test_DMSEncoding_Roundtrip() {
        let original = 123.4530
        let dms = AngleConversions.parseDMSEncoded(original)
        let encoded = AngleConversions.encodeDMS(dms)
        
        XCTAssertEqual(encoded, original, accuracy: 1e-4)
    }
    
    // MARK: - Angle Normalization Tests
    
    func test_NormalizeDegrees_Positive() {
        let result = AngleConversions.normalizeDegrees(450)
        XCTAssertEqual(result, 90, accuracy: 1e-10)
    }
    
    func test_NormalizeDegrees_Negative() {
        let result = AngleConversions.normalizeDegrees(-90)
        XCTAssertEqual(result, 270, accuracy: 1e-10)
    }
    
    func test_NormalizeDegrees_360_Returns0() {
        let result = AngleConversions.normalizeDegrees(360)
        XCTAssertEqual(result, 0, accuracy: 1e-10)
    }
    
    func test_NormalizeDegrees_720_Returns0() {
        let result = AngleConversions.normalizeDegrees(720)
        XCTAssertEqual(result, 0, accuracy: 1e-10)
    }
    
    func test_NormalizeRadians_Positive() {
        let result = AngleConversions.normalizeRadians(3 * .pi)
        XCTAssertEqual(result, .pi, accuracy: 1e-10)
    }
    
    func test_NormalizeRadians_Negative() {
        let result = AngleConversions.normalizeRadians(-.pi / 2)
        XCTAssertEqual(result, 3 * .pi / 2, accuracy: 1e-10)
    }
    
    func test_NormalizeGradians_Positive() {
        let result = AngleConversions.normalizeGradians(500)
        XCTAssertEqual(result, 100, accuracy: 1e-10)
    }
    
    func test_NormalizeGradians_Negative() {
        let result = AngleConversions.normalizeGradians(-100)
        XCTAssertEqual(result, 300, accuracy: 1e-10)
    }
}

// MARK: - Coordinate Conversion Tests

final class CoordinateConversionsTests: XCTestCase {
    
    // MARK: - Rectangular to Polar Tests
    
    func test_RectToPolar_3And4_Returns5AndAngle() {
        let result = CoordinateConversions.rectangularToPolar(x: 3, y: 4, angleMode: .degrees)
        
        XCTAssertEqual(result.r, 5, accuracy: 1e-10)
        XCTAssertEqual(result.theta, 53.13010235, accuracy: 1e-5)
    }
    
    func test_RectToPolar_Origin_ReturnsZero() {
        let result = CoordinateConversions.rectangularToPolar(x: 0, y: 0, angleMode: .degrees)
        
        XCTAssertEqual(result.r, 0, accuracy: 1e-15)
        XCTAssertEqual(result.theta, 0, accuracy: 1e-15)
    }
    
    func test_RectToPolar_PositiveX_Returns0Degrees() {
        let result = CoordinateConversions.rectangularToPolar(x: 5, y: 0, angleMode: .degrees)
        
        XCTAssertEqual(result.r, 5, accuracy: 1e-10)
        XCTAssertEqual(result.theta, 0, accuracy: 1e-10)
    }
    
    func test_RectToPolar_PositiveY_Returns90Degrees() {
        let result = CoordinateConversions.rectangularToPolar(x: 0, y: 5, angleMode: .degrees)
        
        XCTAssertEqual(result.r, 5, accuracy: 1e-10)
        XCTAssertEqual(result.theta, 90, accuracy: 1e-10)
    }
    
    func test_RectToPolar_NegativeX_Returns180Degrees() {
        let result = CoordinateConversions.rectangularToPolar(x: -5, y: 0, angleMode: .degrees)
        
        XCTAssertEqual(result.r, 5, accuracy: 1e-10)
        XCTAssertEqual(result.theta, 180, accuracy: 1e-10)
    }
    
    func test_RectToPolar_NegativeY_ReturnsMinus90Degrees() {
        let result = CoordinateConversions.rectangularToPolar(x: 0, y: -5, angleMode: .degrees)
        
        XCTAssertEqual(result.r, 5, accuracy: 1e-10)
        XCTAssertEqual(result.theta, -90, accuracy: 1e-10)
    }
    
    func test_RectToPolar_InRadians() {
        let result = CoordinateConversions.rectangularToPolar(x: 1, y: 1, angleMode: .radians)
        
        XCTAssertEqual(result.r, sqrt(2), accuracy: 1e-10)
        XCTAssertEqual(result.theta, .pi / 4, accuracy: 1e-10)
    }
    
    func test_RectToPolar_InGradians() {
        let result = CoordinateConversions.rectangularToPolar(x: 1, y: 1, angleMode: .gradians)
        
        XCTAssertEqual(result.r, sqrt(2), accuracy: 1e-10)
        XCTAssertEqual(result.theta, 50, accuracy: 1e-10)
    }
    
    // MARK: - Polar to Rectangular Tests
    
    func test_PolarToRect_5And53deg_Returns3And4() {
        let result = CoordinateConversions.polarToRectangular(r: 5, theta: 53.13010235, angleMode: .degrees)
        
        XCTAssertEqual(result.x, 3, accuracy: 1e-5)
        XCTAssertEqual(result.y, 4, accuracy: 1e-5)
    }
    
    func test_PolarToRect_0Magnitude_ReturnsOrigin() {
        let result = CoordinateConversions.polarToRectangular(r: 0, theta: 45, angleMode: .degrees)
        
        XCTAssertEqual(result.x, 0, accuracy: 1e-15)
        XCTAssertEqual(result.y, 0, accuracy: 1e-15)
    }
    
    func test_PolarToRect_0Degrees_ReturnsPositiveX() {
        let result = CoordinateConversions.polarToRectangular(r: 5, theta: 0, angleMode: .degrees)
        
        XCTAssertEqual(result.x, 5, accuracy: 1e-10)
        XCTAssertEqual(result.y, 0, accuracy: 1e-10)
    }
    
    func test_PolarToRect_90Degrees_ReturnsPositiveY() {
        let result = CoordinateConversions.polarToRectangular(r: 5, theta: 90, angleMode: .degrees)
        
        XCTAssertEqual(result.x, 0, accuracy: 1e-10)
        XCTAssertEqual(result.y, 5, accuracy: 1e-10)
    }
    
    func test_PolarToRect_180Degrees_ReturnsNegativeX() {
        let result = CoordinateConversions.polarToRectangular(r: 5, theta: 180, angleMode: .degrees)
        
        XCTAssertEqual(result.x, -5, accuracy: 1e-10)
        XCTAssertEqual(result.y, 0, accuracy: 1e-10)
    }
    
    func test_PolarToRect_InRadians() {
        let result = CoordinateConversions.polarToRectangular(r: sqrt(2), theta: .pi / 4, angleMode: .radians)
        
        XCTAssertEqual(result.x, 1, accuracy: 1e-10)
        XCTAssertEqual(result.y, 1, accuracy: 1e-10)
    }
    
    func test_PolarToRect_InGradians() {
        let result = CoordinateConversions.polarToRectangular(r: sqrt(2), theta: 50, angleMode: .gradians)
        
        XCTAssertEqual(result.x, 1, accuracy: 1e-10)
        XCTAssertEqual(result.y, 1, accuracy: 1e-10)
    }
    
    // MARK: - Coordinate Conversion Roundtrip Tests
    
    func test_CoordinateConversion_Roundtrip_Degrees() {
        let originalX = 3.0
        let originalY = 4.0
        
        let polar = CoordinateConversions.rectangularToPolar(x: originalX, y: originalY, angleMode: .degrees)
        let rect = CoordinateConversions.polarToRectangular(r: polar.r, theta: polar.theta, angleMode: .degrees)
        
        XCTAssertEqual(rect.x, originalX, accuracy: 1e-10)
        XCTAssertEqual(rect.y, originalY, accuracy: 1e-10)
    }
    
    func test_CoordinateConversion_Roundtrip_Radians() {
        let originalX = -2.5
        let originalY = 1.5
        
        let polar = CoordinateConversions.rectangularToPolar(x: originalX, y: originalY, angleMode: .radians)
        let rect = CoordinateConversions.polarToRectangular(r: polar.r, theta: polar.theta, angleMode: .radians)
        
        XCTAssertEqual(rect.x, originalX, accuracy: 1e-10)
        XCTAssertEqual(rect.y, originalY, accuracy: 1e-10)
    }
    
    func test_CoordinateConversion_Roundtrip_Gradians() {
        let originalX = 1.0
        let originalY = -3.0
        
        let polar = CoordinateConversions.rectangularToPolar(x: originalX, y: originalY, angleMode: .gradians)
        let rect = CoordinateConversions.polarToRectangular(r: polar.r, theta: polar.theta, angleMode: .gradians)
        
        XCTAssertEqual(rect.x, originalX, accuracy: 1e-10)
        XCTAssertEqual(rect.y, originalY, accuracy: 1e-10)
    }
    
    func test_PolarResult_Equatable() {
        let result1 = CoordinateConversions.PolarResult(r: 5, theta: 45)
        let result2 = CoordinateConversions.PolarResult(r: 5, theta: 45)
        let result3 = CoordinateConversions.PolarResult(r: 5, theta: 90)
        
        XCTAssertEqual(result1, result2)
        XCTAssertNotEqual(result1, result3)
    }
    
    func test_RectangularResult_Equatable() {
        let result1 = CoordinateConversions.RectangularResult(x: 3, y: 4)
        let result2 = CoordinateConversions.RectangularResult(x: 3, y: 4)
        let result3 = CoordinateConversions.RectangularResult(x: 3, y: 5)
        
        XCTAssertEqual(result1, result2)
        XCTAssertNotEqual(result1, result3)
    }
}

// MARK: - DMS Equatable Tests

final class DMSEquatableTests: XCTestCase {
    
    func test_DMS_Equatable_Equal() {
        let dms1 = DMS(degrees: 45, minutes: 30, seconds: 15)
        let dms2 = DMS(degrees: 45, minutes: 30, seconds: 15)
        
        XCTAssertEqual(dms1, dms2)
    }
    
    func test_DMS_Equatable_NotEqual_Degrees() {
        let dms1 = DMS(degrees: 45, minutes: 30, seconds: 15)
        let dms2 = DMS(degrees: 46, minutes: 30, seconds: 15)
        
        XCTAssertNotEqual(dms1, dms2)
    }
    
    func test_DMS_Equatable_NotEqual_Minutes() {
        let dms1 = DMS(degrees: 45, minutes: 30, seconds: 15)
        let dms2 = DMS(degrees: 45, minutes: 31, seconds: 15)
        
        XCTAssertNotEqual(dms1, dms2)
    }
    
    func test_DMS_Equatable_NotEqual_Sign() {
        let dms1 = DMS(degrees: 45, minutes: 30, seconds: 15, isNegative: false)
        let dms2 = DMS(degrees: 45, minutes: 30, seconds: 15, isNegative: true)
        
        XCTAssertNotEqual(dms1, dms2)
    }
}
