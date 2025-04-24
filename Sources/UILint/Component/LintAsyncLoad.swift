//
//  SwiftUIView.swift
//  UILint
//
//  Created by gzhang on 2025/4/14.
//

import SwiftUI

struct LintAsyncLoad<Content: View, Value>: View {
    
    @Binding var data: Value?
    var mode: Mode = .flex
    var reload: ( @escaping (Value?) -> Void ) -> Void
    @ViewBuilder let content: (Value) -> Content
    
    @State private var reloading: Bool? = nil
    
    public var body: some View {
        if mode == .fixed {
            VStack{
                Spacer(minLength: 0)
                HStack{
                    Spacer(minLength: 0)
                    if reloading == nil {
                        ProgressView().onAppear() {
                            self.refresh()
                        }
                    }else{
                        Text("")
                    }
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
            .opacity(data != nil ? 0 : 1)
            .overlay(content: {
                if let data = data {
                    content(data).onAppear() {
                        reloading = nil
                    }
                }else{
                    if let reloading = reloading {
                        if reloading {
                            ProgressView()
                        }else{
                            Button(action: refresh, label: {
                                Image(systemName: "arrow.clockwise").font(.title)
                            }).buttonStyle(.plain)
                        }
                    }else{
                        Text("")
                    }
                }
            })
        }else {
            if let data = data {
                content(data).onAppear() {
                    reloading = nil
                }
            }else{
                if let reloading = reloading {
                    if reloading {
                        ProgressView()
                    }else {
                        Button(action: refresh, label: {
                            Image(systemName: "arrow.clockwise").font(.title)
                        }).buttonStyle(.plain)
                        
                    }
                }else{
                    ProgressView().onAppear() {
                        self.refresh()
                    }
                }
            }
        }
    }
    
    func refresh() {
        reloading = true
        DispatchQueue.main.async {
            reload({
                reloading = false
                self.data = $0
            })
        }
    }
    
    public enum Mode: String {
        case flex, fixed
    }
    
}

#Preview {
    LintAsyncLoad(data: .constant(true), reload: { $0(true) }, content: { v in
        Text("Hello world")
    })
    .frame(width:320, height: 192, alignment: .center)
}
