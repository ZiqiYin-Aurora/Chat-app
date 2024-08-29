//
//  EnterView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/4.
//

import SwiftUI

struct EnterView: View {
    @State var flag = true
    var body: some View {
        ZStack {
            if flag {
                SignInView(flag: self.$flag)
            }
            else {
                MainView(isHide: false)
            }
        }
        
    }
}

struct EnterView_Previews: PreviewProvider {
    static var previews: some View {
        EnterView()
    }
}
