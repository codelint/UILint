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
    
    @State private var totalHeight = CGFloat.zero
    
    public init(items: [Value], @ViewBuilder content: @escaping (_ item: Value) -> Content) {
        self.items = items
        self.item = content
    }

    public var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }.frame(height: totalHeight)
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        // items.indices.last
        return ZStack(alignment: .topLeading) {
            
            ForEach(items.indices, id: \.self) { idx in
                self.item(items[idx])
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        
                        if idx == items.indices.last! {
                            width = 0
                        } else {
                            width -= d.width
                        }
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
        }.background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
                // print("totalHeight: ", rect.size.height)
            }
            return .clear
        }
    }
    
}

struct LineWrapper_Previews: PreviewProvider {
    struct TestData: LintBadgeIdentifier {
        var lintId: String = "hello"
        
        var lintName: String = "hello"
    }
    static var previews: some View {
        VStack{
            LintLineWrapper(items: [TestData(), TestData(lintId: "2", lintName: "world")]) { item in
                Text(item.lintName)
                    .bold()
                    .font(.footnote)
                    .padding(.all, 5)
                    .frame(minWidth: 48)
                    .background(Color.gray)
                    .cornerRadius(5)
                    .border(Color.red)
            }
            // BadgeSelector(["dfjkd", "dkfjdk"], selects: ["dfjkd"])
        }
        .padding()
        .frame(width: 320, height: 640)
    }
}
