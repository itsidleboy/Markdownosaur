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

/// A SwiftUI view that displays Markdown content as rich text with inline images
@available(iOS 13.0, *)
public struct MarkdownTextView: UIViewRepresentable {
    let markdownText: String
    let baseFontSize: CGFloat
    let loadImages: Bool
    let maxImageWidth: CGFloat
    
    /// Creates a new MarkdownTextView
    /// - Parameters:
    ///   - text: The markdown text to display (can include escaped newlines like \n)
    ///   - baseFontSize: The base font size used to calculate sizes for all text types (default: 15)
    ///   - loadImages: Whether to load and display images inline (default: true)
    ///   - maxImageWidth: Maximum width for inline images (default: 300)
    public init(text: String, baseFontSize: CGFloat = 15.0, loadImages: Bool = true, maxImageWidth: CGFloat = 300) {
        self.markdownText = text
        self.baseFontSize = baseFontSize
        self.loadImages = loadImages
        self.maxImageWidth = maxImageWidth
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
        
        // Enable selection for better copy/paste support
        textView.isSelectable = true
        textView.dataDetectorTypes = [.link]
        
        return textView
    }
    
    public func updateUIView(_ textView: UITextView, context: Context) {
        var markdownosaur = Markdownosaur(baseFontSize: baseFontSize)
        let attributedString = markdownosaur.attributedString(from: markdownText)
        
        if loadImages {
            // Process and load images asynchronously
            let processedString = processImages(in: attributedString, maxWidth: maxImageWidth)
            textView.attributedText = processedString
            
            // Load images asynchronously and update
            loadImagesAsync(in: processedString, textView: textView, maxWidth: maxImageWidth)
        } else {
            textView.attributedText = attributedString
        }
    }
    
    /// Process images in attributed string and create text attachments
    private func processImages(in attributedString: NSAttributedString, maxWidth: CGFloat) -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: attributedString)
        var imageRanges: [(range: NSRange, url: URL)] = []
        
        // Find all images
        attributedString.enumerateAttribute(.imageURL, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
            if let url = value as? URL {
                imageRanges.append((range, url))
            }
        }
        
        // Process in reverse order to maintain correct ranges
        for (range, url) in imageRanges.reversed() {
            // Create a placeholder attachment
            let attachment = NSTextAttachment()
            
            // Try to load image synchronously from cache only
            if let cachedImage = ImageLoader.shared.cache.object(forKey: url as NSURL) {
                let scaledImage = scaleImage(cachedImage, maxWidth: maxWidth)
                attachment.image = scaledImage
                attachment.bounds = CGRect(x: 0, y: 0, width: scaledImage.size.width, height: scaledImage.size.height)
            } else {
                // Use placeholder
                let placeholderImage = createPlaceholderImage(width: maxWidth)
                attachment.image = placeholderImage
                attachment.bounds = CGRect(x: 0, y: 0, width: placeholderImage.size.width, height: placeholderImage.size.height)
            }
            
            // Create attributed string with attachment
            let imageString = NSAttributedString(attachment: attachment)
            
            // Replace the text with image attachment
            mutableString.replaceCharacters(in: range, with: imageString)
            
            // Store URL as attribute for async loading
            mutableString.addAttribute(.link, value: url, range: NSRange(location: range.location, length: 1))
        }
        
        return mutableString
    }
    
    /// Load images asynchronously and update text view
    private func loadImagesAsync(in attributedString: NSAttributedString, textView: UITextView, maxWidth: CGFloat) {
        var imageURLs: [(range: NSRange, url: URL)] = []
        
        attributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
            if let url = value as? URL {
                // Check if this is an image attachment location
                if attributedString.attributedSubstring(from: range).string == "\u{FFFC}" {
                    imageURLs.append((range, url))
                }
            }
        }
        
        for (range, url) in imageURLs {
            ImageLoader.shared.loadImage(from: url) { image in
                guard let image = image else { return }
                
                DispatchQueue.main.async {
                    let mutableString = NSMutableAttributedString(attributedString: textView.attributedText)
                    
                    // Create new attachment with loaded image
                    let attachment = NSTextAttachment()
                    let scaledImage = self.scaleImage(image, maxWidth: maxWidth)
                    attachment.image = scaledImage
                    attachment.bounds = CGRect(x: 0, y: 0, width: scaledImage.size.width, height: scaledImage.size.height)
                    
                    // Replace placeholder with actual image
                    let imageString = NSAttributedString(attachment: attachment)
                    mutableString.replaceCharacters(in: range, with: imageString)
                    
                    textView.attributedText = mutableString
                }
            }
        }
    }
    
    /// Scale image to fit within max width while maintaining aspect ratio
    private func scaleImage(_ image: UIImage, maxWidth: CGFloat) -> UIImage {
        let size = image.size
        
        if size.width <= maxWidth {
            return image
        }
        
        let scale = maxWidth / size.width
        let newSize = CGSize(width: maxWidth, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage ?? image
    }
    
    /// Create a placeholder image for loading state
    private func createPlaceholderImage(width: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: width * 0.6)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        // Draw gray background
        context?.setFillColor(UIColor.systemGray5.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        
        // Draw icon
        let iconSize: CGFloat = 40
        let iconRect = CGRect(x: (size.width - iconSize) / 2, y: (size.height - iconSize) / 2, width: iconSize, height: iconSize)
        context?.setFillColor(UIColor.systemGray3.cgColor)
        context?.fillEllipse(in: iconRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}

/// Preview provider for SwiftUI canvas
@available(iOS 13.0, *)
struct MarkdownTextView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with inline images
            MarkdownTextView(text: """
                # Markdown with Images
                
                This is a **bold** text and this is _italic_.
                
                ## Features
                
                * Lists work great
                * With multiple items
                    * And nested items
                
                > Block quotes are supported
                
                ![Swift Logo](https://swift.org/assets/images/swift.svg)
                
                Images are loaded inline automatically!
                
                Check out [this link](https://example.com).
                """, loadImages: true, maxImageWidth: 250)
            .previewDisplayName("With Inline Images")
            
            // Preview with larger font size
            MarkdownTextView(text: """
                # Large Text Example
                
                **Bold text** with _italic_ and _**both**_.
                
                1. Numbered lists
                2. Are also supported
                3. With proper formatting
                
                ![GitHub](https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png)
                """, baseFontSize: 20.0, loadImages: true, maxImageWidth: 200)
            .previewDisplayName("Large Size with Images")
            
            // Preview without images
            MarkdownTextView(text: """
                # Without Images
                
                ![Image](https://example.com/image.jpg)
                
                Images are not loaded, only alt text shown.
                """, loadImages: false)
            .previewDisplayName("Images Disabled")
            
            // Preview with escaped newlines (from JSON)
            MarkdownTextView(text: "# Header\\n\\n**Bold text** from JSON\\n\\n* Item 1\\n* Item 2\\n\\n![Logo](https://swift.org/assets/images/swift.svg)")
            .previewDisplayName("JSON with \\n and Images")
        }
    }
}
#endif
