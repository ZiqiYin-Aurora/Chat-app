//
//  ChatInfoView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/5.
//

import SwiftUI

struct ChatInfoView: View {
    @EnvironmentObject var model: AppStateModel
    @Environment(\.presentationMode) var presentation
    @Environment(\.viewController) private var holder
    
    @Binding var chat: Chat
    @Binding var Chatname: String
    @State var newImg: String = ""
    
    var body: some View {
        ZStack{
            Image("bg3")
                .resizable(resizingMode: .stretch)
                .ignoresSafeArea()
            
            VStack{
                Spacer()
                Text("Chat Info.")
                    .bold()
                    .font(Font.custom("Avenir Next", size: 24, relativeTo: .body))
                    .foregroundColor(Color.black)
                    .padding()
                    .border(Color.black, width: 5)
                    
                Spacer()

                HStack{
//                    Image(chat.img)
                    chat.img.resizable()
                        .clipShape(Circle())
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 130, height: 130)
                        .padding()
                    
                    VStack{
                        Text(model.specificUser.name)
                            .bold()
                            .font(Font.custom("Avenir Next", size: 24, relativeTo: .body))
                            .padding()

                        Text("ID: \(model.otherUID)")
                            .bold()
                            .font(Font.custom("Avenir Next", size: 24, relativeTo: .body))
                            .padding()
                    }
                    .onAppear{
                        print("otherUser:::::: \(model.otherUser)")
                    }
                }
                Spacer()
                
                HStack{
                    Text("CHAT NAME")
                        .bold()
                        .font(Font.custom("Avenir Next", size: 20, relativeTo: .body))
                        .padding()
                    
                    TextField("", text: $Chatname)
                        .placeholder(when: Chatname.isEmpty) {
                            Text(chat.name).foregroundColor(Color.black.opacity(0.8))
                        }
                        .modifier(SettingText())
                        
                }

                Button(action: {
                    self.update()
                    self.presentation.wrappedValue.dismiss()
                }) {
                    Text("APPLY")
                        .font(Font.custom("Avenir Next", size: 20, relativeTo: .body))
                        .fontWeight(.semibold)
                        .padding(.all)
                        .cornerRadius(30)
                        .frame(width: 100)
                        .background(Color.green
                                        .blur(radius: 5))
                        .foregroundColor(Color.white)
                }
                .padding()

                Button(action: {
                    model.delChat()
                    self.presentation.wrappedValue.dismiss()
                }) {
                    Text("DELETE CHAT")
                        .font(Font.custom("Avenir Next", size: 20, relativeTo: .body))
                        .fontWeight(.semibold)
                        .padding(.all)
                        .frame(width: 170)
                        .background(Color.red
                                        .blur(radius: 5))
                        .foregroundColor(Color.white)
                }
                .padding()
                Spacer()

            }
        }
    }
    func update() {
        guard !Chatname.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }
        
        model.updateChatInfo(name: Chatname)
    }
}

