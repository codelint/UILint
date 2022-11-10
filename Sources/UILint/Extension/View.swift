//
//  File.swift
//  
//
//  Created by gzhang on 2022/11/10.
//

import Foundation
import SwiftUI

@available(macOS 10.15, *)
extension View {
    
    // 支持 View{}.if() 的写法
    /* 例子
     Text("Hello")
     .if(true) { view in
     view
     .frame(maxWidth: .infinity)
     }
     */
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }


}

/*
 * 平台判定条件封装
 * 用法：
 *    Text("Hello World")
 *        .iOS { $0.padding(10) }
 *
 * @link https://www.hackingwithswift.com/quick-start/swiftui/swiftui-tips-and-tricks
 */
@available(macOS 10.15, *)
extension View {
    func iOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(iOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    func macOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(macOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    func tvOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(tvOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    func watchOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(watchOS)
        return modifier(self)
        #else
        return self
        #endif
    }
}

@available(macOS 10.15, *)
struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

@available(macOS 10.15, *)
extension View {
    // 支持多边配置
    // 例子：.border(width: 3, edges: [.trailing], color: Color.orange)
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
