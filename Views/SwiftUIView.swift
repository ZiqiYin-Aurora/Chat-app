//
//  SwiftUIView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/11/16.
//

import SwiftUI

struct SwiftUIView: View {
    @EnvironmentObject var model: AppStateModel
    @State private var query = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(model.getFilteredChats(query: query)) { chat in
                    ZStack {
                        ConversationRow(chat: chat)
                        
                        // hidden NavigationLink. This hides the disclosure arrow!
                        NavigationLink(destination: ChatView(chat: chat).environmentObject(model)) {}
                        .buttonStyle(PlainButtonStyle())
                        .frame(width:0)
                        .opacity(0)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(action: {
                            model.markAsUnread(!chat.hasUnreadMessage, chat: chat)
                        }) {
                            if chat.hasUnreadMessage {
                                Label("Read", systemImage: "text.bubble")
                            } else {
                                Label("Read", systemImage: "circle.fill")
                            }
                        }
                        .tint(.blue)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .searchable(text: $query)
            .navigationTitle("Chats")
            .navigationBarItems(trailing: Button(action: {}) {
                Image(systemName: "square.and.pencil")
            })
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Sign out"){
                        self.signOut()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink(
                        destination: SearchView{name in
                            self.showSearch = false
                            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                                self.showChat = true
                                self.otherUsername = name
                            }
                        },
                        isActive: $showSearch,
                        label: {
                            Image(systemName: "magnifyingglass")
                        })
                }
                
            }
            .fullScreenCover(isPresented: $model.showingSignIn, content:{
                SignInView()
            })
            .onAppear {
                guard model.auth.currentUser != nil else {
                    return
                }
                
                model.getConversations()
            }
                
        }
    }
    
    func signOut(){
        model.signOut()
    }
    
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
