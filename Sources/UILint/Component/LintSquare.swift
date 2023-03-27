//
//  SwiftUIView.swift
//  
//
//  Created by gzhang on 2023/3/27.
//

import SwiftUI

public struct LintSquare<Content:View>: View {
    
    @State var width: CGFloat = 0
    @State var height: CGFloat = 0
    
    let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        ZStack{
            content()
                .background(GeometryReader { proxy in
                    Color.clear
                        .onAppear() {
                            width = proxy.size.width
                            height = proxy.size.height
                        }
                }).opacity(0)
            content()
                .frame(width: max(width, height), height: max(width, height))
        }
    }
}

struct LintSquare_Previews: PreviewProvider {
    static var previews: some View {
        LintSquare {
            Image(systemName: "plus").padding()
        }
        .borderRadius(radius: 16, color: .black.opacity(0.5), width: 1)
    }
}
