//
//  CreateGroupView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/5.
//

import SwiftUI

struct CreateGroupView: View {
    @EnvironmentObject var model: AppStateModel
    @Environment(\.presentationMode) var presentation
    @Environment(\.viewController) private var holder
    @State var showEditing = false
    @State var groupname: String = ""
//    @State var persons: String = ""
    @State var persons: [String] = []

    var body: some View {
        ZStack{
            Image("sky")
                .resizable(resizingMode: .stretch)
                .ignoresSafeArea()
            
            VStack (alignment: .center){
                Spacer()
                Text("Create A Group")
                    .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        .foregroundColor(Color.purple)
                        .background(Color.white.opacity(0.8).blur(radius: 5.0))
                        .padding(10)
                        .border(Color.white.opacity(0.9), width: 5)
                
//                Spacer()
                Text("Group Name")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .font(.title2)
                    .padding(5)
                
                TextField("", text: $groupname)
                    .frame(width: 250)
                    .modifier(SettingText())
                    .foregroundColor(.white)
                    .padding()
                
                Text("Invite People")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .font(.title2)
                    .padding(5)
                
                Button(action: {
                    self.showEditing.toggle()
                }) {
                    Text("CHOOSE")
                        .font(Font.custom("Avenir Next", size: 19, relativeTo: .body))
                        .fontWeight(.semibold)
                        .padding(.all)
                        .frame(width: 240)
                        .background(Color.white.opacity(0.4)
                                        .blur(radius: 10))
                        .cornerRadius(18)
                        .foregroundColor(Color.white)
                }
                Text("\(String(describing:self.persons))")
                    .foregroundColor(.white)
                    .font(.title2)
                
                Spacer()
                Button(action: {
                    self.update()
                    self.presentation.wrappedValue.dismiss()
                }) {
                    Text("CREATE")
                        .font(Font.custom("Avenir Next", size: 21, relativeTo: .body))
                        .fontWeight(.semibold)
                        .padding(.all)
                        .frame(width: 170)
                        .background(Color.yellow
                                        .blur(radius: 5.0))
                        .foregroundColor(Color.white)
                }
                
                Spacer()
            }
            .sheet(isPresented: $showEditing,
                   content: {
                SelectView(persons: self.$persons).environmentObject(model)
            })
        }
    }
    func update() {
        guard !groupname.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }
        
        model.CreateGroup()
        model.addPersontoGroup(name: groupname, pid: self.persons, expid: [model.currentUID])
        self.persons.append(model.currentUID)
        let result = model.updateGroupName(newname: groupname, pids: self.persons)
        
//        model.sendMessage(text: "Group Created!", chat: <#T##Chat#>)
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
    }
}

struct SelectView: View {
    @EnvironmentObject var model: AppStateModel
    @Environment(\.presentationMode) var presentation
    @Environment(\.viewController) private var holder
    
    @State private var appear = false
    @State private var selection = Set<String>()
    @State var addButtonDisabled = false
    @State var isEditing = false
    @State var names: [String] = []
    @Binding var persons: [String]

    var body: some View {
        ZStack{
            Color.clear
                .contentShape(Rectangle())
            
            VStack{
                Spacer()
                NavigationView {
                    List(names, id: \.self, selection: $selection) { name in
                        Text(name)
                            .fontWeight(.semibold)
                            .padding(10)
                    }
                    .frame(height: 400)
                    .cornerRadius(20)
                    .onAppear(perform: assign)
                    .onDisappear(perform: bind)
                    .navigationBarItems(leading:
                        EditButton()
                    )
                }
                .frame(height: 400)
                .cornerRadius(20)
                .font(Font.custom("Avenir Next", size: 18, relativeTo: .body))
            }
        }
        .edgesIgnoringSafeArea(.all)
        .background(BackgroundClearView())
        
    }
    func assign() {
        model.conversations.forEach{ i in
            if Array(i.id)[0] != "G" {
                names.append(i.id)
            }
        }
        persons = [String](selection)
    }
    func bind() {
        persons = [String](selection)
        print("selection:\([String](selection)) persons:\(persons)")
    }
}

struct BackgroundClearView: UIViewRepresentable{
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
