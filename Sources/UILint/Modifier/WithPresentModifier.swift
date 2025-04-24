//
//  SwiftUIView.swift
//  
//
//  Created by gzhang on 2024/3/13.
//

import SwiftUI

struct WithPresentModifier<Value: Equatable, Sheet: View>: ViewModifier {
    
    @Binding var value: Value?
    
    var onDismiss: (() -> Void)? = nil
    
    @State var present: Bool = false
    @ViewBuilder let sheet: (Value) -> Sheet
    
    func body(content: Content) -> some View {
        content
            .onChange(of: present, perform: { if !$0 {
                value = nil
            } })
            .onChange(of: value, perform: { if !present { present = $0 != nil } })
            .onAppear(perform: { present = value != nil })
            .sheet(isPresented: $present, onDismiss: {
                value = nil
                onDismiss?()
            }, content: {
                if let value = value {
                    sheet(value)
                }else{
                    Text("").onAppear() {
                        present = false
                    }
                }
            })
    }
}

//extension View {
//    @ViewBuilder func lint<Value: Equatable, Content: View>(with value: Binding<Optional<Value>>, onDismiss: (() -> Void)? = nil , @ViewBuilder sheet: @escaping (Value) -> Content) -> some View {
//        self.modifier(WithPresentModifier(value: value, onDismiss: onDismiss, sheet: { sheet($0) }))
//    }
//}

#if DEBUG
struct WithPresentModifierTesting: View {
    
    @State var msg: String? = nil
    
    var body: some View {
        VStack{
            Text("hello world")
                .modifier(WithPresentModifier(value: $msg, sheet: { Text($0) }))
        }
        .onAppear() {
            msg = "WTF"
        }
    }
}
#Preview {
    WithPresentModifierTesting().frame(width:320, height: 192, alignment: .center)
}

#endif

