import Foundation

// MARK: - Parsing Context

/// Current parsing context for context-aware parsing
enum ParsingContext {
    case standard
    case complex
    case matrix
    case vector
    case baseN
}

// MARK: - Parser

/// Parses a token array into an Abstract Syntax Tree using precedence climbing.
struct Parser {
    private var tokens: [Token]
    private var position: Int
    private var context: ParsingContext
    
    init(tokens: [Token], context: ParsingContext = .standard) {
        self.tokens = tokens
        self.position = 0
        self.context = context
    }
    
    // MARK: - Public Interface
    
    /// Parses the tokens into an AST.
    mutating func parse() throws -> ASTNode {
        guard !tokens.isEmpty else {
            throw CalculatorError.syntaxError("Empty input")
        }
        
        let result = try parseExpression(minPrecedence: 0)
        
        if currentToken.type != .end {
            throw CalculatorError.syntaxError("Unexpected token after expression")
        }
        
        return result
    }
    
    /// Parses with a specific context.
    mutating func parse(in parsingContext: ParsingContext) throws -> ASTNode {
        self.context = parsingContext
        return try parse()
    }
    
    // MARK: - Token Access
    
    private var currentToken: Token {
        guard position < tokens.count else {
            return Token(type: .end, position: position)
        }
        return tokens[position]
    }
    
    private func peek(ahead offset: Int = 0) -> Token? {
        let index = position + offset
        guard index < tokens.count else { return nil }
        return tokens[index]
    }
    
    private mutating func advance() {
        if position < tokens.count {
            position += 1
        }
    }
    
    private mutating func expect(_ expectedType: TokenType) throws {
        guard currentToken.type == expectedType else {
            throw CalculatorError.syntaxError("Expected \(expectedType), got \(currentToken.type)")
        }
        advance()
    }
    
    private mutating func consumeIfMatch(_ type: TokenType) -> Bool {
        if currentToken.type == type {
            advance()
            return true
        }
        return false
    }
    
    private func match(_ type: TokenType) -> Bool {
        return currentToken.type == type
    }
    
    // MARK: - Precedence Climbing Parser
    
    /// Parses an expression with the given minimum precedence.
    private mutating func parseExpression(minPrecedence: Int) throws -> ASTNode {
        var left = try parsePrimary()
        
        while true {
            left = try parsePostfixOperators(left)
            left = try parseImplicitMultiplication(left)
            
            guard case .binaryOperator(let op) = currentToken.type else {
                break
            }
            
            let precedence = op.precedence
            if precedence < minPrecedence {
                break
            }
            
            advance()
            
            let nextMinPrecedence = op.isRightAssociative ? precedence : precedence + 1
            let right = try parseExpression(minPrecedence: nextMinPrecedence)
            
            left = resolveBinaryOperator(op, left: left, right: right)
        }
        
        return left
    }
    
    // MARK: - Binary Operator Resolution
    
    /// Resolves binary operators based on operand types for context-aware parsing.
    private func resolveBinaryOperator(_ op: BinaryOperator, left: ASTNode, right: ASTNode) -> ASTNode {
        let resolvedOp = op
        
        // Context-aware operator resolution
        if op == .multiply {
            // In vector context or when both operands are vectors, × could be cross product
            if (context == .vector || (left.isVectorExpression && right.isVectorExpression)) {
                // Keep as multiply for scalars, but evaluator will handle vector multiplication
            }
        }
        
        return .binaryOp(resolvedOp, left, right)
    }
    
    // MARK: - Primary Expressions
    
