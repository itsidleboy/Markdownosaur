//
//  ExpandableMarkdownTextView.swift
//  Markdownosaur
//
//  A SwiftUI view with truncation and "Read more" support
//

#if canImport(SwiftUI)
import SwiftUI
import UIKit
import Markdown

/// A SwiftUI view that displays Markdown content with truncation and expand/collapse support
@available(iOS 13.0, *)
public struct ExpandableMarkdownTextView: View {
    let markdownText: String
    let baseFontSize: CGFloat
    let loadImages: Bool
    let maxImageWidth: CGFloat
    let lineLimit: Int?
    let onMentionTap: ((String) -> Void)?
    
    @State private var isExpanded: Bool = false
    @State private var isTruncated: Bool = false
    
    /// Creates a new ExpandableMarkdownTextView
    /// - Parameters:
    ///   - text: The markdown text to display
    ///   - baseFontSize: The base font size (default: 15)
    ///   - loadImages: Whether to load images inline (default: true)
    ///   - maxImageWidth: Maximum width for inline images (default: 300)
    ///   - lineLimit: Number of lines before truncation (default: 5, nil for no limit)
    ///   - onMentionTap: Callback when a user mention is tapped
    public init(
        text: String,
        baseFontSize: CGFloat = 15.0,
        loadImages: Bool = true,
        maxImageWidth: CGFloat = 300,
        lineLimit: Int? = 5,
        onMentionTap: ((String) -> Void)? = nil
    ) {
        self.markdownText = text
        self.baseFontSize = baseFontSize
        self.loadImages = loadImages
        self.maxImageWidth = maxImageWidth
        self.lineLimit = lineLimit
        self.onMentionTap = onMentionTap
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MarkdownTextViewWithTruncation(
                text: markdownText,
                baseFontSize: baseFontSize,
                loadImages: loadImages,
                maxImageWidth: maxImageWidth,
                lineLimit: isExpanded ? nil : lineLimit,
                isTruncated: $isTruncated,
                onMentionTap: onMentionTap
            )
            
            if isTruncated && !isExpanded {
                Button(action: {
                    withAnimation {
                        isExpanded = true
                    }
                }) {
                    Text("Read more")
                        .font(.system(size: CGFloat(baseFontSize), weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            
            if isExpanded && lineLimit != nil {
                Button(action: {
                    withAnimation {
                        isExpanded = false
                    }
                }) {
                    Text("Show less")
                        .font(.system(size: CGFloat(baseFontSize), weight: .medium))
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

/// Internal view that handles the actual text rendering and truncation detection
@available(iOS 13.0, *)
struct MarkdownTextViewWithTruncation: UIViewRepresentable {
    let text: String
    let baseFontSize: CGFloat
    let loadImages: Bool
    let maxImageWidth: CGFloat
    let lineLimit: Int?
    @Binding var isTruncated: Bool
    let onMentionTap: ((String) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onMentionTap: onMentionTap)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.delegate = context.coordinator
        
        // Enable text selection and data detectors
        textView.isSelectable = true
        textView.dataDetectorTypes = [.link]
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        var markdownosaur = Markdownosaur(baseFontSize: baseFontSize)
        let attributedString = markdownosaur.attributedString(from: text)
        
        var finalString: NSMutableAttributedString
        
        if loadImages {
            finalString = processImages(in: attributedString, maxWidth: maxImageWidth)
            textView.attributedText = finalString
            loadImagesAsync(in: finalString, textView: textView, maxWidth: maxImageWidth)
        } else {
            finalString = NSMutableAttributedString(attributedString: attributedString)
            textView.attributedText = finalString
        }
        
        // Apply truncation if needed
        if let limit = lineLimit {
            DispatchQueue.main.async {
                let layoutManager = textView.layoutManager
                let numberOfGlyphs = layoutManager.numberOfGlyphs
                var lineCount = 0
                var index = 0
                
                while index < numberOfGlyphs {
                    var lineRange = NSRange(location: 0, length: 0)
                    layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
                    lineCount += 1
                    index = NSMaxRange(lineRange)
                }
                
                isTruncated = lineCount > limit
                
                if isTruncated {
                    textView.textContainer.maximumNumberOfLines = limit
                } else {
                    textView.textContainer.maximumNumberOfLines = 0
                }
            }
        } else {
            textView.textContainer.maximumNumberOfLines = 0
            isTruncated = false
        }
    }
    
    // Helper methods from MarkdownTextView
    private func processImages(in attributedString: NSAttributedString, maxWidth: CGFloat) -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: attributedString)
        var imageRanges: [(range: NSRange, url: URL)] = []
        
        attributedString.enumerateAttribute(.imageURL, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
            if let url = value as? URL {
                imageRanges.append((range, url))
            }
        }
        
        for (range, url) in imageRanges.reversed() {
            let attachment = NSTextAttachment()
            
            if let cachedImage = ImageLoader.shared.cache.object(forKey: url as NSURL) {
                let scaledImage = scaleImage(cachedImage, maxWidth: maxWidth)
                attachment.image = scaledImage
                attachment.bounds = CGRect(x: 0, y: 0, width: scaledImage.size.width, height: scaledImage.size.height)
            } else {
                let placeholderImage = createPlaceholderImage(width: maxWidth)
                attachment.image = placeholderImage
                attachment.bounds = CGRect(x: 0, y: 0, width: placeholderImage.size.width, height: placeholderImage.size.height)
            }
            
            let imageString = NSAttributedString(attachment: attachment)
            mutableString.replaceCharacters(in: range, with: imageString)
            mutableString.addAttribute(.link, value: url, range: NSRange(location: range.location, length: 1))
        }
        
        return mutableString
    }
    
    private func loadImagesAsync(in attributedString: NSAttributedString, textView: UITextView, maxWidth: CGFloat) {
        var imageURLs: [(range: NSRange, url: URL)] = []
        
        attributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
            if let url = value as? URL, attributedString.attributedSubstring(from: range).string == "\u{FFFC}" {
                imageURLs.append((range, url))
            }
        }
        
        for (range, url) in imageURLs {
            ImageLoader.shared.loadImage(from: url) { image in
                guard let image = image else { return }
                
                DispatchQueue.main.async {
                    let mutableString = NSMutableAttributedString(attributedString: textView.attributedText)
                    let attachment = NSTextAttachment()
                    let scaledImage = self.scaleImage(image, maxWidth: maxWidth)
                    attachment.image = scaledImage
                    attachment.bounds = CGRect(x: 0, y: 0, width: scaledImage.size.width, height: scaledImage.size.height)
                    
                    let imageString = NSAttributedString(attachment: attachment)
                    mutableString.replaceCharacters(in: range, with: imageString)
                    textView.attributedText = mutableString
                }
            }
        }
    }
    
    private func scaleImage(_ image: UIImage, maxWidth: CGFloat) -> UIImage {
        let size = image.size
        if size.width <= maxWidth { return image }
        
        let scale = maxWidth / size.width
        let newSize = CGSize(width: maxWidth, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage ?? image
    }
    
    private func createPlaceholderImage(width: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: width * 0.6)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.systemGray5.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        
        let iconSize: CGFloat = 40
        let iconRect = CGRect(x: (size.width - iconSize) / 2, y: (size.height - iconSize) / 2, width: iconSize, height: iconSize)
        context?.setFillColor(UIColor.systemGray3.cgColor)
        context?.fillEllipse(in: iconRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let onMentionTap: ((String) -> Void)?
        
        init(onMentionTap: ((String) -> Void)?) {
            self.onMentionTap = onMentionTap
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            // Handle mention links
            if URL.scheme == "mention", let userId = URL.host {
                onMentionTap?(userId)
                return false
            }
            return true
        }
    }
}

#endif
