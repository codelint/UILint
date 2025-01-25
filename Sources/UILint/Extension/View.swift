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
    
    /**
     *  sample
     *   View().lint { view in
     *      if yesOrNot {
     *          view.opacity(1)
     *      }else{
     *          view.opacity(0)
     *      }
     *   }
     */
    @ViewBuilder func lint<Content: View>(@ViewBuilder _ view: (Self) -> Content) -> some View {
        view(self)
    }
    
    @ViewBuilder func lint<Content: View>(transform view: (Self) -> Content) -> some View { view(self) }
    
    @ViewBuilder func lint(opacityIf condition: Bool, _ opacity: CGFloat = 0) -> some View {
        if condition {
            self.opacity(opacity)
        } else {
            self
        }
    }
    
    
    /**
     * Optional
     */
    @ViewBuilder func lint<Value, Content: View>(notNil value: Optional<Value>, @ViewBuilder view transform: (Self, Value) -> Content) -> some View {
        if let v = value {
            transform(self, v)
        } else {
            self
        }
    }
    
    @ViewBuilder func lint<Value, Content: View>(with value: Optional<Value>, @ViewBuilder view transform: (Self, Value) -> Content) -> some View {
        if let v = value {
            transform(self, v)
        } else {
            self
        }
    }
    
    @ViewBuilder func lint<Value, VIF: View, VELSE: View>(with value: Optional<Value>, @ViewBuilder vif: (Self, Value) -> VIF, @ViewBuilder velse: (Self) -> VELSE) -> some View {
        if let value = value {
            vif(self, value)
        }else{
            velse(self)
        }
    }
    
    @ViewBuilder func lint<Value, VELSE: View>(without value: Optional<Value>, @ViewBuilder transform: (Self) -> VELSE) -> some View {
        if nil == value {
            transform(self)
        }else{
            self
        }
    }
    
    /**
     * Bool
     */
    
    @ViewBuilder func lint<YES: View, NO: View>(bool condition: Bool, @ViewBuilder vif yes: @escaping (Self) -> YES, @ViewBuilder velse not: @escaping (Self) -> NO) -> some View {
        if condition { yes(self) } else { not(self) }
    }
    
    @ViewBuilder func lint<YES: View, NO: View>(bool condition: Bool, @ViewBuilder yes: @escaping (Self) -> YES, @ViewBuilder not: @escaping (Self) -> NO) -> some View {
        if condition { yes(self) } else { not(self) }
    }
    
    @ViewBuilder func lint<Content: View>(bool condition: Bool, @ViewBuilder view: @escaping (Self) -> Content) -> some View {
        lint(bool: condition, yes: view, not: { $0 })
    }
    
    @ViewBuilder func lint<Content: View>(vif condition: Bool, @ViewBuilder transform: @escaping (Self) -> Content) -> some View { lint(bool: condition, yes: transform, not: { $0 }) }
    
    @ViewBuilder func lint<Content: View>(velse condition: Bool, @ViewBuilder transform: @escaping (Self) -> Content) -> some View { lint(bool: condition, yes: { $0 }, not: transform) }
    
    @ViewBuilder func lint<Content: View>(bool condition: Bool, transform: @escaping (Self) -> Content) -> some View {  lint(vif: condition, transform: transform) }
    
    @ViewBuilder func lint(vif bool: Bool) -> some View {
        if bool {
            self
        }
    }
    
    // 支持 View{}.if() 的写法
    /* 例子
     Text("Hello")
     .if(true) { view in
     view
     .frame(maxWidth: .infinity)
     }
     * @deprecated
     */
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: @escaping (Self) -> Content) -> some View {
        self.lint(bool: condition, view: transform)
    }
    
    /**
     * naming more human, but easy to conflict with other lib
     */
    @ViewBuilder func whether<Content: View>(_ condition: Bool, @ViewBuilder transform: @escaping (Self) -> Content) -> some View {
        self.lint(bool: condition, view: transform)
    }
    
    @ViewBuilder func whether<YES: View, NO: View>(_ condition: Bool,@ViewBuilder yes: @escaping (Self) -> YES, @ViewBuilder orNo: @escaping (Self) -> NO) -> some View {
        self.lint(bool: condition, yes: yes, not: orNo)
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
    
    @ViewBuilder func ifNotNil<Value, Content: View>(_ value: Optional<Value>,@ViewBuilder transform: (Self, Value) -> Content) -> some View {
        lint(notNil: value, view: transform)
    }
    
    @ViewBuilder func with<Value, Content: View>(_ value: Optional<Value>, @ViewBuilder transform: (Self, Value) -> Content) -> some View {
        lint(with: value, view: transform)
    }
    
    @ViewBuilder func tap<Content: View>(@ViewBuilder _ transform: (Self) -> Content) -> some View { lint(transform) }
    
}

