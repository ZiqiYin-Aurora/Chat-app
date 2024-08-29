//
//  AccountView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/2.
//

import SwiftUI

struct AccountView: View {
    @Environment(\.viewController) private var holder
    @EnvironmentObject var model: AppStateModel
    @State var showEditing = false
    @State private var isShow = false
    
    var body: some View {
        NavigationView{
            ZStack{
                Image("background-1")
                    .resizable(resizingMode: .stretch)
                    .ignoresSafeArea()
                
                VStack{
                    // Heading
                    model.currentUser.img
                        .resizable()
                        .clipShape(Circle())
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)

                    Text(model.currentUsername) //nickname
                        .bold()
                        .font(.system(size: 25))
                        .padding([.leading, .trailing])

                    Text("ID: \(model.currentUID)")
                        .bold()
                        .padding(.top, -10)
                        .padding([.leading, .trailing])

                    Spacer()

                    HStack{ // username
                        Text("Username")
                            .bold()
                        Spacer()
                        Text(model.currentUsername)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.leading, 50)
                    .padding(.trailing, 70)
                    .padding([.top, .bottom])

                    HStack{
                        Text("E-mail")
                            .bold()
                        Spacer()
                        Text(model.currentEmail)
                            .fontWeight(.semibold)
                            .lineLimit(90)
                            .multilineTextAlignment(.center)
                            .frame(width: 170)

                    }
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                    .padding([.top, .bottom])

                    HStack{
                        Text("Friends")
                            .bold()
                        Spacer()
                        Text("29")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.leading, 50)
                    .padding(.trailing, 90)
                    .padding([.top, .bottom])
//
//                    //                    HStack{ // username
//                    //                        Text("Birth")
//                    //                            .bold()
//                    //                            .font(.system(size: 22))
//                    //                        Spacer()
//                    //                        Text("27/10/2000")
//                    //                            .multilineTextAlignment(.center)
//                    //                            .font(.system(size: 20))
//                    //
//                    //                    }
//                    //                    .padding(.leading, 50)
//                    //                    .padding(.trailing, 70)
//                    //                    .padding([.top, .bottom])
//
                    Spacer()

                    Button(action: {
                        self.signOut()
                    }, label: {
                        Text("Sign Out")
                            .fontWeight(.semibold)
                            .padding(.all)
                            .frame(width: 180)
                            .background(Color.pink.blur(radius: 8.0))
                            .foregroundColor(Color.white)
                    })
                    Spacer()
                }
            }
            .onAppear{model.getConversations()}
            .font(.custom("Avenir Next", size: 20))
            .sheet(isPresented: $showEditing,
                   content: {
                SettingView().environmentObject(model)
            })
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    
                    Button(action: {
                        self.showEditing.toggle()
                    }, label: {
                        Text("Settings")
                            .bold()
                            .frame(width: 100, height: 30)
                            .foregroundColor(.white)
                            .background(Color.white.blur(radius: 8.0).opacity(0.6))
                    })
                }
            }
        }
    }
    func signOut(){
        let result = model.signOut()
        if !result {
            holder?.present { Alert().environmentObject(model) }
        }
        holder?.present { MainView(isHide: false).environmentObject(model) }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}

