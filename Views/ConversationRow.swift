//
//  SwiftUIView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/11/15.
//

import SwiftUI

struct ConversationRow: View {
    @EnvironmentObject var model: AppStateModel
    
    @State var chat: Chat
    
//    init(chat: Chat) {
//        self.chat = chat
//    }
    
    var body: some View {
            HStack(spacing: 20) {

                chat.img
                    .resizable()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                
                ZStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            Text(chat.name)
                                .font(Font.custom("Avenir Next", size: 19, relativeTo: .body))
                                .bold()
                                .onAppear {
                                    print("pppp: \(chat)")
                                }
                            Spacer()
                            Text(chat.messages.last?.date.descriptiveString() ?? "")
                                .foregroundColor(chat.hasUnreadMsg ? .blue : .gray)
                        }
                        Spacer()
                        HStack {
                            Text(chat.messages.last?.text ?? "")
                                .foregroundColor(.gray)
                                .lineLimit(2)
                                .frame(height: 50, alignment: .top)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.trailing, 40)
                        }
                        Spacer()
                    }
                    
                    Circle()
                        .foregroundColor(chat.hasUnreadMsg ? .blue : .clear)
                        .frame(width: 18, height: 18)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .frame(height: 80)
            .listRowBackground(Color.clear)
            .font(Font.custom("Avenir Next", size: 17, relativeTo: .body))
        
    }
    
}

struct ConversationRow_Previews: PreviewProvider {
    //        static var previews: some View {
    //            ConversationView()
    //        }
    static var previews: some View {
        let chat = Chat(id: "47374648",
                        name: "YYY",
                        img: Image("img7"),
                        personIDs: [AppStateModel().currentUID, "47374648"],
                        messages: [Message(text: "Hey flo, how are you?", type: .received, sender: "Aurora")], hasUnreadMsg: true)
        ConversationRow(chat: chat)
            .padding(.horizontal)
    }
}
