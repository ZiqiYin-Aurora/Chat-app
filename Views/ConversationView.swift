//
//  ConversationView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/11/13.
//

import SwiftUI

struct ConversationView: View {
    @Environment(\.viewController) private var holder
    @EnvironmentObject var model: AppStateModel
    
    @State var otherUsername: String = ""
    @State var showChat = false
    @State var showSearch = false
    @State var showEditing = false
    @State var showTalk = false
    @State private var query = ""
    @State private var tabBar: CircleTab! = nil
    @Binding var isHide: Bool
    
    var body: some View {
            NavigationView {
                ZStack{
                    Image("bg2")
                        .resizable(resizingMode: .stretch)
                        .edgesIgnoringSafeArea(.all)
                        .ignoresSafeArea()
                    
                    VStack {
                        List {
                            ForEach(model.getFilteredChats(query: query)) { chat in
                                ZStack {
                                    ConversationRow(chat: chat)
                                        .onAppear{
                                            let x = Array(chat.id)[0]
                                            if x != "G" {
                                                model.getUserInfo(uid: chat.id, isG: false)
                                            }
//                                            else {
//                                                model.otherUser = model.getUserInfo(uid: chat.id, isG: false)
//                                            }
                                        }
                                    // hidden NavigationLink. This hides the disclosure arrow!
                                    NavigationLink(destination: ChatView(chat: chat, Chatname: chat.name, isHide: .constant(false), otherUsername: chat.name, otherUID: chat.id).environmentObject(model)
                                    ) {}
                                    .navigationTitle("CONVERSATION")
                                    .font(Font.custom("Avenir Next", size: 28, relativeTo: .body))
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(width:0)
                                    .opacity(0)
                                }
                                .onAppear {
                                    self.initialize()
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button(action: {
                                        model.markAsUnread(!chat.hasUnreadMsg, chat: chat)
                                    }) {
                                        if chat.hasUnreadMsg {
                                            Label("Read", systemImage: "text.bubble")
                                        } else {
                                            Label("Read", systemImage: "circle.fill")
                                        }
                                    }
                                    .tint(.blue)
                                }
                            }
                            .listRowBackground(Color.white.opacity(0.3))
                        }
                        .searchable(text: $query)
                        .sheet(isPresented: $showEditing,
                               content: {
                            CreateGroupView().environmentObject(model)
                        })
                        .sheet(isPresented: $showTalk,
                               content: {
                            TalkView(ishide: false).environmentObject(model)
                        })
                        .toolbar{
                            ToolbarItem(placement: .navigationBarLeading){
                                Button(action: {
                                    self.showTalk.toggle()
                                }) {
                                    Text("Talking")
                                        .font(Font.custom("Avenir Next", size: 16, relativeTo: .body))
                                        .fontWeight(.semibold)
                                        .padding(6)
                                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                                        .cornerRadius(40)
                                        .foregroundColor(.white)
                                        .padding(3)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 40)
                                                .stroke(Color.mint, lineWidth: 2)
                                        )
                                }
                            }

                            ToolbarItem(placement: .navigationBarTrailing){
                                Button(action: {
                                    self.showEditing.toggle()
                                }) {
                                    Text("Create Group")
                                        .font(Font.custom("Avenir Next", size: 16, relativeTo: .body))
                                        .fontWeight(.semibold)
                                        .padding(6)
                                        .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing))
                                        .cornerRadius(40)
                                        .foregroundColor(.white)
                                        .padding(3)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 40)
                                                .stroke(Color.purple, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .onAppear {
                            self.initialize()
                            guard model.auth.currentUser != nil else {
                                return
                            }
                            model.getConversations()
                        }
                    }
                    .padding(.vertical, 6)
            }
        }        
    }
    func initialize(){
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableView.appearance().tableFooterView = UIView()
     }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(isHide: .constant(false))
    }
}