    /// Parses a primary expression.
    private mutating func parsePrimary() throws -> ASTNode {
        let token = currentToken
        
        switch token.type {
        case .number(let value):
            advance()
            return .number(value)
            
        case .constant(let constant):
            advance()
            return .constant(constant)
            
        case .scientificConstant(let constant):
            advance()
            return .scientificConstant(constant)
            
        case .variable(let name):
            advance()
            return .variable(name)
            
        case .function(let function):
            advance()
            return try parseFunctionCall(function)
            
        case .leftParen:
            return try parseParenthesizedOrVector()
            
        case .leftBracket:
            return try parseMatrixLiteral()
            
        case .unaryOperator(let op):
            return try parseUnaryOperator(op)
            
        // Phase 3: Imaginary unit
        case .imaginaryUnit:
            advance()
            return .imaginaryUnit
            
        // Phase 3: Matrix references
        case .matrixRef(let ref):
            advance()
            return .matrixRef(ref)
            
        // Phase 3: Vector references
        case .vectorRef(let ref):
            advance()
            return .vectorRef(ref)
            
        // Phase 3: Base indicator (sets context for following expression)
        case .baseIndicator(let base):
            advance()
            return try parseBaseNExpression(base)
            
        // Phase 4: Statistical variables
        case .statVariable(let statVar):
            advance()
            return .statVariable(statVar)
            
        // Phase 4: Statistical functions
        case .statFunction(let statFunc):
            advance()
            return try parseStatFunctionCall(statFunc)
            
        // Phase 6: Calculus operators
        case .calculusOperator(let calcOp):
            advance()
            return try parseCalculusExpression(calcOp)
            
        case .binaryOperator, .rightParen, .rightBracket, .comma, .semicolon:
            throw CalculatorError.syntaxError("Unexpected token: \(token.type)")
            
        case .end:
            throw CalculatorError.syntaxError("Unexpected end of input")
        }
    }
    
    // MARK: - Unary Operator Parsing
    
    /// Parses a unary operator expression.
    private mutating func parseUnaryOperator(_ op: UnaryOperator) throws -> ASTNode {
        advance()
        
        switch op {
        case .negate:
            let operand = try parsePrimary()
            return .unaryOp(.negate, operand)
            
        // Phase 3: Prefix unary operators that expect parenthesized argument
        case .bitwiseNot, .bitwiseNeg,
             .conjugate, .realPart, .imagPart, .argument,
             .determinant, .normalize:
            let argument = try parseFunctionArgument()
            return .unaryOp(op, argument)
            
        default:
            throw CalculatorError.syntaxError("Unexpected unary operator: \(op)")
        }
    }
    
    // MARK: - Phase 3: Parenthesized Expression or Vector Literal
    
    /// Parses a parenthesized expression or vector literal.
    private mutating func parseParenthesizedOrVector() throws -> ASTNode {
        guard consumeIfMatch(.leftParen) else {
            throw CalculatorError.syntaxError("Expected '('")
        }
        
        // Check for empty parentheses
        if match(.rightParen) {
            throw CalculatorError.syntaxError("Empty parentheses")
        }
        
        let first = try parseExpression(minPrecedence: 0)
        
        // Check for comma - indicates vector literal
        if consumeIfMatch(.comma) {
            var components = [first]
            
            repeat {
                let component = try parseExpression(minPrecedence: 0)
                components.append(component)
            } while consumeIfMatch(.comma)
            
            guard consumeIfMatch(.rightParen) else {
                throw CalculatorError.syntaxError("Expected ')' after vector components")
            }
            
            // Validate vector dimension (2D or 3D)
            if components.count < 2 || components.count > 3 {
                throw CalculatorError.syntaxError("Vector must have 2 or 3 components")
            }
            
            return .vectorLiteral(components)
        }
        
        // Regular parenthesized expression
        guard consumeIfMatch(.rightParen) else {
            throw CalculatorError.syntaxError("Expected ')'")
        }
        
        return first
    }
    
    // MARK: - Phase 3: Matrix Literal Parsing
    
