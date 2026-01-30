import Foundation

// MARK: - Lexer

/// Tokenizes mathematical expression strings into Token arrays
struct Lexer {
    private let input: String
    private var position: Int
    private var currentIndex: String.Index
    private var tokens: [Token]
    
    /// Current number base for Base-N mode (affects number parsing)
    private var currentBase: NumberBase
    
    init(input: String, base: NumberBase = .decimal) {
        self.input = input
        self.position = 0
        self.currentIndex = input.startIndex
        self.tokens = []
        self.currentBase = base
    }
    
    // MARK: - Public Interface
    
    /// Tokenizes the input string and returns an array of tokens
    mutating func tokenize() throws -> [Token] {
        tokens = []
        position = 0
        currentIndex = input.startIndex
        
        while !isAtEnd {
            try scanToken()
        }
        
        tokens.append(Token(type: .end, position: position))
        return tokens
    }
    
    // MARK: - Scanning
    
    private var isAtEnd: Bool {
        currentIndex >= input.endIndex
    }
    
    private var currentChar: Character? {
        guard !isAtEnd else { return nil }
        return input[currentIndex]
    }
    
    private mutating func advance() -> Character? {
        guard !isAtEnd else { return nil }
        let char = input[currentIndex]
        currentIndex = input.index(after: currentIndex)
        position += 1
        return char
    }
    
    private func peek() -> Character? {
        guard !isAtEnd else { return nil }
        return input[currentIndex]
    }
    
    private func peekNext() -> Character? {
        let nextIndex = input.index(after: currentIndex)
        guard nextIndex < input.endIndex else { return nil }
        return input[nextIndex]
    }
    
    private func peekAt(offset: Int) -> Character? {
        var idx = currentIndex
        for _ in 0..<offset {
            guard idx < input.endIndex else { return nil }
            idx = input.index(after: idx)
        }
        guard idx < input.endIndex else { return nil }
        return input[idx]
    }
    
    private mutating func scanToken() throws {
        skipWhitespace()
        guard !isAtEnd else { return }
        
        let startPosition = position
        guard let char = peek() else { return }
        
        // Check for hex numbers with 0x prefix
        if char == "0" && (peekNext() == "x" || peekNext() == "X") {
            try scanHexNumber(startPosition: startPosition)
        } else if char == "0" && (peekNext() == "b" || peekNext() == "B") {
            try scanBinaryNumber(startPosition: startPosition)
        } else if char == "0" && (peekNext() == "o" || peekNext() == "O") {
            try scanOctalNumber(startPosition: startPosition)
        } else if isValidDigit(char, for: currentBase) || (char == "." && peekNext()?.isNumber == true) {
            try scanNumber(startPosition: startPosition)
        } else if char.isLetter || char == "π" || char == "_" {
            try scanIdentifier(startPosition: startPosition)
        } else {
            try scanOperatorOrPunctuation(startPosition: startPosition)
        }
    }
    
    // MARK: - Whitespace Handling
    
    private mutating func skipWhitespace() {
        while let char = peek(), char.isWhitespace {
            _ = advance()
        }
    }
    
    // MARK: - Number Scanning
    
    /// Checks if a character is a valid digit for the given base
    private func isValidDigit(_ char: Character, for base: NumberBase) -> Bool {
        let validChars = base.validDigits
        return validChars.contains(char)
    }
    
    /// Scans a hexadecimal number with 0x prefix
    private mutating func scanHexNumber(startPosition: Int) throws {
        _ = advance() // consume '0'
        _ = advance() // consume 'x' or 'X'
        
        var hexString = ""
        while let char = peek(), "0123456789ABCDEFabcdef".contains(char) {
            hexString.append(advance()!)
        }
        
        guard !hexString.isEmpty else {
            throw CalculatorError.syntaxError("Invalid hexadecimal number: expected digits after 0x")
        }
        
        guard let value = Int(hexString, radix: 16) else {
            throw CalculatorError.syntaxError("Invalid hexadecimal number: '\(hexString)'")
        }
        
        tokens.append(Token(type: .number(Double(value)), position: startPosition))
    }
    
