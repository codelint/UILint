//
//  File.swift
//  UILint
//
//  Created by gzhang on 2025/10/31.
//

import Foundation
import SwiftUI
import CoreText

public extension CGFont {
    
    /**
     * Get CGFont from url
     */
    static func lint(font url: URL) -> CGFont?{
        do {
            let fontData = try Data(contentsOf: url)
            if let fontDataProvider = CGDataProvider(data: fontData as CFData), let font = CGFont(fontDataProvider) {
                return font
            }else{
                return nil
            }
        } catch {
            return nil
        }
    }
    
    /**
     * Get the font name from url
     */
    static func lint(fontName url: URL?) -> String? {
        if let url = url, let font = lint(font: url) {
            let ctFont = CTFontCreateWithGraphicsFont(font, 12, nil, nil)
            return CTFontCopyName(ctFont, kCTFontFullNameKey) as? String
        }else{
            return nil
        }
    }
    
    /**
     * Register font from url 
     */
    static func lint(register url: URL) -> CGFont? {
        do {
            let fontData = try Data(contentsOf: url)
            if let fontDataProvider = CGDataProvider(data: fontData as CFData), let font = CGFont(fontDataProvider) {
                if font.registered {
                    return font
                }
                
                var error: Unmanaged<CFError>?
                
                if CTFontManagerRegisterGraphicsFont(font, &error) {
                    return font
                } else {
                    print(error.debugDescription)
                    return nil
                }
            }else{
                return nil
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
     
    static func lint(registered url: URL) -> Bool { lint(font: url)?.registered ?? false }
    
    var registered: Bool {
        let registeredFonts = CTFontManagerCopyAvailableFontFamilyNames() as? [String] ?? []
        let ctFont = CTFontCreateWithGraphicsFont(self, 12, nil, nil)
        if let name = CTFontCopyName(ctFont, kCTFontFamilyNameKey) as? String {
            return registeredFonts.contains { $0 == name }
        }else{
            return false
        }
    }
}
public enum LintFont: String, CaseIterable {
    case largeTitle, title, title2, title3
    case body, headline
    case callout, subheadline
    case footnote
    case caption, caption2, caption3
    
    public var size: CGFloat {
        switch self {
        case .largeTitle: 32
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline: 17
        case .body: 17
        case .callout : 16
        case .subheadline: 15
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        case .caption3: 8
        }
    }
    
    public var weight: Font.Weight? {
        switch self {
        case .title, .title2, .title3, .headline: .semibold
        default: .regular
        }
    }
}


@available(iOS 16, *)
public extension View {
    
    // @ViewBuilder func lint(font: Font) -> some View { self.font(font) }
    @ViewBuilder func lintFont(size: CGFloat, family name: String? = nil) -> some View {
        if let fontName = name == nil || name!.count == 0 ? UserDefaults.standard.string(forKey: "LINT_FONT") : name, fontName.count > 0 {
            self.font(.custom(fontName, size: size))
        }else{
            self.font(.custom("", size: size))
        }
    }
    
    @ViewBuilder func lintFont(_ font: LintFont?, with name: String? = nil) -> some View {
        if let font = font {
            if let fontName = name == nil || name!.count == 0 ? UserDefaults.standard.string(forKey: "LINT_FONT") : name, fontName.count > 0 {
                self.font(.custom(fontName, size: font.size)).fontWeight(font.weight)
            }else{
                switch font {
                case .largeTitle: self.font(.largeTitle)
                case .title: self.font(.title)
                case .title2: self.font(.title2)
                case .title3: self.font(.title3)
                case .body: self.font(.body)
                case .headline: self.font(.headline)
                case .callout: self.font(.callout)
                case .subheadline: self.font(.subheadline)
                case .footnote: self.font(.footnote)
                case .caption: self.font(.caption)
                case .caption2: self.font(.caption2)
                case .caption3: self.lintFont(size: 8)
                @unknown default: self.font(.body)
                }
            }
        }else{
            if let fontName = name ?? UserDefaults.standard.string(forKey: "LINT_FONT") {
                self.font(.custom(fontName, size: LintFont.body.size))
            }else{
                self
            }
        }
    }
   
}

public extension Font {
    
    static func lint(_ font: LintFont, with name: String? = nil) -> Font {
        if let fontName = name == nil || name!.count == 0 ? UserDefaults.standard.string(forKey: "LINT_FONT") : name, fontName.count > 0 {
            .custom(fontName, size: font.size)
        }else{
            switch font {
            case .largeTitle: .largeTitle
            case .title: .title
            case .title2: .title2
            case .title3: .title3
            case .body: .body
            case .headline: .headline
            case .callout: .callout
            case .subheadline: .subheadline
            case .footnote: .footnote
            case .caption: .caption
            case .caption2: .caption2
            case .caption3: .custom("", size: 8)
            @unknown default: .body
            }
        }
    }
    
}


