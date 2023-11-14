//
//  SwiftUIView.swift
//  
//
//  Created by gzhang on 2023/11/14.
//

import SwiftUI

struct LintTimer<Content: View>: View {
    
    var interval: TimeInterval = 1
    @ViewBuilder let content: (Date) -> Content
    
    // @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    @State private var now = Date()
    
    init(interval: TimeInterval, content: @escaping (Date) -> Content) {
        self.content = content
        self.interval = interval
    }
    
    init(content: @escaping (Date) -> Content) {
        self.content = content
    }
    
    var body: some View {
        content(now)
            .onReceive(Timer.publish(every: interval, on: .main, in: .common).autoconnect()) { output in
                now = Date()
            }
    }
}

#Preview {
    LintTimer(interval: 1) { now in
        VStack{
            Text(now.description)
            Text("Hello world")
        }
    }
}
