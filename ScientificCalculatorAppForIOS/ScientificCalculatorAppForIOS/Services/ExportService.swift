import Foundation
import UIKit
import PDFKit

// MARK: - ExportFormat

/// Export format options
enum ExportFormat: String, CaseIterable {
    case text = "Plain Text"
    case csv = "CSV"
    case json = "JSON"
    case pdf = "PDF"
    
    var fileExtension: String {
        switch self {
        case .text: return "txt"
        case .csv: return "csv"
        case .json: return "json"
        case .pdf: return "pdf"
        }
    }
    
    var mimeType: String {
        switch self {
        case .text: return "text/plain"
        case .csv: return "text/csv"
        case .json: return "application/json"
        case .pdf: return "application/pdf"
        }
    }
}

// MARK: - ExportError

enum ExportError: LocalizedError {
    case encodingFailed
    case fileCreationFailed
    case unsupportedFormat
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode data"
        case .fileCreationFailed:
            return "Failed to create export file"
        case .unsupportedFormat:
            return "Unsupported export format"
        }
    }
}

// MARK: - HistoryExport

struct HistoryExport: Codable {
    let exportDate: Date
    let appVersion: String
    let entryCount: Int
    let entries: [HistoryEntry]
}

// MARK: - ExportService

/// Service for exporting calculator data
class ExportService {
    
    // MARK: - Singleton
    
    static let shared = ExportService()
    
    private init() {}
    
    // MARK: - Export History
    
    /// Exports calculation history in the specified format
    func exportHistory(
        format: ExportFormat,
        entries: [HistoryEntry],
        title: String = "Calculation History"
    ) throws -> Data {
        switch format {
        case .text:
            return try exportAsText(entries: entries, title: title)
        case .csv:
            return try exportAsCSV(entries: entries)
        case .json:
            return try exportAsJSON(entries: entries)
        case .pdf:
            return try exportAsPDF(entries: entries, title: title)
        }
    }
    
    // MARK: - Text Export
    
    private func exportAsText(entries: [HistoryEntry], title: String) throws -> Data {
        var text = "\(title)\n"
        text += "Exported: \(Date().formatted())\n"
        text += String(repeating: "=", count: 60) + "\n\n"
        
        for entry in entries {
            text += "[\(entry.formattedTime)] (\(entry.mode))\n"
            text += "  Input:  \(entry.expression)\n"
            text += "  Result: \(entry.result)"
            if entry.isError { text += " (Error)" }
            text += "\n"
            if let notes = entry.notes, !notes.isEmpty {
                text += "  Notes:  \(notes)\n"
            }
            text += "\n"
        }
        
        text += String(repeating: "=", count: 60) + "\n"
        text += "Total: \(entries.count) calculations\n"
        
        guard let data = text.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }
    
    // MARK: - CSV Export
    
    private func exportAsCSV(entries: [HistoryEntry]) throws -> Data {
        var csv = "Timestamp,Mode,Expression,Result,IsError,Notes\n"
        
        for entry in entries {
            let timestamp = entry.timestamp.ISO8601Format()
            let mode = escapeCSV(entry.mode)
            let expr = escapeCSV(entry.expression)
            let result = escapeCSV(entry.result)
            let error = entry.isError ? "true" : "false"
            let notes = escapeCSV(entry.notes ?? "")
            
            csv += "\(timestamp),\(mode),\(expr),\(result),\(error),\(notes)\n"
        }
        
        guard let data = csv.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }
    
    private func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
    
    // MARK: - JSON Export
    
    private func exportAsJSON(entries: [HistoryEntry]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let exportData = HistoryExport(
            exportDate: Date(),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            entryCount: entries.count,
            entries: entries
        )
        
        return try encoder.encode(exportData)
    }
    
    // MARK: - PDF Export
    
    private func exportAsPDF(entries: [HistoryEntry], title: String) throws -> Data {
        let pageWidth: CGFloat = 612  // US Letter width
        let pageHeight: CGFloat = 792 // US Letter height
        let margin: CGFloat = 50
        
        let pdfMetaData = [
            kCGPDFContextCreator: "Scientific Calculator",
            kCGPDFContextTitle: title
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            var currentY: CGFloat = margin
            var pageNumber = 1
            
            // Start first page
            context.beginPage()
            
            // Draw title
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            
            let titleString = title
            titleString.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttributes)
            currentY += 40
            
            // Draw export date
            let dateFont = UIFont.systemFont(ofSize: 12)
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: dateFont,
                .foregroundColor: UIColor.gray
            ]
            
