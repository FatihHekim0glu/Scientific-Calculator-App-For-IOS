import XCTest
@testable import ScientificCalculatorAppForIOS

final class BaseNArithmeticTests: XCTestCase {
    
    // MARK: - NumberBase Tests
    
    func test_NumberBase_Name_ReturnsCorrectName() {
        XCTAssertEqual(NumberBase.binary.name, "BIN")
        XCTAssertEqual(NumberBase.octal.name, "OCT")
        XCTAssertEqual(NumberBase.decimal.name, "DEC")
        XCTAssertEqual(NumberBase.hexadecimal.name, "HEX")
    }
    
    func test_NumberBase_ValidDigits_Binary() {
        XCTAssertEqual(NumberBase.binary.validDigits, "01")
    }
    
    func test_NumberBase_ValidDigits_Hexadecimal() {
        XCTAssertTrue(NumberBase.hexadecimal.validDigits.contains("A"))
        XCTAssertTrue(NumberBase.hexadecimal.validDigits.contains("F"))
    }
    
    func test_NumberBase_RawValue() {
        XCTAssertEqual(NumberBase.binary.rawValue, 2)
        XCTAssertEqual(NumberBase.octal.rawValue, 8)
        XCTAssertEqual(NumberBase.decimal.rawValue, 10)
        XCTAssertEqual(NumberBase.hexadecimal.rawValue, 16)
    }
    
    // MARK: - BaseNNumber Initialization Tests
    
    func test_Init_Int32Value_Stores() {
        let n = BaseNNumber(42)
        XCTAssertEqual(n.value, 42)
        XCTAssertEqual(n.base, .decimal)
    }
    
    func test_Init_WithBase_StoresBase() {
        let n = BaseNNumber(255, base: .hexadecimal)
        XCTAssertEqual(n.value, 255)
        XCTAssertEqual(n.base, .hexadecimal)
    }
    
    func test_Init_Double_TruncatesAndStores() throws {
        let n = try BaseNNumber(3.7)
        XCTAssertEqual(n.value, 3)
    }
    
    func test_Init_NegativeDouble_TruncatesCorrectly() throws {
        let n = try BaseNNumber(-3.7)
        XCTAssertEqual(n.value, -3)
    }
    
    func test_Init_DoubleOutOfRange_ThrowsError() {
        XCTAssertThrowsError(try BaseNNumber(Double(Int64.max))) { error in
            XCTAssertEqual(error as? CalculatorError, .overflow)
        }
    }
    
    func test_Init_StringBinary_ParsesCorrectly() {
        let n = BaseNNumber(string: "1010", base: .binary)
        XCTAssertNotNil(n)
        XCTAssertEqual(n?.value, 10)
    }
    
    func test_Init_StringOctal_ParsesCorrectly() {
        let n = BaseNNumber(string: "17", base: .octal)
        XCTAssertNotNil(n)
        XCTAssertEqual(n?.value, 15)
    }
    
    func test_Init_StringDecimal_ParsesCorrectly() {
        let n = BaseNNumber(string: "255", base: .decimal)
        XCTAssertNotNil(n)
        XCTAssertEqual(n?.value, 255)
    }
    
    func test_Init_StringHex_ParsesCorrectly() {
        let n = BaseNNumber(string: "FF", base: .hexadecimal)
        XCTAssertNotNil(n)
        XCTAssertEqual(n?.value, 255)
    }
    
    func test_Init_StringHex_LowerCase_ParsesCorrectly() {
        let n = BaseNNumber(string: "ff", base: .hexadecimal)
        XCTAssertNotNil(n)
        XCTAssertEqual(n?.value, 255)
    }
    
    func test_Init_InvalidString_ReturnsNil() {
        let n = BaseNNumber(string: "123", base: .binary)
        XCTAssertNil(n)
    }
    
    func test_Init_EmptyString_ReturnsNil() {
        let n = BaseNNumber(string: "", base: .decimal)
        XCTAssertNil(n)
    }
    
    // MARK: - Conversion Tests
    
    func test_Convert_DecimalToBinary() {
        let n = BaseNNumber(10, base: .decimal)
        let converted = n.convert(to: .binary)
        
        XCTAssertEqual(converted.value, 10)
        XCTAssertEqual(converted.base, .binary)
    }
    
    func test_Convert_BinaryToHex() {
        let n = BaseNNumber(255, base: .binary)
        let converted = n.convert(to: .hexadecimal)
        
        XCTAssertEqual(converted.value, 255)
        XCTAssertEqual(converted.base, .hexadecimal)
    }
    
