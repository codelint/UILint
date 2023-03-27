//
//  SwiftUIView.swift
//  
//
//  Created by gzhang on 2023/3/24.
//

import SwiftUI

struct Center<Content: View>: View {
    
    var content: () -> Content
    
    var body: some View {
        VStack{
            Spacer(minLength: 1)
            HStack{
                Spacer(minLength: 1)
                content()
                Spacer(minLength: 1)
            }
            Spacer(minLength: 1)
        }
    }
}

struct Center_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            Center {
                Text("hello")
            }
        }
    }
}