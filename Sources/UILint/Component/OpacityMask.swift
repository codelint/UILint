//
//  SwiftUIView.swift
//  
//
//  Created by gzhang on 2023/3/24.
//

import SwiftUI

struct OpacityMask<Content: View>: View {
    
    var content: () -> Content
    var opacity: CGFloat
    var onClick: (() -> Void)?
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.opacity = 0.1
        self.onClick = nil
    }
    
    init(opacity: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.opacity = opacity
        self.onClick = nil
    }
    
    init(opacity: CGFloat, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.opacity = opacity
        self.onClick = action
    }
    
    var body: some View {
        ZStack{
            content().whether(opacity > 0){ view in
                view.overlay {
                    Center(content: {
                        Text("")
                    })
                    .background(Color.white.opacity(opacity)).onTapGesture {
                        onClick?()
                    }
                }
            }
        }
    }
}

struct OpacityMask_Previews: PreviewProvider {
    struct TestView: View {
        
        @State var opacity = 0.5
        
        var body: some View {
            OpacityMask(opacity: opacity) {
                opacity = 0
            } content: {
                Center{
                    Text("Hello world")
                }
            }
        }
    }
    static var previews: some View {
        VStack{
            TestView()
        }.frame(width: 320, height: 640)
    }
}
