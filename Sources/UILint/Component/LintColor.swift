//
//  File.swift
//  UILint
//
//  Created by gzhang on 2025/10/30.
//

import Foundation
import SwiftUI

public enum LintColor: String, CaseIterable, Codable {
    
    public static let buttonColors: Set<Self> = [.primary,
        .blue, .yellow, .red, .orange, .green, .cyan, .gray, .purple,
        .success, .danger, .warning
    ]
    
    public static let sevenColors: [Self] = [.red, .orange, .yellow, .green, .blue, .purple, .cyan]
    
    case primary, primary_font, background, block, font
    case btn_font, secondary
    case listBackground, listItemBackground, listItemFont
    case success, danger, warning
    
    case blue, yellow, red, orange, green, purple, cyan, gray, pink
    
    case golden, silver, bronze
    
    case success_font, danger_font, warning_font
    case secondary_font
    case blue_font, yellow_font, red_font, orange_font
    case green_font, purple_font, cyan_font, gray_font
    case pink_font
    
    public var defaultsKey: String {
        "lint.theme.\(self.rawValue)"
    }
    
    public var fonts: [LintColor] { Self.fonts(background: self) }
    
    public static func fonts(background: LintColor) -> [LintColor] {
        if let color = LintColor(rawValue: "\(background.rawValue)_font") {
            return [
                color,
                buttonColors.contains(background) ? .btn_font : .font
            ]
        }else{
            return [buttonColors.contains(background) ? .btn_font : .font]
        }
    }
    
    public var font: LintColor {
        if let fc = LintColor(rawValue: "\(rawValue)_font") {
            return fc
        }
        switch self {
        case .listItemBackground, .listBackground:
            return .listItemFont
        case .blue, .yellow, .red, .orange, .green, .purple, .cyan, .gray:
            return .btn_font
        default:
            return .font
        }
    }
    
}

public extension Color {
    
    static var LINT_COLORS: [LintColor: String] = [:]

    static func lint(c color: LintColor) -> Color {
        if !linted() {
            return Color(color)
        }
        if let hex = Self.LINT_COLORS[color] {
            return Color(hex: hex)
        }else{
            return Color(color)
        }
    }
        
    static func linted() -> Bool { LINT_COLORS.count > 0 }
    
    init(_ color: LintColor, prefix: String = "c_"){ self.init("\(prefix)\(color.rawValue)") }
        
    func lint(opacity: CGFloat, base: CGFloat = 0.0) -> Color {
        let b = min(1.0, max(0.0, base))
        return self.opacity(min(1.0, max(0.0, b + (1-b)*opacity)))
    }
 
    func lint(further a: Color, _ b: Color) -> Color { return .init(uiColor: lintUI.lint(further: a.lintUI, b.lintUI)) }
    
    @available(iOS 16, *)
    static func lint(base64: String) -> Color? {
        if let data = Data(base64Encoded: base64), let uc = UIImage(data: data)?.lint(dominants: 1)?.first {
            return .init(uiColor: uc)
        }else {
            return nil
        }
    }

}

//public extension View {
//    @ViewBuilder var standardColors: some View { self.foregroundColor(.lint(c: .font)).background(Color.lint(c: .background)) }
//    
//    @ViewBuilder var standardFont: some View { self.lint(font: .body) }
//    
//    @ViewBuilder var standardPage: some View { self.standardColors.standardFont.buttonStyle(.plain) }
//}
