//public struct UILint {
//    public private(set) var text = "Hello, World!"
//
//    public init() {
//    }
//}

import SwiftUI

@available(iOS 16, *)
public extension View {
    @ViewBuilder var withLintColors: some View { self.foregroundColor(.lint(c: .font)).background(Color.lint(c: .background)) }
    
    @ViewBuilder var withLintFont: some View { self.lintFont(.body) }
    
    @ViewBuilder var withLintPage: some View { self.withLintColors.withLintFont.buttonStyle(.plain) }
}
