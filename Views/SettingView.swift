//
//  SettingView.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/2.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var model: AppStateModel
    @Environment(\.presentationMode) var presentation
    @Environment(\.viewController) private var holder
    @State var showImagePicker = false
    @State var newusername: String = ""
    @State var newpassword: String = ""
    @State var newemail: String = ""
    @State var image: Image? = nil
        
    var body: some View {
        ZStack{
            Image("background-1")
                .resizable(resizingMode: .stretch)
                .ignoresSafeArea()
            
            VStack(alignment: .center){
                Text("SETTINGS")
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding()
                    .font(Font.custom("Avenir Next", size: 34, relativeTo: .body))
                
                Spacer()
                
                HStack{
                    Spacer()
                    VStack{
                        Text("ID")
                            .bold()
                            .lineLimit(70)

                        Spacer()
                        Text("Photo")
                            .bold()
                            .lineLimit(70)
                            .padding(.top, 15)

                        Spacer()
                        Text("Name")
                            .bold()
                            .lineLimit(70)
                            .padding(.top, 25)

                        Spacer()
                        Text("E-mail")
                            .bold()
                            .lineLimit(70)
                            .padding(.top, 18)

                        Spacer()
                        Text("Password")
                            .bold()
                            .lineLimit(70)
                            .padding()
                    }
                    .frame(height: 370)
                    .font(Font.custom("Avenir Next", size: 23, relativeTo: .body))

                    Spacer()
                    VStack{
                        Text("\(model.currentUID)")
                            .bold()
                            .font(Font.custom("Avenir Next", size: 25, relativeTo: .body))
                        Spacer()
                        Button(action: {
                            self.showImagePicker.toggle()
//                            showImagePicker.toggle()
                        }) {
                            image?
                                .resizable()
                                .clipShape(Circle())
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                        }
                        
                        Spacer()
                        TextField(model.currentUsername, text: $newusername)
                            .modifier(SettingText())
                        
                        Spacer()
                        TextField(model.currentEmail, text: $newemail)
                            .frame(width: 150)
                            .modifier(SettingText())
                        
                        Spacer()
                        TextField("new password", text: $newpassword)
                            .modifier(SettingText())
                    }
                    .frame(height: 370)
                    Spacer()
                }
                
                Spacer()
                
                Button(action: {
                    self.update()
                    self.presentation.wrappedValue.dismiss()
                }) {
                    Text("SAVE")
                        .font(Font.custom("Avenir Next", size: 20, relativeTo: .body))
                        .fontWeight(.semibold)
                        .padding(.all)
                        .frame(width: 170)
                        .background(Color.pink
                                        .blur(radius: /*@START_MENU_TOKEN@*/8.0/*@END_MENU_TOKEN@*/))
                        .foregroundColor(Color.white)
                }
                
                Spacer()

            }
            .onAppear{
                self.image = model.currentUser.img
            }
            .sheet(isPresented: $showImagePicker) {
                        ImagePicker(sourceType: .photoLibrary) { i in
                            self.image = Image(uiImage: i)
                            let x = imageToBase64(image: i)
                            let y = imageToBase64(image: UIImage(imageLiteralResourceName: "snow2"))
                            if x==y {
                                print("$$$ True")
                            }
                            else{
                                print("$$$ False")
                            }
                            model.currentUser.img = Image(uiImage: i)
                            model.updateImg(img: i)
                        }
                    }
        }
    }
    func update() {
        var result1 = true
        var result2 = true
        var result3 = true
        
        if !newemail.trimmingCharacters(in: .whitespaces).isEmpty {
            result1 = model.updateEmail(email: newemail)
        }
        
        if !newusername.trimmingCharacters(in: .whitespaces).isEmpty {
            result2 = model.updateUsername(name: newusername)
        }
        
        if !newpassword.trimmingCharacters(in: .whitespaces).isEmpty {
            result3 = model.updatePwd(password: newpassword)
        }
        
        if !result1 {
            holder?.present { Alert().environmentObject(model) }
        }
        if !result2 {
            holder?.present { Alert().environmentObject(model) }
        }
        if !result3 {
            holder?.present { Alert().environmentObject(model) }
        }
    }
//        self.present(userIconAlert, animated: true, completion: nil)
    func imageToBase64(image: UIImage) -> String {
        //将获取的图片通过jpegData(compressionQuality: 1.0)方法转成Data类型的数据。
        //参数1.0表示不压缩，因为jpeg是有损格式，jpg和jpeg都用这个方法。无损格式PNG使用pngData()方法转换，没有参数，也就是不压缩。
        let imageData: Data? = image.jpegData(compressionQuality: 1.0)
        let str: String = imageData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        //返回
        return str
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