    /// Parses a matrix literal [[a, b], [c, d]] or [[a, b; c, d]].
    private mutating func parseMatrixLiteral() throws -> ASTNode {
        guard consumeIfMatch(.leftBracket) else {
            throw CalculatorError.syntaxError("Expected '[' for matrix literal")
        }
        
        var rows: [[ASTNode]] = []
        
        // Check if using nested brackets [[a,b],[c,d]] or semicolon format [a,b;c,d]
        if match(.leftBracket) {
            // Nested bracket format
            rows = try parseNestedBracketMatrix()
        } else {
            // Semicolon format or single row
            rows = try parseSemicolonMatrix()
        }
        
        guard consumeIfMatch(.rightBracket) else {
            throw CalculatorError.syntaxError("Expected ']' after matrix literal")
        }
        
        // Validate matrix dimensions
        guard !rows.isEmpty else {
            throw CalculatorError.syntaxError("Matrix cannot be empty")
        }
        
        let colCount = rows[0].count
        guard colCount > 0 else {
            throw CalculatorError.syntaxError("Matrix rows cannot be empty")
        }
        
        for row in rows {
            if row.count != colCount {
                throw CalculatorError.syntaxError("All matrix rows must have the same number of columns")
            }
        }
        
        // Validate maximum dimensions
        if rows.count > 4 || colCount > 4 {
            throw CalculatorError.syntaxError("Matrix dimensions cannot exceed 4×4")
        }
        
        return .matrixLiteral(rows)
    }
    
    /// Parses nested bracket matrix format: [[a,b],[c,d]].
    private mutating func parseNestedBracketMatrix() throws -> [[ASTNode]] {
        var rows: [[ASTNode]] = []
        
        repeat {
            guard consumeIfMatch(.leftBracket) else {
                throw CalculatorError.syntaxError("Expected '[' for matrix row")
            }
            
            var row: [ASTNode] = []
            
            repeat {
                let element = try parseExpression(minPrecedence: 0)
                row.append(element)
            } while consumeIfMatch(.comma)
            
            guard consumeIfMatch(.rightBracket) else {
                throw CalculatorError.syntaxError("Expected ']' after matrix row")
            }
            
            rows.append(row)
            
        } while consumeIfMatch(.comma)
        
        return rows
    }
    
    /// Parses semicolon-separated matrix format: [a,b;c,d].
    private mutating func parseSemicolonMatrix() throws -> [[ASTNode]] {
        var rows: [[ASTNode]] = []
        
        repeat {
            var row: [ASTNode] = []
            
            repeat {
                let element = try parseExpression(minPrecedence: 0)
                row.append(element)
            } while consumeIfMatch(.comma)
            
            rows.append(row)
            
        } while consumeIfMatch(.semicolon)
        
        return rows
    }
    
    // MARK: - Phase 3: Base-N Expression Parsing
    
    /// Parses an expression in Base-N context.
    private mutating func parseBaseNExpression(_ base: NumberBase) throws -> ASTNode {
        // The base indicator sets context; following number is in that base
        guard case .number(let value) = currentToken.type else {
            throw CalculatorError.syntaxError("Expected number after base indicator \(base.name)")
        }
        
        advance()
        
        // Convert the value to Int32 for Base-N
        guard value >= Double(Int32.min) && value <= Double(Int32.max) else {
            throw CalculatorError.rangeError("Number out of 32-bit range for Base-N mode")
        }
        
        return .baseNNumber(value: Int32(value), base: base)
    }
    
    // MARK: - Function Parsing
    
    /// Parses a function call based on the function's argument count.
    private mutating func parseFunctionCall(_ function: MathFunction) throws -> ASTNode {
        if function.isZeroArgument {
            return try parseZeroArgFunction(function)
        } else if function.isTwoArgument {
            return try parseTwoArgFunction(function)
        } else {
            return try parseSingleArgFunction(function)
        }
    }
    
    /// Parses a zero-argument function call (e.g., random).
    private mutating func parseZeroArgFunction(_ function: MathFunction) throws -> ASTNode {
        if currentToken.type == .leftParen {
            advance()
            if currentToken.type != .rightParen {
                throw CalculatorError.syntaxError("\(function) takes no arguments")
            }
            advance()
        }
        return .function0(function)
    }
    
