//
//  DashedCornerRadius.swift
//  statement
//
//  Created by gzhang on 2024/3/6.
//

import SwiftUI

struct DashedCornerRadius: Shape {
    let radius: CGFloat
    func path(in rect: CGRect)->Path {
        let radius = min(rect.height, rect.width, radius*2)/2
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(
            center: .init(x: rect.minX+radius, y: rect.minY + radius),
            radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.addLine(to: .init(x: rect.maxX - radius, y: rect.minY))
        path.addArc(
            center: .init(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: .init(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(
            center: .init(x: rect.maxX - radius, y: rect.maxY - radius),
            radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: .init(x: rect.minX + radius, y: rect.maxY))
        path.addArc(
            center: .init(x: rect.minX + radius, y: rect.maxY - radius),
            radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        // path.addLine(to: .init(x: rect.minX, y: rect.maxY - radius))
        path.closeSubpath()
        return path
    }
}

struct DashedRoundedBorder: ViewModifier {
    
    var radius: CGFloat = 16
    var lineWidth: CGFloat = 0.5
    var dashed: [CGFloat] = [3, 3]
    var color: Color = Color(hex: "#000000")
    
    func body(content: Content) -> some View {
        content.overlay(content: {
            Rectangle().fill(color).clipShape(DashedCornerRadius(radius: radius).stroke(style: .init(lineWidth: lineWidth, dash: dashed)))
        })
    }
}



#Preview {
    Text("hello world")
        .padding()
        .padding(.vertical)
        .padding(.vertical)
        .modifier(DashedRoundedBorder(radius: 64, dashed: [1, 2]))
    
}
