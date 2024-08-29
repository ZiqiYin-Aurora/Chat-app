//
//  GroupInfoView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/6.
//

import SwiftUI

struct GroupInfoView: View {
    @EnvironmentObject var model: AppStateModel
    @Environment(\.presentationMode) var presentation
    @Environment(\.viewController) private var holder
    
    @Binding var chat: Chat
    @State var newChatname: String = ""
    @State var newImg: String = ""
    @State var showEditing = false
    @State var show = false
    @State var selectedPersons: [String] = []
//    @State var currentMembers: [String] = []
    
    @State private var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    @State var members: [Person]
    @State private var symbols = ["keyboard", "hifispeaker.fill", "printer.fill", "tv.fill", "desktopcomputer", "headphones", "tv.music.note", "mic", "plus.bubble", "video"]

    @State private var colors: [Color] = [.yellow, .purple, .green]
    @State private var num: Int = 2
    
    var body: some View {
            ZStack{
                Image("bg3")
                    .resizable(resizingMode: .stretch)
                    .ignoresSafeArea()
                
                VStack{
                    Spacer()
                    Text("Group Info.")
                        .bold()
                        .font(Font.custom("Avenir Next", size: 24, relativeTo: .body))
                        .foregroundColor(Color.black)
                        .padding()
                        .border(Color.black, width: 5)

                   
                    HStack{
                        chat.img
                            .resizable()
                            .clipShape(Circle())
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .padding()

                        VStack{
                            Text(chat.name)
                                .bold()
                                .font(Font.custom("Avenir Next", size: 24, relativeTo: .body))
                                .padding()

                            Text("ID: \(chat.id)")
                                .bold()
                                .font(Font.custom("Avenir Next", size: 24, relativeTo: .body))
                                .padding()
                        }
                    }
                    Spacer()

                    HStack{
                        Text("GROUP NAME")
                            .bold()
                            .font(Font.custom("Avenir Next", size: 20, relativeTo: .body))
                            .padding()

                        TextField("", text: $newChatname)
                            .placeholder(when: newChatname.isEmpty) {
                                Text(chat.name).foregroundColor(Color.black.opacity(0.8))
                            }
                            .modifier(SettingText())

                    }
//                    Spacer()

                    Button(action: {
                        self.update()
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("APPLY")
                            .font(Font.custom("Avenir Next", size: 20, relativeTo: .body))
                            .fontWeight(.semibold)
                            .padding(.all)
                            .cornerRadius(30)
                            .frame(width: 100, height: 45)
                            .background(Color.green
                                            .blur(radius: 5))
                            .foregroundColor(Color.white)
                    }
                    .padding()
                    
                    ScrollView () {
                        HStack{
                            Button(action: {
                                self.showEditing.toggle()
                                self.invite()
                            }) {
                                HStack {
                                    Text("+")
                                        .font(Font.custom("Avenir Next", size: 40, relativeTo: .body))
                                        .fontWeight(.semibold)
                                        .padding()
                                        .background(Color.white.opacity(0.8))
                                        .foregroundColor(Color.indigo)
                                        .clipShape(Circle())
                                        .frame(width: 70, height: 70)
                                }
                            }
                        }
                        LazyVGrid(columns: gridItemLayout, alignment: .center, spacing: 15) {
                            ForEach((0...(members.count-1)), id: \.self) {
                                let img = members[$0 % members.count].img
                                let name = members[$0 % members.count].name
                                let id = members[$0 % members.count].id

                                Button(action: {}) {
                                    VStack{
                                        img
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(20)
                                        Text(name)
                                            .font(Font.custom("Avenir Next", size: 16, relativeTo: .body))
                                            .foregroundColor(Color.black)
                                        Text(id)
                                            .font(Font.custom("Avenir Next", size: 16, relativeTo: .body))
                                            .foregroundColor(Color.black)
                                    }
                                }
                            }
                        }
                        .onAppear{
                            members = model.groupMbrs
                        }
                    }
                    
                    Button(action: {
                        model.delChat()
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("QUIT GROUP")
                            .font(Font.custom("Avenir Next", size: 18, relativeTo: .body))
                            .fontWeight(.semibold)
                            .padding(.all)
                            .frame(width: 170, height: 40)
                            .background(Color.white
                                            .opacity(0.85)
                                            .blur(radius: 5))
                            .foregroundColor(Color.red)
                    }
                    .padding()
                    Spacer()
                }
                .sheet(isPresented: $showEditing,
                       content: {
                    SelectView(persons: $selectedPersons).environmentObject(model)
                })
                .onAppear{
                    members = model.groupMbrs
                }
                
            
        }
        
    }
    func update() {
        guard !newChatname.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }
        var pids: [String] = []
        members.forEach{ i in
            pids.append(i.id)
        }
        model.updateGroupName(newname: newChatname, pids: pids)
    }
    
    func invite() {
        print("~~~~ \(model.otherUID) \(selectedPersons)  \(chat.personIDs)")
        let result = model.addPersontoGroup(name: chat.name, pid: selectedPersons, expid: chat.personIDs)
        if !result {
            holder?.present { Alert().environmentObject(model) }
        }
    }
    
    func kick() {
        
    }
}

