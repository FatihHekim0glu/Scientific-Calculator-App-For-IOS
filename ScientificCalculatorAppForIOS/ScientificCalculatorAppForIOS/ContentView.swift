import SwiftUI

struct ContentView: View {
    @State private var display: String = "0"
    @State private var currentInput: String = ""
    @State private var previousResult: Double = 0
    @State private var angleMode: AngleMode = .degrees
    @State private var showingScientific: Bool = true
    
    private let buttons: [[CalculatorButton]] = [
        [.clear, .plusMinus, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equals]
    ]
    
    private let scientificButtons: [[CalculatorButton]] = [
        [.sin, .cos, .tan, .pi],
        [.ln, .log, .sqrt, .power],
        [.leftParen, .rightParen, .factorial, .exp]
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                Spacer()
                
                // Display
                VStack(alignment: .trailing, spacing: 4) {
                    if !currentInput.isEmpty {
                        Text(currentInput)
                            .font(.system(size: 24, weight: .light, design: .monospaced))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    
                    Text(display)
                        .font(.system(size: 56, weight: .light, design: .monospaced))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                // Mode indicator
                HStack {
                    Text(angleMode.rawValue.uppercased())
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Button(action: { showingScientific.toggle() }) {
                        Image(systemName: showingScientific ? "function" : "number")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 24)
                
                // Scientific buttons
                if showingScientific {
                    VStack(spacing: 10) {
                        ForEach(scientificButtons, id: \.self) { row in
                            HStack(spacing: 10) {
                                ForEach(row, id: \.self) { button in
                                    CalculatorButtonView(button: button) {
                                        buttonTapped(button)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
                
                // Main buttons
                VStack(spacing: 10) {
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(row, id: \.self) { button in
                                CalculatorButtonView(
                                    button: button,
                                    isWide: button == .zero
                                ) {
                                    buttonTapped(button)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 20)
            }
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private func buttonTapped(_ button: CalculatorButton) {
        switch button {
        case .clear:
            display = "0"
            currentInput = ""
            
        case .plusMinus:
            if let value = Double(display) {
                display = formatNumber(-value)
            }
            
        case .percent:
            if let value = Double(display) {
                display = formatNumber(value / 100)
            }
            
        case .equals:
            evaluate()
            
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            appendDigit(button.rawValue)
            
        case .decimal:
            if !currentInput.contains(".") {
                currentInput += currentInput.isEmpty ? "0." : "."
                display = currentInput
            }
            
        case .add, .subtract, .multiply, .divide:
            appendOperator(button.symbol)
            
        case .sin, .cos, .tan:
            appendFunction(button.rawValue)
            
        case .ln:
            appendFunction("ln")
            
        case .log:
            appendFunction("log")
            
        case .sqrt:
            appendFunction("√")
            
        case .power:
            appendOperator("^")
            
        case .exp:
            appendFunction("exp")
            
        case .pi:
            currentInput += "π"
            display = currentInput
            
        case .factorial:
            currentInput += "!"
            display = currentInput
            
        case .leftParen:
            currentInput += "("
            display = currentInput
            
        case .rightParen:
            currentInput += ")"
            display = currentInput
        }
    }
    
    private func appendDigit(_ digit: String) {
        if display == "0" && digit != "." {
            currentInput = digit
        } else {
            currentInput += digit
        }
        display = currentInput
    }
    
    private func appendOperator(_ op: String) {
        if !currentInput.isEmpty {
            currentInput += op
            display = currentInput
        }
    }
    
    private func appendFunction(_ name: String) {
        currentInput += name + "("
        display = currentInput
    }
    
    private func evaluate() {
        guard !currentInput.isEmpty else { return }
        
        // Replace display symbols with evaluable versions
        var expression = currentInput
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "π", with: String(Double.pi))
            .replacingOccurrences(of: "√(", with: "sqrt(")
        
        do {
            var lexer = Lexer(input: expression)
            let tokens = try lexer.tokenize()
            var parser = Parser(tokens: tokens)
            let ast = try parser.parse()
            
            let context = EvaluationContext(angleMode: angleMode)
            var evaluator = Evaluator(context: context)
            let result = try evaluator.evaluate(ast)
            
            if let doubleValue = result.doubleValue {
                display = formatNumber(doubleValue)
                previousResult = doubleValue
            } else {
                display = result.description
            }
            currentInput = ""
        } catch {
            display = "Error"
            currentInput = ""
        }
    }
    
    private func formatNumber(_ value: Double) -> String {
        if value.isNaN { return "Error" }
        if value.isInfinite { return value > 0 ? "∞" : "-∞" }
        
        if value == floor(value) && abs(value) < 1e15 {
            return String(format: "%.0f", value)
        }
        
        let formatted = String(format: "%.10g", value)
        return formatted
    }
}

// MARK: - Calculator Button Enum

enum CalculatorButton: String, Hashable {
    case zero = "0", one = "1", two = "2", three = "3", four = "4"
    case five = "5", six = "6", seven = "7", eight = "8", nine = "9"
    case decimal = "."
    case add = "+", subtract = "-", multiply = "×", divide = "÷"
    case equals = "=", clear = "AC", plusMinus = "±", percent = "%"
    case sin = "sin", cos = "cos", tan = "tan"
    case ln = "ln", log = "log", sqrt = "√", power = "^"
    case pi = "π", exp = "e^x", factorial = "!"
    case leftParen = "(", rightParen = ")"
    
    var symbol: String {
        switch self {
        case .add: return "+"
        case .subtract: return "-"
        case .multiply: return "×"
        case .divide: return "÷"
        default: return rawValue
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .clear, .plusMinus, .percent:
            return Color(UIColor.systemGray4)
        case .add, .subtract, .multiply, .divide, .equals:
            return .orange
        case .sin, .cos, .tan, .ln, .log, .sqrt, .power, .pi, .exp, .factorial, .leftParen, .rightParen:
            return Color(UIColor.systemGray2)
        default:
            return Color(UIColor.systemGray5)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .add, .subtract, .multiply, .divide, .equals:
            return .white
        default:
            return .primary
        }
    }
}

// MARK: - Calculator Button View

struct CalculatorButtonView: View {
    let button: CalculatorButton
    var isWide: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(button.rawValue)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(button.foregroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(isWide ? 2.2 : 1, contentMode: .fit)
                .background(button.backgroundColor)
                .cornerRadius(40)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
