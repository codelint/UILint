//
//  File.swift
//  
//
//  Created by gzhang on 2022/11/10.
//

import Foundation
#if canImport(UIKit)
import UIKit
import Vision
import CryptoKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension CGFloat {
    func uiLint(to range: ClosedRange<CGFloat>) -> CGFloat {
        return self > range.upperBound ? range.upperBound : (self < range.lowerBound ? range.lowerBound : self)
    }
}

public extension UIImage {
    
    var base64: String? {
        self.jpegData(compressionQuality: 1)?.base64EncodedString()
    }
    
    var byteInt: Int {
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

@available(iOS 16, *)
public extension UIImage {
    
    var barcodes: [String] {
        guard let ci = CIImage(image: self) else { return [] }
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        return detector.features(in: ci).map({ feature  in
            if let qr = feature as? CIQRCodeFeature {
                return qr.messageString
            }else{
                return nil
            }
        })
        .filter({ $0 != nil }).map({ $0! })
    }
    
    func lint(languages: [String] = [], strings transform: @escaping ([String]) -> Void){
        let uiImage = self
        
        let handler = VNImageRequestHandler(cgImage: uiImage.cgImage!, options: [:])
        let request = VNRecognizeTextRequest(completionHandler: { req, err in
            guard let results = req.results as? [VNRecognizedTextObservation] else {
                return
            }
            var texts: [String] = []
            if results.count > 0 {
                for result in results {
                    texts.append(result.topCandidates(1).first?.string ?? "xxx")
                }
            }
            transform(texts)
        })
        // print(Bundle.main.preferredLocalizations.stringified ?? "")
        request.recognitionLanguages = languages.count > 0 ? languages : Bundle.main.preferredLocalizations
        // request.recognitionLevel = .accurate
        request.automaticallyDetectsLanguage = false
        
        do {
            try handler.perform([request])
        }catch {
            transform([])
        }
    }
        
    var md5: String? {
        guard let imgData = jpegData(compressionQuality: 1.0) else { return nil }
        return Insecure.MD5.hash(data: imgData).map({ String(format: "%02x", $0) }).joined()
    }
    
    func lintCrop(width: CGFloat, height: CGFloat, offset: CGSize = .zero) -> UIImage {
        let offset: CGSize = .init(width: offset.width*size.width, height: offset.height*size.height)
        let ow = size.width - abs(offset.width)*2
        let oh = size.height - abs(offset.height)*2
        var tw: CGFloat, th: CGFloat
        var x: CGFloat, y: CGFloat
        // let minDim = min(ow, oh)
        if ow/oh < width/height {
            tw = ow
            th = ow*(height/width)
            x = 0
            y = (oh - th)/2
        }else{
            tw = oh*(width/height)
            th = oh
            // ow/oh > tw/th , th == oh
            x = (ow - tw)/2
            y = 0
        }
        
        let ox = offset.width < 0 ? 2*abs(offset.width) : 0
        let oy  = offset.height < 0 ? 2*abs(offset.height) : 0
        
        x = ox + x
        y = oy + y
        
        let squareRect = CGRect(x: x, y: y , width: tw, height: th)
        
        let render = UIGraphicsImageRenderer(size: squareRect.size)
        let cropped = render.image { context in
            self.draw(at: .init(x: -squareRect.origin.x, y: -squareRect.origin.y))
        }
        
        return cropped
    }
    
    func lint(lomo opacity: CGFloat) -> UIImage? {
        guard let ci = CIImage(image: self) else { return nil }
        
        let colorControls = CIFilter.colorControls()
        let vignetteFilter = CIFilter.vignette()
        let sepiaFilter = CIFilter.sepiaTone()
//        let edgeWorkFilter = CIFilter.unsharpMask()
        let sharpFilter = CIFilter.sharpenLuminance()
//
        let intensity = Float(opacity.uiLint(to: 0...1))
        
        colorControls.inputImage = ci
        colorControls.saturation = 0.5
        colorControls.brightness = 0.1
        colorControls.contrast = 1.1

        vignetteFilter.inputImage = colorControls.outputImage
        vignetteFilter.intensity = intensity
        
        sepiaFilter.inputImage = vignetteFilter.outputImage
        sepiaFilter.intensity = 0.05
        
        sharpFilter.inputImage = sepiaFilter.outputImage

        guard let output = sharpFilter.outputImage else { return nil }
        
        let context = CIContext()
        guard let cgi = context.createCGImage(output, from: output.extent) else { return nil }
        
        return UIImage(cgImage: cgi, scale: 1.0, orientation: self.imageOrientation)
    }
    
    func lint(resize scale: CGFloat) -> UIImage? {
        let scale = scale.uiLint(to: 0...1)
        let image = self
        let newSize: CGSize = .init(width: image.size.width*scale, height: image.size.height*scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: .init(origin: .zero, size: newSize))
        let resizedImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImg
    }
            
    func lint(rotate angle: CGFloat) -> UIImage {
        let radian = angle * .pi / 180
        let rotatedSize = CGRect(origin: .zero, size: size).applying(CGAffineTransform(rotationAngle: radian)).size
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        let rect = CGRect(origin: .zero, size: size)
        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: angle * .pi / 180)
        context.translateBy(x: -rect.midX, y: -rect.midY)
        draw(in: rect)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage.resize(width: max(size.width, size.height), height: max(size.width, size.height))
    }
    
    func lintFlipVeritcally() -> UIImage? {
        guard let cgi = self.cgImage else { return nil}
        let wid = cgi.width
        let hei = cgi.height
        let bytesPerPixel = 4
        let bytesPerRow = wid * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: wid, height: hei, bitsPerComponent: cgi.bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = context else { return nil }
        
        context.translateBy(x: 0, y: CGFloat(hei))
        context.scaleBy(x: 1, y: -1)
        context.draw(cgi, in: .init(x: 0, y: 0, width: wid, height: hei))
        
        guard let mi = context.makeImage() else { return  nil }
        
        return UIImage(cgImage: mi)
    }
    
    func lint(dominants count: Int, alpha opacity: CGFloat = 0.5) -> [UIColor]? {
        guard let cgImage = self.cgImage,
              let provider = cgImage.dataProvider,
              let providerData = provider.data,
              let _ = CFDataGetBytePtr(providerData) else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let pixelCount = width * height
        var pixels = [UInt32](repeating: 0, count: pixelCount)
        
        // 创建 RGB 颜色空间
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        )
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 统计颜色出现频率
        var colorFrequency = [UIColor: Int]()
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width) + x
                let pixel = pixels[offset]
                let a = CGFloat((pixel >> 24) & 0xFF) / 255.0
                let b = CGFloat((pixel >> 16) & 0xFF) / 255.0
                let g = CGFloat((pixel >> 8) & 0xFF) / 255.0
                let r = CGFloat(pixel & 0xFF) / 255.0
                
                // 忽略透明或接近透明的像素
                guard a > opacity else { continue }
                
                
                let color = UIColor(red: r, green: g, blue: b, alpha: CGFloat(Int(a*100)/10)/10)
                colorFrequency[color] = (colorFrequency[color] ?? 0) + 1
            }
        }
        
        // 按频率排序并返回前N个颜色
        let sortedColors = colorFrequency.sorted { $0.value > $1.value }
        return Array(sortedColors.prefix(count).map { $0.key })
    }
    
    static func lint(QRCode text: String, size: CGSize) -> UIImage? {
        let ciContext = CIContext(options: nil)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let strData = text.data(using: .utf8, allowLossyConversion: false)
        filter.setDefaults()
        filter.setValue(strData, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        
        guard let qrImage = filter.outputImage else { return nil }

        let scaleX = size.width / qrImage.extent.width
        let scaleY = size.height / qrImage.extent.height
        
        let scale = min(scaleX, scaleY)
        
        let transformedImage = qrImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        if let cgImage = ciContext.createCGImage(transformedImage, from: transformedImage.extent) {
            return UIImage(cgImage: cgImage)
        }else{
            return nil
        }
    }
    
    
}

#endif
