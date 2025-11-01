//
//  ImageLoader.swift
//  Markdownosaur
//
//  Helper for loading and caching images for inline display
//

import UIKit

/// A simple image loader and cache for markdown images
public class ImageLoader {
    public static let shared = ImageLoader()
    
    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    
    public init() {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024)
        self.session = URLSession(configuration: config)
    }
    
    /// Load an image from a URL (synchronously - use with caution)
    public func loadImageSync(from url: URL) -> UIImage? {
        // Check cache first
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }
        
        // Try to load from URL
        guard let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        
        // Cache the image
        cache.setObject(image, forKey: url as NSURL)
        return image
    }
    
    /// Load an image from a URL asynchronously
    public func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cached = cache.object(forKey: url as NSURL) {
            completion(cached)
            return
        }
        
        // Load from network
        session.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            // Cache the image
            self?.cache.setObject(image, forKey: url as NSURL)
            completion(image)
        }.resume()
    }
    
    /// Clear the image cache
    public func clearCache() {
        cache.removeAllObjects()
    }
}
