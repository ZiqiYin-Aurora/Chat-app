//
//  ViewModifier.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/4.
//

import Foundation
import SwiftUI

struct CustomField: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .font(Font.custom("Avenir Next", size: 18, relativeTo: .body))
            .padding()
            .background(Color(.secondarySystemBackground).opacity(0.4))
            .cornerRadius(18)
    }
}

struct SettingText: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    var isLight: Bool {
      colorScheme == .light
    }
    
    func body(content: Content) -> some View {
        return content
            .padding()
            .font(Font.custom("Avenir Next", size: 18, relativeTo: .body))
            .background(Color(.secondarySystemBackground).opacity(0.15))
            .foregroundColor(isLight ? Color.black : Color.white)
            .cornerRadius(18)
            .lineLimit(70)
            .frame(width: 160)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
}

struct AlertBox: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding(50)
            .background(Color.white)
            .cornerRadius(30)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
