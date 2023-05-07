//
//  ImageRepository.swift
//  accentor
//
//  Created by Robbe Van Petegem on 07/05/2023.
//

import Foundation

// NOTE: it isn't exactly great that we need to duplicate all this code, just make the difference between NSImage and UIImage
// Make figure out if there is a better way of doing this?

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
protocol ImageRepositoryProtocol {
    func getImage(imageURL: URL) async -> NSImage?
    func downloadImage(imageURL: URL) async -> NSImage?
    func loadImageFromCache(imageURL: URL) async -> NSImage?
}
#else
protocol ImageRepositoryProtocol {
    func getImage(imageURL: URL) async -> UIImage?
    func downloadImage(imageURL: URL) async -> UIImage?
    func loadImageFromCache(imageURL: URL) async -> UIImage?
}
#endif

#if os(macOS)
public class ImageRepository: ImageRepositoryProtocol {
    
    let cache = URLCache.shared
    
    func getImage(imageURL: URL) async -> NSImage? {
        let request = URLRequest(url: imageURL)
        
        if (self.cache.cachedResponse(for: request) != nil) {
            let image = self.loadImageFromCache(imageURL: imageURL)
            if (image != nil) { return image! }
        }

        return await self.downloadImage(imageURL: imageURL)
    }
    
    func downloadImage(imageURL: URL) async -> NSImage? {
        do {
            let request = URLRequest(url: imageURL)
            let (data, response) = try await URLSession.shared.data(for: request)
    
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            
            guard let image = NSImage(data: data) else {
                return nil
            }
            
            // Only cache the data if we got a correct image
            let cachedData = CachedURLResponse(response: response, data: data)
            self.cache.storeCachedResponse(cachedData, for: request)
            
            return image

        } catch {
            return nil
        }
    }
    
    func loadImageFromCache(imageURL: URL) -> NSImage? {
        let request = URLRequest(url: imageURL)
        
        guard let data = self.cache.cachedResponse(for: request)?.data else {
            return nil
        }
        
        return NSImage(data: data)
    }
}
#else
public class ImageRepository: ImageRepositoryProtocol {
    
    let cache = URLCache.shared
    
    func getImage(imageURL: URL) async -> UIImage? {
        let request = URLRequest(url: imageURL)
        
        if (self.cache.cachedResponse(for: request) != nil) {
            let image = self.loadImageFromCache(imageURL: imageURL)
            if (image != nil) { return image! }
        }

        return await self.downloadImage(imageURL: imageURL)
    }
    
    func downloadImage(imageURL: URL) async -> UIImage? {
        do {
            let request = URLRequest(url: imageURL)
            let (data, response) = try await URLSession.shared.data(for: request)
    
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            
            guard let image = UIImage(data: data) else {
                return nil
            }
            
            // Only cache the data if we got a correct image
            let cachedData = CachedURLResponse(response: response, data: data)
            self.cache.storeCachedResponse(cachedData, for: request)
            
            return image

        } catch {
            return nil
        }
    }
    
    func loadImageFromCache(imageURL: URL) -> UIImage? {
        let request = URLRequest(url: imageURL)
        
        guard let data = self.cache.cachedResponse(for: request)?.data else {
            return nil
        }
        
        return UIImage(data: data)
    }
}
#endif