    /// Scans a binary number with 0b prefix
    private mutating func scanBinaryNumber(startPosition: Int) throws {
        _ = advance() // consume '0'
        _ = advance() // consume 'b' or 'B'
        
        var binaryString = ""
        while let char = peek(), "01".contains(char) {
            binaryString.append(advance()!)
        }
        
        guard !binaryString.isEmpty else {
            throw CalculatorError.syntaxError("Invalid binary number: expected digits after 0b")
        }
        
        guard let value = Int(binaryString, radix: 2) else {
            throw CalculatorError.syntaxError("Invalid binary number: '\(binaryString)'")
        }
        
        tokens.append(Token(type: .number(Double(value)), position: startPosition))
    }
    
    /// Scans an octal number with 0o prefix
    private mutating func scanOctalNumber(startPosition: Int) throws {
        _ = advance() // consume '0'
        _ = advance() // consume 'o' or 'O'
        
        var octalString = ""
        while let char = peek(), "01234567".contains(char) {
            octalString.append(advance()!)
        }
        
        guard !octalString.isEmpty else {
            throw CalculatorError.syntaxError("Invalid octal number: expected digits after 0o")
        }
        
        guard let value = Int(octalString, radix: 8) else {
            throw CalculatorError.syntaxError("Invalid octal number: '\(octalString)'")
        }
        
        tokens.append(Token(type: .number(Double(value)), position: startPosition))
    }
    
    private mutating func scanNumber(startPosition: Int) throws {
        var numberString = ""
        
        // Handle hex digits in Base-N HEX mode
        if currentBase == .hexadecimal {
            while let char = peek(), "0123456789ABCDEFabcdef".contains(char) {
                numberString.append(advance()!)
            }
            
            // Check for imaginary unit suffix
            if peek() == "i" && (peekNext() == nil || !peekNext()!.isLetter) {
                if let value = Int(numberString, radix: 16) {
                    tokens.append(Token(type: .number(Double(value)), position: startPosition))
                    _ = advance() // consume 'i'
                    tokens.append(Token(type: .imaginaryUnit, position: position - 1))
                    return
                }
            }
            
            guard let value = Int(numberString, radix: 16) else {
                throw CalculatorError.syntaxError("Malformed hexadecimal number: '\(numberString)'")
            }
            
            tokens.append(Token(type: .number(Double(value)), position: startPosition))
            return
        }
        
        // Integer part
        while let char = peek(), char.isNumber {
            numberString.append(advance()!)
        }
        
        // Decimal part
        if peek() == "." {
            numberString.append(advance()!)
            
            if let nextChar = peek(), nextChar.isNumber {
                while let char = peek(), char.isNumber {
                    numberString.append(advance()!)
                }
            } else if numberString == "." {
                throw CalculatorError.syntaxError("Malformed number: decimal point must be followed by digits")
            }
        }
        
        // Scientific notation
        if let char = peek(), char == "e" || char == "E" {
            let savedIndex = currentIndex
            let savedPosition = position
            var expString = String(advance()!)
            
            if let sign = peek(), sign == "+" || sign == "-" || sign == "−" {
                expString.append(advance()!)
            }
            
            if let digit = peek(), digit.isNumber {
                while let d = peek(), d.isNumber {
                    expString.append(advance()!)
                }
                numberString.append(contentsOf: expString.replacingOccurrences(of: "−", with: "-"))
            } else {
                // Not scientific notation, restore position
                currentIndex = savedIndex
                position = savedPosition
            }
        }
        
        // Check for imaginary unit suffix
        if peek() == "i" && (peekNext() == nil || !peekNext()!.isLetter) {
            guard let value = Double(numberString) else {
                throw CalculatorError.syntaxError("Malformed number: '\(numberString)'")
            }
            
            tokens.append(Token(type: .number(value), position: startPosition))
            _ = advance() // consume 'i'
            tokens.append(Token(type: .imaginaryUnit, position: position - 1))
            return
        }
        
        guard let value = Double(numberString) else {
            throw CalculatorError.syntaxError("Malformed number: '\(numberString)'")
        }
        
        tokens.append(Token(type: .number(value), position: startPosition))
    }
    
