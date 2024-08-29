//
//  SignUpView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/11/11.
//

import SwiftUI

struct SignUpView: View {
    @State var username: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var isAlert1 = false // for success msg
    @State var isAlert2 = false // for error msg
    @State var isAlert3 = false // for pwd less
    @State var showPwd = false
    
    @Environment(\.viewController) private var holder
    @EnvironmentObject var model: AppStateModel

    var body: some View {
        ZStack{
            Image("sky")
                .resizable(resizingMode: .stretch)
                .ignoresSafeArea()
            
            VStack {
                Spacer()

                // Heading
                Image("Fox")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .padding()
                
                // Textfields
                VStack {
                    Spacer()

                    TextField("Email Address", text: $email)
                        .modifier(CustomField())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    TextField("Username", text: $username)
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
                    Spacer()

                    Button(action: {
                        self.signUp()
                        
                        if isAlert1 {
                            holder?.present { Alert1().environmentObject(model) }
                        }
                        else if isAlert3 {
                            holder?.present { Alert3().environmentObject(model) }
                        }
                        holder?.present { Alert().environmentObject(model) }
                        
                    }, label: {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .padding(.all)
                            .foregroundColor(Color.white)
                            .frame(width: 180)
                            .cornerRadius(6)
                            .background(Color.orange
                                            .blur(radius: 8.0))
                    })
                        .padding()
                    Spacer()

                }
                .padding()

                Spacer()
            }
            .navigationBarTitle("Create Account", displayMode: .inline)
        }
    }

    func signUp() {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              (password.count >= 6) && (password.count < 12) else {
                  isAlert3 = true
            return
        }

        let result = model.signUp(email: email, username: username, password: password)
        
        if !result { // if server said NO
            isAlert2 = true
        }
        else {
            print("UID: \(model.currentUID) \(model.client.recv_dic["UID"])")
            isAlert1 = true
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .preferredColorScheme(.dark)
    }
}
