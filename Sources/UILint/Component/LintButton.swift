//
//  LintButton.swift
//  statement
//
//  Created by gzhang on 2023/11/24.
//

import SwiftUI

public struct LintButton<Label: View>: View {
    
    var delay: Double = 0
    var action: (() -> Void)? = nil
    var callback: ((@escaping () -> Void) -> Void)? = nil
    
    @ViewBuilder let label: () -> Label
    
    @State var canTap: Bool = true
    
    public init(
        delay: Double  = 0.0,
        action: (() -> Void)? = nil,
        callback: ((@escaping () -> Void) -> Void)? = nil,
        label: @escaping () -> Label,
        canTap: Bool = true) {
        self.delay = delay
        self.action = action
        self.callback = callback
        self.label = label
        self.canTap = canTap
    }
    
    public var body: some View {
        Button(action: {
            turnOff()
            action?()
            if let callback = callback {
                callback({
                    self.turnOn()
                })
            }else{
                self.turnOn()
            }
        }, label: {
            label()
                .lint(bool: !canTap && callback != nil, view: {
                    $0.overlay(content: {
                        LintCenter{
                            ProgressView()
                        }
                        .background(.ultraThinMaterial.opacity(0.01))
                    })
                })
        })
        .buttonStyle(.plain)
        .disabled(!canTap)
    }
    
    public func turnOn() {
        if delay > 0.001 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay*1000)), execute: {
                canTap = true
            })
        }else{
            canTap = true
        }
    }
    
    public func turnOff(){
        canTap = false
    }
}

public extension View {
    @ViewBuilder func lint(delay seconds: CGFloat = 0.2, button action: @escaping () -> Void) -> some View {
        lintButton(delay: seconds, action)
    }
    
    @ViewBuilder func lint(button callback: @escaping (@escaping () -> Void) -> Void) -> some View { lintButton(delay: 0.2, callback) }
    
    @ViewBuilder func lintButton(delay seconds: Double = 0, _ action: @escaping () -> Void) -> some View {
        LintButton(delay: seconds, action: action, label: {
            self
        })
    }
    
    @ViewBuilder func lintButton(delay: Double = 0, _ callback: @escaping (@escaping () -> Void) -> Void) -> some View {
        LintButton(delay: delay, callback: callback, label: {
            self
        })
    }
}

#Preview {
    Text("hello")
        .padding().foregroundColor(.black)
        .background(.blue)
        .lintButton(delay: 3) { next in
            next()
        }
        .cornerRadius(16)
}
