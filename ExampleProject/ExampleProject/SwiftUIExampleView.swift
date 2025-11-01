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
    // Example markdown with various formatting
    let sampleMarkdown = """
    # Welcome to Markdownosaur
    
    This is a **SwiftUI** example showing rich text rendering.
    
    ## Features
    
    * **Bold** and _italic_ text
    * Nested lists work great
        * Like this nested item
        * And this one
    * Images and links too!
    
    ### Code Support
    
    Inline code like `NSAttributedString` is supported.
    
    ```swift
    var markdownosaur = Markdownosaur()
    let result = markdownosaur.attributedString(from: source)
    ```
    
    > Block quotes look great for callouts and important information.
    
    #### Links and Images
    
    Check out [Apple's website](https://apple.com) or view an image:
    
    ![Sample](https://example.com/image.jpg)
    
    ---
    
    You can adjust the base font size for different reading experiences.
    """
    
    // Example from JSON with escaped newlines
    let jsonMarkdown = "# From JSON\\n\\n**Bold text** with escaped newlines\\n\\n* Item 1\\n* Item 2\\n\\n> Quote from API response"
    
    @State private var selectedSize: CGFloat = 15.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Font size selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Base Font Size: \(Int(selectedSize))pt")
                            .font(.headline)
                        
                        Slider(value: $selectedSize, in: 12...24, step: 1)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    // Regular markdown example
                    VStack(alignment: .leading) {
                        Text("Regular Markdown")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        MarkdownTextView(text: sampleMarkdown, baseFontSize: selectedSize)
                            .frame(minHeight: 400)
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
                        
                        MarkdownTextView(text: jsonMarkdown, baseFontSize: selectedSize)
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
