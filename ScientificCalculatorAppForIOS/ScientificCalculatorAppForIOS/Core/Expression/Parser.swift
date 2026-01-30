import Foundation

// MARK: - Parser

/// Parses a token array into an Abstract Syntax Tree using precedence climbing.
struct Parser {
    private var tokens: [Token]
    private var position: Int
    
    init(tokens: [Token]) {
        self.tokens = tokens
        self.position = 0
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
    
    // MARK: - Precedence Climbing Parser
    
    /// Parses an expression with the given minimum precedence.
    private mutating func parseExpression(minPrecedence: Int) throws -> ASTNode {
        var left = try parsePrimary()
        
        while true {
            left = try parsePostfixOperators(left)
            
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
            
            left = .binaryOp(op, left, right)
        }
        
        return left
    }
    
    // MARK: - Primary Expressions
    
    /// Parses a primary expression (numbers, constants, variables, functions, parentheses, unary operators).
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
            advance()
            let expression = try parseExpression(minPrecedence: 0)
            try expect(.rightParen)
            return expression
            
        case .unaryOperator(let op):
            if op == .negate {
                advance()
                let operand = try parsePrimary()
                return .unaryOp(.negate, operand)
            } else {
                throw CalculatorError.syntaxError("Unexpected unary operator: \(op)")
            }
            
        case .binaryOperator, .rightParen, .comma:
            throw CalculatorError.syntaxError("Unexpected token: \(token.type)")
            
        case .end:
            throw CalculatorError.syntaxError("Unexpected end of input")
        }
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
    
    /// Parses a two-argument function call (e.g., gcd, lcm, pol, rec, randomInt).
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
    /// Handles: factorial (!), percent (%), square (²), cube (³), reciprocal (⁻¹)
    private mutating func parsePostfixOperators(_ operand: ASTNode) throws -> ASTNode {
        var result = operand
        
        while case .unaryOperator(let op) = currentToken.type {
            switch op {
            case .factorial, .percent, .square, .cube, .reciprocal:
                advance()
                result = .unaryOp(op, result)
            default:
                return result
            }
        }
        
        return result
    }
}
