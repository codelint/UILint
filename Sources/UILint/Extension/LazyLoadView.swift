//
//  LazyView.swift
//  statement
//
//  Created by gzhang on 2023/12/29.
//

import SwiftUI
import Combine

extension View {
    @ViewBuilder func lintAppear(after ms: Int, perform next: @escaping () -> Void) -> some View {
        onAppear() {
            if ms > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(ms)), execute: {
                    next()
                })
            }else{
                DispatchQueue.main.async {
                    next()
                }
            }
        }
    }
}

public struct LazyLoad<Content: View>: View {
    
    var delay: Int = 20
    
    var boot: () -> Void = {}
    
    @ViewBuilder let content: () -> Content
    
    public init(delay: Int = 20, boot: @escaping () -> Void = {}, @ViewBuilder content: @escaping () -> Content) {
        self.delay = delay
        self.boot = boot
        self.content = content
    }
    
    public var body: some View {
        LazyLoadWith(delay: delay, loadData: { next in
            self.boot()
            next(true)
        }, content: { _ in
            content()
        })
    }
}

public struct LazyLoadWith<Content: View, Value>: View {
    
    var delay: Int = 1
    var loadData: ( @escaping (Value?) -> Void ) -> Void
    @ViewBuilder let content: (Value) -> Content
    
    @State var data: Value? = nil
    @State var present: Bool = false
    
    public init(delay: Int = 1, loadData: @escaping (@escaping (Value?) -> Void) -> Void, content: @escaping (Value) -> Content) {
        self.delay = delay
        self.loadData = loadData
        self.content = content
    }
    
    public var body: some View {
        VStack{
            if let data = data {
                content(data)
            }
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(delay)), execute: {
                loadData({
                    self.data = $0
                })
            })
        }
    }
}

public struct LazyLoadVElse<WITH: View, WITHOUT: View, Value>: View {
    
    var delay: Int = 1
    var loadData: ( @escaping (Value?) -> Void ) -> Void
    @ViewBuilder let VIF: (Value) -> WITH
    @ViewBuilder let VELSE: () -> WITHOUT
    
    @State var data: Value? = nil
    @State var present: Bool = false
    
    public init(
        delay: Int = 1,
        loadData: @escaping (@escaping (Value?) -> Void) -> Void,
        @ViewBuilder VIF: @escaping (Value) -> WITH,
        @ViewBuilder VELSE: @escaping () -> WITHOUT
    ) {
        self.delay = delay
        self.loadData = loadData
        self.VIF = VIF
        self.VELSE = VELSE
    }
    
    public var body: some View {
        if let data = data {
            VIF(data)
        }else{
            VELSE().onAppear() {
                let startTime = DispatchTime.now()
                loadData({ a in
                    let endTime = DispatchTime.now()
                    let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                    let executionTime = Int(Double(nanoTime) / 1000000)
                    let d = executionTime > delay ? 1 : delay - executionTime
                    DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(d)), execute: {
                        self.data = a
                    })
                })
            }
        }
    }
}


public struct LazyLoadView<Content: View, Value>: View {
    
    var mode: Mode = .fixed
    var refreshInterval: Double? = nil
    var loadData: ( @escaping (Value?) -> Void ) -> Void
    @ViewBuilder let content: (Value?) -> Content
    
    @State var data: Value? = nil
    @State var present: Bool = false
    
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>? = nil
    
    public init(mode: Mode  = .fixed, refreshInterval: Double? = nil, loadData: @escaping (@escaping (Value?) -> Void) -> Void, @ViewBuilder content: @escaping (Value?) -> Content) {
        self.mode = mode
        self.refreshInterval = refreshInterval
        self.loadData = loadData
        self.content = content
        self.data = data
        self.present = present
        self.timer = timer
    }
    
    @ViewBuilder func viewInFixed() -> some View{
        LintCenter(){
            if !present {
                ProgressView().onAppear() {
                    DispatchQueue.main.async {
                        loadData({
                            self.data = $0
                            self.present = true
                        })
                    }
                }
            }else{
                Button(action: {
                    present = true
                }, label: {
                    Image(systemName: "arrow.clockwise")
                })
                .buttonStyle(.plain)
            }
        }
        .opacity(present ? 0 : 1)
        .background(content: {
            if present {
                content(data)
            }
        })
    }
    
    @ViewBuilder func viewInVIF() -> some View {
        var working = false
        VStack{
            if present {
                content(data)
            }
        }
        .lintAppear(after: 10){
            if !working {
                working = true
                loadData({
                    working = false
                    self.data = $0
                    self.present = true
                })
            }
        }
    }
    
    @ViewBuilder func viewInFlex() -> some View{
        var working = false
        if present {
            content(data)
        }else{
            ProgressView().padding().onAppear() {
                DispatchQueue.main.async {
                    if !working {
                        working = true
                        loadData({
                            working = false
                            self.data = $0
                            self.present = true
                        })
                    }
                }
            }
        }
    }
    
    public var body: some View {
        Group{
            switch mode {
            case .fixed: viewInFixed()
            case .flex: viewInFlex()
            case .vif: viewInVIF()
            }
        }
        .lint(with: refreshInterval, view: { view, interval in
            view.onAppear() {
                if timer == nil {
                    self.timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
                }
            }
        })
        .lint(with: timer, view: {
            $0.onReceive($1, perform: { _ in
                loadData({ data = $0 })
            })
        })
        
    }
    
    public enum Mode: String {
        case flex, fixed, vif
    }
}

public extension View {
    
    @ViewBuilder func lazyloading() -> some View {
        lazyloading(milliseconds: 1)
    }
    
    @ViewBuilder func lazyloading(milliseconds ms: Int) -> some View {
        LazyLoadWith(delay: ms, loadData: { $0(true) }, content: { _ in
            self
        })
    }
    
    @ViewBuilder func lazyloading<Content: View>(milliseconds ms: Int = 20, @ViewBuilder placeholder content: @escaping () -> Content) -> some View {
        LazyLoadVElse(delay: ms, loadData: { $0(true) }, VIF: { _ in
            self
        }, VELSE: {
            content()
        })
    }
    
    @ViewBuilder func lazyloading<Content: View>(prepare boot: @escaping () -> Void, @ViewBuilder placeholder content: @escaping () -> Content) -> some View {
        LazyLoadVElse(loadData: { next in
            boot()
            next(true)
        }, VIF: { _ in
            self
        }, VELSE: {
            content()
        })
    }
    
    @ViewBuilder func lazyloading<Content:View>(delay ms: Int, @ViewBuilder view content: @escaping (Self) -> Content) -> some View {
        LazyLoadVElse(delay: ms, loadData: { next in
            next(true)
        }, VIF: { _ in
            content(self)
        }, VELSE: {
            self
        })
    }
}

#Preview {
    LazyLoadView(mode: .fixed, refreshInterval: 1, loadData: { next in
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(3)), execute: {
            next(Date())
        })
    }){ date in
        LintCenter {
            Text(date?.description ?? "")
        }
    }
    .border(.red)
}
