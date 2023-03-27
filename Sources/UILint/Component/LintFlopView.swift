//
//  SwiftUIView.swift
//  
//
//  Created by gzhang on 2023/3/24.
//

import SwiftUI

public struct LintFlopView<First: View, Second: View>: View {
    
    @Binding var isFirstPresent: Bool
    
    let first: () -> First
    let second: () -> Second
    
    public init(isFirstPresent: Binding<Bool>, first: @escaping () -> First, second: @escaping () -> Second) {
        self._isFirstPresent = isFirstPresent
        self.first = first
        self.second = second
    }
    
    public var body: some View {
        ZStack{
            first()
                .opacity(isFirstPresent ? 1 : 0)
                .rotation3DEffect(Angle(degrees: isFirstPresent ? 0 : 180), axis: (0,1,0))
                .animation(.linear, value: isFirstPresent)
            second()
                .opacity(isFirstPresent ? 0 : 1)
                .rotation3DEffect(Angle(degrees: isFirstPresent ? 180 : 360), axis: (0,1,0))
                .animation(.linear, value: isFirstPresent)
        }
        
    }
}

struct FlopView_Previews: PreviewProvider {
    
    struct TestView: View {
        @State var first = true
        var body: some View {
            LintFlopView(isFirstPresent: $first, first: {
                ZStack{
                    Color(.red)
                    LintCenter{
                        Button(action: {
                            first = false
                        }, label: {
                            Text("next")
                        })
                    }
                }
                
            }, second: {
                ZStack{
                    Color(.yellow)
                    LintCenter{
                        Button(action: {
                            first = true
                        }, label: {
                            Text("word")
                        })
                    }
                }
            })
        }
    }
    
    static var previews: some View {
        TestView()
    }
}
