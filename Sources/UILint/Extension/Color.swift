//
//  File.swift
//  
//
//  Created by gzhang on 2024/3/13.
//

import Foundation
import SwiftUI


public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    init(hex: Int, alpha: Double = 1) {
        let components = hex > 0x00FFFFFF ? (
            R: Double((hex >> 24) & 0xff) / 255,
            G: Double((hex >> 16) & 0xff) / 255,
            B: Double((hex >> 08) & 0xff) / 255,
            A: Double((hex >> 00) & 0xff) / 255
        ) : (
            R: Double((hex >> 16) & 0xff) / 255,
            G: Double((hex >> 08) & 0xff) / 255,
            B: Double((hex >> 00) & 0xff) / 255,
            A: alpha
        )
        self.init(
            .sRGB,
            red: components.R,
            green: components.G,
            blue: components.B,
            opacity: alpha
        )
    }
    
    static func random() -> Color {
        Color(
            red: Double(arc4random()) / Double(UInt32.max),
            green: Double(arc4random()) / Double(UInt32.max),
            blue: Double(arc4random()) / Double(UInt32.max)
        )
    }
    
}

#if canImport(UIKit)
public extension Color {
    
    var lintRevert: Color { Color(hex: UIColor(self).hexRevert) }
    
    var lintGradient: Color { Color(hex: UIColor(self).hexGradient) }
    
    var lintUI: UIColor { UIColor(self) }
    
    func add(brightness: CGFloat) -> Color { Color(uiColor: lintUI.add(brightness: brightness)) }
    
}
#endif
