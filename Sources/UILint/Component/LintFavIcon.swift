//
//  File.swift
//  UILint
//
//  Created by gzhang on 2025/10/31.
//

import Foundation
import SwiftUI

public struct LintFavIcon: View {
    
    let url: String
    
    @State private var base64String: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var loaded: Bool = false
    
    var size: CGFloat = 48
    var placeholding: Bool = false
    
    var onLoaded: ((String) -> Void)? = nil
    
    public init(url: String, size: CGFloat = 48, placeholding: Bool = false, onLoaded: ((String) -> Void)? = nil) {
        self.url = url
        self.size = size
        self.placeholding = placeholding
        self.onLoaded = onLoaded
    }
    
    @ViewBuilder var dimg: some View {
        if placeholding {
            Image(systemName: "photo").font(.custom("", size: size*0.75))
        }
    }
    
    public var body: some View {
        if url.starts(with: "base64://") {
            VStack{
                if let image = imageFromBase64(String(url.dropFirst("base64://".count))) {
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)
                }else {
                    dimg
                }
            }.frame(width: size, height: size, alignment: .center)
        }else{
            
            VStack(spacing: 20) {
                if isLoading {
                    ZStack{
                        dimg
                        ProgressView()
                    }
                } else if let _ = errorMessage {
                    dimg
                } else if !base64String.isEmpty, let image = imageFromBase64(base64String){
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fit).onAppear(){
                        onLoaded?(base64String)
                    }
                }else{
                    dimg
                }
            }
            .frame(width: size, height: size, alignment: .center)
            .lint(changeOf: errorMessage, perform: { _ in
                loaded = true
            })
            .onAppear(after: 20, perform: {
                loadAndConvert()
            })
            .whether(!placeholding || !loaded)
        }
        
    }
    
    func loadAndConvert() {
        guard let url = URL(string: url) else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        base64String = ""
        
        // 首先检查是否是直接图片URL
        if isImageURL(url) {
            fetchAndProcessImage(url: url)
        } else {
            // 是网页URL，需要提取favicon
            extractFaviconURL(from: url) { faviconURL in
                if let faviconURL = faviconURL {
                    fetchAndProcessImage(url: faviconURL)
                } else if let defaultFaviconURL = URL(string: "/favicon.ico", relativeTo: url)?.absoluteURL {
                    fetchAndProcessImage(url: defaultFaviconURL)
                } else {
                    DispatchQueue.main.async {
                        isLoading = false
                        errorMessage = "Could not find favicon"
                        print("Could not find favicon")
                    }
                }
            }
        }
    }
    
    // 判断URL是否是图片
    func isImageURL(_ url: URL) -> Bool {
        let path = url.path.lowercased()
        return path.hasSuffix(".ico") || path.hasSuffix(".png") || path.hasSuffix(".jpg") || path.hasSuffix(".jpeg") || path.hasSuffix(".gif")
    }
    
    // 从网页HTML中提取favicon URL
    func extractFaviconURL(from pageURL: URL, completion: @escaping (URL?) -> Void) {
        URLSession.shared.dataTask(with: pageURL) { data, response, error in
            guard let data = data,
                  let htmlString = String(data: data, encoding: .utf8),
                  error == nil else {
                completion(nil)
                return
            }
            
            // 使用简单正则表达式查找favicon链接
            let pattern = "<link[^><]*?rel=\"[^><]*?icon[^><]*?\"[^><]*?href=\"(.*?)\"[^><]*?>"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: htmlString.utf16.count)
                if let match = regex.firstMatch(in: htmlString, options: [], range: range),
                   let hrefRange = Range(match.range(at: 1), in: htmlString) {
                    let href = String(htmlString[hrefRange])
                    if let faviconURL = URL(string: href, relativeTo: pageURL)?.absoluteURL {
                        completion(faviconURL)
                        return
                    }
                }
            }
            let p2 = "<link[^><]*?href=\"(.*?)\"[^><]*?rel=\"[^><]*?icon[^><]*?\"[^><]*?>"
            if let regex = try? NSRegularExpression(pattern: p2, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: htmlString.utf16.count)
                if let match = regex.firstMatch(in: htmlString, options: [], range: range),
                   let hrefRange = Range(match.range(at: 1), in: htmlString) {
                    let href = String(htmlString[hrefRange])
                    if let faviconURL = URL(string: href, relativeTo: pageURL)?.absoluteURL {
                        completion(faviconURL)
                        return
                    }
                }
            }
            
            completion(nil)
        }.resume()
    }
    
    // 获取并处理图片
    func fetchAndProcessImage(url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                // 处理图片数据
                self.processImageData(data)
            }
        }.resume()
    }
    
    func processImageData(_ data: Data) {
        // 尝试将数据转换为UIImage
        guard let image = UIImage(data: data) else {
            errorMessage = "Failed to create image from data"
            return
        }
        
        // 检查并调整尺寸
        let resizedImage: UIImage
        if image.size.width > 144 || image.size.height > 144 {
            resizedImage = resizeImage(image, maxDimension: 144)
        } else {
            resizedImage = image
        }
        
        // 转换为PNG数据的Base64字符串
        if let pngData = resizedImage.pngData() {
            base64String = pngData.base64EncodedString()
        } else {
            errorMessage = "Failed to convert image to PNG"
        }
    }
    
    // 缩放图片，保持宽高比
    func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let widthRatio = maxDimension / size.width
        let heightRatio = maxDimension / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    // 从Base64字符串创建UIImage
    func imageFromBase64(_ base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
}

#Preview {
    LintFavIcon(url:"https://www.geekpark.net", size: 64, placeholding: false)
}
