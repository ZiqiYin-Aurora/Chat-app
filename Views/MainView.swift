//
//  MainView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/1.
//

import SwiftUI
import InputBarAccessoryView

struct MainView: View {
    @State var index = 0
    @State var isHide: Bool
    @EnvironmentObject var model: AppStateModel
    @State var cookies: String =  ""
    @State var flag = true
    @State var i: String = ""
    
    var body: some View {
        ZStack {
            if flag {
                SignInView(flag: self.$flag)
            }
            else {
                VStack{
                    Spacer()
                    ZStack{
                        if self.index == 0 {
                            GalaxyView()
                                .onAppear {
                                    self.i = "sky"
                                    guard model.auth.currentUser != nil else {
                                        return
                                    }
                                }
                        }
                        else if self.index == 1 {
                            ConversationView(isHide: .constant(false))
                                .onAppear{
                                    self.i = "bg2"
                                }
                        }
                        else {
                            AccountView()
                                .onAppear{
                                    self.i = "background-1"
                                }
                        }
                    }
                    .edgesIgnoringSafeArea(.all)

                    
                    if isHide {
                        CircleTab(index: self.$index).hidden()
                    }
                    else {
                        CircleTab(index: self.$index)
                    }
                }
                .background(
                    Image(self.i)
                                .resizable(resizingMode: .stretch)
                                .edgesIgnoringSafeArea(.all)
                                .ignoresSafeArea()
                )
                .edgesIgnoringSafeArea(.all)
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(isHide: false)
    }
}

struct CircleTab: View{
    @Binding var index : Int
    
    var body: some View{
            HStack{
                Spacer()
                Button(action: {
                    self.index = 0
                }) {
                    VStack{
                        if self.index != 0{
                            Image("Star").foregroundColor(Color.black.opacity(0.2))
                        }
                        else{
                            Image("Star")
                                .resizable()
                                .frame(width: 57, height: 57)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .offset(y: -10)
                                .padding(.bottom, -20)
                            
                            Text("Galaxy")
                                .foregroundColor(Color.black.opacity(0.7))
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    self.index = 1
                }) {
                    VStack{
                        if self.index != 1{
                            Image("chat").foregroundColor(Color.black.opacity(0.2))
                        }
                        else{
                            Image("chat")
                                .resizable()
                                .frame(width: 57, height: 57)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .offset(y: -10)
                                .padding(.bottom, -20)
                            
                            Text("Chat")
                                .foregroundColor(Color.black.opacity(0.7))
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    self.index = 2
                    
                }) {
                    VStack{
                        if self.index != 2{
                            Image("Account").foregroundColor(Color.black.opacity(0.2))
                        }
                        else{
                            Image("Account")
                                .resizable()
                                .frame(width: 57, height: 57)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .offset(y: -10)
                                .padding(.bottom, -20)
                            
                            Text("Account")
                                .foregroundColor(Color.black.opacity(0.7))
                                .fontWeight(.semibold)
                        }
                    }
                }
                Spacer()

            }
            .padding(.horizontal, 10)
            .frame(height: 75)
            .background(Color.white.blur(radius: 8.0).opacity(0.9))
            .animation(.spring())
            .font(Font.custom("Avenir Next", size: 18, relativeTo: .body))
            .edgesIgnoringSafeArea(.all)

        }
        
    //}
}

