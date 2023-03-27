//
//  SwiftUIView.swift
//  
//
//  Created by gzhang on 2023/3/24.
//

import SwiftUI

public struct LintCenter<Content: View>: View {
    
    @State var width: CGFloat = 0
    @State var height: CGFloat = 0
    
    public var content: (CGFloat,CGFloat) -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = { _,_ in content() }
    }
    
    public init(@ViewBuilder content: @escaping (CGFloat, CGFloat) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        VStack{
            Spacer(minLength: 0)
            HStack{
                Spacer(minLength: 0)
                content(width, height)
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
        .background(GeometryReader { proxy in
            Color.clear
                .onAppear() {
                    width = proxy.size.width
                    height = proxy.size.height
                }
        })
    }
}

struct LintCenter_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            LintCenter { w, h in
                Text("\(w)x\(h)")
            }
        }.frame(width: 320, height: 768)
    }
}
