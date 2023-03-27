//
//  File.swift
//  
//
//  Created by gzhang on 2022/11/10.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public extension View {
    
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
    
    @ViewBuilder func whether<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func whether<YES: View, NO: View>(_ condition: Bool, yes: (Self) -> YES, orNo: (Self) -> NO) -> some View {
        if condition {
            yes(self)
        } else {
            orNo(self)
        }
    }
    
    @ViewBuilder func whether(_ condition: Bool, opacity: CGFloat = 1) -> some View {
        if condition {
            self.opacity(opacity)
        } else {
            self.opacity(0)
        }
    }
    
    
    @ViewBuilder func opacityIf(_ condition: Bool, opacity: CGFloat = 0) -> some View {
        if condition {
            self.opacity(opacity)
        } else {
            self
        }
    }
    
    @ViewBuilder func ifNotNil<Value, Content: View>(_ value: Optional<Value>, transform: (Self, Value) -> Content) -> some View {
        if let v = value {
            transform(self, v)
        } else {
            self
        }
    }
    
    @ViewBuilder func with<Value, Content: View>(_ value: Optional<Value>, transform: (Self, Value) -> Content) -> some View {
        if let v = value {
            transform(self, v)
        } else {
            self
        }
    }
    
    @ViewBuilder func tap<Content: View>(_ transform: (Self) -> Content) -> some View {
        transform(self)
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
public extension View {
    
    func iOS<Content: View>(@ViewBuilder _ modifier: (Self) -> Content) -> some View {
        #if os(iOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    func macOS<Content: View>(@ViewBuilder _ modifier: (Self) -> Content) -> some View {
        #if os(macOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    func tvOS<Content: View>(@ViewBuilder _ modifier: (Self) -> Content) -> some View {
        #if os(tvOS)
        return modifier(self)
        #else
        return self
        #endif
    }
    
    func watchOS<Content: View>(@ViewBuilder _ modifier: (Self) -> Content) -> some View {
        #if os(watchOS)
        return modifier(self)
        #else
        return self
        #endif
    }
}

public struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    public func path(in rect: CGRect) -> Path {
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

public extension View {
    // 支持多边配置
    // 例子：.border(width: 3, edges: [.trailing], color: Color.orange)
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
    
}

// 读取View尺寸（）
public extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

#if canImport(UIKit)
public extension View {
    /*
     // view保存为照片
     // 用法举例
     var textView: some View {
     Text("Hello, SwiftUI")
     }
     var body: some View {
     textView
     Button("Save to image") {
     let image = textView.snapshot()
     UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
     }
     }
     */
    func snapshot() -> UIImage {
        // Bug fixed for iOS 15: since iOS 15 it seems these two modifiers are required.
        // @link: https://www.vinzius.com/post/how-to-remove-padding-when-snapshotting-swiftui-view-ios15/
        let controller = UIHostingController(
            rootView: self.ignoresSafeArea()
                .fixedSize(horizontal: true, vertical: true)
        )
        
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }

}

#endif


public extension View {
    
    @ViewBuilder func borderRadius(radius: CGFloat, color: Color, width: CGFloat) -> some View {
        self.cornerRadius(radius).overlay {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                     .stroke(color, lineWidth: width)
        }
    }
    
}
