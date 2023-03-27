//
//  SwiftUIView.swift
//  
//
//  Created by gzhang on 2023/3/24.
//

import SwiftUI

public struct FlopView<First: View, Second: View>: View {
    
    @Binding var isFirstPresent: Bool
    
    let first: () -> First
    let second: () -> Second
    
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
            FlopView(isFirstPresent: $first, first: {
                ZStack{
                    Color(.red)
                    Center{
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
                    Center{
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