public extension View {
    
    @ViewBuilder func lint<Value, Content: View>(within values: [Optional<Value>], @ViewBuilder view transform: (Self, Value) -> Content) -> some View {
        if let v = values.reduce(nil, { $0 == nil ? $1 : $0 }) {
            transform(self, v)
        } else {
            self
        }
    }
    
    @ViewBuilder func lint<Value, Content: View>(withs values: [Optional<Value>], @ViewBuilder view content: (Self, [Value]) -> Content) -> some View {
        let notNils = values.filter({ $0 != nil }).map({ $0! })
        if notNils.count == values.count {
            content(self, notNils)
        }else{
            self
        }
    }
    
    @ViewBuilder func lint<Value, VIF: View, VELSE: View>(within values: [Optional<Value>], @ViewBuilder exist: (Self, Value) -> VIF, @ViewBuilder nothing: (Self) -> VELSE) -> some View {
        if let v = values.reduce(nil, { $0 == nil ? $1 : $0 }) {
            exist(self, v)
        } else {
            nothing(self)
        }
    }
    
    @ViewBuilder func lint(horizontal padding: CGFloat) -> some View {
        HStack(spacing: padding){
            Spacer(minLength: padding)
            self
            Spacer(minLength: padding)
        }
    }
    
    @ViewBuilder func lint(vertical padding: CGFloat) -> some View {
        VStack(spacing: padding){
            Spacer(minLength: padding)
            self
            Spacer(minLength: padding)
        }
    }
    
    @ViewBuilder func lint(scroll axis: Axis.Set, showsIndicators: Bool = false) -> some View {
        ScrollView(axis, showsIndicators: false) {
            self
        }
    }
    
    @ViewBuilder func lint(center padding: CGFloat) -> some View {
        self.lint(horizontal: padding).lint(vertical: padding)
    }
    
}

/**
 * UserDefaults related
 */
public extension View {
    @ViewBuilder func lint<Value, VIF: View, VELSE: View>(userKey key: String, @ViewBuilder vif: (Self, Value) -> VIF, @ViewBuilder velse: (Self) -> VELSE) -> some View {
        if let value = UserDefaults.standard.object(forKey: key) as? Value {
            vif(self, value)
        }else{
            velse(self)
        }
    }
    
    @ViewBuilder func lint<Value, Content: View>(userKey key: String, @ViewBuilder vif transform: (Self, Value) -> Content) -> some View {
        lint(userKey: key, vif: transform, velse: { $0 })
    }
    
    @ViewBuilder func lint<Value, Content: View>(userKey key: String, @ViewBuilder velse transform: (Self) -> Content) -> some View {
        if nil == UserDefaults.standard.object(forKey: key) as? Value {
            transform(self)
        }else{
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
public extension View {
    
    /**
     * view for ios
     */
    func lintIOS<Content: View>(@ViewBuilder view: (Self) -> Content) -> some View {
        #if os(iOS)
        return view(self)
        #else
        return self
        #endif
    }
    
    
    /**
     * view for macOS
     */
    func lintMacOS<Content: View>(@ViewBuilder view: (Self) -> Content) -> some View {
        #if os(macOS)
        return view(self)
        #else
        return self
        #endif
    }
    
    /**
     * view for tvOS
     */
    func lintTvOS<Content: View>(@ViewBuilder view: (Self) -> Content) -> some View {
        #if os(tvOS)
        return view(self)
        #else
        return self
        #endif
    }
    
    /**
     * view for watchOS
     */
    func lintWatchOS<Content: View>(@ViewBuilder view: (Self) -> Content) -> some View {
        #if os(watchOS)
        return view(self)
        #else
        return self
        #endif
    }
    
}

public struct LintEdgeBorder: Shape {
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
        overlay(LintEdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
    
    func border(width: CGFloat, edge: Edge, color: Color) -> some View {
        overlay(LintEdgeBorder(width: width, edges: [edge]).foregroundColor(color))
    }
}

// 读取View尺寸（）
public extension View {
    
    func lintSize(_ onSize: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onSize)
    }
    
    func readSize(_ perform: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: perform)
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
    
    func borderRadius(radius: CGFloat, color: Color, width: CGFloat) -> some View {
        self.cornerRadius(radius).overlay {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                     .stroke(color, lineWidth: width)
        }
    }
    
    func lint(border: Color, width: CGFloat = 1, radius: CGFloat = 0) -> some View {
        cornerRadius(radius).overlay {
            RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(border, lineWidth: width)
        }
    }
    
}


/**
 * helper component
 */

public extension View {
    
    @ViewBuilder func lint(refresh interval: TimeInterval) -> some View {
        LintTimer(interval: interval, content: { date in
            if date <= Date() {
                self
            }else{
                self
            }
        })
    }

}
