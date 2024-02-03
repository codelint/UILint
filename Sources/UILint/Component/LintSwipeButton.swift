//
//  SwipeButton.swift
//  trac
//
//  Created by gzhang on 2021/6/7.
//

import Foundation
import SwiftUI

public struct LintSwipeButton<Content:View>: View {
    
    @GestureState private var translation: CGSize = .zero
    @State var buttonWidth: CGFloat = .zero
    @State var widths: [String:CGFloat] = [String:CGFloat]()
    @State var isDragging = false
    @State var scrollX: CGFloat = .zero
    @State var contentHeight: CGFloat = .zero
    @State var contentWidth: CGFloat = .zero
    @State var selected: Int? = nil
    
    var options: [ButtonOption] = []
    
    @ViewBuilder
    var content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public init(defines: [ButtonDefine], @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        for define in defines {
            switch define {
            case .common(let text, let bgColor, let action):
                if text.count > 0 {
                    options.append(ButtonOption(text: text, backgroundColor: bgColor, foregroundColor: .white, action: action))
                }
            case .quick(let text, let bgColor, let action):
                if text.count > 0 {
                    options.append(ButtonOption(text: text, backgroundColor: bgColor, foregroundColor: .white, isTip: false, action: action))
                }
            case .custom(let text, let bgColor, let color, let action):
                options.append(ButtonOption(text: text, backgroundColor: bgColor, foregroundColor: color, action: action))
            case .simple(let text, let bgColor):
                options.append(ButtonOption(text: text, backgroundColor: bgColor))
            case .icon(let icon, let bgColor, let action):
                if icon.count > 0 {
                    options.append(ButtonOption(text: icon, icon: icon, backgroundColor: bgColor, foregroundColor: .white, isTip: false, action: action))
                }
            case .icon2(let icon, let bgColor, let action):
                if icon.count > 0 {
                    options.append(ButtonOption(text: icon, icon: icon, backgroundColor: bgColor, foregroundColor: .white, isTip: true, action: action))
                }
            }
        }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { event in
                withAnimation {
                    self.isDragging = true
                    if(event.translation.width > 0){
                        self.scrollX = 0
                    }else{
                        self.scrollX = event.translation.width + buttonWidth > 0 ? (abs(event.translation.width) > 16 ? event.translation.width: 0) : (0-buttonWidth)
                    }
                }
                
            }
            .onEnded { event in
                // print("ended...")
                let x = (event.translation.width + buttonWidth/2) > 0 ?  0 : (0-buttonWidth)
                // x = self.scrollX < -32 && self.scrollX > 32 ? self.scrollX : 0
                withAnimation(.linear(duration: 0.2)) {
                    self.isDragging = false
                    self.scrollX = x
                }
                
                if self.scrollX < 5 {
                    select(offset: nil)
                }
            }.updating($translation) { value, state, _ in
                state = value.translation
            }
    }
    
    var unfoldRate: CGFloat {
        let rate = buttonWidth < 0.0001 ? 0.0 : 1 - (buttonWidth + scrollX)/buttonWidth
        
        return rate < 0 ? 0 : (rate > 1 ? 1 :rate)
    }
    func fold() {
        withAnimation {
            scrollX = 0
            selected = nil
        }
    }
    
    func unfold() {
        withAnimation {
            self.scrollX = 0 - buttonWidth
        }
    }
    
    var screenWidth: CGFloat {
    #if os(macOS)
        min(max(buttonWidth*2, contentWidth), 640)
    #else
        min(max(buttonWidth*2, contentWidth), UIScreen.main.bounds.width)
    #endif
        
    }
    
    struct ButtonOption {
        var text: String
        var icon: String? = nil
        var backgroundColor: Color = .red
        var foregroundColor: Color = .white
        var isTip: Bool = true
        var action: ((@escaping () -> Void) -> Void)? = nil
    }
    
    public enum ButtonDefine{
        case custom(String, Color, Color, (@escaping () -> Void) -> Void)
        case quick(String, Color, (@escaping () -> Void) -> Void)
        case icon(String, Color, (@escaping () -> Void) -> Void)
        case icon2(String, Color, (@escaping () -> Void) -> Void)
        case simple(String, Color)
        case common(String, Color, (@escaping () -> Void) -> Void)
    }
    
    func buttonWidth(offset: Int) -> CGFloat {
        if let selected = self.selected {
            if selected < offset {
                return widths[options[offset].text] ?? 0
            }
            if selected > offset {
                return 0
            }
            
            return buttonWidth
        }else{
            return widths[options[offset].text] ?? 0
        }
    }
    
//    func buttonOffset(offset: Int) -> CGFloat {
//        
//        let pre:CGFloat = (options.enumerated()).reduce(0.0, { res, item in
//            if item.offset < offset {
//                return res + (widths[item.element.text] ?? 0)
//            }
//            return res
//        })
//        
//        if let selected = self.selected {
//            if selected < offset {
//                return screenWidth + buttonWidth
//            }
//            if selected > offset {
//                return screenWidth + scrollX
//            }
//            
//            return screenWidth + scrollX
//        }else{
//            return screenWidth + scrollX + pre * unfoldRate
//        }
//        
//    }
    
    func buttonOffset(offset: Int) -> CGFloat {
        var mo = 0.0
        for idx in offset..<options.count {
            let wid = widths[options[idx].text] ?? 0
            // mo = mo + buttonWidth(offset: idx)
            mo = mo + wid
        }
        if let selected = self.selected {
            return 0
        }else{
            return mo*(1-unfoldRate)
        }
    }
    
