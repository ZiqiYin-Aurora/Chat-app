//
//  TalkView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/9.
//


import SwiftUI
import grpc
import FirebaseFirestoreSwift

struct TalkView: View {
    @FocusState private var isFocused
    @EnvironmentObject var model: AppStateModel
    @Environment(\.presentationMode) var presentationMode
    @State var message: String = ""
    @State var text: String = ""
    @State var chat: Chat = Chat(id: "", name: "", img: Image("snow2"), personIDs: [], messages: [], hasUnreadMsg: false)
    @State var Chatname: String = ""
    @State private var showingPopover = false
    @State private var messageIDToScroll: UUID?
    @State private var members: [Person] = []
    @State var ishide: Bool
    @State var isclicked: Bool = false
//    @Binding var isHide: Bool

//    let otherUsername: String = ""
    @State var otherUID: String = "" // value transfer by GalaxyView, only use when search bar is hidden
    let spacing: CGFloat = 10
    let minSpacing: CGFloat = 3

    var body: some View {
        NavigationView {
            ZStack{
                Image("bg5")
                    .resizable(resizingMode: .stretch)
                    .edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea()
               
                VStack(spacing: 0) {
                    if !ishide {
                        HStack {
                            Spacer()
                            Text("Receiver: ")
                                .foregroundColor(.white)
                            TextField("User ID...", text: $text)
                                .padding(.horizontal, 10)
                                .frame(height: 40)
                                .background(Color.white.opacity(0.7))
                                .foregroundColor(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                            
                            Spacer()
                            Button(action: {
                                self.isclicked = true
                                // check if exist
                                model.otherUID = text
                                model.getUserInfo(uid: text, isG: false)
                                let p = model.findUser(uid: text)
                                model.otherUser = p
                                model.otherUsername = p.name
                                print("kkkk \(text) \(model.otherUID) \(model.otherUsername) \(model.otherUser)")
                                let pids = [model.currentUID, text]
                                self.chat = model.createConversation(personIDs: pids)
                                model.observeChat()                                
                            }) {
                                Text("OK")
                                    .font(Font.custom("Avenir Next", size: 14, relativeTo: .body))
                                    .fontWeight(.semibold)
                                    .padding(10)
                                    .background(Color.green)
                                    .cornerRadius(40)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    
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
                    
                    if self.ishide {
                        self.isclicked = true
                        model.otherUID = otherUID
                        model.getUserInfo(uid: model.otherUID, isG: false)
                        let p = model.findUser(uid: otherUID)
                        model.otherUser = p
                        model.otherUsername = p.name
                            print("oooo \(otherUID) \(model.otherUID) \(model.otherUsername)")
                            model.observeChat()
                            print("oooooo \(self.chat)")
                    }
                    
          
                }
            }
        }
        
    }

    func getChatsView(viewWidth: CGFloat) -> some View {
        ScrollView(.vertical) {
            ScrollViewReader { scrollReader in
                LazyVGrid(columns: [GridItem(.flexible(minimum: 0))], spacing: 0, pinnedViews: [.sectionHeaders]) {
                    if isclicked{
                        ForEach(model.messages, id: \.self) { message in
                            let isReceived = message.type == .received
                            HStack {
                                ZStack {
                                    Text(message.text)
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                        .background(isReceived ? Color.mint.opacity(0.8) : Color.orange.opacity(0.9))
                                        .cornerRadius(13)
                                }
                                .frame(width: viewWidth * 0.7, alignment: isReceived ? .leading  : .trailing)
                                .padding(.vertical, 5)

                            }
                            .frame(maxWidth: .infinity, alignment: isReceived ? .leading  : .trailing)
                            .id(message.id)
                            
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
                                scrollReader.scrollTo(model.messages.last!.id, anchor: .bottom)
                            }
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
                Spacer()
                Button("Back") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                chat.img
                //Image(chat.person.imgString)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                                
                Text(chat.name)
                    .bold()
                Spacer()
            }
            .foregroundColor(.white)
        }
        .popover(isPresented: $showingPopover) {
            if Array(model.otherUID)[0] != "G" {
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

struct TalkView_Previews: PreviewProvider {
    static var previews: some View {
        TalkView(ishide: true)
                .preferredColorScheme(.dark)
    }
}


