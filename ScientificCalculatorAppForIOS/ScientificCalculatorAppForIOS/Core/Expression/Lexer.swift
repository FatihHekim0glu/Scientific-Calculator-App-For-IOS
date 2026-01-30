import Foundation

// MARK: - Lexer

/// Tokenizes mathematical expression strings into Token arrays
struct Lexer {
    private let input: String
    private var position: Int
    private var currentIndex: String.Index
    private var tokens: [Token]
    
    init(input: String) {
        self.input = input
        self.position = 0
        self.currentIndex = input.startIndex
        self.tokens = []
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
        
        if char.isNumber || (char == "." && peekNext()?.isNumber == true) {
            try scanNumber(startPosition: startPosition)
        } else if char.isLetter || char == "π" {
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
    
    private mutating func scanNumber(startPosition: Int) throws {
        var numberString = ""
        
        // Integer part
        while let char = peek(), char.isNumber {
            numberString.append(advance()!)
        }
        
        // Decimal part
        if peek() == "." {
            numberString.append(advance()!)
            
            guard let nextChar = peek(), nextChar.isNumber else {
                throw CalculatorError.syntaxError("Malformed number: decimal point must be followed by digits")
            }
            
            while let char = peek(), char.isNumber {
                numberString.append(advance()!)
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
        
        // Single letter variables A-F
        if identifier.count == 1, let first = identifier.uppercased().first,
           first >= "A" && first <= "F" {
            tokens.append(Token(type: .variable(String(first)), position: startPosition))
            return
        }
        
        throw CalculatorError.syntaxError("Unknown identifier: '\(identifier)'")
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
        // Check if previous token is a number (for nPr or nCr pattern)
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
            
        case ",":
            tokens.append(Token(type: .comma, position: startPosition))
            
        case "+":
            tokens.append(Token(type: .binaryOperator(.add), position: startPosition))
            
        case "-", "−":
            if isUnaryMinusContext() {
                tokens.append(Token(type: .unaryOperator(.negate), position: startPosition))
            } else {
                tokens.append(Token(type: .binaryOperator(.subtract), position: startPosition))
            }
            
        case "*", "×":
            tokens.append(Token(type: .binaryOperator(.multiply), position: startPosition))
            
        case "/", "÷":
            tokens.append(Token(type: .binaryOperator(.divide), position: startPosition))
            
        case "^":
            // Check for ^-1, ^2, ^3 postfix operators
            if let next = peek() {
                if next == "-" || next == "−" {
                    // Check for ^-1 (reciprocal)
                    if peekNext() == "1" {
                        _ = advance() // consume -
                        _ = advance() // consume 1
                        tokens.append(Token(type: .unaryOperator(.reciprocal), position: startPosition))
                        return
                    }
                }
                if next == "2" && !peekNext()?.isNumber ?? true {
                    _ = advance() // consume 2
                    tokens.append(Token(type: .unaryOperator(.square), position: startPosition))
                    return
                }
                if next == "3" && !peekNext()?.isNumber ?? true {
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
            // Standalone ¹ after ⁻ is handled above, standalone is error
            throw CalculatorError.syntaxError("Unexpected character: '¹'")
            
        default:
            throw CalculatorError.syntaxError("Unknown character: '\(char)'")
        }
    }
    
    // MARK: - Unary Minus Detection
    
    /// Returns true if the current position indicates a unary minus context
    private func isUnaryMinusContext() -> Bool {
        guard let lastToken = tokens.last else {
            // Start of expression
            return true
        }
        
        switch lastToken.type {
        case .leftParen:
            return true
        case .comma:
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