    // MARK: - Identifier Scanning
    
    private mutating func scanIdentifier(startPosition: Int) throws {
        // Handle π constant
        if peek() == "π" {
            _ = advance()
            tokens.append(Token(type: .constant(.pi), position: startPosition))
            return
        }
        
        var identifier = ""
        while let char = peek(), char.isLetter || char.isNumber || char == "_" {
            identifier.append(advance()!)
        }
        
        let lowercased = identifier.lowercased()
        
        // Check for imaginary unit 'i' (standalone)
        if lowercased == "i" {
            tokens.append(Token(type: .imaginaryUnit, position: startPosition))
            return
        }
        
        // Check for matrix references (MatA, MatB, MatC, MatD)
        if lowercased.hasPrefix("mat") && identifier.count == 4 {
            if let lastChar = identifier.last?.uppercased().first {
                switch lastChar {
                case "A":
                    tokens.append(Token(type: .matrixRef(.matA), position: startPosition))
                    return
                case "B":
                    tokens.append(Token(type: .matrixRef(.matB), position: startPosition))
                    return
                case "C":
                    tokens.append(Token(type: .matrixRef(.matC), position: startPosition))
                    return
                case "D":
                    tokens.append(Token(type: .matrixRef(.matD), position: startPosition))
                    return
                default:
                    break
                }
            }
        }
        
        // Check for vector references (VctA, VctB, VctC, VctD or VecA, VecB, etc.)
        if (lowercased.hasPrefix("vct") || lowercased.hasPrefix("vec")) && identifier.count == 4 {
            if let vctRef = VectorRef.fromAlternative(identifier) {
                tokens.append(Token(type: .vectorRef(vctRef), position: startPosition))
                return
            }
        }
        
        // Check for nPr and nCr patterns (P or C between numbers)
        if identifier.uppercased() == "P" && isPermutationCombinationContext() {
            tokens.append(Token(type: .binaryOperator(.permutation), position: startPosition))
            return
        }
        
        if identifier.uppercased() == "C" && isPermutationCombinationContext() {
            tokens.append(Token(type: .binaryOperator(.combination), position: startPosition))
            return
        }
        
        // Check for modulo operator
        if lowercased == "mod" {
            tokens.append(Token(type: .binaryOperator(.modulo), position: startPosition))
            return
        }
        
        // Check for Phase 3 tokens (bitwise, complex, matrix, vector, base indicators)
        if let phase3Token = matchPhase3Token(lowercased, startPosition: startPosition) {
            tokens.append(phase3Token)
            return
        }
        
        // Check for Phase 2 functions (case-insensitive)
        if let functionToken = matchPhase2Function(lowercased, startPosition: startPosition) {
            tokens.append(functionToken)
            return
        }
        
        // Check for existing functions
        if let function = MathFunction(rawValue: lowercased) {
            tokens.append(Token(type: .function(function), position: startPosition))
            return
        }
        
        // Check for mathematical constants
        if lowercased == "pi" {
            tokens.append(Token(type: .constant(.pi), position: startPosition))
            return
        }
        
        if lowercased == "e" && identifier.count == 1 {
            tokens.append(Token(type: .constant(.e), position: startPosition))
            return
        }
        
        // Check for scientific constants
        if let scientificConstant = matchScientificConstant(lowercased) {
            tokens.append(Token(type: .scientificConstant(scientificConstant), position: startPosition))
            return
        }
        
        // Check for variables
        if lowercased == "ans" {
            tokens.append(Token(type: .variable("Ans"), position: startPosition))
            return
        }
        
        if lowercased == "preans" {
            tokens.append(Token(type: .variable("PreAns"), position: startPosition))
            return
        }
        
        if lowercased == "m" && identifier.count == 1 {
            tokens.append(Token(type: .variable("M"), position: startPosition))
            return
        }
        
        // Single letter variables A-F (but not 'i' which is imaginaryUnit)
        if identifier.count == 1, let first = identifier.uppercased().first,
           first >= "A" && first <= "F" && first != "I" {
            tokens.append(Token(type: .variable(String(first)), position: startPosition))
            return
        }
        
        throw CalculatorError.syntaxError("Unknown identifier: '\(identifier)'")
    }
    
