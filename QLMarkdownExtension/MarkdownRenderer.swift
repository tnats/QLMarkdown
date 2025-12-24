import Foundation

class MarkdownRenderer {

    func render(markdown: String, title: String) -> String {
        let htmlBody = convertMarkdownToHTML(markdown)

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
        </head>
        <body style="font-family: -apple-system, Helvetica, Arial, sans-serif; font-size: 18px; line-height: 1.6; padding: 20px;">
        \(htmlBody)
        </body>
        </html>
        """
    }

    private func convertMarkdownToHTML(_ markdown: String) -> String {
        var result = [String]()
        var inCodeBlock = false
        var codeBlockContent = ""
        let lines = markdown.components(separatedBy: "\n")

        var i = 0
        while i < lines.count {
            let line = lines[i]
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // Fenced code blocks
            if trimmedLine.hasPrefix("```") {
                if !inCodeBlock {
                    inCodeBlock = true
                    codeBlockContent = ""
                } else {
                    inCodeBlock = false
                    let highlightedCode = highlightCode(codeBlockContent)
                    result.append("<table width=\"100%\" cellpadding=\"12\" cellspacing=\"0\" border=\"1\" bordercolor=\"#e1e4e8\" style=\"border-collapse: collapse;\"><tr><td bgcolor=\"#f6f8fa\"><font face=\"Menlo, Monaco, Courier, monospace\"><pre style=\"margin: 0;\">\(highlightedCode)</pre></font></td></tr></table><br>")
                }
                i += 1
                continue
            }

            if inCodeBlock {
                if !codeBlockContent.isEmpty {
                    codeBlockContent += "\n"
                }
                codeBlockContent += line
                i += 1
                continue
            }

            // Headers
            if line.hasPrefix("######") {
                result.append("<p style=\"margin-top: 20px; margin-bottom: 10px;\"><b>\(processInline(String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)))</b></p>")
            } else if line.hasPrefix("#####") {
                result.append("<p style=\"margin-top: 20px; margin-bottom: 10px;\"><font size=\"4\"><b>\(processInline(String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)))</b></font></p>")
            } else if line.hasPrefix("####") {
                result.append("<p style=\"margin-top: 24px; margin-bottom: 12px;\"><font size=\"4\"><b>\(processInline(String(line.dropFirst(4)).trimmingCharacters(in: .whitespaces)))</b></font></p>")
            } else if line.hasPrefix("###") {
                result.append("<p style=\"margin-top: 24px; margin-bottom: 12px;\"><font size=\"5\"><b>\(processInline(String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)))</b></font></p>")
            } else if line.hasPrefix("##") {
                result.append("<p style=\"margin-top: 28px; margin-bottom: 12px;\"><font size=\"5\"><b>\(processInline(String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)))</b></font></p>")
            } else if line.hasPrefix("#") {
                result.append("<p style=\"margin-top: 32px; margin-bottom: 16px;\"><font size=\"6\"><b>\(processInline(String(line.dropFirst(1)).trimmingCharacters(in: .whitespaces)))</b></font></p>")
            }
            // Horizontal rule
            else if trimmedLine.matches(pattern: "^(-{3,}|\\*{3,}|_{3,})$") {
                let hrLine = String(repeating: "─", count: 25)
                result.append("<p style=\"margin: 8px 0;\"><font color=\"#c0c0c0\">\(hrLine)</font></p>")
            }
            // Blockquote
            else if line.hasPrefix(">") {
                var quoteLines = [String]()
                var j = i
                while j < lines.count && lines[j].hasPrefix(">") {
                    let quoteLine = String(lines[j].dropFirst(1))
                    quoteLines.append(quoteLine.hasPrefix(" ") ? String(quoteLine.dropFirst(1)) : quoteLine)
                    j += 1
                }
                let quoteContent = quoteLines.joined(separator: "<br>")
                result.append("<table width=\"100%\" cellpadding=\"10\" cellspacing=\"0\" border=\"0\"><tr><td bgcolor=\"#f9f9f9\" style=\"border-left: 4px solid #ddd\"><font color=\"#666666\"><i>\(processInline(quoteContent))</i></font></td></tr></table>")
                i = j
                continue
            }
            // Task list
            else if line.matches(pattern: "^\\s*[-*+]\\s+\\[[ xX]\\]\\s+") {
                var listItems = [String]()
                var j = i
                while j < lines.count && lines[j].matches(pattern: "^\\s*[-*+]\\s+\\[[ xX]\\]\\s+") {
                    let isChecked = lines[j].contains("[x]") || lines[j].contains("[X]")
                    let itemContent = lines[j].replacingOccurrences(of: "^\\s*[-*+]\\s+\\[[ xX]\\]\\s+", with: "", options: .regularExpression)
                    let checkbox = isChecked ? "☑" : "☐"
                    listItems.append("<p style=\"margin: 4px 0;\">\(checkbox) \(processInline(itemContent))</p>")
                    j += 1
                }
                result.append("<div style=\"margin-left: 10px;\">\(listItems.joined())</div>")
                i = j
                continue
            }
            // Unordered list
            else if line.matches(pattern: "^\\s*[-*+]\\s+") {
                var listItems = [String]()
                var j = i
                while j < lines.count && lines[j].matches(pattern: "^\\s*[-*+]\\s+") {
                    let itemContent = lines[j].replacingOccurrences(of: "^\\s*[-*+]\\s+", with: "", options: .regularExpression)
                    listItems.append("<li>\(processInline(itemContent))</li>")
                    j += 1
                }
                result.append("<ul>\(listItems.joined())</ul>")
                i = j
                continue
            }
            // Ordered list
            else if line.matches(pattern: "^\\s*\\d+\\.\\s+") {
                if let match = line.range(of: "^\\s*(\\d+)\\.", options: .regularExpression) {
                    let numStr = line[match].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ".", with: "")
                    let itemContent = line.replacingOccurrences(of: "^\\s*\\d+\\.\\s+", with: "", options: .regularExpression)
                    result.append("<p style=\"margin: 8px 0; margin-left: 20px;\"><b>\(numStr).</b> \(processInline(itemContent))</p>")
                }
                i += 1
                continue
            }
            // Indented code block
            else if line.hasPrefix("    ") || line.hasPrefix("\t") {
                var codeLines = [String]()
                var j = i
                while j < lines.count {
                    let codeLine = lines[j]
                    if codeLine.hasPrefix("    ") {
                        codeLines.append(String(codeLine.dropFirst(4)))
                        j += 1
                    } else if codeLine.hasPrefix("\t") {
                        codeLines.append(String(codeLine.dropFirst(1)))
                        j += 1
                    } else if codeLine.trimmingCharacters(in: .whitespaces).isEmpty {
                        codeLines.append("")
                        j += 1
                    } else {
                        break
                    }
                }
                while !codeLines.isEmpty && codeLines.last?.isEmpty == true {
                    codeLines.removeLast()
                }
                if !codeLines.isEmpty {
                    let codeContent = codeLines.joined(separator: "\n")
                    let highlightedCode = highlightCode(codeContent)
                    result.append("<table width=\"100%\" cellpadding=\"12\" cellspacing=\"0\" border=\"1\" bordercolor=\"#e1e4e8\" style=\"border-collapse: collapse;\"><tr><td bgcolor=\"#f6f8fa\"><font face=\"Menlo, Monaco, Courier, monospace\"><pre style=\"margin: 0;\">\(highlightedCode)</pre></font></td></tr></table><br>")
                }
                i = j
                continue
            }
            // Table
            else if line.contains("|") && i + 1 < lines.count && lines[i + 1].matches(pattern: "^\\|?[\\s:-]+\\|") {
                var tableLines = [String]()
                var j = i
                while j < lines.count && lines[j].contains("|") {
                    tableLines.append(lines[j])
                    j += 1
                }
                result.append(parseTable(tableLines))
                i = j
                continue
            }
            // Empty line
            else if trimmedLine.isEmpty {
                result.append("<br>")
            }
            // Regular paragraph
            else {
                var paragraphLines = [String]()
                var j = i
                while j < lines.count {
                    let pLine = lines[j]
                    let pTrimmed = pLine.trimmingCharacters(in: .whitespaces)
                    if pTrimmed.isEmpty ||
                       pLine.hasPrefix("#") ||
                       pTrimmed.hasPrefix("```") ||
                       pLine.hasPrefix(">") ||
                       pLine.matches(pattern: "^\\s*[-*+]\\s+") ||
                       pLine.matches(pattern: "^\\s*\\d+\\.\\s+") ||
                       pLine.hasPrefix("    ") ||
                       pLine.hasPrefix("\t") ||
                       (pLine.contains("|") && j + 1 < lines.count && lines[j + 1].matches(pattern: "^\\|?[\\s:-]+\\|")) {
                        break
                    }
                    paragraphLines.append(pLine)
                    j += 1
                }
                if !paragraphLines.isEmpty {
                    let paragraphContent = paragraphLines.joined(separator: " ")
                    result.append("<p style=\"margin: 12px 0;\">\(processInline(paragraphContent))</p>")
                }
                i = j
                continue
            }

            i += 1
        }

        return result.joined(separator: "\n")
    }

    private func processInline(_ text: String) -> String {
        var result = escapeHTML(text)

        // Images
        result = result.replacingOccurrences(
            of: "!\\[([^\\]]*)\\]\\(([^)]+)\\)",
            with: "<img src=\"$2\" alt=\"$1\">",
            options: .regularExpression
        )

        // Links
        result = result.replacingOccurrences(
            of: "\\[([^\\]]+)\\]\\(([^)]+)\\)",
            with: "<a href=\"$2\"><font color=\"#0969da\">$1</font></a>",
            options: .regularExpression
        )

        // Bold
        result = result.replacingOccurrences(
            of: "\\*\\*(.+?)\\*\\*",
            with: "<b>$1</b>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: "__(.+?)__",
            with: "<b>$1</b>",
            options: .regularExpression
        )

        // Italic
        result = result.replacingOccurrences(
            of: "\\*(.+?)\\*",
            with: "<i>$1</i>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: "(?<![a-zA-Z0-9])_(.+?)_(?![a-zA-Z0-9])",
            with: "<i>$1</i>",
            options: .regularExpression
        )

        // Strikethrough
        result = result.replacingOccurrences(
            of: "~~(.+?)~~",
            with: "<s>$1</s>",
            options: .regularExpression
        )

        // Inline code
        result = result.replacingOccurrences(
            of: "`([^`]+)`",
            with: "<font face=\"Menlo, Monaco, monospace\" color=\"#d73a49\">$1</font>",
            options: .regularExpression
        )

        return result
    }

    private func escapeHTML(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private func highlightCode(_ code: String) -> String {
        var result = ""
        let lines = code.components(separatedBy: "\n")

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let escaped = escapeHTML(line)

            if trimmed.hasPrefix("#") {
                result += "<font color=\"#008000\">\(escaped)</font>\n"
            } else {
                var highlighted = escaped
                let commands = ["curl", "grep", "head", "tail", "echo", "cat", "railway", "bash", "npm", "node", "python", "git", "cd", "ls", "mkdir", "rm", "cp", "mv"]
                for cmd in commands {
                    highlighted = highlighted.replacingOccurrences(
                        of: "\\b\(cmd)\\b",
                        with: "<font color=\"#d73a49\">\(cmd)</font>",
                        options: .regularExpression
                    )
                }
                result += "\(highlighted)\n"
            }
        }

        if result.hasSuffix("\n") {
            result = String(result.dropLast())
        }

        return result
    }

    private func parseTable(_ lines: [String]) -> String {
        guard lines.count >= 2 else { return "" }

        func parseCells(_ line: String) -> [String] {
            var cells = line.split(separator: "|", omittingEmptySubsequences: false).map { String($0).trimmingCharacters(in: .whitespaces) }
            if cells.first?.isEmpty == true { cells.removeFirst() }
            if cells.last?.isEmpty == true { cells.removeLast() }
            return cells
        }

        let headerCells = parseCells(lines[0])

        var html = "<table border=\"1\" cellpadding=\"6\" cellspacing=\"0\">\n<tr bgcolor=\"#f6f8fa\">\n"
        for cell in headerCells {
            html += "<td><b>\(processInline(cell))</b></td>\n"
        }
        html += "</tr>\n"

        for j in 2..<lines.count {
            let rowCells = parseCells(lines[j])
            html += "<tr>\n"
            for cell in rowCells {
                html += "<td>\(processInline(cell))</td>\n"
            }
            html += "</tr>\n"
        }

        html += "</table>"
        return html
    }
}

extension String {
    func matches(pattern: String) -> Bool {
        return self.range(of: pattern, options: .regularExpression) != nil
    }
}
