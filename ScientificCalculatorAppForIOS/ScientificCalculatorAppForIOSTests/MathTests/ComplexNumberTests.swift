import XCTest
@testable import ScientificCalculatorAppForIOS

final class ComplexNumberTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func test_Init_RealPart_CreatesComplexWithZeroImaginary() {
        let c = ComplexNumber(5.0)
        XCTAssertEqual(c.real, 5.0, accuracy: 1e-15)
        XCTAssertEqual(c.imaginary, 0.0, accuracy: 1e-15)
    }
    
    func test_Init_RectangularForm_StoresCorrectValues() {
        let c = ComplexNumber(real: 3.0, imaginary: 4.0)
        XCTAssertEqual(c.real, 3.0, accuracy: 1e-15)
        XCTAssertEqual(c.imaginary, 4.0, accuracy: 1e-15)
    }
    
    func test_Init_DefaultImaginary_IsZero() {
        let c = ComplexNumber(real: 7.0)
        XCTAssertEqual(c.imaginary, 0.0, accuracy: 1e-15)
    }
    
    func test_FromPolar_CreatesCorrectRectangular() {
        let c = ComplexNumber.fromPolar(r: 2.0, theta: .pi / 4)
        XCTAssertEqual(c.real, sqrt(2.0), accuracy: 1e-10)
        XCTAssertEqual(c.imaginary, sqrt(2.0), accuracy: 1e-10)
    }
    
    func test_FromPolar_ZeroMagnitude_ReturnsZero() {
        let c = ComplexNumber.fromPolar(r: 0, theta: .pi)
        XCTAssertEqual(c.real, 0.0, accuracy: 1e-15)
        XCTAssertEqual(c.imaginary, 0.0, accuracy: 1e-15)
    }
    
    func test_FromPolar_90Degrees_ReturnsImaginaryUnit() {
        let c = ComplexNumber.fromPolar(r: 1, theta: .pi / 2)
        XCTAssertEqual(c.real, 0.0, accuracy: 1e-10)
        XCTAssertEqual(c.imaginary, 1.0, accuracy: 1e-10)
    }
    
    // MARK: - Property Tests
    
    func test_Magnitude_3Plus4i_Returns5() {
        let c = ComplexNumber(real: 3.0, imaginary: 4.0)
        XCTAssertEqual(c.magnitude, 5.0, accuracy: 1e-15)
    }
    
    func test_Magnitude_PureReal_ReturnsAbsoluteValue() {
        let c = ComplexNumber(real: -5.0, imaginary: 0.0)
        XCTAssertEqual(c.magnitude, 5.0, accuracy: 1e-15)
    }
    
    func test_Magnitude_PureImaginary_ReturnsAbsoluteValue() {
        let c = ComplexNumber(real: 0.0, imaginary: -3.0)
        XCTAssertEqual(c.magnitude, 3.0, accuracy: 1e-15)
    }
    
    func test_Argument_1Plus1i_ReturnsPiOver4() {
        let c = ComplexNumber(real: 1.0, imaginary: 1.0)
        XCTAssertEqual(c.argument, .pi / 4, accuracy: 1e-15)
    }
    
    func test_Argument_NegativeReal_ReturnsPi() {
        let c = ComplexNumber(real: -1.0, imaginary: 0.0)
        XCTAssertEqual(c.argument, .pi, accuracy: 1e-15)
    }
    
    func test_Argument_PureImaginaryPositive_ReturnsPiOver2() {
        let c = ComplexNumber(real: 0.0, imaginary: 1.0)
        XCTAssertEqual(c.argument, .pi / 2, accuracy: 1e-15)
    }
    
    func test_IsReal_RealNumber_ReturnsTrue() {
        let c = ComplexNumber(real: 5.0, imaginary: 0.0)
        XCTAssertTrue(c.isReal)
    }
    
    func test_IsReal_ComplexNumber_ReturnsFalse() {
        let c = ComplexNumber(real: 3.0, imaginary: 4.0)
        XCTAssertFalse(c.isReal)
    }
    
    func test_IsReal_VerySmallImaginary_ReturnsTrue() {
        let c = ComplexNumber(real: 5.0, imaginary: 1e-16)
        XCTAssertTrue(c.isReal)
    }
    
    func test_IsPureImaginary_3i_ReturnsTrue() {
        let c = ComplexNumber(real: 0.0, imaginary: 3.0)
        XCTAssertTrue(c.isPureImaginary)
    }
    
    func test_IsPureImaginary_RealNumber_ReturnsFalse() {
        let c = ComplexNumber(real: 5.0, imaginary: 0.0)
        XCTAssertFalse(c.isPureImaginary)
    }
    
    func test_IsPureImaginary_Complex_ReturnsFalse() {
        let c = ComplexNumber(real: 1.0, imaginary: 1.0)
        XCTAssertFalse(c.isPureImaginary)
    }
    
    func test_IsZero_ZeroComplex_ReturnsTrue() {
        let c = ComplexNumber(real: 0.0, imaginary: 0.0)
        XCTAssertTrue(c.isZero)
    }
    
    func test_IsZero_NonZero_ReturnsFalse() {
        let c = ComplexNumber(real: 0.0, imaginary: 0.001)
        XCTAssertFalse(c.isZero)
    }
    
    // MARK: - Common Values Tests
    
    func test_CommonValue_Zero() {
        XCTAssertEqual(ComplexNumber.zero.real, 0.0, accuracy: 1e-15)
        XCTAssertEqual(ComplexNumber.zero.imaginary, 0.0, accuracy: 1e-15)
    }
    
    func test_CommonValue_One() {
        XCTAssertEqual(ComplexNumber.one.real, 1.0, accuracy: 1e-15)
        XCTAssertEqual(ComplexNumber.one.imaginary, 0.0, accuracy: 1e-15)
    }
    
    func test_CommonValue_i() {
        XCTAssertEqual(ComplexNumber.i.real, 0.0, accuracy: 1e-15)
        XCTAssertEqual(ComplexNumber.i.imaginary, 1.0, accuracy: 1e-15)
    }
    
    // MARK: - Arithmetic Tests
    
    func test_Addition_TwoComplex_ReturnsSum() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let b = ComplexNumber(real: 1.0, imaginary: 2.0)
        let result = a + b
        
        XCTAssertEqual(result.real, 4.0, accuracy: 1e-15)
        XCTAssertEqual(result.imaginary, 6.0, accuracy: 1e-15)
    }
    
    func test_Addition_WithZero_ReturnsSame() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let result = a + ComplexNumber.zero
        
        XCTAssertEqual(result, a)
    }
    
    func test_Subtraction_TwoComplex_ReturnsDifference() {
        let a = ComplexNumber(real: 5.0, imaginary: 7.0)
        let b = ComplexNumber(real: 2.0, imaginary: 3.0)
        let result = a - b
        
        XCTAssertEqual(result.real, 3.0, accuracy: 1e-15)
        XCTAssertEqual(result.imaginary, 4.0, accuracy: 1e-15)
    }
    
    func test_Subtraction_FromItself_ReturnsZero() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let result = a - a
        
        XCTAssertTrue(result.isZero)
    }
    
    func test_Multiplication_TwoComplex_ReturnsProduct() {
        let a = ComplexNumber(real: 3.0, imaginary: 2.0)
        let b = ComplexNumber(real: 1.0, imaginary: 4.0)
        let result = a * b
        
        // (3+2i)(1+4i) = 3 + 12i + 2i + 8i² = 3 + 14i - 8 = -5 + 14i
        XCTAssertEqual(result.real, -5.0, accuracy: 1e-15)
        XCTAssertEqual(result.imaginary, 14.0, accuracy: 1e-15)
    }
    
    func test_Multiplication_WithOne_ReturnsSame() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let result = a * ComplexNumber.one
        
        XCTAssertEqual(result, a)
    }
    
    func test_Multiplication_WithZero_ReturnsZero() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let result = a * ComplexNumber.zero
        
        XCTAssertTrue(result.isZero)
    }
    
    func test_Division_TwoComplex_ReturnsQuotient() throws {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let b = ComplexNumber(real: 1.0, imaginary: 2.0)
        let result = try a / b
        
        // (3+4i)/(1+2i) = (3+4i)(1-2i)/5 = (3-6i+4i-8i²)/5 = (11-2i)/5 = 2.2 - 0.4i
        XCTAssertEqual(result.real, 2.2, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, -0.4, accuracy: 1e-10)
    }
    
    func test_Division_ByOne_ReturnsSame() throws {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let result = try a / ComplexNumber.one
        
        XCTAssertEqual(result.real, a.real, accuracy: 1e-15)
        XCTAssertEqual(result.imaginary, a.imaginary, accuracy: 1e-15)
    }
    
    func test_Division_ByZero_ThrowsError() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        
        XCTAssertThrowsError(try a / ComplexNumber.zero) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_ScalarMultiplication_Left_ReturnsScaled() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let result = 2.0 * a
        
        XCTAssertEqual(result.real, 6.0, accuracy: 1e-15)
        XCTAssertEqual(result.imaginary, 8.0, accuracy: 1e-15)
    }
    
    func test_ScalarMultiplication_Right_ReturnsScaled() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let result = a * 0.5
        
        XCTAssertEqual(result.real, 1.5, accuracy: 1e-15)
        XCTAssertEqual(result.imaginary, 2.0, accuracy: 1e-15)
    }
    
    func test_ScalarDivision_ReturnsScaled() throws {
        let a = ComplexNumber(real: 6.0, imaginary: 8.0)
        let result = try a / 2.0
        
        XCTAssertEqual(result.real, 3.0, accuracy: 1e-15)
        XCTAssertEqual(result.imaginary, 4.0, accuracy: 1e-15)
    }
    
    func test_ScalarDivision_ByZero_ThrowsError() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        
        XCTAssertThrowsError(try a / 0.0) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_Negation_ReturnsNegated() {
        let a = ComplexNumber(real: 3.0, imaginary: -4.0)
        let result = -a
        
        XCTAssertEqual(result.real, -3.0, accuracy: 1e-15)
        XCTAssertEqual(result.imaginary, 4.0, accuracy: 1e-15)
    }
    
    // MARK: - Function Tests
    
    func test_Conjugate_FlipsImaginarySign() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let result = a.conjugate()
        
        XCTAssertEqual(result.real, 3.0, accuracy: 1e-15)
        XCTAssertEqual(result.imaginary, -4.0, accuracy: 1e-15)
    }
    
    func test_Conjugate_OfConjugate_ReturnsOriginal() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let result = a.conjugate().conjugate()
        
        XCTAssertEqual(result, a)
    }
    
    func test_Reciprocal_ReturnsCorrectInverse() throws {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let reciprocal = try a.reciprocal()
        let product = a * reciprocal
        
        XCTAssertEqual(product.real, 1.0, accuracy: 1e-10)
        XCTAssertEqual(product.imaginary, 0.0, accuracy: 1e-10)
    }
    
    func test_Reciprocal_Zero_ThrowsError() {
        XCTAssertThrowsError(try ComplexNumber.zero.reciprocal()) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_Power_IntegerExponent_UsesDeMovire() {
        let a = ComplexNumber(real: 1.0, imaginary: 1.0)
        let result = a.power(2)
        
        // (1+i)² = 1 + 2i - 1 = 2i
        XCTAssertEqual(result.real, 0.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 2.0, accuracy: 1e-10)
    }
    
    func test_Power_Zero_ReturnsOne() {
        let a = ComplexNumber(real: 5.0, imaginary: 3.0)
        let result = a.power(0)
        
        XCTAssertEqual(result, ComplexNumber.one)
    }
    
    func test_Power_NegativeExponent_ReturnsReciprocal() {
        let a = ComplexNumber(real: 0.0, imaginary: 1.0) // i
        let result = a.power(-2)
        
        // i^(-2) = 1/i² = 1/(-1) = -1
        XCTAssertEqual(result.real, -1.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    func test_Power_RealExponent() {
        let a = ComplexNumber(real: 4.0, imaginary: 0.0)
        let result = a.power(0.5)
        
        XCTAssertEqual(result.real, 2.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    func test_SquareRoot_Negative1_ReturnsI() {
        let a = ComplexNumber(real: -1.0, imaginary: 0.0)
        let result = a.squareRoot()
        
        XCTAssertEqual(result.real, 0.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 1.0, accuracy: 1e-10)
    }
    
    func test_SquareRoot_4_Returns2() {
        let a = ComplexNumber(real: 4.0, imaginary: 0.0)
        let result = a.squareRoot()
        
        XCTAssertEqual(result.real, 2.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    func test_SquareRoot_Squared_ReturnsOriginal() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let root = a.squareRoot()
        let squared = root * root
        
        XCTAssertEqual(squared.real, a.real, accuracy: 1e-10)
        XCTAssertEqual(squared.imaginary, a.imaginary, accuracy: 1e-10)
    }
    
    func test_Exp_Zero_ReturnsOne() {
        let result = ComplexNumber.zero.exp()
        
        XCTAssertEqual(result.real, 1.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    func test_Exp_PureImaginaryPi_ReturnsNegativeOne() {
        let a = ComplexNumber(real: 0.0, imaginary: .pi)
        let result = a.exp()
        
        // e^(iπ) = -1
        XCTAssertEqual(result.real, -1.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    func test_Ln_One_ReturnsZero() throws {
        let result = try ComplexNumber.one.ln()
        
        XCTAssertEqual(result.real, 0.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    func test_Ln_E_ReturnsOne() throws {
        let a = ComplexNumber(real: M_E, imaginary: 0.0)
        let result = try a.ln()
        
        XCTAssertEqual(result.real, 1.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    func test_Ln_Zero_ThrowsError() {
        XCTAssertThrowsError(try ComplexNumber.zero.ln()) { error in
            guard case CalculatorError.domainError = error else {
                XCTFail("Expected domain error")
                return
            }
        }
    }
    
    func test_Sin_Zero_ReturnsZero() {
        let result = ComplexNumber.zero.sin()
        
        XCTAssertEqual(result.real, 0.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    func test_Cos_Zero_ReturnsOne() {
        let result = ComplexNumber.zero.cos()
        
        XCTAssertEqual(result.real, 1.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    func test_Tan_Zero_ReturnsZero() throws {
        let result = try ComplexNumber.zero.tan()
        
        XCTAssertEqual(result.real, 0.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    func test_Sinh_Zero_ReturnsZero() {
        let result = ComplexNumber.zero.complexSinh()
        
        XCTAssertEqual(result.real, 0.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    func test_Cosh_Zero_ReturnsOne() {
        let result = ComplexNumber.zero.complexCosh()
        
        XCTAssertEqual(result.real, 1.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    // MARK: - Display Tests
    
    func test_Description_PositiveImaginary_FormatsCorrectly() {
        let c = ComplexNumber(real: 3.0, imaginary: 4.0)
        XCTAssertTrue(c.description.contains("+"))
    }
    
    func test_Description_NegativeImaginary_FormatsCorrectly() {
        let c = ComplexNumber(real: 3.0, imaginary: -4.0)
        XCTAssertTrue(c.description.contains("-"))
    }
    
    func test_Description_Zero_ReturnsZero() {
        let c = ComplexNumber.zero
        XCTAssertEqual(c.description, "0")
    }
    
    func test_Description_PureReal_NoImaginaryPart() {
        let c = ComplexNumber(real: 5.0, imaginary: 0.0)
        XCTAssertFalse(c.description.contains("i"))
    }
    
    func test_Description_PureImaginary_OnlyImaginaryPart() {
        let c = ComplexNumber(real: 0.0, imaginary: 3.0)
        XCTAssertTrue(c.description.contains("i"))
    }
    
    func test_PolarDescription_FormatsCorrectly() {
        let c = ComplexNumber(real: 1.0, imaginary: 1.0)
        let description = c.polarDescription(angleMode: .degrees)
        
        XCTAssertTrue(description.contains("∠"))
        XCTAssertTrue(description.contains("°"))
    }
    
    func test_ToDouble_RealNumber_ReturnsValue() {
        let c = ComplexNumber(real: 5.0, imaginary: 0.0)
        XCTAssertEqual(c.toDouble(), 5.0)
    }
    
    func test_ToDouble_ComplexNumber_ReturnsNil() {
        let c = ComplexNumber(real: 3.0, imaginary: 4.0)
        XCTAssertNil(c.toDouble())
    }
    
    // MARK: - Identity Tests
    
    func test_AdditionIdentity_PlusZero_ReturnsSame() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let result = a + ComplexNumber.zero
        
        XCTAssertEqual(result, a)
    }
    
    func test_MultiplicationIdentity_TimesOne_ReturnsSame() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let result = a * ComplexNumber.one
        
        XCTAssertEqual(result, a)
    }
    
    func test_iSquared_ReturnsNegativeOne() {
        let result = ComplexNumber.i * ComplexNumber.i
        
        XCTAssertEqual(result.real, -1.0, accuracy: 1e-15)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-15)
    }
    
    func test_iCubed_ReturnsNegativeI() {
        let result = ComplexNumber.i.power(3)
        
        XCTAssertEqual(result.real, 0.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, -1.0, accuracy: 1e-10)
    }
    
    func test_iFourth_ReturnsOne() {
        let result = ComplexNumber.i.power(4)
        
        XCTAssertEqual(result.real, 1.0, accuracy: 1e-10)
        XCTAssertEqual(result.imaginary, 0.0, accuracy: 1e-10)
    }
    
    // MARK: - Parsing Tests
    
    func test_Parse_PureReal_Parses() throws {
        let c = try ComplexNumber.parse("5")
        XCTAssertEqual(c.real, 5.0, accuracy: 1e-15)
        XCTAssertEqual(c.imaginary, 0.0, accuracy: 1e-15)
    }
    
    func test_Parse_PureImaginaryI_Parses() throws {
        let c = try ComplexNumber.parse("i")
        XCTAssertEqual(c.real, 0.0, accuracy: 1e-15)
        XCTAssertEqual(c.imaginary, 1.0, accuracy: 1e-15)
    }
    
    func test_Parse_NegativeI_Parses() throws {
        let c = try ComplexNumber.parse("-i")
        XCTAssertEqual(c.real, 0.0, accuracy: 1e-15)
        XCTAssertEqual(c.imaginary, -1.0, accuracy: 1e-15)
    }
    
    func test_Parse_CoefficientI_Parses() throws {
        let c = try ComplexNumber.parse("3i")
        XCTAssertEqual(c.real, 0.0, accuracy: 1e-15)
        XCTAssertEqual(c.imaginary, 3.0, accuracy: 1e-15)
    }
    
    func test_Parse_Rectangular_Parses() throws {
        let c = try ComplexNumber.parse("3+4i")
        XCTAssertEqual(c.real, 3.0, accuracy: 1e-15)
        XCTAssertEqual(c.imaginary, 4.0, accuracy: 1e-15)
    }
    
    func test_Parse_RectangularNegativeImaginary_Parses() throws {
        let c = try ComplexNumber.parse("3-4i")
        XCTAssertEqual(c.real, 3.0, accuracy: 1e-15)
        XCTAssertEqual(c.imaginary, -4.0, accuracy: 1e-15)
    }
    
    func test_Parse_EmptyString_ThrowsError() {
        XCTAssertThrowsError(try ComplexNumber.parse("")) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntax error")
                return
            }
        }
    }
    
    // MARK: - Equatable Tests
    
    func test_Equatable_SameValues_AreEqual() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let b = ComplexNumber(real: 3.0, imaginary: 4.0)
        
        XCTAssertEqual(a, b)
    }
    
    func test_Equatable_DifferentValues_AreNotEqual() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let b = ComplexNumber(real: 3.0, imaginary: 5.0)
        
        XCTAssertNotEqual(a, b)
    }
    
    func test_Equatable_WithinEpsilon_AreEqual() {
        let a = ComplexNumber(real: 3.0, imaginary: 4.0)
        let b = ComplexNumber(real: 3.0 + 1e-16, imaginary: 4.0 - 1e-16)
        
        XCTAssertEqual(a, b)
    }
}