            let dateString = "Exported: \(Date().formatted())"
            dateString.draw(at: CGPoint(x: margin, y: currentY), withAttributes: dateAttributes)
            currentY += 30
            
            // Draw separator line
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: margin, y: currentY))
            linePath.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
            UIColor.gray.setStroke()
            linePath.stroke()
            currentY += 20
            
            // Draw entries
            let entryFont = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
            let labelFont = UIFont.systemFont(ofSize: 10)
            
            for entry in entries {
                // Check if we need a new page
                let entryHeight: CGFloat = 80
                if currentY + entryHeight > pageHeight - margin {
                    // Draw page number
                    drawPageNumber(pageNumber, at: CGPoint(x: pageWidth / 2, y: pageHeight - 30), font: labelFont)
                    pageNumber += 1
                    
                    context.beginPage()
                    currentY = margin
                }
                
                // Timestamp and mode
                let headerText = "[\(entry.formattedTime)] \(entry.mode)"
                headerText.draw(
                    at: CGPoint(x: margin, y: currentY),
                    withAttributes: [.font: labelFont, .foregroundColor: UIColor.darkGray]
                )
                currentY += 18
                
                // Expression
                let exprText = "  \(entry.expression)"
                exprText.draw(
                    at: CGPoint(x: margin, y: currentY),
                    withAttributes: [.font: entryFont, .foregroundColor: UIColor.black]
                )
                currentY += 18
                
                // Result
                let resultColor = entry.isError ? UIColor.red : UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
                let resultText = "  = \(entry.result)"
                resultText.draw(
                    at: CGPoint(x: margin, y: currentY),
                    withAttributes: [.font: entryFont, .foregroundColor: resultColor]
                )
                currentY += 18
                
                // Notes if present
                if let notes = entry.notes, !notes.isEmpty {
                    let notesText = "  Note: \(notes)"
                    notesText.draw(
                        at: CGPoint(x: margin, y: currentY),
                        withAttributes: [.font: labelFont, .foregroundColor: UIColor.gray]
                    )
                    currentY += 16
                }
                
                currentY += 10
            }
            
            // Draw final page number
            drawPageNumber(pageNumber, at: CGPoint(x: pageWidth / 2, y: pageHeight - 30), font: labelFont)
            
            // Draw total count
            let totalText = "Total: \(entries.count) calculations"
            let totalWidth = totalText.size(withAttributes: [.font: labelFont]).width
            totalText.draw(
                at: CGPoint(x: pageWidth - margin - totalWidth, y: pageHeight - 30),
                withAttributes: [.font: labelFont, .foregroundColor: UIColor.gray]
            )
        }
        
        return data
    }
    
    private func drawPageNumber(_ number: Int, at point: CGPoint, font: UIFont) {
        let text = "Page \(number)"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.gray
        ]
        let size = text.size(withAttributes: attributes)
        text.draw(at: CGPoint(x: point.x - size.width / 2, y: point.y), withAttributes: attributes)
    }
    
    // MARK: - Create Share Item
    
    /// Creates a temporary file URL for sharing
    func createShareableFile(data: Data, format: ExportFormat, filename: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(filename).\(format.fileExtension)")
        
        try data.write(to: fileURL)
        return fileURL
    }
    
    // MARK: - Export Spreadsheet
    
    /// Exports spreadsheet data as CSV
    func exportSpreadsheet(from spreadsheet: Spreadsheet) throws -> Data {
        var csv = ""
        
        // Header row
        csv += CellReference.columnLetters.joined(separator: ",") + "\n"
        
        // Data rows
        for row in 0..<Spreadsheet.rows {
            var rowData: [String] = []
            for col in 0..<Spreadsheet.columns {
                if let ref = try? CellReference(column: col, row: row) {
                    let cell = spreadsheet.cell(at: ref)
                    let value = cell.displayValue
                    rowData.append(escapeCSV(value))
                }
            }
            csv += rowData.joined(separator: ",") + "\n"
        }
        
        guard let data = csv.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }
    
    // MARK: - Export Table
    
    /// Exports function table as CSV
    func exportTable(rows: [TableRow], includeG: Bool) throws -> Data {
        var csv = includeG ? "X,f(X),g(X)\n" : "X,f(X)\n"
        
        for row in rows {
            let x = String(row.x)
            let fx = row.fx.map { String($0) } ?? row.fError ?? "Error"
            
            if includeG {
                let gx = row.gx.map { String($0) } ?? row.gError ?? ""
                csv += "\(x),\(escapeCSV(fx)),\(escapeCSV(gx))\n"
            } else {
                csv += "\(x),\(escapeCSV(fx))\n"
            }
        }
        
        guard let data = csv.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }
}
