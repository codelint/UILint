//
//  File.swift
//  
//
//  Created by gzhang on 2022/11/10.
//

import Foundation
#if canImport(UIKit)
import UIKit

extension UIImage {
    
    var base64: String? {
        self.jpegData(compressionQuality: 1)?.base64EncodedString()
    }
    
    var byteSize: Int {
        return NSData(data: self.jpegData(compressionQuality: 1) ?? Data()).count
    }

    func compress(_ quality: CGFloat = 1.0) -> UIImage  {
        if (quality >= 1) { return self }
        
        return UIImage(data: self.jpegData(compressionQuality: quality) ?? Data()) ?? UIImage()
    }
    
    func resize(width: CGFloat, height: CGFloat = 0) -> UIImage {
        
        if self.size.width < width && self.size.height < height {
            return self
        }
        
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(
            (self.jpegData(compressionQuality: 1.0) ?? Data()) as CFData,
            imageSourceOptions) else {
            return UIImage()
        }
        
        let maxDimensionInPixels = max(
            width > 0 ? min(width, self.size.width) : self.size.width,
            height > 0 ? min(self.size.height, height) : self.size.height
        )
        
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options) else {
            return UIImage()
        }
        
        return UIImage(cgImage: downsampledImage)
    }

    func resize(_ scale: CGFloat = 1.0, quality: CGFloat = 1.0) -> UIImage {
        if (scale == 1 && quality >= 1) { return self }
        
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(
            (self.jpegData(compressionQuality: quality) ?? Data()) as CFData,
            imageSourceOptions) else {
            return UIImage()
        }
        
        // Calculate the desired dimension
        let maxDimensionInPixels = max(self.size.width, self.size.height) * scale
        
        // Perform downsampling
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return UIImage()
        }
        
        // Return the downsampled image as UIImage
        return UIImage(cgImage: downsampledImage)
    }


}

#endif
