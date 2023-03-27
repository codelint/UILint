//
//  SwiftUIView.swift
//  
//
//  Created by gzhang on 2023/3/27.
//

import SwiftUI

public struct LintHorizontalWheel<Value: StringProtocol, Content: View>: View {
    
    let tags: [Value]
    @Binding var selected: Int
    
    @State var offset: CGFloat = 0.0
    @State var scrollX: CGFloat = 0.0
    
    var fontSize: CGFloat? = nil
    
    @State var tagWidth: CGFloat = 0
    @State var tagMaxWidth: CGFloat = 0
    @State var maxWidth: CGFloat = 320
    
    let itemContent: (Value, Int) -> Content
    
    var onSelect: ((Value, Int) -> Void)? = nil
    
    public init(selected: Binding<Int>, tags: [Value], tagWidth: CGFloat,
         fontSize: CGFloat? = 16,
         label: @escaping (Value, Int) -> Content,
         onSelect: ((Value, Int) -> Void)? = nil) {
        self.itemContent = label
        self.tags = tags
        self._selected = selected
        self.tagWidth = tagWidth
        self.fontSize = fontSize
        self.onSelect = onSelect
        
    }
    
    public init(selected: Binding<Int>, tags: [Value], label: @escaping (Value, Int) -> Content, onSelect: @escaping (Value, Int) -> Void) {
        self.tags = tags
        self._selected = selected
        self.onSelect = onSelect
        self.itemContent = label
    }
    
    public init(selected: Binding<Int>, tags: [Value], label: @escaping (Value, Int) -> Content) {
        self.tags = tags
        self._selected = selected
        self.itemContent = label
        self.onSelect = nil
    }
    
    public var body: some View {
        VStack{
            // Text("\(tagMaxWidth)/\(tagWidth)")
            ZStack{
                ForEach(tags.indices, id: \.self) { idx in
                    Button(action: {
                        
                    }, label: {
                        itemContent(tags[idx], idx)
                            .lineLimit(1)
                    })
                    .opacity(0)
                    .font(fontSize == nil ? .body : .custom("", size: fontSize!))
                    .overlay(GeometryReader { proxy in
                        Color.clear.onAppear(){
                            
                            self.tagMaxWidth = min(max(self.tagMaxWidth, max(proxy.size.width, 50)), maxWidth/3)
                            // self.tagWidth = self.tagMaxWidth
                            self.tagWidth = self.tagMaxWidth
                        }
                    })
                    
                }
                
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0){
                        ForEach(tags.indices, id: \.self) { idx in
                            Button(action: {
                                refresh(sel: idx)
                            }, label: {
                                VStack{
                                    itemContent(tags[idx], idx).lineLimit(1)
                                    // Text(tags[idx]).lineLimit(1)
                                }
                            })
                            .opacity(tagOpacity(sel: idx))
                            .font(tagFont(idx))
                            .frame(width: tagWidth)
                            .buttonStyle(.plain)
                            // .border(Color.red)
                        }
                    }
                    .offset(x: offset)
                }
                .tap{ view in
                    if #available(macOS 13.0, iOS 16, *) {
                        view.scrollDisabled(true)
                    } else {
                        view.disabled(true).background {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 0){
                                    ForEach(tags.indices, id: \.self) { idx in
                                        Button(action: {
                                            refresh(sel: idx)
                                        }, label: {
                                            VStack{
                                                itemContent(tags[idx], idx).lineLimit(1)
                                                // Text(tags[idx]).lineLimit(1)
                                            }
                                        })
                                        .opacity(tagOpacity(sel: idx))
                                        .font(tagFont(idx))
                                        .frame(width: tagWidth)
                                        .buttonStyle(.plain)
                                        // .border(Color.red)
                                    }
                                }
                                .offset(x: offset)
                            }
                        }
                    }
                }
                .highPriorityGesture(drag)
            }
        }
        .onAppear(){
            refresh(sel: selected)
        }
        .onChange(of: tagMaxWidth) { newValue in
            refresh(sel: selected)
        }
        .onChange(of: selected) { newValue in
            onSelect?(tags[newValue], newValue)
        }
        .background(GeometryReader { proxy in
            Color.clear
                .onAppear() {
                    maxWidth = proxy.size.width
                }
        })
        // .border(Color.red)
    }
    
    var minX: CGFloat {
        maxWidth/2 - (tagWidth/2 +  CGFloat(tags.count - 1)*tagWidth) - 16
    }
    
    var maxX: CGFloat {
        maxWidth/2 - (tagWidth/2 +  CGFloat(0)*tagWidth) - 16
    }
    
    var selecting: Int {
        let selected = (offset - (maxWidth/2) + 66)/tagWidth
        return Int(round(abs(selected)))
    }
    
    @State var drag_at: Date? = nil
    var drag: some Gesture {
        DragGesture()
            .onChanged { event in
                drag_at = drag_at ?? Date()
                var newX = scrollX + event.translation.width
                newX = min(maxX, newX)
                newX = max(minX, newX)
                withAnimation {
                    self.offset = newX
                }
                // offset = offset - event.translation.width
                
            }
            .onEnded { event in
                refresh()
            }
    }
    
    func refresh(sel: Int? = nil) {
        let sel = (sel ?? selecting)%tags.count
        withAnimation(.linear) {
            offset = maxWidth/2 - (tagWidth/2 +  CGFloat(sel)*tagWidth)
        }
        scrollX = offset
        selected = sel
    }
    
    func distance(_ sel: Int) -> CGFloat {
         CGFloat(sel) + (offset - (maxWidth/2) + (tagWidth/2))/tagWidth
    }
    
    func distanceRate(_ sel: Int) -> CGFloat {
        let dis = abs(distance(sel))
        if dis > 12 {
            return 12
        }
        return 1 - dis/CGFloat(min(tags.count, 12))
    }
    
    func tagOpacity(sel: Int) -> CGFloat {
        pow(distanceRate(sel), 10)
    }
    
    func tagFont(_ idx: Int) -> Font {
        if let fontSize = fontSize {
            let rate = distanceRate(idx)
            return .custom("", size: max(pow(rate,2) * fontSize, fontSize/2))
        }else{
            return .body
        }
    }
    
    func onSelect(_ callback: @escaping (Value, Int) -> Void) -> Self {
        .init(selected: $selected, tags: tags, tagWidth: tagWidth, fontSize: fontSize, label: itemContent, onSelect: callback)
    }
    
}

struct HorizontalWheel_Previews: PreviewProvider {
    
    struct TestView: View {
        @State var selected = 3
        
        @State var selected_text = ""
        
        let tags: [String] = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
        
        var body: some View {
            VStack{
                Text("\(selected)/\(selected_text)")
                HStack{
                    Text("hello")
                    LintHorizontalWheel(
                        selected: $selected,
                        tags: tags
                    ) { text, _ in
                        Text(text).padding()
                    }
                    .onSelect({ text, idx in
                        selected_text = text
                    })
                    .onAppear(){
                        selected = 15%12
                    }
                    Text("hello")
                }
                .padding(16)
            }
        }
        
    }
    
    static var previews: some View {
        VStack{
            TestView()
        }.frame(width: 1024, height: 768)
    }
}