    // MARK: - Phase 3 Token Matching
    
    private func matchPhase3Token(_ lowercased: String, startPosition: Int) -> Token? {
        switch lowercased {
        // Bitwise operators (as keywords)
        case "and":
            return Token(type: .binaryOperator(.bitwiseAnd), position: startPosition)
        case "or":
            return Token(type: .binaryOperator(.bitwiseOr), position: startPosition)
        case "xor":
            return Token(type: .binaryOperator(.bitwiseXor), position: startPosition)
        case "xnor":
            return Token(type: .binaryOperator(.bitwiseXnor), position: startPosition)
        case "not":
            return Token(type: .unaryOperator(.bitwiseNot), position: startPosition)
        case "neg":
            return Token(type: .unaryOperator(.bitwiseNeg), position: startPosition)
            
        // Complex functions
        case "conj":
            return Token(type: .unaryOperator(.conjugate), position: startPosition)
        case "re":
            return Token(type: .unaryOperator(.realPart), position: startPosition)
        case "im":
            return Token(type: .unaryOperator(.imagPart), position: startPosition)
        case "arg":
            return Token(type: .unaryOperator(.argument), position: startPosition)
            
        // Matrix functions
        case "det":
            return Token(type: .unaryOperator(.determinant), position: startPosition)
        case "trace", "tr":
            return Token(type: .function(.trace), position: startPosition)
        case "identity":
            return Token(type: .function(.identity), position: startPosition)
            
        // Vector functions
        case "dot":
            return Token(type: .binaryOperator(.dotProduct), position: startPosition)
        case "cross":
            return Token(type: .binaryOperator(.crossProduct), position: startPosition)
        case "norm", "normalize":
            return Token(type: .unaryOperator(.normalize), position: startPosition)
        case "mag", "magnitude":
            return Token(type: .unaryOperator(.vectorMagnitude), position: startPosition)
        case "angle":
            return Token(type: .function(.vectorAngle), position: startPosition)
        case "proj", "project":
            return Token(type: .function(.vectorProject), position: startPosition)
            
        // Base indicators
        case "bin":
            return Token(type: .baseIndicator(.binary), position: startPosition)
        case "oct":
            return Token(type: .baseIndicator(.octal), position: startPosition)
        case "dec":
            return Token(type: .baseIndicator(.decimal), position: startPosition)
        case "hex":
            return Token(type: .baseIndicator(.hexadecimal), position: startPosition)
            
        // Complex-specific math functions
        case "csqrt":
            return Token(type: .function(.complexSqrt), position: startPosition)
        case "cexp":
            return Token(type: .function(.complexExp), position: startPosition)
        case "cln":
            return Token(type: .function(.complexLn), position: startPosition)
        case "csin":
            return Token(type: .function(.complexSin), position: startPosition)
        case "ccos":
            return Token(type: .function(.complexCos), position: startPosition)
        case "ctan":
            return Token(type: .function(.complexTan), position: startPosition)
            
        default:
            return nil
        }
    }
    
    // MARK: - Phase 2 Function Matching
    
