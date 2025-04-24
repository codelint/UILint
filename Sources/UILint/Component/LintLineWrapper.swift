//
//  SwiftUIView.swift
//  
//
//  Created by gzhang on 2023/3/24.
//

import Foundation
import SwiftUI

protocol LintBadgeIdentifier: Equatable {
    var lintId: String {get}
    var lintName: String {get}
}

extension String: LintBadgeIdentifier {
    public var lintId: String { get { self } }
    public var lintName: String { get { self } }
}

public struct LintLineWrapper<Content: View, Value>: View {
    
    var items = [Value]()
    
    let item: ((Value) -> Content)!
    
    var layoutDirection: Direction
    var horizontalSpacing: CGFloat
    var verticalSpacing: CGFloat
    
    @State private var totalHeight = CGFloat.zero
    @State private var totalSize = CGSize.zero
    
    public init(items: [Value],
                direction: Direction = .ltr,
                hs hspace: CGFloat? = nil,
                vs vspace: CGFloat? = nil,
                @ViewBuilder content: @escaping (_ item: Value) -> Content) {
        self.items = items
        self.item = content
        self.layoutDirection = direction
        self.horizontalSpacing = hspace ?? vspace ?? 4
        self.verticalSpacing = vspace ?? hspace ?? 4
    }

    public var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry).background(viewSizeReader($totalSize))
        }
        .frame(height: totalSize.height)
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        var lastItemHeight: CGFloat = CGFloat.zero
        var mw = CGFloat.zero
        var tw = CGFloat.zero
//        var firstWidth = CGFloat.zero
        // items.indices.last
        return ZStack(alignment: layoutDirection == .ltr ? .topLeading : .topTrailing) {
            ForEach(items.indices, id: \.self) { idx in
                self.item(items[idx])
//                    .padding([.horizontal, .vertical], 4)
//                    .padding(.horizontal, horizontalSpacing)
//                    .padding(.vertical, verticalSpacing)
                    .border(Color.green)
                    .alignmentGuide(layoutDirection == .ltr ? .leading : .trailing, computeValue: { d in
                        let itemWidth = d.width + horizontalSpacing
                        
                        if (abs(width + itemWidth) - horizontalSpacing > g.size.width)
                        {
                            tw = max(mw, tw)
                            mw = 0
                            width = 0
                            height -= lastItemHeight + verticalSpacing
                        }
                        
                        let result = layoutDirection == .ltr ? -width : (width + itemWidth)
                        
                        if idx == items.indices.last! {
                            tw = max(mw, tw)
                            mw = 0
                            width = 0
                        } else {
                            width += itemWidth
                        }
                        lastItemHeight = d.height
                        mw = mw + itemWidth
                        
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if idx == items.indices.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
//        .background(viewSizeReader($totalSize))
//        .background(viewHeightReader($totalHeight))
//        .onAppear(){
//            totalWidth = tw
//        }

    }
    
    private func viewSizeReader(_ binding: Binding<CGSize>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size
                // print("totalHeight: ", rect.size.height)
            }
            return .clear
        }
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = max(binding.wrappedValue, rect.size.height)
                // print("totalHeight: ", rect.size.height)
            }
            return .clear
        }
    }
    
    private func viewWidthReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = max(binding.wrappedValue, rect.size.width)
                // print("totalHeight: ", rect.size.height)
            }
            return .clear
        }
    }
    
    public enum Direction {
        case ltr, rtl
    }
}

struct LineWrapper_Previews: PreviewProvider {
    struct TestData: LintBadgeIdentifier {
        var lintId: String = "hello"
        
        var lintName: String = "hello"
    }
    static var previews: some View {
        VStack(alignment: .trailing){
            LintLineWrapper(items: [
                TestData(), TestData(lintId: "2", lintName: "world"),
                TestData(lintId: "4", lintName: "inotseeyou"),
                TestData(lintId: "5", lintName: "unotseeme"),
                TestData(lintId: "6", lintName: "wtf"),
                TestData(lintId: "6", lintName: "wtf!!"),
                TestData(lintId: "6", lintName: "wtf abc"),
                TestData(lintId: "6", lintName: "wtf!")
            ], direction: .rtl, hs: 12, vs: 8) { item in
                Text(item.lintName)
                    .bold()
                    .font(.footnote)
                    .padding(.all, 5)
                    .frame(minWidth: 48)
                    .background(Color.gray)
                    .cornerRadius(5)
                    .border(Color.red)
            }
            .frame(width: 320, height: 640, alignment: .topTrailing)
            .border(Color.red)
            // BadgeSelector(["dfjkd", "dkfjdk"], selects: ["dfjkd"])
        }
//        .padding()
//        .frame(width: 320, height: 640, alignment: .top)
        
    }
}
