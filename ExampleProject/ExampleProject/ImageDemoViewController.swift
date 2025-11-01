//
//  ImageDemoViewController.swift
//  ExampleProject
//
//  Demonstrates how to use Markdownosaur with image support
//

import UIKit
import Markdown
import Markdownosaur

class ImageDemoViewController: UIViewController {
    
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Setup text view
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        
        // Load and display markdown with images
        displayMarkdown()
    }
    
    func displayMarkdown() {
        // Example 1: Using the convenience method with escaped newlines (e.g., from JSON)
        let jsonMarkdown = "# Markdown from JSON\\n\\n**Bold text** with escaped newlines.\\n\\n![GIF](https://media.tenor.com/uOlZaeZu4fYAAAAC/gwa-testing.gif)"
        
        var markdownosaur = Markdownosaur()
        
        // This automatically handles \n escape sequences
        let attributedStringFromJSON = markdownosaur.attributedString(from: jsonMarkdown)
        
        // Example 2: Traditional usage with regular string
        let source = """
        # Markdown with Images Demo
        
        Here's a regular image:
        
        ![Sample Image](https://example.com/image.jpg)
        
        And here's an animated GIF:
        
        ![Animated GIF](https://media.tenor.com/uOlZaeZu4fYAAAAC/gwa-testing.gif)
        
        **Bold text** with _italic_ and _**both**_.
        
        > A quote block with an image
        > ![Quote Image](https://example.com/quote.png)
        
        ## Features
        
        * Lists with images
        * ![List Image](https://example.com/list.jpg) Image in list item
        * More list items
        
        [Regular link](https://example.com)
        """
        
        let document = Document(parsing: source)
        let attributedString = markdownosaur.attributedString(from: document)
        
        // Process the attributed string to handle images
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        
        // Find all images and potentially replace them with actual image views or text attachments
        attributedString.enumerateAttribute(.imageURL, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
            if let imageURL = value as? URL {
                print("Found image at range \(range): \(imageURL)")
                
                // Example: You could load the image and create an NSTextAttachment
                // For now, we'll just add a visual indicator
                let imageIndicator = "🖼️ "
                mutableAttributedString.insert(NSAttributedString(string: imageIndicator), at: range.location)
                
                // In a real app, you might:
                // 1. Download the image asynchronously
                // 2. Create an NSTextAttachment with the image
                // 3. Replace the text with the attachment
                // 4. Handle GIFs specially (e.g., with FLAnimatedImage library)
                
                // Example for static images:
                /*
                if let image = downloadImage(from: imageURL) {
                    let attachment = NSTextAttachment()
                    attachment.image = image
                    
                    let imageString = NSAttributedString(attachment: attachment)
                    mutableAttributedString.replaceCharacters(in: range, with: imageString)
                }
                */
            }
        }
        
        textView.attributedText = mutableAttributedString
    }
    
    // Helper method to download images (you would implement this)
    private func downloadImage(from url: URL) -> UIImage? {
        // Implementation would go here
        // For GIFs, you might use a library like FLAnimatedImage or SDWebImage
        return nil
    }
}
