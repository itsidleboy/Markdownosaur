//
//  MarkdownTextView.swift
//  Markdownosaur
//
//  A SwiftUI view that renders Markdown with rich text formatting
//

#if canImport(SwiftUI)
import SwiftUI
import UIKit
import Markdown

/// A SwiftUI view that displays Markdown content as rich text
@available(iOS 13.0, *)
public struct MarkdownTextView: UIViewRepresentable {
    let markdownText: String
    let baseFontSize: CGFloat
    
    /// Creates a new MarkdownTextView
    /// - Parameters:
    ///   - text: The markdown text to display (can include escaped newlines like \n)
    ///   - baseFontSize: The base font size used to calculate sizes for all text types (default: 15)
    public init(text: String, baseFontSize: CGFloat = 15.0) {
        self.markdownText = text
        self.baseFontSize = baseFontSize
    }
    
    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        // Configure text view for better rendering
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        
        return textView
    }
    
    public func updateUIView(_ textView: UITextView, context: Context) {
        var markdownosaur = Markdownosaur(baseFontSize: baseFontSize)
        let attributedString = markdownosaur.attributedString(from: markdownText)
        textView.attributedText = attributedString
    }
}

/// Preview provider for SwiftUI canvas
@available(iOS 13.0, *)
struct MarkdownTextView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with default font size
            MarkdownTextView(text: """
                # Markdown Preview
                
                This is a **bold** text and this is _italic_.
                
                ## Features
                
                * Lists work great
                * With multiple items
                    * And nested items
                
                > Block quotes are supported
                
                ![Image](https://example.com/image.jpg)
                
                Check out [this link](https://example.com).
                """)
            .previewDisplayName("Default Size (15pt)")
            
            // Preview with larger font size
            MarkdownTextView(text: """
                # Large Text Example
                
                **Bold text** with _italic_ and _**both**_.
                
                1. Numbered lists
                2. Are also supported
                3. With proper formatting
                """, baseFontSize: 20.0)
            .previewDisplayName("Large Size (20pt)")
            
            // Preview with escaped newlines (from JSON)
            MarkdownTextView(text: "# Header\\n\\n**Bold text** from JSON\\n\\n* Item 1\\n* Item 2")
            .previewDisplayName("JSON with \\n")
        }
    }
}
#endif