    func test_Convert_HexToOctal() {
        let n = BaseNNumber(64, base: .hexadecimal)
        let converted = n.convert(to: .octal)
        
        XCTAssertEqual(converted.value, 64)
        XCTAssertEqual(converted.base, .octal)
    }
    
    func test_ToString_Binary_FormatsCorrectly() {
        let n = BaseNNumber(10, base: .binary)
        XCTAssertEqual(n.toString(), "1010")
    }
    
    func test_ToString_Octal_FormatsCorrectly() {
        let n = BaseNNumber(64, base: .octal)
        XCTAssertEqual(n.toString(), "100")
    }
    
    func test_ToString_Decimal_FormatsCorrectly() {
        let n = BaseNNumber(255, base: .decimal)
        XCTAssertEqual(n.toString(), "255")
    }
    
    func test_ToString_Hex_UsesUppercase() {
        let n = BaseNNumber(255, base: .hexadecimal)
        XCTAssertEqual(n.toString(), "FF")
    }
    
    func test_ToString_NegativeInBinary_ShowsTwosComplement() {
        let n = BaseNNumber(-1, base: .binary)
        let str = n.toString()
        // -1 in two's complement is all 1s
        XCTAssertEqual(str, "11111111111111111111111111111111")
    }
    
    func test_ToString_NegativeInHex_ShowsTwosComplement() {
        let n = BaseNNumber(-1, base: .hexadecimal)
        XCTAssertEqual(n.toString(), "FFFFFFFF")
    }
    
    func test_ToString_WithMinDigits_PadsWithZeros() {
        let n = BaseNNumber(5, base: .binary)
        XCTAssertEqual(n.toString(in: .binary, minDigits: 8), "00000101")
    }
    
    func test_ToStringWithPrefix_IncludesPrefix() {
        let n = BaseNNumber(255, base: .hexadecimal)
        XCTAssertEqual(n.toStringWithPrefix(), "0xFF")
    }
    
    func test_DoubleValue_ReturnsDouble() {
        let n = BaseNNumber(42)
        XCTAssertEqual(n.doubleValue, 42.0, accuracy: 1e-15)
    }
    
    func test_UnsignedValue_ReturnsUnsigned() {
        let n = BaseNNumber(-1)
        XCTAssertEqual(n.unsignedValue, UInt32.max)
    }
    
    // MARK: - Arithmetic Tests
    
    func test_Addition_Simple() {
        let a = BaseNNumber(10)
        let b = BaseNNumber(20)
        let result = a + b
        
        XCTAssertEqual(result.value, 30)
    }
    
    func test_Addition_WrapsOn32BitOverflow() {
        let a = BaseNNumber(Int32.max)
        let b = BaseNNumber(1)
        let result = a + b
        
        XCTAssertEqual(result.value, Int32.min)
    }
    
    func test_Subtraction_Simple() {
        let a = BaseNNumber(30)
        let b = BaseNNumber(10)
        let result = a - b
        
        XCTAssertEqual(result.value, 20)
    }
    
    func test_Subtraction_WrapsOnUnderflow() {
        let a = BaseNNumber(Int32.min)
        let b = BaseNNumber(1)
        let result = a - b
        
        XCTAssertEqual(result.value, Int32.max)
    }
    
    func test_Multiplication_Simple() {
        let a = BaseNNumber(6)
        let b = BaseNNumber(7)
        let result = a * b
        
        XCTAssertEqual(result.value, 42)
    }
    
    func test_Multiplication_WrapsCorrectly() {
        let a = BaseNNumber(Int32.max)
        let b = BaseNNumber(2)
        let result = a * b
        
        // Overflow wraps
        XCTAssertEqual(result.value, -2)
    }
    
    func test_Division_ReturnsQuotient() throws {
        let a = BaseNNumber(42)
        let b = BaseNNumber(6)
        let result = try a / b
        
        XCTAssertEqual(result.value, 7)
    }
    
    func test_Division_Truncates() throws {
        let a = BaseNNumber(7)
        let b = BaseNNumber(2)
        let result = try a / b
        
        XCTAssertEqual(result.value, 3)
    }
    