    /// Parses a single-argument function call.
    private mutating func parseSingleArgFunction(_ function: MathFunction) throws -> ASTNode {
        let argument = try parseFunctionArgument()
        return .function(function, argument)
    }
    
    /// Parses a two-argument function call (e.g., gcd, lcm, pol, rec, randomInt, vectorAngle, vectorProject).
    private mutating func parseTwoArgFunction(_ function: MathFunction) throws -> ASTNode {
        guard consumeIfMatch(.leftParen) else {
            throw CalculatorError.syntaxError("Expected '(' after \(function)")
        }
        
        let arg1 = try parseExpression(minPrecedence: 0)
        
        guard consumeIfMatch(.comma) else {
            throw CalculatorError.syntaxError("Expected ',' between arguments in \(function)")
        }
        
        let arg2 = try parseExpression(minPrecedence: 0)
        
        guard consumeIfMatch(.rightParen) else {
            throw CalculatorError.syntaxError("Expected ')' after arguments in \(function)")
        }
        
        return .function2(function, arg1, arg2)
    }
    
    // MARK: - Function Arguments
    
    /// Parses the argument for a single-argument function call.
    private mutating func parseFunctionArgument() throws -> ASTNode {
        if currentToken.type == .leftParen {
            advance()
            let argument = try parseExpression(minPrecedence: 0)
            try expect(.rightParen)
            return argument
        }
        
        return try parsePrimary()
    }
    
    // MARK: - Postfix Operators
    
    /// Parses postfix operators applied to an operand.
    private mutating func parsePostfixOperators(_ operand: ASTNode) throws -> ASTNode {
        var result = operand
        
        while case .unaryOperator(let op) = currentToken.type {
            switch op {
            // Basic postfix operators
            case .factorial, .percent, .square, .cube, .reciprocal:
                advance()
                result = .unaryOp(op, result)
                
            // Phase 3: Matrix postfix operators
            case .transpose:
                advance()
                result = .unaryOp(.transpose, result)
                
            case .matrixInverse:
                advance()
                result = .unaryOp(.matrixInverse, result)
                
            // Phase 3: Vector magnitude (if using postfix notation)
            case .vectorMagnitude:
                advance()
                result = .unaryOp(.vectorMagnitude, result)
                
            default:
                return result
            }
        }
        
        return result
    }
    
    // MARK: - Phase 3: Implicit Multiplication
    
    /// Handles implicit multiplication cases, particularly with imaginary unit.
    private mutating func parseImplicitMultiplication(_ node: ASTNode) throws -> ASTNode {
        var result = node
        
        // Check for implicit multiplication with imaginary unit
        // e.g., "3i" should be parsed as 3 × i
        if case .imaginaryUnit = currentToken.type {
            // Only apply implicit multiplication for numbers and certain expressions
            if canHaveImplicitMultiplication(result) {
                advance()
                result = .binaryOp(.multiply, result, .imaginaryUnit)
            }
        }
        
        // Check for implicit multiplication with parentheses
        // e.g., "2(3)" should be parsed as 2 × 3
        if case .leftParen = currentToken.type {
            if canHaveImplicitMultiplication(result) {
                let right = try parseParenthesizedOrVector()
                result = .binaryOp(.multiply, result, right)
                result = try parseImplicitMultiplication(result)
            }
        }
        
        // Check for implicit multiplication with matrix/vector refs
        // e.g., "2MatA" should be 2 × MatA
        if case .matrixRef(let ref) = currentToken.type {
            if canHaveImplicitMultiplication(result) {
                advance()
                result = .binaryOp(.multiply, result, .matrixRef(ref))
            }
        }
        
        if case .vectorRef(let ref) = currentToken.type {
            if canHaveImplicitMultiplication(result) {
                advance()
                result = .binaryOp(.multiply, result, .vectorRef(ref))
            }
        }
        
        return result
    }
    
