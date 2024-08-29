//
//  Alert.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/4.
//

import Foundation
import SwiftUI

// failed Alerts

struct Alert: View {
    @Environment(\.viewController) private var holder
    @EnvironmentObject var model: AppStateModel
    @State private var appear = false

    var body: some View{
//        NavigationView{
            ZStack{
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture{
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.appear = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            self.holder?.dismiss(animated: true, completion: .none)
                        }
                    }
                if model.client.recv_dic["code"] == "1001" { // sign up
                    Text("Cannot sign up with these info.\nPlease try again!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1003" { //
                    Text("User ID NOT EXIST!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1011" { // sign out
                    Text("Unexpected ERROR!\nCookie NOT EXIST!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                        .onAppear {
                            model.cookies = ""
                        }
//                    NavigationLink(destination: SignInView(),
//                                   label: {
//                        Text("Log Out")
//                            .fontWeight(.semibold)
//                            .frame(width: 120, height: 45, alignment: .center)
//                    })
//                        .foregroundColor(Color.white)
//                        .background(Color.mint
//                                        .blur(radius: 6.0))
                } else if model.client.recv_dic["code"] == "1004" { // sign in
                    Text("Already Login in other place!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                        .onDisappear {
                            let result = model.signOut()
                            if !result {
                                holder?.present { Alert().environmentObject(model) }
                            }
                        }
                } else if model.client.recv_dic["code"] == "1006" { // sign in
                    Text("Invaild user ID or password!\nPlease try again!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1007" { //
                    Text("No Such User!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1016" { // update pwd
                    Text("Error when updating Password!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1017" { // update name
                    Text("Error when updating Username!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1031" { // group
                    Text("Group Create Error!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1032" { //
                    Text("Error when updating Group name!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1033" { //
                    Text("Group ID Not Exist!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1034" { //
                    Text("User Already Is an Admin!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1035" { //
                    Text("User Is Not an Admin!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1036" { //
                    Text("User Already In the Group!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1037" { //
                    Text("User Not In the Group!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "1038" { //
                    Text("Owner Exit Group!\nDENY!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "2001" { //
                    Text("Too Much Or Too Less Parameter!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "2002" { //
                    Text("Parameter Error NaN!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "9001" { // query info
                    Text("SafetyViolation!\nInconsistent cookie with uid!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "9002" { // query info
                    Text("Not Authorized!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                } else if model.client.recv_dic["code"] == "9003" { // query info
                    Text("Priority Not High Enough!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .modifier(AlertBox())
                }
                
            }
      //  }
        
    }
}

// Field not be filled/satisfised

struct Alert3: View {
    @Environment(\.viewController) private var holder
    @State private var appear = false
    @EnvironmentObject var model: AppStateModel

    var body: some View{
        ZStack{
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture{
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.appear = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        self.holder?.dismiss(animated: true, completion: .none)
                    }
                }
            Text("Password need >= 6 && < 12 characters!\nCheck whether all fields are filled~")
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .modifier(AlertBox())
        }
    }
}

// Sign Up successed

struct Alert1: View {
    @Environment(\.viewController) private var holder
    @State private var appear = false
    @EnvironmentObject var model: AppStateModel

    var body: some View{
        ZStack{
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture{
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.appear = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        self.holder?.dismiss(animated: true, completion: .none)
                    }
                }
            VStack{
                Text("Your ID: \(model.client.recv_dic["UID"]!)")
                    .fontWeight(.bold)
                    .padding(20)
                    .background(Color.green.blur(radius: 8.0))
                    .cornerRadius(20)
                    .multilineTextAlignment(.center)
                    .frame(height: 60)
                
                Text("Sign Up Successfully!\nUse this ID to log in~")
                    .fontWeight(.semibold)
                    .padding(40)
                    .background(Color.white)
                    .cornerRadius(30)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