    private func matchPhase2Function(_ lowercased: String, startPosition: Int) -> Token? {
        switch lowercased {
        // Number functions
        case "int":
            return Token(type: .function(.intPart), position: startPosition)
        case "frac":
            return Token(type: .function(.fracPart), position: startPosition)
        case "floor":
            return Token(type: .function(.floor), position: startPosition)
        case "ceil":
            return Token(type: .function(.ceil), position: startPosition)
        case "round", "rnd":
            return Token(type: .function(.round), position: startPosition)
            
        // Random functions
        case "ran", "random":
            return Token(type: .function(.random), position: startPosition)
        case "ranint", "randomint":
            return Token(type: .function(.randomInt), position: startPosition)
            
        // Coordinate conversions
        case "pol":
            return Token(type: .function(.pol), position: startPosition)
        case "rec":
            return Token(type: .function(.rec), position: startPosition)
            
        // Number theory
        case "gcd":
            return Token(type: .function(.gcd), position: startPosition)
        case "lcm":
            return Token(type: .function(.lcm), position: startPosition)
            
        // Angle conversions
        case "degtorad":
            return Token(type: .function(.degToRad), position: startPosition)
        case "radtodeg":
            return Token(type: .function(.radToDeg), position: startPosition)
        case "degtograd":
            return Token(type: .function(.degToGrad), position: startPosition)
        case "gradtodeg":
            return Token(type: .function(.gradToDeg), position: startPosition)
        case "dmstodec", "dmstod":
            return Token(type: .function(.dmsToDecimal), position: startPosition)
        case "dectodms", "dtodms":
            return Token(type: .function(.decimalToDms), position: startPosition)
            
        // Power functions
        case "tenpow":
            return Token(type: .function(.tenPow), position: startPosition)
            
        default:
            return nil
        }
    }
    
    // MARK: - Scientific Constant Matching
    
    private func matchScientificConstant(_ lowercased: String) -> ScientificConstant? {
        for constant in ScientificConstant.allCases {
            if constant.rawValue.lowercased() == lowercased {
                return constant
            }
        }
        return nil
    }
    
    // MARK: - Permutation/Combination Context Check
    
