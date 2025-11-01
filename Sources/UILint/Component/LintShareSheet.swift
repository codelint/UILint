//
//  SwiftUIView.swift
//  UILint
//
//  Created by gzhang on 2025/10/31.
//

import SwiftUI

public struct LintShareImage: UIViewControllerRepresentable {
    
    let image: UIImage
    
    public func makeUIViewController(context: Context) -> some UIActivityViewController {
        // let image = UIImage(systemName: "checkmark")!
        return UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

@available(iOS 16, *)
public struct LintShareSheet<Content: View>: View {
    
    @ViewBuilder let content: () -> Content
    
    @State var image: UIImage? = nil
    @State var previewPresent: Bool = false
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        VStack{
            content()
                .padding(1)
                .background(content: {
                    content().shadow(radius: 1)
                })
                .padding()
                .lint(vertical: 0)
            VStack{
                Spacer(minLength: 0)
                Image(systemName: "square.and.arrow.up")
                    .padding()
                    .background(content: {
                        Circle().fill(Color.lint(c: .primary))
                    })
                    .shadow(radius: 0.5)
                    .lint(button: {
                        image = content().lintFont(.body).snapshot()
                        DispatchQueue.main.async {
                            previewPresent = true
                        }
                    })
            }
            .lint(vertical: 0)
            .sheet(isPresented: $previewPresent, onDismiss: {
                image = nil
            }, content: {
                if let image = image {
                    LintShareImage(image: image)
                }else{
                    ProgressView()
                }
            })
        }
    }
}

#Preview {
    VStack{
        if #available(iOS 16, *) {
            LintShareSheet(){
                Text("hello world").padding().border(Color.red)
            }
        } else {
            Text("hello world")
        }
    }
}
