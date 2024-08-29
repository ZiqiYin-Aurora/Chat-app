////
////  ContentView.swift
////  Chatting
////
////  Created by Yin Celia on 2021/10/17.
////
//
//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//
//        ZStack() {
//            Image("IMG_0030")
//                .resizable(resizingMode: .stretch)
//                .ignoresSafeArea()
//
//            VStack() {
//                //up to 10 elements, arranged vertically
//                //HStack: Horizentally  ZStack: Top叠放，元素的代码写的靠前->元素放在底层
//                Spacer()//把上下相邻两个元素分别推到最远端
//
//                Image(/*@START_MENU_TOKEN@*/"Fox"/*@END_MENU_TOKEN@*/)
//                    .padding(.all)
////                    .resizable()
////                    .aspectRatio(contentMode: .fit)
//
//                //Spacer()
//                Text("Welcome to Foxx!!!!\nLet's begin the adventure!!")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(Color.green)
//                    .padding(.all)
//               // Spacer()
//                HStack(){
//                    Spacer()
//                    VStack() {
//                        Label("User ID", systemImage: "27.circle")
//                            .padding(.all)
//                        Label("Password", systemImage: "27.circle")
//                            .padding(.all)
//                    }
//                    Spacer()
//                    VStack() {
//                        TextField("Enter ur ID", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
//                            .padding(.all)
//                        TextField("Enter ur Pwd", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
//                            .padding(.all)
//                    }
//                    Spacer()
//                }
//                Spacer()//
//                HStack() {
//                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
//                        Text(" Continue ")
//                        .fontWeight(.semibold)
//                        .padding(.all)
//                        .background(Color.green
//                                    .blur(radius: /*@START_MENU_TOKEN@*/8.0/*@END_MENU_TOKEN@*/))
//                    }
//                }
//                Spacer()
//                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
//                Text("Sign Up")
//                    .font(.footnote)
//                    .fontWeight(.semibold)
//                    .padding()
//                    .background(Color.orange
//                                    .blur(radius: 12.0))
//                }
//                Spacer()//3个spacer将元素等间距分开
//            }
//        }
//    }
//}
//
////struct ContentView_Previews: PreviewProvider {
////    static var previews: some View {
////        ContentView()
////    }
////}
//
