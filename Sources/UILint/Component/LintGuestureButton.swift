//
//  GestureButton.swift
//  going
//
//  Created by gzhang on 2023/1/24.
//

import SwiftUI

public struct LintGestureButton<Content: View>: View {
    
    @State var scrollX: CGFloat = 0
    @State var scrollY: CGFloat = 0
    
    let action: () -> Void
    let label: () -> Content
    
    let move: ((CGFloat, CGFloat) -> Void)?
    let moveEnd: ((CGFloat, CGFloat) -> Void)?
    
    let direction: Direction
    
    
    init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Content) {
        self.action = action
        self.label = label
        self.move = nil
        self.moveEnd = nil
        self.direction = .both
    }
    
    init(action: @escaping () -> Void,
         @ViewBuilder label: @escaping () -> Content,
         onMove: ((CGFloat, CGFloat) -> Void)?,
         onMoveEnd: ((CGFloat, CGFloat) -> Void)?) {
        self.action = action
        self.label = label
        self.move = onMove
        self.moveEnd = onMoveEnd
        self.direction = .both
    }
    
    init(_ direction: Direction, action: @escaping () -> Void,
         @ViewBuilder label: @escaping () -> Content,
         onMove: ((CGFloat, CGFloat) -> Void)?,
         onMoveEnd: ((CGFloat, CGFloat) -> Void)?) {
        self.action = action
        self.label = label
        self.move = onMove
        self.moveEnd = onMoveEnd
        self.direction = direction
    }
    
    func direct(_ direction: Direction) -> Self {
        GestureButton(direction, action: action, label: label, onMove: move, onMoveEnd: moveEnd)
    }
    
    func onMove(_ callback: @escaping (CGFloat, CGFloat) -> Void) -> GestureButton<Content> {
        return GestureButton(action: action, label: label, onMove: { x,y in
            move?(x,y)
            callback(x,y)
        }, onMoveEnd: moveEnd)
    }
    
    func onMoveEnd(_ callback: @escaping () -> Void) -> GestureButton<Content> {
        return GestureButton(action: action, label: label, onMove: move, onMoveEnd: { x,y in
            if let exist = moveEnd {
                exist(x, y)
            }
            callback()
        })
    }
    
    func onMoveEnd(_ callback: @escaping (CGFloat, CGFloat) -> Void) -> GestureButton<Content> {
        return GestureButton(action: action, label: label, onMove: move, onMoveEnd: { x, y in
            moveEnd?(x, y)
            callback(x,y)
        })
    }
    
    public var body: some View {
        Button(action: action, label: label)
            .offset(x: scrollX, y: scrollY)
            .highPriorityGesture(drag)
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { event in
                switch direction {
                case .vertical:
                    scrollY = event.translation.height
                case .horizontal:
                    scrollX = event.translation.width
                case .both:
                    scrollY = event.translation.height
                    scrollX = event.translation.width
                }
                
                move?(scrollX, scrollY)
            }
            .onEnded { event in
                withAnimation(.linear) {
                    scrollY = 0
                    scrollX = 0
                }
                moveEnd?(event.translation.width, event.translation.height)
            }
    }
    
    enum Direction: String {
        case vertical, horizontal, both
    }
}


struct GestureButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            LintGestureButton(action: {
                
            }, label: {
                Text("Hello")
            })
        }
        .frame(width: 320, height: 640)
    }
}