    /// Determines if a node can have implicit multiplication applied after it.
    private func canHaveImplicitMultiplication(_ node: ASTNode) -> Bool {
        switch node {
        case .number, .constant, .scientificConstant, .variable:
            return true
        case .unaryOp(let op, _):
            // After postfix operators like factorial, square, etc.
            switch op {
            case .factorial, .percent, .square, .cube, .reciprocal:
                return true
            default:
                return false
            }
        case .imaginaryUnit:
            // Allow chaining like "2ii" = 2 × i × i
            return true
        default:
            return false
        }
    }
    
    // MARK: - Phase 4: Statistical Function Parsing
    
    /// Parses a statistical function call with its arguments.
    private mutating func parseStatFunctionCall(_ statFunc: StatFunction) throws -> ASTNode {
        // Convert StatFunction to corresponding MathFunction
        let mathFunc: MathFunction
        switch statFunc {
        case .mean: mathFunc = .mean
        case .sum: mathFunc = .sum
        case .stdDev: mathFunc = .sampleStdDev
        case .variance: mathFunc = .variance
        case .min: mathFunc = .minimum
        case .max: mathFunc = .maximum
        case .median: mathFunc = .median
        case .count: mathFunc = .count
        case .range: mathFunc = .sampleStdDev  // range uses similar calculation
        }
        
        // Parse arguments in parentheses
        guard consumeIfMatch(.leftParen) else {
            throw CalculatorError.syntaxError("Expected '(' after \(statFunc.rawValue)")
        }
        
        var arguments: [ASTNode] = []
        
        if !match(.rightParen) {
            repeat {
                let arg = try parseExpression(minPrecedence: 0)
                arguments.append(arg)
            } while consumeIfMatch(.comma)
        }
        
        guard consumeIfMatch(.rightParen) else {
            throw CalculatorError.syntaxError("Expected ')' after function arguments")
        }
        
        guard arguments.count >= statFunc.minArguments else {
            throw CalculatorError.invalidInput("\(statFunc.rawValue) requires at least \(statFunc.minArguments) arguments")
        }
        
        return .functionN(mathFunc, arguments)
    }
    
    // MARK: - Phase 6: Calculus Expression Parsing
    
    /// Parses a calculus operator expression.
    private mutating func parseCalculusExpression(_ calcOp: CalcOperator) throws -> ASTNode {
        // Convert CalcOperator to corresponding MathFunction
        let mathFunc: MathFunction
        switch calcOp {
        case .integral: mathFunc = .integrate
        case .derivative: mathFunc = .differentiate
        case .sigma: mathFunc = .summation
        case .pi: mathFunc = .product
        }
        
        // Parse arguments in parentheses
        guard consumeIfMatch(.leftParen) else {
            throw CalculatorError.syntaxError("Expected '(' after \(calcOp.displaySymbol)")
        }
        
        var arguments: [ASTNode] = []
        
        if !match(.rightParen) {
            repeat {
                let arg = try parseExpression(minPrecedence: 0)
                arguments.append(arg)
            } while consumeIfMatch(.comma)
        }
        
        guard consumeIfMatch(.rightParen) else {
            throw CalculatorError.syntaxError("Expected ')' after calculus operator arguments")
        }
        
        return .functionN(mathFunc, arguments)
    }
}

// MARK: - Parser Factory Methods

extension Parser {
    /// Creates a parser for complex mode expressions.
    static func forComplexMode(tokens: [Token]) -> Parser {
        return Parser(tokens: tokens, context: .complex)
    }
    
    /// Creates a parser for matrix mode expressions.
    static func forMatrixMode(tokens: [Token]) -> Parser {
        return Parser(tokens: tokens, context: .matrix)
    }
    
    /// Creates a parser for vector mode expressions.
    static func forVectorMode(tokens: [Token]) -> Parser {
        return Parser(tokens: tokens, context: .vector)
    }
    
    /// Creates a parser for Base-N mode expressions.
    static func forBaseNMode(tokens: [Token]) -> Parser {
        return Parser(tokens: tokens, context: .baseN)
    }
}