    func select(offset: Int?) {
        withAnimation {
            selected = offset
        }
    }
    
    func label(option: ButtonOption) -> some View {
        HStack{
            if let _ = option.icon {
                Image(systemName: "figure.flexibility").padding(.horizontal, 8)
                // Image(systemName: icon).padding(.horizontal)
            }else{
                Text(option.text)
            }
        }
        .opacity(0)
        .padding()
        .background {
            HStack{
                Spacer(minLength: 0)
                if let icon = option.icon {
                    Image(systemName: icon).padding(.horizontal)
                }else{
                    Text(option.text)
                }
                Spacer(minLength: 0)
            }
            .foregroundColor(option.foregroundColor)
        }
        
    }
    
    public var body: some View {
        VStack {
            ZStack(alignment: .leading){
                HStack(spacing:0){
                    content()
                        .background(GeometryReader{ proxy in
                            Color.clear.preference(key: ObservableSwipeButtonHeightPreferenceKey.self, value: [proxy.size.height, proxy.size.width])
                        })
                        .onPreferenceChange(ObservableSwipeButtonHeightPreferenceKey.self) { value in
                            if value.count > 0 {
                                contentHeight = value[0]
                                contentWidth = value[1]
                            }
                        }
                }
                
                if buttonWidth > 0 {
                    HStack{
                        // Text("\(scrollX)")
                        Spacer()
                    }
                    .frame(height: contentHeight)
                    .background(Color.black.opacity(0.1))
                    .opacity(unfoldRate)
                    // .offset(x: screenWidth*(scrollX + buttonWidth)/buttonWidth)
                    .onTapGesture {
                        if selected == nil {
                            fold()
                        }else{
                            select(offset: nil)
                        }
                        
                    }
                }
                
                
                ForEach(Array(self.options.enumerated()), id: \.offset) { e in
                    Button(action: {
                        
                    }, label: {
                        label(option: options[e.offset])
                            .frame(height: contentHeight)
                            .background(options[e.offset].backgroundColor)
                    })
                    .background(GeometryReader{ proxy in
                        Color.clear.preference(key: ObservableSwipeButtonWidthPreferenceKey.self, value: [options[e.offset].text: proxy.size.width])
                    })
                    .opacity(0)
                }
                
                HStack(spacing: 0){
                    Spacer(minLength: 0)
                    ForEach(Array(self.options.enumerated()), id: \.offset) { e in
                        if selected == nil || selected == e.offset {
                            Button(action: {
                                if self.selected == nil && options[e.offset].isTip {
                                    select(offset: e.offset)
                                    return
                                }
                                
                                if let f = options[e.offset].action {
                                    f({
                                        fold()
                                    })
                                }else{
                                    fold()
                                }
                            }, label: {
                                label(option: options[e.offset])
                                    .frame(width: buttonWidth(offset: e.offset), height: contentHeight)
                                    .background(options[e.offset].backgroundColor)
                                
                            })
                            .offset(x: buttonOffset(offset: e.offset))
                            .opacity(unfoldRate)
                            .opacity(selected == nil ? 1 : (selected == e.offset ? 1 : 0))
                            .scaleEffect(x: selected == nil ? 1 : (selected == e.offset ? 1 : 0))
                            .buttonStyle(.plain)
                        }
                    }
                    
                }
                    
                
            }
            // .offset(x: scrollX, y: 0)
            .highPriorityGesture(drag)
            .onPreferenceChange(ObservableSwipeButtonWidthPreferenceKey.self) { value in
                buttonWidth = value.values.reduce(0, { res, v in
                    return res + v
                })
                widths = value
            }
            
        }
        // .frame(width: screenWidth)
        .clipped()
    }

}

struct ObservableSwipeButtonHeightPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]
    static var defaultValue:[CGFloat] = []

    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}


struct ObservableSwipeButtonWidthPreferenceKey: PreferenceKey {
    typealias Value = [String:CGFloat]
    static var defaultValue:[String:CGFloat] = [String:CGFloat]()

    static func reduce(value: inout [String:CGFloat], nextValue: () -> [String:CGFloat]) {
        for (k, v) in nextValue() {
            value[k] = v
        }
    }
}

struct TestView: View {
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment:.top, spacing: 0){
                VStack(alignment: .trailing){
                    Text("#123").font(.footnote).foregroundColor(.gray)
                    
                    Text("dddd").font(.caption2)
                    
                }.frame(width: 48)
                Text("dakdfjdddddkdkd dk kak dkkdakddfd dkdkaddddddaaaksj")
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
            Divider()
        }
        .background(Color.white)
    }
}

#if DEBUG
struct SwipeButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            VStack{
                
                LintSwipeButton(defines: [
                    .common("Delete", .red, { next in
                        next()
                    }),
                    .icon2("clock", .yellow, { next in
                        next()
                    })
                ], content: {
                    HStack{
                        Spacer()
                        Text("Hello world").foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.01))
                    // TestView()
                })
                .background(Color.white)
                .cornerRadius(16)
                
                // .border(Color.black.opacity(0.3))
                
            }
            .frame(width: 320)
            .padding(32)
            .border(Color.red)
            .background(.ultraThinMaterial)
            
        }
    }
}
#endif
