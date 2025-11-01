//
//  SwiftUIExampleView.swift
//  ExampleProject
//
//  Demonstrates how to use MarkdownTextView in SwiftUI
//

import SwiftUI
import Markdownosaur

@available(iOS 13.0, *)
struct SwiftUIExampleView: View {
    // Example markdown with various formatting and images
    let sampleMarkdown = """
    # Welcome to Markdownosaur
    
    This is a **SwiftUI** example showing rich text rendering with inline images!
    
    ## Features
    
    * **Bold** and _italic_ text
    * Nested lists work great
        * Like this nested item
        * And this one
    * Images and videos are displayed inline!
    
    ### Code Support
    
    Inline code like `NSAttributedString` is supported.
    
    ```swift
    var markdownosaur = Markdownosaur()
    let result = markdownosaur.attributedString(from: source)
    ```
    
    > Block quotes look great for callouts and important information.
    
    #### Links and Images
    
    Check out [Apple's website](https://apple.com) or view inline images:
    
    ![Swift Logo](https://swift.org/assets/images/swift.svg)
    
    Images are loaded asynchronously and cached for better performance.
    
    ![GitHub Logo](https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png)
    
    ---
    
    You can adjust the base font size and image width for different experiences.
    """
    
    // Example from JSON with escaped newlines
    let jsonMarkdown = "# From JSON\\n\\n**Bold text** with escaped newlines\\n\\n* Item 1\\n* Item 2\\n\\n> Quote from API response"
    
    @State private var selectedSize: CGFloat = 15.0
    @State private var loadImages: Bool = true
    @State private var maxImageWidth: CGFloat = 300
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Controls
                    VStack(alignment: .leading, spacing: 12) {
                        // Font size selector
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Base Font Size: \(Int(selectedSize))pt")
                                .font(.subheadline)
                            
                            Slider(value: $selectedSize, in: 12...24, step: 1)
                        }
                        
                        // Image loading toggle
                        Toggle("Load Images Inline", isOn: $loadImages)
                            .font(.subheadline)
                        
                        // Image width slider
                        if loadImages {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Max Image Width: \(Int(maxImageWidth))pt")
                                    .font(.subheadline)
                                
                                Slider(value: $maxImageWidth, in: 150...400, step: 50)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    // Regular markdown example with images
                    VStack(alignment: .leading) {
                        Text("Markdown with Inline Images")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        MarkdownTextView(
                            text: sampleMarkdown,
                            baseFontSize: selectedSize,
                            loadImages: loadImages,
                            maxImageWidth: maxImageWidth
                        )
                        .frame(minHeight: 500)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                    
                    // JSON markdown example
                    VStack(alignment: .leading) {
                        Text("From JSON (with \\n)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        MarkdownTextView(
                            text: jsonMarkdown,
                            baseFontSize: selectedSize,
                            loadImages: loadImages,
                            maxImageWidth: maxImageWidth
                        )
                        .frame(minHeight: 200)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Markdownosaur Demo")
        }
    }
}

@available(iOS 13.0, *)
struct SwiftUIExampleView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIExampleView()
    }
}
