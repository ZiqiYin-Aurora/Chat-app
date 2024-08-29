//
//  ChatRow.swift
//  Chatting
//
//  Created by Yin Celia on 2021/10/17.
//

import SwiftUI

struct ChatRow: View {
    let type: MessageType
    @EnvironmentObject var model: AppStateModel

    var isSender: Bool {
        return type == .sent
    }

    let text: String

    init(text: String, type: MessageType) {
        self.text = text
        self.type = type
    }

    var body: some View {
        HStack {
            if isSender { Spacer() }
            
            if !isSender{
                VStack{
                    Spacer()
                    Image(model.currentUsername == "Matt" ? "photo1" : "photo2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .foregroundColor(Color.pink)
                        .clipShape(Circle())
                }
            }
            
            HStack{
                Text(text)
                    .foregroundColor(isSender ? Color.white : Color(.label))
                    .padding()
            }
            .background(isSender ? Color.orange : Color(.systemGray4))
            .padding(isSender ? .leading : .trailing, isSender ? UIScreen.main.bounds.width/3 : UIScreen.main.bounds.width/5)
            .cornerRadius(8)

        
            if !isSender { Spacer() }

        }
    }
}

struct ChatRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatRow(text: "test", type: .sent)
                .preferredColorScheme(.dark)
            ChatRow(text: "test", type: .received)
                .preferredColorScheme(.light)

        }
    }
}
