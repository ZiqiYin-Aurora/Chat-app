//
//  ChatView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/11/11.
//

import SwiftUI
import grpc
import FirebaseFirestoreSwift

struct ChatView: View {
    @FocusState private var isFocused
    @EnvironmentObject var model: AppStateModel
    @Environment(\.presentationMode) var presentationMode
    @State var message: String = ""
    @State var chat: Chat
    @State var Chatname: String
    @State private var showingPopover = false
    @State private var messageIDToScroll: UUID?
    @State private var members: [Person] = []
    @Binding var isHide: Bool

    let otherUsername: String
    let otherUID: String
    let spacing: CGFloat = 10
    let minSpacing: CGFloat = 3

    var body: some View {
        ZStack{
            Image("bg3")
                .resizable(resizingMode: .stretch)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                GeometryReader{ reader in
                    getChatsView(viewWidth: reader.size.width)
                        .onTapGesture {
                            isFocused = false
                        }
                }
                .padding(.bottom, 5)

                toolbarView()
            }
            .padding(.top, 1)
            .navigationBarItems(leading: navBarLeadingBtn(), trailing: navBarTrailingBtn())
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                model.markAsUnread(false, chat: chat)
                chat.hasUnreadMsg = false
                model.otherUsername = otherUsername
                print("otherNNN: \(otherUsername)")
                model.otherUID = otherUID
                self.isHide = true
                MainView(isHide: true).hidden()
                print("friends: \(model.friends)")
                if Array(otherUID)[0] != "G" {
                    model.getUserInfo(uid: otherUID, isG: false)
                    model.otherUser = model.specificUser
                }
                else {
                    chat.personIDs.forEach { i in
                        let p = model.getUserInfo(uid: i, isG: true)
                }
                    members = model.groupMbrs
                }
                model.observeChat()
            }
            .onDisappear{
                model.groupMbrs = []
//                model.getConversations()
            }
            
        }
        .font(Font.custom("Avenir Next", size: 17, relativeTo: .body))

    }

    func getChatsView(viewWidth: CGFloat) -> some View {
        ScrollView(.vertical) {
            ScrollViewReader { scrollReader in
                LazyVGrid(columns: [GridItem(.flexible(minimum: 0))], spacing: 0, pinnedViews: [.sectionHeaders]) {
                    let sectionMessages = model.getSectionMessages(for: chat)
                    ForEach(sectionMessages.indices, id: \.self) { i in
                        let messages = sectionMessages[i]
                        Section(header: sectionHeader(firstMessage: messages.first!)) {
                            ForEach(model.messages, id: \.self) { message in
                                let isReceived = message.type == .received
                                HStack {
                                    ZStack {
                                        VStack(alignment: isReceived ? .leading : .trailing){
                                            Text(isReceived ? message.sender : model.currentUser.name)
                                                .foregroundColor(Color.gray)
                                                .font(.system(size: 14, weight: .regular))
                                                .padding(.bottom, -5)
                                            Text(message.text)
                                                .padding(.horizontal)
                                                .padding(.vertical, 12)
                                                .background(isReceived ? Color.mint.opacity(0.8) : Color.orange.opacity(0.9))
                                                .cornerRadius(13)
                                        }
                                    }
                                    .frame(width: viewWidth * 0.7, alignment: isReceived ? .leading  : .trailing)
                                    .padding(.vertical, 5)

                                }
                                .frame(maxWidth: .infinity, alignment: isReceived ? .leading  : .trailing)
                                .id(message.id)
                                
                            }
                        }
                    }
                    .onChange(of: isFocused) { _ in
                        if isFocused && (chat.messages.count ?? 0 > 0) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeIn(duration: 0.5)) {
                                    scrollReader.scrollTo(chat.messages.last!.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .onChange(of: messageIDToScroll) { _ in
                        // This scrolls down to the new sent Message
                        if let messageID = messageIDToScroll {
                            DispatchQueue.main.async {
                                withAnimation(.easeIn) {
                                    scrollReader.scrollTo(messageID)
                                }
                            }
                        }
                    }
                    .onAppear {
                        Chatname = chat.name
                        MainView(isHide: true)
                        DispatchQueue.main.async {
                            scrollReader.scrollTo(chat.messages.last!.id, anchor: .bottom)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        //.background(Color.black)
    }
    
    func toolbarView() -> some View {
        VStack {
            let height: CGFloat = 37

            // Field, Send Button
            HStack {
                TextField("Message...", text: $message)
                    .padding(.horizontal, 10)
                    .frame(height: height)
                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .focused($isFocused)
                
                SendButton(text: $message, chat: self.$chat)
            }
            .frame(height: height)
        }
        .edgesIgnoringSafeArea(.all)
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(.thickMaterial)
    }

    func sectionHeader(firstMessage message: Message) -> some View {
        ZStack {
            let color = Color(hue: 0.587, saturation: 0.742, brightness: 0.924)
            Text(message.date.descriptiveString(dateStyle: .medium))
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .regular))
                .frame(width: 120)
                .padding(.vertical, 4)
                .background(Capsule().foregroundColor(color))
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
    }

    func navBarLeadingBtn() -> some View {
        Button(action: {
            showingPopover = true
        }) {
            HStack {
                chat.img
                //Image(chat.person.imgString)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                                
                Text(Chatname)
                    .bold()
            }
            .foregroundColor(.white)
        }
        .popover(isPresented: $showingPopover) {
            if Array(otherUID)[0] != "G" {
                ChatInfoView(chat: $chat, Chatname: $Chatname).environmentObject(model)
            }
            else {
                GroupInfoView(chat: $chat, members: model.groupMbrs).environmentObject(model)
            }
        }
    }

    func navBarTrailingBtn() -> some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "video")
            }

            Button(action: {}) {
                Image(systemName: "phone")
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(chat: AppStateModel().chat ?? AppStateModel().sampleChat, Chatname: "friend1", isHide: .constant(false), otherUsername: "Samantha", otherUID: "123456")
                .preferredColorScheme(.dark)
    }
}


