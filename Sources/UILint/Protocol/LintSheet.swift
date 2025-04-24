//
//  SwiftUIView.swift
//  UILint
//
//  Created by gzhang on 2025/4/14.
//

import SwiftUI

public protocol LintSheet: View {
    associatedtype V: View
    @ViewBuilder var sheet: V { get }
}

public extension LintSheet {
    var body: some View {
        sheet
    }
}

struct LintSheetTesting: LintSheet {
    var sheet: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    LintSheetTesting().frame(width: 360, height: 240, alignment: .center)
}