    private func isPermutationCombinationContext() -> Bool {
        guard let lastToken = tokens.last else { return false }
        
        switch lastToken.type {
        case .number, .rightParen, .variable:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Operator and Punctuation Scanning
    
    private mutating func scanOperatorOrPunctuation(startPosition: Int) throws {
        guard let char = advance() else { return }
        
        switch char {
        case "(":
            tokens.append(Token(type: .leftParen, position: startPosition))
            
        case ")":
            tokens.append(Token(type: .rightParen, position: startPosition))
            
        case "[":
            tokens.append(Token(type: .leftBracket, position: startPosition))
            
        case "]":
            tokens.append(Token(type: .rightBracket, position: startPosition))
            
        case ",":
            tokens.append(Token(type: .comma, position: startPosition))
            
        case ";":
            tokens.append(Token(type: .semicolon, position: startPosition))
            
        case "+":
            tokens.append(Token(type: .binaryOperator(.add), position: startPosition))
            
        case "-", "−":
            if isUnaryMinusContext() {
                tokens.append(Token(type: .unaryOperator(.negate), position: startPosition))
            } else {
                tokens.append(Token(type: .binaryOperator(.subtract), position: startPosition))
            }
            
        case "*", "×":
            // Check for cross product notation (when in vector context)
            tokens.append(Token(type: .binaryOperator(.multiply), position: startPosition))
            
        case "/", "÷":
            tokens.append(Token(type: .binaryOperator(.divide), position: startPosition))
            
        case "^":
            // Check for ^-1, ^2, ^3 postfix operators
            if let next = peek() {
                if next == "-" || next == "−" {
                    if peekNext() == "1" {
                        _ = advance() // consume -
                        _ = advance() // consume 1
                        tokens.append(Token(type: .unaryOperator(.reciprocal), position: startPosition))
                        return
                    }
                }
                if next == "2" && !(peekNext()?.isNumber ?? false) {
                    _ = advance() // consume 2
                    tokens.append(Token(type: .unaryOperator(.square), position: startPosition))
                    return
                }
                if next == "3" && !(peekNext()?.isNumber ?? false) {
                    _ = advance() // consume 3
                    tokens.append(Token(type: .unaryOperator(.cube), position: startPosition))
                    return
                }
            }
            tokens.append(Token(type: .binaryOperator(.power), position: startPosition))
            
        case "!":
            tokens.append(Token(type: .unaryOperator(.factorial), position: startPosition))
            
        case "%":
            tokens.append(Token(type: .unaryOperator(.percent), position: startPosition))
            
        case "√":
            // Check if previous token is a number (for nth root: n√x)
            if let lastToken = tokens.last, case .number = lastToken.type {
                tokens.append(Token(type: .binaryOperator(.nthRoot), position: startPosition))
            } else {
                tokens.append(Token(type: .function(.sqrt), position: startPosition))
            }
            
        case "²":
            tokens.append(Token(type: .unaryOperator(.square), position: startPosition))
            
        case "³":
            tokens.append(Token(type: .unaryOperator(.cube), position: startPosition))
            
        case "⁻":
            // Check for ⁻¹ (reciprocal)
            if peek() == "¹" {
                _ = advance()
                tokens.append(Token(type: .unaryOperator(.reciprocal), position: startPosition))
            } else {
                throw CalculatorError.syntaxError("Invalid superscript sequence")
            }
            
        case "¹":
            throw CalculatorError.syntaxError("Unexpected character: '¹'")
            
        // Phase 3: Shift operators
        case "<":
            if peek() == "<" {
                _ = advance()
                tokens.append(Token(type: .binaryOperator(.leftShift), position: startPosition))
            } else {
                throw CalculatorError.syntaxError("Unexpected '<'. Did you mean '<<' (left shift)?")
            }
            
        case ">":
            if peek() == ">" {
                _ = advance()
                tokens.append(Token(type: .binaryOperator(.rightShift), position: startPosition))
            } else {
                throw CalculatorError.syntaxError("Unexpected '>'. Did you mean '>>' (right shift)?")
            }
            
        // Phase 3: Middle dot for dot product
        case "·", "•":
            tokens.append(Token(type: .binaryOperator(.dotProduct), position: startPosition))
            
        // Phase 3: Superscript T for transpose
        case "ᵀ":
            tokens.append(Token(type: .unaryOperator(.transpose), position: startPosition))
            
        // Phase 3: Double vertical bar for vector magnitude
        case "‖":
            // Check if it's closing ‖...‖
            if let lastToken = tokens.last, case .unaryOperator(.vectorMagnitude) = lastToken.type {
                // This is a closing ‖, which is handled by parser
                tokens.append(Token(type: .unaryOperator(.vectorMagnitude), position: startPosition))
            } else {
                // Opening ‖
                tokens.append(Token(type: .unaryOperator(.vectorMagnitude), position: startPosition))
            }
            
        // Phase 3: Bitwise operators as symbols
        case "&":
            tokens.append(Token(type: .binaryOperator(.bitwiseAnd), position: startPosition))
            
        case "|":
            tokens.append(Token(type: .binaryOperator(.bitwiseOr), position: startPosition))
            
        case "~":
            tokens.append(Token(type: .unaryOperator(.bitwiseNot), position: startPosition))
            
        default:
            throw CalculatorError.syntaxError("Unknown character: '\(char)'")
        }
    }
    
    // MARK: - Unary Minus Detection
    
    private func isUnaryMinusContext() -> Bool {
        guard let lastToken = tokens.last else {
            return true
        }
        
        switch lastToken.type {
        case .leftParen, .leftBracket:
            return true
        case .comma, .semicolon:
            return true
        case .binaryOperator:
            return true
        case .unaryOperator(let op) where op == .negate:
            return true
        case .function:
            return true
        default:
            return false
        }
    }
}
