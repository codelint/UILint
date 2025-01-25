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
        
        let min = min(red, green, blue)
        let max = max(red, green, blue)
        let theta = theta > 0 ? min(255 - max*255, theta) : max(0 - min*255, theta)
        
        red = red*255 + theta
        green = green*255 + theta
        blue = blue*255 + theta

        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    func brightness(enhance percent: CGFloat) -> UIColor {
        var red = CGFloat.zero, blue = CGFloat.zero, green = CGFloat.zero, alpha = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let min = min(red, green, blue)
        let max = max(red, green, blue)
        let theta = 255*(min + percent*(1 - max + min))
        
        red = red*255 + theta
        green = green*255 + theta
        blue = blue*255 + theta

        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
#endif
