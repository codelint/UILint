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
    
    func clamped(_ value: Value, to range: ClosedRange<CGFloat>) -> CGFloat {
        self > range.upperBound ? range.upperBound : (self < range.lowerBound ? range.lowerBound : self)
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
        
        red = red*255 + theta
        green = green*255 + theta
        blue = blue*255 + theta
        
        let min = min(red, green, blue)
        let max = max(red, green, blue)
        if min < 0 {
            red = red - min
            green = green - min
            blue = blue - min
        }
        if max > 255 {
            red = red + 255 - max
            green = green + 255 - max
            blue = blue + 255 - max
        }
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
#endif
