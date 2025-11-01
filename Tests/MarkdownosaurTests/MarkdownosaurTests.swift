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
}
