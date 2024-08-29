//
//  SendButton.swift
//  Chatting
//
//  Created by Yin Celia on 2021/10/17.
//

import SwiftUI

struct SendButton: View {
    @Binding var text: String
    @EnvironmentObject var model: AppStateModel
    @Binding var chat: Chat

    var body: some View {
        let height: CGFloat = 37
        
        Button(action: {
//                    if let newMessage = model.sendMessage(text: message) {
//                        message = ""
//                        messageIDToScroll = newMessage.id
//                    }
            self.sendMessage()
        }) {
            Image(systemName: "paperplane.fill")
                .foregroundColor(.white)
                .frame(width: height, height: height)
                .background(
                    Circle()
                        .foregroundColor(text.isEmpty ? .gray : .blue))
        }
    }

    func sendMessage() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        model.sendMessage(text: text, chat: chat)
        text = ""
    }
}
