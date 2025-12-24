import Cocoa
import Quartz

class PreviewViewController: NSViewController, QLPreviewingController {

    private var textView: NSTextView!
    private var scrollView: NSScrollView!

    override func loadView() {
        scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autoresizingMask = [.width, .height]

        textView = NSTextView(frame: scrollView.bounds)
        textView.isEditable = false
        textView.isSelectable = true
        textView.autoresizingMask = [.width]
        textView.textContainerInset = NSSize(width: 20, height: 20)
        textView.backgroundColor = NSColor.textBackgroundColor

        scrollView.documentView = textView
        self.view = scrollView
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let markdownContent = try String(contentsOf: url, encoding: .utf8)
            let renderer = MarkdownRenderer()
            let htmlContent = renderer.render(markdown: markdownContent, title: url.lastPathComponent)

            if let htmlData = htmlContent.data(using: .utf8) {
                let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ]

                if let attributedString = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil) {
                    DispatchQueue.main.async { [weak self] in
                        self?.textView.textStorage?.setAttributedString(attributedString)
                    }
                }
            }

            handler(nil)
        } catch {
            handler(error)
        }
    }
}