    func test_Division_ByZero_ThrowsError() {
        let a = BaseNNumber(42)
        let b = BaseNNumber(0)
        
        XCTAssertThrowsError(try a / b) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_Modulo_ReturnsRemainder() throws {
        let a = BaseNNumber(17)
        let b = BaseNNumber(5)
        let result = try a % b
        
        XCTAssertEqual(result.value, 2)
    }
    
    func test_Modulo_ByZero_ThrowsError() {
        let a = BaseNNumber(17)
        let b = BaseNNumber(0)
        
        XCTAssertThrowsError(try a % b) { error in
            XCTAssertEqual(error as? CalculatorError, .divisionByZero)
        }
    }
    
    func test_Negation_ReturnsTwosComplement() {
        let n = BaseNNumber(42)
        let result = -n
        
        XCTAssertEqual(result.value, -42)
    }
    
    // MARK: - Bitwise Tests
    
    func test_And_ReturnsCorrectBits() {
        let a = BaseNNumber(0b1100)
        let b = BaseNNumber(0b1010)
        let result = a & b
        
        XCTAssertEqual(result.value, 0b1000)
    }
    
    func test_Or_ReturnsCorrectBits() {
        let a = BaseNNumber(0b1100)
        let b = BaseNNumber(0b1010)
        let result = a | b
        
        XCTAssertEqual(result.value, 0b1110)
    }
    
    func test_Xor_ReturnsCorrectBits() {
        let a = BaseNNumber(0b1100)
        let b = BaseNNumber(0b1010)
        let result = a ^ b
        
        XCTAssertEqual(result.value, 0b0110)
    }
    
    func test_Xnor_ReturnsCorrectBits() {
        let a = BaseNNumber(0b1100)
        let b = BaseNNumber(0b1100)
        let result = BaseNNumber.xnor(a, b)
        
        // XNOR of same values is all 1s
        XCTAssertEqual(result.value, -1)
    }
    
    func test_Not_InvertsAllBits() {
        let n = BaseNNumber(0)
        let result = ~n
        
        XCTAssertEqual(result.value, -1)
    }
    
    func test_Not_ZeroToAllOnes() {
        let n = BaseNNumber(0)
        let result = ~n
        
        XCTAssertEqual(result.unsignedValue, UInt32.max)
    }
    
    func test_LeftShift_ShiftsBitsLeft() {
        let n = BaseNNumber(1)
        let result = n << 4
        
        XCTAssertEqual(result.value, 16)
    }
    
    func test_LeftShift_LargeShift_Clamps() {
        let n = BaseNNumber(1)
        let result = n << 100
        
        // Clamped to 31
        XCTAssertEqual(result.value, Int32.min)
    }
    
    func test_RightShift_Arithmetic_PreservesSign() {
        let n = BaseNNumber(-8)
        let result = n >> 2
        
        XCTAssertEqual(result.value, -2)
    }
    
    func test_RightShift_Positive() {
        let n = BaseNNumber(16)
        let result = n >> 2
        
        XCTAssertEqual(result.value, 4)
    }
    
    func test_LogicalRightShift_FillsWithZeros() {
        let n = BaseNNumber(-1)  // All 1s
        let result = n.logicalRightShift(1)
        
        // Should be 0x7FFFFFFF
        XCTAssertEqual(result.value, Int32.max)
    }
    
    func test_RotateLeft_RotatesBits() {
        let n = BaseNNumber(Int32(bitPattern: 0x80000001))
        let result = n.rotateLeft(1)
        
        XCTAssertEqual(result.value, 3)
    }
    
    func test_RotateRight_RotatesBits() {
        let n = BaseNNumber(3)
        let result = n.rotateRight(1)
        
        XCTAssertEqual(result.value, Int32(bitPattern: 0x80000001))
    }
    
    // MARK: - BaseNArithmetic Utility Tests
    
    func test_Parse_Binary_ParsesCorrectly() throws {
        let value = try BaseNArithmetic.parse("1010", base: .binary)
        XCTAssertEqual(value, 10)
    }
    
    func test_Parse_WithPrefix_ParsesCorrectly() throws {
        let value = try BaseNArithmetic.parse("0xFF", base: .hexadecimal)
        XCTAssertEqual(value, 255)
    }
    
    func test_Parse_EmptyString_ThrowsError() {
        XCTAssertThrowsError(try BaseNArithmetic.parse("", base: .decimal)) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntax error")
                return
            }
        }
    }
    
    func test_Parse_InvalidDigits_ThrowsError() {
        XCTAssertThrowsError(try BaseNArithmetic.parse("123", base: .binary)) { error in
            guard case CalculatorError.syntaxError = error else {
                XCTFail("Expected syntax error")
                return
            }
        }
    }
    
    func test_Format_Binary() {
        let result = BaseNArithmetic.format(10, base: .binary)
        XCTAssertEqual(result, "1010")
    }
    
    func test_Format_WithMinDigits() {
        let result = BaseNArithmetic.format(5, base: .binary, minDigits: 8)
        XCTAssertEqual(result, "00000101")
    }
    
    func test_FormatGrouped_Binary() {
        let result = BaseNArithmetic.formatGrouped(255, base: .binary)
        XCTAssertTrue(result.contains(" "))
    }
    
    func test_FormatGrouped_Decimal_NoGrouping() {
        let result = BaseNArithmetic.formatGrouped(12345, base: .decimal)
        XCTAssertFalse(result.contains(" "))
    }
    
    // MARK: - Validation Tests
    
    func test_IsValid_BinaryWithInvalidDigit_ReturnsFalse() {
        XCTAssertFalse(BaseNArithmetic.isValid("102", for: .binary))
    }
    
    func test_IsValid_BinaryValid_ReturnsTrue() {
        XCTAssertTrue(BaseNArithmetic.isValid("1010", for: .binary))
    }
    
    func test_IsValid_HexValid_ReturnsTrue() {
        XCTAssertTrue(BaseNArithmetic.isValid("DEADBEEF", for: .hexadecimal))
    }
    
    func test_IsValid_HexInvalid_ReturnsFalse() {
        XCTAssertFalse(BaseNArithmetic.isValid("GHIJ", for: .hexadecimal))
    }
    
    func test_DetectBase_0xPrefix_ReturnsHex() {
        XCTAssertEqual(BaseNArithmetic.detectBase("0xFF"), .hexadecimal)
    }
    
    func test_DetectBase_0bPrefix_ReturnsBinary() {
        XCTAssertEqual(BaseNArithmetic.detectBase("0b1010"), .binary)
    }
    
    func test_DetectBase_0oPrefix_ReturnsOctal() {
        XCTAssertEqual(BaseNArithmetic.detectBase("0o77"), .octal)
    }
    
    func test_DetectBase_NoPrefix_ReturnsNil() {
        XCTAssertNil(BaseNArithmetic.detectBase("123"))
    }
    
    func test_ParseWithAutoDetect_Hex() throws {
        let (value, base) = try BaseNArithmetic.parseWithAutoDetect("0xFF")
        XCTAssertEqual(value, 255)
        XCTAssertEqual(base, .hexadecimal)
    }
    
    func test_ParseWithAutoDetect_NoPrefix() throws {
        let (value, base) = try BaseNArithmetic.parseWithAutoDetect("123")
        XCTAssertEqual(value, 123)
        XCTAssertEqual(base, .decimal)
    }
    
    // MARK: - Bitwise Function Tests
    
    func test_BitwiseAnd_Function() {
        let result = BaseNArithmetic.and(0b1100, 0b1010)
        XCTAssertEqual(result, 0b1000)
    }
    
    func test_BitwiseOr_Function() {
        let result = BaseNArithmetic.or(0b1100, 0b1010)
        XCTAssertEqual(result, 0b1110)
    }
    
    func test_BitwiseXor_Function() {
        let result = BaseNArithmetic.xor(0b1100, 0b1010)
        XCTAssertEqual(result, 0b0110)
    }
    
    func test_BitwiseXnor_Function() {
        let result = BaseNArithmetic.xnor(0b1111, 0b1111)
        XCTAssertEqual(result, -1)  // All 1s
    }
    
    func test_BitwiseNot_Function() {
        let result = BaseNArithmetic.not(0)
        XCTAssertEqual(result, -1)
    }
    
    func test_BitwiseNeg_Function() {
        let result = BaseNArithmetic.neg(42)
        XCTAssertEqual(result, -42)
    }
    
    func test_LeftShift_Function() {
        let result = BaseNArithmetic.leftShift(1, by: 4)
        XCTAssertEqual(result, 16)
    }
    
    func test_RightShift_Function() {
        let result = BaseNArithmetic.rightShift(16, by: 2)
        XCTAssertEqual(result, 4)
    }
    
    func test_LogicalRightShift_Function() {
        let result = BaseNArithmetic.logicalRightShift(-1, by: 1)
        XCTAssertEqual(result, Int32.max)
    }
    
    // MARK: - Bit Manipulation Tests
    
    func test_PopCount_ReturnsBitCount() {
        let count = BaseNArithmetic.popCount(0b10101010)
        XCTAssertEqual(count, 4)
    }
    
    func test_HighestBit_ReturnsPosition() {
        let pos = BaseNArithmetic.highestBit(0b10000)
        XCTAssertEqual(pos, 4)
    }
    
    func test_HighestBit_Zero_ReturnsMinusOne() {
        let pos = BaseNArithmetic.highestBit(0)
        XCTAssertEqual(pos, -1)
    }
    
    func test_LowestBit_ReturnsPosition() {
        let pos = BaseNArithmetic.lowestBit(0b10100)
        XCTAssertEqual(pos, 2)
    }
    
    func test_LowestBit_Zero_ReturnsMinusOne() {
        let pos = BaseNArithmetic.lowestBit(0)
        XCTAssertEqual(pos, -1)
    }
    
    func test_TestBit_SetBit_ReturnsTrue() {
        XCTAssertTrue(BaseNArithmetic.testBit(0b1000, bit: 3))
    }
    
    func test_TestBit_UnsetBit_ReturnsFalse() {
        XCTAssertFalse(BaseNArithmetic.testBit(0b1000, bit: 2))
    }
    
    func test_SetBit_SetsSpecificBit() {
        let result = BaseNArithmetic.setBit(0, bit: 3)
        XCTAssertEqual(result, 8)
    }
    
    func test_ClearBit_ClearsSpecificBit() {
        let result = BaseNArithmetic.clearBit(0b1111, bit: 2)
        XCTAssertEqual(result, 0b1011)
    }
    
    func test_ToggleBit_TogglesSpecificBit() {
        let set = BaseNArithmetic.toggleBit(0, bit: 3)
        XCTAssertEqual(set, 8)
        
        let unset = BaseNArithmetic.toggleBit(8, bit: 3)
        XCTAssertEqual(unset, 0)
    }
    
    func test_ReverseBits_ReversesBitOrder() {
        let result = BaseNArithmetic.reverseBits(1)
        XCTAssertEqual(result, Int32(bitPattern: 0x80000000))
    }
    
    // MARK: - Byte Operations Tests
    
    func test_ByteSwap_SwapsEndianness() {
        let result = BaseNArithmetic.byteSwap(Int32(bitPattern: 0x12345678))
        XCTAssertEqual(result, Int32(bitPattern: 0x78563412))
    }
    
    func test_GetByte_ReturnsCorrectByte() {
        let value: Int32 = Int32(bitPattern: 0x12345678)
        
        XCTAssertEqual(BaseNArithmetic.getByte(value, at: 0), 0x78)
        XCTAssertEqual(BaseNArithmetic.getByte(value, at: 1), 0x56)
        XCTAssertEqual(BaseNArithmetic.getByte(value, at: 2), 0x34)
        XCTAssertEqual(BaseNArithmetic.getByte(value, at: 3), 0x12)
    }
    
    // MARK: - Common Values Tests
    
    func test_CommonValue_Zero() {
        XCTAssertEqual(BaseNNumber.zero.value, 0)
    }
    
    func test_CommonValue_One() {
        XCTAssertEqual(BaseNNumber.one.value, 1)
    }
    
    func test_CommonValue_AllOnes() {
        XCTAssertEqual(BaseNNumber.allOnes.value, -1)
    }
    
    func test_CommonValue_Max() {
        XCTAssertEqual(BaseNNumber.max.value, Int32.max)
    }
    
    func test_CommonValue_Min() {
        XCTAssertEqual(BaseNNumber.min.value, Int32.min)
    }
    
    // MARK: - Comparison Tests
    
    func test_Comparable_LessThan() {
        let a = BaseNNumber(10)
        let b = BaseNNumber(20)
        
        XCTAssertLessThan(a, b)
    }
    
    func test_Comparable_GreaterThan() {
        let a = BaseNNumber(20)
        let b = BaseNNumber(10)
        
        XCTAssertGreaterThan(a, b)
    }
    
    // MARK: - Equatable Tests
    
    func test_Equatable_SameValue_AreEqual() {
        let a = BaseNNumber(42, base: .decimal)
        let b = BaseNNumber(42, base: .hexadecimal)
        
        XCTAssertEqual(a, b)  // Value equality, not base
    }
    
    func test_Equatable_DifferentValue_AreNotEqual() {
        let a = BaseNNumber(42)
        let b = BaseNNumber(43)
        
        XCTAssertNotEqual(a, b)
    }
}
