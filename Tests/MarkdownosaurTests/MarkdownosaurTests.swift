import XCTest
import Markdown
@testable import Markdownosaur

final class MarkdownosaurTests: XCTestCase {
    func testExample() throws {}
    
    func testBasicImage() throws {
        let source = "![Alt Text](https://example.com/image.jpg)"
        let document = Document(parsing: source)
        
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0, "Attributed string should not be empty")
        XCTAssertTrue(attributedString.string.contains("Alt Text"), "Should contain alt text")
        
        // Check if image URL attribute is set
        var foundImageURL = false
        attributedString.enumerateAttribute(.imageURL, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, stop in
            if let url = value as? URL {
                XCTAssertEqual(url.absoluteString, "https://example.com/image.jpg")
                foundImageURL = true
            }
        }
        XCTAssertTrue(foundImageURL, "Should have image URL attribute")
    }
    
    func testImageWithTitle() throws {
        let source = "![Alt Text](https://example.com/image.jpg \"Image Title\")"
        let document = Document(parsing: source)
        
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0)
        
        // Check if image title attribute is set
        var foundImageTitle = false
        attributedString.enumerateAttribute(.imageTitle, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, stop in
            if let title = value as? String {
                XCTAssertEqual(title, "Image Title")
                foundImageTitle = true
            }
        }
        XCTAssertTrue(foundImageTitle, "Should have image title attribute")
    }
    
    func testGifAsImage() throws {
        let source = "![PostImage](https://media.tenor.com/uOlZaeZu4fYAAAAC/gwa-testing.gif)"
        let document = Document(parsing: source)
        
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("PostImage"), "Should contain alt text")
        
        // Check if image URL attribute is set to a GIF
        var foundGifURL = false
        attributedString.enumerateAttribute(.imageURL, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, stop in
            if let url = value as? URL {
                XCTAssertTrue(url.absoluteString.hasSuffix(".gif"))
                foundGifURL = true
            }
        }
        XCTAssertTrue(foundGifURL, "Should have GIF URL attribute")
    }
    
    func testComplexMarkdownWithImages() throws {
        let source = """
        ## Header
        
        Here's some text with an image:
        
        ![Test Image](https://example.com/test.png)
        
        And more text after.
        """
        
        let document = Document(parsing: source)
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("Header"))
        XCTAssertTrue(attributedString.string.contains("Test Image"))
    }
    
    func testMultipleImages() throws {
        let source = """
        ![First](https://example.com/first.jpg)
        ![Second](https://example.com/second.png)
        ![Third](https://example.com/third.gif)
        """
        
        let document = Document(parsing: source)
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        var imageURLCount = 0
        attributedString.enumerateAttribute(.imageURL, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, stop in
            if value != nil {
                imageURLCount += 1
            }
        }
        
        XCTAssertGreaterThan(imageURLCount, 0, "Should have at least one image URL")
    }
    
    func testImageInList() throws {
        let source = """
        - Item 1
        - ![Image in list](https://example.com/list.jpg)
        - Item 3
        """
        
        let document = Document(parsing: source)
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("Image in list"))
    }
    
    func testBoldItalicCombinations() throws {
        let source = """
        **Bold text**
        
        _Italic text_
        
        _**Bold and italic text**_
        """
        
        let document = Document(parsing: source)
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("Bold text"))
        XCTAssertTrue(attributedString.string.contains("Italic text"))
        XCTAssertTrue(attributedString.string.contains("Bold and italic text"))
    }
    
    func testNestedLists() throws {
        let source = """
        *   Item 1
        *   Item 2
            *   Nested 1
                *   Deep nested
            *   Nested 2
        *   Item 3
        """
        
        let document = Document(parsing: source)
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("Item 1"))
        XCTAssertTrue(attributedString.string.contains("Deep nested"))
    }
    
    func testOrderedAndUnorderedLists() throws {
        let source = """
        1.  First ordered item
        2.  Second ordered item
            1.  Nested ordered
                *   Nested unordered
            2.  Another nested ordered
        3.  Third ordered item
        """
        
        let document = Document(parsing: source)
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("First ordered item"))
    }
    
    func testBlockQuote() throws {
        let source = """
        > This is a quote block.
        > 
        > Multiple lines in quote.
        """
        
        let document = Document(parsing: source)
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("This is a quote block"))
    }
    
    func testLinks() throws {
        let source = "[Link Text](https://example.com)"
        let document = Document(parsing: source)
        
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("Link Text"))
        
        // Check if link attribute is set
        var foundLink = false
        attributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, stop in
            if let url = value as? URL {
                XCTAssertEqual(url.absoluteString, "https://example.com")
                foundLink = true
            }
        }
        XCTAssertTrue(foundLink, "Should have link attribute")
    }
    
    func testComplexDocument() throws {
        let source = """
        # Main Heading
        
        **Lorem Ipsum** is simply dummy text.
        
        ### Subheading
        
        *   List item 1
        *   List item 2
            *   Nested item
        
        ![Test Image](https://example.com/test.gif)
        
        > Quote text
        
        _Italic_ and **bold** and _**both**_.
        
        [Link](https://example.com)
        """
        
        let document = Document(parsing: source)
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("Main Heading"))
        XCTAssertTrue(attributedString.string.contains("Lorem Ipsum"))
        XCTAssertTrue(attributedString.string.contains("Test Image"))
        XCTAssertTrue(attributedString.string.contains("Quote text"))
    }
    
    func testSetextStyleHeaders() throws {
        let source = """
        Main Heading
        ============
        
        Some content here.
        
        Subheading
        ----------
        
        More content.
        """
        
        let document = Document(parsing: source)
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("Main Heading"))
        XCTAssertTrue(attributedString.string.contains("Subheading"))
        XCTAssertTrue(attributedString.string.contains("Some content here"))
    }
    
    func testEmojisInText() throws {
        let source = "Here's an emoji 🔰 in text."
        let document = Document(parsing: source)
        
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.string.contains("🔰"))
    }
    
    func testPlainURLs() throws {
        let source = "[https://example.com/path](https://example.com/path)"
        let document = Document(parsing: source)
        
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: document)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("https://example.com/path"))
    }
    
    func testEscapedNewlinesFromJSON() throws {
        // Simulating markdown from JSON with escaped newlines
        let source = "What is Lorem Ipsum?\\n--------------------\\n\\n**Lorem Ipsum** is simply dummy text."
        
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: source)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("What is Lorem Ipsum?"))
        XCTAssertTrue(attributedString.string.contains("Lorem Ipsum"))
        
        // The text should be parsed as a heading (setext style) followed by bold text
        // Verify bold text is present
        var foundBold = false
        attributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, stop in
            if let font = value as? UIFont {
                if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    foundBold = true
                }
            }
        }
        XCTAssertTrue(foundBold, "Should have bold text from **Lorem Ipsum**")
    }
    
    func testSingleEscapedNewline() throws {
        let source = "First line\\nSecond line"
        
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: source)
        
        XCTAssertTrue(attributedString.string.contains("First line"))
        XCTAssertTrue(attributedString.string.contains("Second line"))
    }
    
    func testDoubleEscapedNewline() throws {
        let source = "First paragraph\\n\\nSecond paragraph"
        
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: source)
        
        XCTAssertTrue(attributedString.string.contains("First paragraph"))
        XCTAssertTrue(attributedString.string.contains("Second paragraph"))
    }
    
    func testComplexMarkdownWithEscapedNewlines() throws {
        // This is similar to the JSON example from the problem statement
        let source = "# Header\\n\\n**Bold text**\\n\\n*Italic text*\\n\\n> Quote\\n\\n![Image](https://example.com/image.jpg)"
        
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: source)
        
        XCTAssertTrue(attributedString.length > 0)
        XCTAssertTrue(attributedString.string.contains("Header"))
        XCTAssertTrue(attributedString.string.contains("Bold text"))
        XCTAssertTrue(attributedString.string.contains("Italic text"))
        XCTAssertTrue(attributedString.string.contains("Quote"))
        XCTAssertTrue(attributedString.string.contains("Image"))
    }
    
    func testCustomBaseFontSize() throws {
        let source = "**Bold text**"
        
        // Test with default font size
        var markdownosaurDefault = Markdownosaur()
        let defaultString = markdownosaurDefault.attributedString(from: source)
        
        // Test with custom font size
        var markdownosaurCustom = Markdownosaur(baseFontSize: 20.0)
        let customString = markdownosaurCustom.attributedString(from: source)
        
        XCTAssertTrue(defaultString.length > 0)
        XCTAssertTrue(customString.length > 0)
        
        // Check that custom font size is applied
        var foundCustomSize = false
        customString.enumerateAttribute(.font, in: NSRange(location: 0, length: customString.length), options: []) { value, range, stop in
            if let font = value as? UIFont {
                if font.pointSize == 20.0 {
                    foundCustomSize = true
                }
            }
        }
        XCTAssertTrue(foundCustomSize, "Custom font size should be applied")
    }
    
    func testBaseFontSizeInHeadings() throws {
        let source = "# Heading"
        
        // Test with base font size of 16
        var markdownosaur = Markdownosaur(baseFontSize: 16.0)
        let attributedString = markdownosaur.attributedString(from: source)
        
        XCTAssertTrue(attributedString.string.contains("Heading"))
        
        // Headings should use a calculated size based on the base font size
        var foundHeadingFont = false
        attributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, stop in
            if let font = value as? UIFont {
                // Level 1 heading uses: 28.0 - (1 * 2) = 26.0 in original code
                // With base size of 16, it should still use the calculated formula
                if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    foundHeadingFont = true
                }
            }
        }
        XCTAssertTrue(foundHeadingFont, "Heading should have bold trait")
    }
    
    func testDifferentBaseFontSizesProduceDifferentOutput() throws {
        let source = "Regular text"
        
        var small = Markdownosaur(baseFontSize: 12.0)
        var large = Markdownosaur(baseFontSize: 24.0)
        
        let smallString = small.attributedString(from: source)
        let largeString = large.attributedString(from: source)
        
        // Extract font sizes
        var smallSize: CGFloat = 0
        var largeSize: CGFloat = 0
        
        smallString.enumerateAttribute(.font, in: NSRange(location: 0, length: smallString.length), options: []) { value, range, stop in
            if let font = value as? UIFont {
                smallSize = font.pointSize
            }
        }
        
        largeString.enumerateAttribute(.font, in: NSRange(location: 0, length: largeString.length), options: []) { value, range, stop in
            if let font = value as? UIFont {
                largeSize = font.pointSize
            }
        }
        
        XCTAssertEqual(smallSize, 12.0, "Small base font size should be 12.0")
        XCTAssertEqual(largeSize, 24.0, "Large base font size should be 24.0")
    }
    
    func testImageLoaderCache() throws {
        let loader = ImageLoader.shared
        
        // Clear cache first
        loader.clearCache()
        
        // Test that cache is initially empty
        let testURL = URL(string: "https://example.com/test.jpg")!
        let cached = loader.cache.object(forKey: testURL as NSURL)
        XCTAssertNil(cached, "Cache should be empty initially")
        
        // After clearing, cache should work for new entries
        loader.clearCache()
        XCTAssertNotNil(loader, "ImageLoader should be initialized")
    }
    
    func testImageURLsInMarkdown() throws {
        let source = """
        Here's an image:
        
        ![Test Image](https://example.com/image.jpg)
        
        And another:
        
        ![Another](https://example.com/other.png)
        """
        
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: source)
        
        var imageCount = 0
        var imageURLs: [URL] = []
        
        attributedString.enumerateAttribute(.imageURL, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, stop in
            if let url = value as? URL {
                imageCount += 1
                imageURLs.append(url)
            }
        }
        
        XCTAssertEqual(imageCount, 2, "Should find 2 images")
        XCTAssertEqual(imageURLs.count, 2, "Should have 2 image URLs")
        XCTAssertTrue(imageURLs.contains(where: { $0.absoluteString.contains("image.jpg") }))
        XCTAssertTrue(imageURLs.contains(where: { $0.absoluteString.contains("other.png") }))
    }
    
    func testVideoAsImage() throws {
        let source = "![Video](https://example.com/video.mp4)"
        
        var markdownosaur = Markdownosaur()
        let attributedString = markdownosaur.attributedString(from: source)
        
        var foundVideoURL = false
        attributedString.enumerateAttribute(.imageURL, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, stop in
            if let url = value as? URL {
                if url.absoluteString.hasSuffix(".mp4") {
                    foundVideoURL = true
                }
            }
        }
        
        XCTAssertTrue(foundVideoURL, "Should detect video URL as image")
        XCTAssertTrue(attributedString.string.contains("Video"), "Should contain alt text")
    }
}
