import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Status Header
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.green)

                VStack(alignment: .leading, spacing: 2) {
                    Text("QLMarkdown Extension Installed")
                        .font(.headline)
                    Text("Ready to preview Markdown files")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.1))
            .cornerRadius(10)

            // Instructions
            VStack(alignment: .leading, spacing: 12) {
                Text("How to Use")
                    .font(.headline)

                HStack(alignment: .top, spacing: 12) {
                    Text("1.")
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    Text("Select any .md file in Finder")
                }

                HStack(alignment: .top, spacing: 12) {
                    Text("2.")
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    Text("Press Space to preview")
                }

                HStack(alignment: .top, spacing: 12) {
                    Text("3.")
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    Text("See rendered Markdown instantly")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)

            // Features
            VStack(alignment: .leading, spacing: 12) {
                Text("Supported Features")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 6) {
                    FeatureRow(text: "Headers, bold, italic, strikethrough")
                    FeatureRow(text: "Code blocks with syntax highlighting")
                    FeatureRow(text: "Tables, blockquotes, lists")
                    FeatureRow(text: "Task lists with checkboxes")
                    FeatureRow(text: "Links and images")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)

            Spacer()

            // Footer
            Text("You can quit this app \u{2014} the extension runs independently.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(width: 400, height: 420)
    }
}

struct FeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.caption)
                .foregroundColor(.green)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    ContentView()
}
