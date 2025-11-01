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
    
    public init(isFirstPresent: Binding<Bool>,
                @ViewBuilder first: @escaping () -> First,
                @ViewBuilder second: @escaping () -> Second
    ) {
        self._isFirstPresent = isFirstPresent
        self.first = first
        self.second = second
    }
    
    public var body: some View {
        LintFlop(isFirstPresent: _isFirstPresent, first: first, second: second)
    }
}

public struct LintFlop<First: View, Second: View>: View {
    
    @Binding var isFirstPresent: Bool
    
    var direction: Direction = .horizontal
    
    @ViewBuilder let first: () -> First
    @ViewBuilder let second: () -> Second
    
    public init(isFirstPresent: Binding<Bool>, direction: Direction = .horizontal, @ViewBuilder first: @escaping () -> First,@ViewBuilder second: @escaping () -> Second) {
        self._isFirstPresent = isFirstPresent
        self.direction = direction
        self.first = first
        self.second = second
    }
    
    public var body: some View {
        ZStack{
            first()
                .opacity(isFirstPresent ? 1 : 0)
                .rotation3DEffect(Angle(degrees: isFirstPresent ? 0 : 180), axis: direction == .vertical ? (1,0,0) : (0,1,0))
                .animation(.linear, value: isFirstPresent)
            second()
                .opacity(isFirstPresent ? 0 : 1)
                .rotation3DEffect(Angle(degrees: isFirstPresent ? 180 : 360), axis: direction == .vertical ? (1,0,0) : (0,1,0))
                .animation(.linear, value: isFirstPresent)
        }
    }
    
    public enum Direction {
        case vertical, horizontal
    }
}

public struct LintFlopCard<First: View, Second: View>: View {
    
    let isFirstPresent: Bool
    
    var direction: Direction = .horizontal
    
    @ViewBuilder let first: () -> First
    @ViewBuilder let second: () -> Second
    
    public init(isFirstPresent: Bool, direction: Direction = .horizontal,
                @ViewBuilder first: @escaping () -> First,
                @ViewBuilder second: @escaping () -> Second
    ) {
        self.isFirstPresent = isFirstPresent
        self.direction = direction
        self.first = first
        self.second = second
    }
    
    public var body: some View {
        ZStack{
            first()
                .opacity(isFirstPresent ? 1 : 0)
                .rotation3DEffect(Angle(degrees: isFirstPresent ? 0 : 180), axis: direction == .vertical ? (1,0,0) : (0,1,0))
                .animation(.linear, value: isFirstPresent)
            second()
                .opacity(isFirstPresent ? 0 : 1)
                .rotation3DEffect(Angle(degrees: isFirstPresent ? 180 : 360), axis: direction == .vertical ? (1,0,0) : (0,1,0))
                .animation(.linear, value: isFirstPresent)
        }
    }
    
    public enum Direction {
        case vertical, horizontal
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
