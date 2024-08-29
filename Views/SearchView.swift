////
////  SearchView.swift
////  Chatting
////
////  Created by Yin Celia on 2021/10/17.
////
//
//import SwiftUI
//import grpc
//import FirebaseFirestoreSwift
//
//struct SearchView: View {
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    @EnvironmentObject var model: AppStateModel
//    @FocusState private var isFocused
//    @State var text: String = ""
//    @State var showChat = false
//    @State var message: String = ""
//    @State private var showingPopover = false
//    @State private var messageIDToScroll: UUID?
//    @State var uids: [String] = []
//    @State var chat = Chat(id: "", name: "", img: "good1_30x30", personIDs: [], hasUnreadMsg: false)
//
//    let spacing: CGFloat = 10
//    let minSpacing: CGFloat = 3
//
//    @State private var members: [Person] = []
//
//    let completion: ((String) -> Void)
//
//    init(completion: @escaping ((String) -> Void)) {
//        self.completion = completion
//    }
//
//    var body: some View {
//        NavigationView{
//            VStack(spacing: 0) {
//                HStack {
//                    Spacer()
//                    Text("Receiver: ")
//                    TextField("User ID...", text: $text)
//                        .modifier(CustomField())
//                    Spacer()
//                }
//
//                            Button("Search") {
//                                    guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
//                                        return
//                                    }
//                                let x = model.getFilteredChats(query: text)
//                                var chat = x[0]
//            
//                                    if chat.id.isEmpty {
//                                        chat = model.createConversation(personIDs: [model.currentUID, text])
//                                    }
//                                model.searchUsers(queryText: text) { uids in
//                                    self.uids = uids
//                                }
//                            }
//                                List {
//                                    ForEach(uids, id: \.self) { i in
//                                        let p = model.getUserInfo(uid: i, isG: false)
//                                        ZStack {
//                                            HStack{
//                                                Image(p.imgString)
//                                                //Image(chat.person.imgString)
//                                                    .resizable()
//                                                    .frame(width: 50, height: 50)
//                                                    .clipShape(Circle())
//                                                Text(i)
//                                                    .font(.system(size: 20))
//                                            }
//                
//                                            NavigationLink(destination: ChatView(chat: chat, Chatname: chat.name, isHide: .constant(false), otherUsername: chat.name, otherUID: chat.id).environmentObject(model)){}
//                                            .navigationTitle("Talk")
//                                            .buttonStyle(PlainButtonStyle())
//                                            .frame(width:0)
//                                            .opacity(0)
//                                        }
//                                        .onTapGesture {
//                                            self.chat = model.createConversation(personIDs: [model.currentUID, text])
//                                            showChat.toggle()
//                                        }
//                                    }
//                            }
//
//                
//            }
//            
//        }
//    }
// 
//    struct SearchView_Previews: PreviewProvider {
//        static var previews: some View {
//            SearchView() { _ in }
//            .preferredColorScheme(.dark)
//        }
//    }
//}
