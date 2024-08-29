//
//  SignInView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/11/11.
//

import SwiftUI

struct SignInView: View {
//    @State var username: String = ""
    @State var uid: String = ""
    @State var password: String = ""
    @State var showPwd = false
    @State var isAlert = false
    @Binding var flag: Bool
    
    @Environment(\.viewController) private var holder
    @EnvironmentObject var model: AppStateModel
    
    var body: some View {
        NavigationView {
            ZStack{
                Image("Background2")
                    .resizable(resizingMode: .stretch)
                    .ignoresSafeArea()
                
                VStack (alignment: .center) {
                    // Heading
                    Image("Fox")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .cornerRadius(30)

                    Text("Welcome to SnowFoxxx!!!!\nLet's begin the adventure!!")
                        .bold()
                        .padding()
                        .font(Font.custom("Avenir Next", size: 26, relativeTo: .body))

                    // Textfields
                    VStack {
                        TextField("User ID", text: $uid)
                            .onAppear() {
                                self.uid = model.currentUID
                            }
                            .modifier(CustomField())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        ZStack(alignment: .trailing){
                            if showPwd {
                                TextField("Password", text: $password)
                                    .modifier(CustomField())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("Password", text: $password)
                                    .modifier(CustomField())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            Button(action: {
                                self.showPwd.toggle()
                            }) {
                                Image(systemName: self.showPwd ?
                            "eye" : "eye.slash")
                                    .frame(width: 70, alignment: .center)
                            }
                        }
                        
                        Button(action: {
                            self.signIn()
                            if (model.recv["code"] == "200") && (model.cookies != "") {
                                self.flag.toggle()
                            }
                            
                        }, label: {
                            Text("Sign In")
                                .fontWeight(.semibold)
                                .padding(.all)
                                .frame(width: 180)
                                .background(Color.green
                                                .blur(radius: 7.0))
                                .frame(height: 100, alignment: .center)
                                .foregroundColor(Color.white)
                            
                        })
                            .padding()
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Sign up
                    HStack(alignment: .center) {
                        Text("New to Foxxx?")
                            .fontWeight(.semibold)
                            .frame(width: 120, height: 35, alignment: .center)

                        NavigationLink(destination: SignUpView(),
                                       label: {
                            Text("Create Account")
                                .fontWeight(.semibold)
                                .frame(width: 150, height: 35, alignment: .center)
                        })
                            .foregroundColor(Color.white)
                            .background(Color.orange
                                            .blur(radius: 6.0))
                    }
                }
            }
        }
    }
    func signIn() {
        guard !uid.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
                  return
              }
        
        let result = model.signIn(uid: uid, password: password)
        if !result {
            holder?.present { Alert().environmentObject(model) }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(flag: .constant(true))
            .preferredColorScheme(.light)
    }
}
