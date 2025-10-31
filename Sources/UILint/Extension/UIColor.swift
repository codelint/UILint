//
//  File.swift
//  
//
//  Created by gzhang on 2024/3/13.
//

import Foundation
#if canImport(UIKit)
import UIKit

public extension UIColor {
    
    func clamped(_ value: CGFloat, to range: ClosedRange<CGFloat>) -> CGFloat {
        value > range.upperBound ? range.upperBound : (value < range.lowerBound ? range.lowerBound : value)
    }
    
    var ARGBHex: String {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X%02X", Int(alpha*255), Int(red*255), Int(green*255), Int(blue*255)).uppercased()
    }
    
    var RGBHex: String {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X", Int(red*255), Int(green*255), Int(blue*255)).uppercased()
    }
    
    var hexRevert: String {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red = clamped((1 - red), to: 0...1)
        green = clamped((1 - green), to: 0...1)
        blue = clamped((1 - blue), to: 0...1)
        return String(format: "#%02X%02X%02X", Int(red*255), Int(green*255), Int(blue*255)).uppercased()
    }
    
    var hexGradient: String {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let gray = clamped(((green + blue + red)/3), to: 0...1)*255
        return String(format: "#%02X%02X%02X", Int(gray), Int(gray), Int(gray)).uppercased()
    }
    
    var intGradient: Int {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Int(clamped(((green + blue + red)/3), to: 0...1)*255)
    }
    
    func add(brightness theta: CGFloat) -> UIColor {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let mi = min(red, green, blue)
        let ma = max(red, green, blue)
        let theta = theta > 0 ? min(255 - ma*255, theta) : max(0 - mi*255, theta)
        
        red = red*255 + theta
        green = green*255 + theta
        blue = blue*255 + theta

        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    func brightness(enhance percent: CGFloat) -> UIColor {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let mi = min(red, green, blue)
        let ma = max(red, green, blue)
        let theta = 255*(mi + percent*(1 - ma + mi))
        
        red = red*255 + theta
        green = green*255 + theta
        blue = blue*255 + theta

        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}

public extension UIColor {
    
    func lint(distance color: UIColor) -> CGFloat {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let redDiff = r1 - r2
        let greenDiff = g1 - g2
        let blueDiff = b1 - b2
        
        return sqrt(redDiff * redDiff + greenDiff * greenDiff + blueDiff * blueDiff)
    }
    
    func lint(nearest a: UIColor, _ b: UIColor) -> UIColor {
        return lint(distance: a) <= lint(distance: b) ? a : b
    }
    
    func lint(further a: UIColor, _ b: UIColor) -> UIColor {
        return lint(distance: a) > lint(distance: b) ? a : b
    }
}
#endif
