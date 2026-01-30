import Foundation

// MARK: - Parser

/// Parses a token array into an Abstract Syntax Tree using the Shunting Yard algorithm.
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
            
        case .variable(let name):
            advance()
            return .variable(name)
            
        case .function(let function):
            advance()
            let argument = try parseFunctionArgument()
            return .function(function, argument)
            
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
            
        case .binaryOperator, .rightParen:
            throw CalculatorError.syntaxError("Unexpected token: \(token.type)")
            
        case .end:
            throw CalculatorError.syntaxError("Unexpected end of input")
        }
    }
    
    // MARK: - Function Arguments
    
    /// Parses the argument for a function call.
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
    
    /// Parses postfix operators (factorial) applied to an operand.
    private mutating func parsePostfixOperators(_ operand: ASTNode) throws -> ASTNode {
        var result = operand
        
        while case .unaryOperator(let op) = currentToken.type {
            if op == .factorial {
                advance()
                result = .unaryOp(.factorial, result)
            } else {
                break
            }
        }
        
        return result
    }
}
