//
//  File.swift
//  
//
//  Created by gzhang on 2024/3/13.
//

import Foundation

#if canImport(UIKit)
extension UIColor {
    
    var ARGBHex: String {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X%02X", (alpha*255).int, (red*255).int, (green*255).int, (blue*255).int).uppercased()
    }
    
    var RGBHex: String {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X", (red*255).int, (green*255).int, (blue*255).int).uppercased()
    }
    
    var hexRevert: String {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red = (1 - red).clamped(to: 0...1)
        green = (1 - green).clamped(to: 0...1)
        blue = (1 - blue).clamped(to: 0...1)
        return String(format: "#%02X%02X%02X", (red*255).int, (green*255).int, (blue*255).int).uppercased()
    }
    
    var hexGradient: String {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let gray = ((green + blue + red)/3).clamped(to: 0...1)*255
        return String(format: "#%02X%02X%02X", gray.int, gray.int, gray.int).uppercased()
    }
    
    var intGradient: Int {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (((green + blue + red)/3).clamped(to: 0...1)*255).int
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
