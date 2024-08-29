//
//  GalaxyView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/2.
//

import SwiftUI

struct ViewControllerHolder {
    weak var value: UIViewController?
    //    init(_ value: UIViewController?) {
    //        self.value = value
    //    }
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication
                                        .shared.windows.first?.rootViewController ) }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}

extension UIViewController {
    func present<Content: View>(@ViewBuilder builder: () -> Content) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = .overCurrentContext
        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, toPresent)
        )
        toPresent.modalTransitionStyle = .crossDissolve
        toPresent.view.backgroundColor = .clear
        
        present(toPresent, animated: false, completion: .none)
    }
}

struct GalaxyView: View {
    @EnvironmentObject var model: AppStateModel
    @Environment(\.viewController) private var holder
    
    @State var sender = true
    @State var isBegin = false
    @State var isFinished = false
    @State var desiredGoal = 10
    @State var currentNum = 0
    @State var flag: Bool = false
    //    @State var chat: Chat = AppStateModel().sampleChat
    @State private var hasTimeElapsed = false
    
    
    var body: some View {
        ZStack{
            
            Image("sky")
                .resizable(resizingMode: .stretch)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            ParticleView(isBegin: $isBegin, isFinished: $isFinished, desiredGoal: $desiredGoal, currentNum: $currentNum, sender: $sender)
            
            VStack{
                Spacer()
                Text("Welcome! \(model.currentUsername)")
                    .fontWeight(.semibold)
                    .padding(.all)
                    .frame(width: 200)
                    .font(Font.custom("Avenir Next", size: 20, relativeTo: .body))
                    .background(Color.white.opacity(0.7).blur(radius: 10.0))
                Text("Choose a Snowflake\nto Encounter your\nNew Friends!")
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.all)
                    .frame(width: 300)
                    .font(Font.custom("Avenir Next", size: 20, relativeTo: .body))
                    .background(Color.white.opacity(0.7).blur(radius: 10.0))
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
            .onAppear(perform: delay)
            
        }
        .onAppear {
            guard model.auth.currentUser != nil else {
                return
            }
            model.getConversations()
        }
        .onTapGesture {
            if !flag  {
                holder?.present{
                    Subview(flag: self.$flag).environmentObject(self.model)
                }
            }
        }
    }
    func delay() {
        // Delay of 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            hasTimeElapsed = true
        }
    }
}

struct GalaxyView_Previews: PreviewProvider {
    static var previews: some View {
        GalaxyView()
    }
}

struct Subview: View {
    @EnvironmentObject var model: AppStateModel
    @Environment(\.viewController) private var holder
    @State private var appear = false
    let otherUsername: String = ""
    let otherUID: String = ""
    @Binding var flag: Bool
    @State var show: Bool = false
    //    @Binding var chat: Chat
    
    var body: some View{
        ZStack{
            Color.black.opacity(appear ? 0.3 : 0)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.appear = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        self.holder?.dismiss(animated: true, completion: .none)
                    }
                }
            
            VStack {
                model.random.img
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180)
                
                VStack(alignment: .center) {
                    
                    Text(model.random.name) //nickname
                        .bold()
                        .font(.system(size: 25))
                        .padding([.leading, .trailing])
                    
                    Text("ID: \(model.random.id)")
                        .bold()
                        .padding(.top, -10)
                        .padding([.leading, .trailing])
                }
                .layoutPriority(100)
                .padding()
                
                Button(action: {
                    self.chatWith()
                    self.show.toggle()
                }) {
                    Text("CHAT")
                        .fontWeight(.semibold)
                        .padding(.all)
                        .frame(width: 90, height: 40, alignment: .center)
                        .background(Color.mint.blur(radius: 8.0))
                        .foregroundColor(Color.white)
                }
                .padding()
                
            }
            .fullScreenCover(isPresented: $show, content:{
                TalkView(chat: model.onechat!, ishide: true, otherUID: model.random.id).environmentObject(self.model)
            })
            .frame(width: 270, height: 465)
            .background(
                Image("bg3")
                    .resizable()
                    .scaleEffect(appear ? 1 : 0.5)
                    .opacity(appear ? 1 : 0)
                    .edgesIgnoringSafeArea(.all)
            )
            .rotationEffect(.init(degrees: appear ? 360 : 0))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
            )
            .padding([.top, .horizontal])
            
        }
        .navigationBarTitle("Home")
        .onAppear {
            guard model.auth.currentUser != nil else {
                return
            }
            model.getRandomUser(currentUID: model.currentUID)
            withAnimation(.easeInOut(duration: 0.5)) {
                self.appear = true
            }
        }

    }
    
    func chatWith(){
        //        self.flag = true
        model.otherUsername = model.random.name
        model.otherUID = model.random.id
        //        print(flag)
        model.onechat = model.createConversation(personIDs: [model.currentUID, model.random.id])
        //        print(model.onechat!)
    }
    
    func goToHomeSecond(){
        if let window = UIApplication.shared.windows.first
        {
            window.rootViewController = UIHostingController(rootView: ChatView(chat: model.onechat!, Chatname: model.onechat!.name, isHide: .constant(false), otherUsername: model.otherUsername, otherUID: model.otherUID).environmentObject(self.model))
            window.makeKeyAndVisible()
        }
    }
    
}

struct Subview_Previews: PreviewProvider {
    static var previews: some View {
        Subview(flag: .constant(true))
    }
}

