//
//  AppStateModel.swift
//  Chatting
//
//  Created by Yin Celia on 2021/10/17.
//

import Foundation
import SwiftUI

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class AppStateModel: ObservableObject {
    let client = Client()
    // Is User signed in
    
    // Current user being chatted with
    // Messages, Conversations
    @AppStorage("currentUsername") var currentUsername: String = ""
    @AppStorage("currentImg") var currentImg: String = ""
    @AppStorage("currentEmail") var currentEmail: String = ""
    @AppStorage("currentUID") var currentUID: String = ""
    @AppStorage("cookies") var cookies: String = ""
    
    @Published var currentUser : Person = Person(id: "", name: "", img: Image(""))
    @Published var showingSignIn: Bool = true
    @Published var conversations: [Chat] = []
    @Published var messages: [Message] = []
    @Published var friends: [Person] = []
    @Published var groupMbrs: [Person] = []
    @Published var chat: Chat?
    @Published var random = Person(id: "", name: "", img: Image("snow2"))
    @Published var specificUser = Person(id: "", name: "", img: Image("snow2"))
    @Published var groupInfo: [String:Any] = [:]
    @Published var recv: [String: String] = [:]
    @Published var onechat: Chat?
    @Published var helloMsg = Message(text: "", type: .sent, sender: "")
    @Published var allUsers: [Person] = []
        
    let sampleChat = Chat(id: "123", name: "Wayne D.", img: Image("img2"), personIDs: ["12345678", "23456789"], messages: [
        Message(text: "Hey Wayne, I just want to say thank you so much for your support on Patreon 🙏", type: .sent, date: Date(timeIntervalSinceNow: -86400 * 4), sender: "Aurora"),
        Message(text: "I hope you will read this ☺️", type: .sent, date: Date(timeIntervalSinceNow: -86400 * 4), sender: "Aurora")
    ], hasUnreadMsg: false)
    
    let database = Firestore.firestore()
    let auth = Auth.auth()
    
    var otherUID: String = ""
    var otherUsername: String = ""
    var otherUser : Person = Person(id: "", name: "", img: Image("snow2"))
    
    var conversationListener: ListenerRegistration?
    var chatListener: ListenerRegistration?
    var GroupInfoListener: ListenerRegistration?
//    var UserInfoListener: ListenerRegistration?

    init() {
        self.showingSignIn = (Auth.auth().currentUser == nil) || (self.cookies != self.client.recv_dic["cookies"]) || (self.cookies == "")
        self.helloMsg = Message(text: "Hello", type: .sent, sender: self.currentUsername)
    }
    
}

// get filtered Chats

extension AppStateModel {
    func getFilteredChats(query: String) -> [Chat] {
        var sortedChats = conversations.sorted {
            guard let date1 = $0.messages.last?.date else { return false }
            guard let date2 = $1.messages.last?.date else { return false }
            return date1 > date2
        }
        
        if query == "" {
            return sortedChats
        }
        
        return sortedChats.filter { $0.name.lowercased().contains(query.lowercased())}
    }

    func getSectionMessages(for chat: Chat) -> [[Message]] {
        var res = [[Message]]()
        var tmp = [Message]()
        for message in chat.messages {
            if let firstMessage = tmp.first {
                let daysBetween = firstMessage.date.daysBetween(date: message.date)
                if daysBetween >= 1 {
                    res.append(tmp)
                    tmp.removeAll()
                    tmp.append(message)
                } else {
                    tmp.append(message)
                }
            } else {
                tmp.append(message)
            }
        }
        res.append(tmp)
        
        return res
    }
    
}

// Search

extension AppStateModel {
    func searchUsers(queryText: String, completion: @escaping ([String]) -> Void) {
        database.collection("users").getDocuments { snapshot, error in
            guard let uids = snapshot?.documents.compactMap({ $0.documentID }),
                  error == nil else {
                      completion([])
                      return
                  }
            
            let filtered = uids.filter({
                $0.lowercased().hasPrefix(queryText.lowercased())
            })
            
            completion(filtered)
        }
    }
    
    func getRandomUser(currentUID: String) {
        var data: Data?
        database.collection("users").getDocuments { snapshot, error in
            guard let info = snapshot?.documents.compactMap({ $0.data() }),
                  error == nil else {
                      return
                  }
            var flag = true
            while(flag){
                let x = info.sample!
                if x.count == 4 {
                    
                    let id = x["id"] as! String
                    if (id != self.currentUID) && (Array(id)[0] != "G"){
                        self.random.id = id
                        self.random.name = x["username"] as! String
                        
                        data = Data(base64Encoded: x["img"] as! String, options: .ignoreUnknownCharacters)
                        self.random.img = Image(uiImage: self.base64ToImage(imageData: data))

                        flag = false
                    }
                }
            }
        }
    }
}

// Conversations

extension AppStateModel {
    func getConversations() {
        // Listen for conversations
        conversationListener = database
            .collection("users")
            .document(currentUID)
            .collection("chats").addSnapshotListener { [weak self] snapshot, error in
                guard let chats_info = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                          return
                      }
                
                var chats: [Chat] = []
                chats_info.forEach { info in
                        var msgs: [Message] = []
                        self?.otherUsername = info["chatname"] as? String ?? ""
                        self?.otherUID = info["receiver"] as? String ?? ""
                        
                    if (self?.otherUsername != "") && (self?.otherUID != "") {
                        self?.database
                            .collection("users")
                            .document(self!.currentUID)
                            .collection("chats")
                            .document(self!.otherUID)
                            .collection("messages")
                            .getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    querySnapshot!.documents.forEach { msg in
                                        guard let date = ISO8601DateFormatter().date(from: msg["date"] as? String ?? "") else {
                                            return
                                        }
//                                        print("111: \(msg.documentID) => \(msg.data())")
//                                        print("222: \(msg["text"])")
                                        msgs.append(Message(text: msg["text"] as? String ?? "",
                                                            type: msg["sender"] as? String == self?.currentUID ? .sent : .received,
                                                            date: date,
                                                            sender: msg["sender name"] as! String))
                                    }
                                }
                                
                                msgs.sort(by: { return $0.date < $1.date })
                                var img: Image = Image("snow4") // by default
                                var chat_id = info["receiver"] as? String ?? ""
                                var pids = info["personIDs"] as? [String] ?? [""]
                                
                                if Array(chat_id)[0] != "G" {
                                    pids.forEach { i in
                                        if i != self!.currentUID {
                                            let user = self?.getUserInfo(uid: i, isG: false)
                                            img = self?.specificUser.img ?? Image("snow4")
                                        }
                                    }
                                }
                                else {
                                    img = Image("group")
                                }
                                
//                                print("SsssS: \(info)")
                                let mark = info["hasUnreadMsg"] as! String
                                var res: Bool = false
                                if mark == "false" {
                                    res = false
                                }
                                else {
                                    res = true
                                }
                                
                                chats.append(Chat(id: chat_id,
                                                  name: info["chatname"] as? String ?? "",
                                                  img: img,
                                                  personIDs: pids,
                                                  messages: msgs,
                                                  hasUnreadMsg: res))
                                
//                                print("555chats: \(chats)")
                                DispatchQueue.main.async {
                                    self?.conversations = chats
                                }
                            }
                    }
                }
            }
    }
    
    func markAsUnread(_ newValue: Bool, chat: Chat) {
        var res = "false"
        if newValue == false {
            res = "false"
        }
        else {
            res = "true"
        }
        if let index = conversations.firstIndex(where: { $0.id == chat.id }) {
            conversations[index].hasUnreadMsg = newValue
        }
        
        database.collection("users")
            .document(currentUID)
            .collection("chats")
            .document(chat.id)
            .updateData(["hasUnreadMsg":res])
    }
    
    func findfriends(uid: String) -> Person{
        var p = Person(id: "", name: "", img: Image(""))
        friends.forEach { i in
            if i.id == uid {
                p = i
            }
        }
        return p
    }
    
    func findUser(uid: String) -> Person{
        var p = Person(id: "", name: "", img: Image(""))
        allUsers.forEach { i in
            if i.id == uid {
                p = i
            }
        }
        return p
    }
    
    func getUserInfo(uid: String, isG: Bool){
        var user = Person(id: "", name: "", img: Image(""))
        
        database.collection("users").getDocuments { snapshot, error in
            guard let info = snapshot?.documents.compactMap({ $0.data() }),
                  error == nil else {
                      return
                  }
            var flag = true
            while(flag){
                info.forEach { x in
                    let data: Data? = Data(base64Encoded: x["img"] as! String, options: .ignoreUnknownCharacters)
                    user = Person(id: (x["id"])! as! String,
                                name: (x["username"])! as! String,
                                  img: Image(uiImage: self.base64ToImage(imageData: data)))
                    
                    let result = self.allUsers.filter { $0.id == user.id }
                    if result.isEmpty { self.allUsers.append(user) }
                        
                    if (x.count == 4) && (x["id"] as! String == uid) {
//                        let z = x["img"] as! String
//                        let y = self.imageToBase64(image: UIImage(imageLiteralResourceName: "snow1"))
//                        if z==y {
//                            print("111 True")
//                        }
//                        else{
//                            print("111 False")
//                        }
//                        print("... \(data)")
                        
                        self.specificUser = user
                        self.otherUser = self.specificUser
                        self.otherUsername = self.specificUser.name

//                        print("... spec::\(self.specificUser)")
                        if isG {
                            self.groupMbrs.append(user)
                        }
//                        print("...G: \(self.groupMbrs)")
                        flag = false
                    }
                }
                
            }
        }
    }
}

// Get Chat / Send Messages

extension AppStateModel {
    func observeChat() -> [Message]{
        //createConversation()
        //read chat msgs from DB
        chatListener = database
            .collection("users")
            .document(currentUID)
            .collection("chats")
            .document(otherUID)
            .collection("messages")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let objects = snapshot?.documents.compactMap({ $0.data() })
                else {
                    print("Nil return!!!!!")
                    return
                }
                
                //assign datas into messages[]
                let messages: [Message] = objects.compactMap({
                    guard let date = ISO8601DateFormatter().date(from: $0["date"] as? String ?? "") else {
                        return nil
                    }
                    return Message(
                        text: $0["text"] as? String ?? "",
                        type: $0["sender"] as? String == self?.currentUID ? .sent : .received,
                        date: date,
                        sender: $0["sender name"] as? String ?? ""
                    )
                }).sorted(by: { first, second in
                    return first.date < second.date
                })
                
                // async do this operation
                DispatchQueue.main.async {
                    self?.messages = messages
                }
            }
        return messages
    }
    
    
    func sendMessage(text: String, chat: Chat) -> [String:Any]? {
        let newMessageId = UUID().uuidString
        let dateString = ISO8601DateFormatter().string(from: Date())
        guard !dateString.isEmpty else {
            return nil
        }
        
        let message = Message(text: text, type: .sent, date: Date(), sender: otherUsername)
        
        let data = [
            "text": text,
            "sender": currentUID,
            "sender name": currentUsername,
            "date": dateString
        ]
//        print(":::: \(currentUID) \(chat.id) \(otherUID) \(otherUser.id)")
        
        // currentUser
        database.collection("users")
            .document(currentUID)
            .collection("chats")
            .document(chat.id)
            .collection("messages")
            .document(newMessageId)
            .setData(data)
        
        // otherUser
        database.collection("users")
            .document(chat.id)
            .collection("chats")
            .document(currentUID)
            .collection("messages")
            .document(newMessageId)
            .setData(data)
       
        var receiver = chat.id
        var recv_group = chat.id
        if Array(chat.id)[0] == "G" {
            chat.personIDs.forEach { i in
                if i != currentUID {
                    database.collection("users")
                        .document(i)
                        .collection("chats")
                        .document(chat.id)
                        .collection("messages")
                        .document(newMessageId)
                        .setData(data)
                    
                    database.collection("users")
                        .document(i)
                        .collection("chats")
                        .document(chat.id)
                        .updateData(["hasUnreadMsg":"true"])
                }
            }
            receiver = "-1"
            recv_group = chat.id
        }
        
        database.collection("users")
            .document(chat.id)
            .collection("chats")
            .document(currentUID)
            .updateData(["hasUnreadMsg":"true"])
        
        // Connect server and send msgs
        client.connectServer()
        
        let str = text.replacingOccurrences(of: " ", with: "%20")
        var now = time_t()
        time(&now)
        
        let msg = "/SendMessage \(cookies) \(currentUID) \(receiver) \(recv_group) \(str) \(now)"
        client.sendMessage(msg, type: 1001)
        
        var flag = true
        while flag {
            recv = client.recv_dic
            if recv.count > 1 {
                flag = false
            }
        }
        
        // if server said OK
        if recv["code"] == "200" {
            return ["type": true, "Msg":message]
        } else {
            return ["type": false, "Msg":message]
        }
    }

    func createConversation(personIDs: [String]) -> Chat{
        if Array(otherUID)[0] == "G" { // if is a Group
            let data0 = [
                "created" : "true",
                "receiver" : otherUID,
                "hasUnreadMsg" : "false",
                "chatname" : otherUID, //chat name
                "personIDs" : personIDs
            ] as [String : Any]
            
            let data1 = [
                "created" : "true",
                "receiver" : otherUID,
                "hasUnreadMsg" : "false",
                "chatname" : otherUID, //chat name
                "personIDs" : personIDs
            ] as [String : Any]
            
            personIDs.forEach { i in
                if i != currentUID {
                    database.collection("users")
                        .document(i)
                        .collection("chats")
                        .document(otherUID).setData(data1)
                }
            }
            database.collection("users")
                .document(currentUID)
                .collection("chats")
                .document(otherUID).setData(data0)
        }
        else { // not a Group
            let data0 = [
                "created" : "true",
                "receiver" : otherUID,
                "hasUnreadMsg" : "false",
                "chatname" : otherUsername, //chat name
                "personIDs" : personIDs
            ] as [String : Any]
            
            let data1 = [
                "created" : "true",
                "receiver" : currentUID,
                "hasUnreadMsg" : "false",
                "chatname" : currentUsername, //chat name
                "personIDs" : personIDs
            ] as [String : Any]
            
            database.collection("users")
                .document(otherUID)
                .collection("chats")
                .document(currentUID).setData(data1)
            
            database.collection("users")
                .document(currentUID)
                .collection("chats")
                .document(otherUID).setData(data0)
        }
      
        return Chat(id: otherUID, name: otherUID, img: Image("snow2"), personIDs: [currentUID, otherUID], messages: [helloMsg], hasUnreadMsg: false)
    }
    
    func delChat() {
        database.collection("users")
            .document(currentUID)
            .collection("chats")
            .document(otherUID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("otherUID successfully removed!")
                }
            }
    }
}

// Group

extension AppStateModel {
    
    func CreateGroup() -> String {
        // Connect server and send msgs
        client.connectServer()
        let msg = "/CreateGroup \(cookies)"
        client.sendMessage(msg, type: 1001)
        
        var flag = true
        while flag {
            recv = client.recv_dic
            if recv.count > 1 {
                flag = false
            }
        }
        
        if recv["code"] == "200" {
            self.otherUID = recv["GID"]!
            self.createConversation(personIDs: [currentUID])

            return recv["GID"]! }
        else { return "" }
        
    }
    
    func updateGroupName(newname: String, pids: [String]) -> Bool{
        pids.forEach { i in
            database.collection("users")
                .document(i)
                .collection("chats")
                .document(otherUID)
                .updateData(["chatname":newname])
        }
        
        // Connect server and send msgs
        client.connectServer()
        let msg = "/ChangeGroupName \(cookies) \(currentUID) \(otherUID) \(newname)"
        client.sendMessage(msg, type: 1001)
        
        var flag = true
        while flag {
            recv = client.recv_dic
            if recv.count > 1 {
                flag = false
            }
        }
        
        if recv["code"] == "200" { return true }
        else { return false }
    }
    
    func quitGroup() -> Bool{
        
        // update persons in all other users group info
        let info = getGroupInfo()
        let users:[String] = info?["personIDs"] as! [String]
        
        // del current userID from array
        let new = users.filter { $0 != currentUID }
        
        users.forEach { i in
            database.collection("users")
                .document(i)
                .collection("chats")
                .document(otherUID)
                .updateData(["personIDs":new])
        }
        
        // current user del chat doc in db
        self.delChat()
        
        // Connect server and send msgs
        client.connectServer()
        let msg = "/QuitFromGroup \(cookies) \(currentUID) \(otherUID)"
        client.sendMessage(msg, type: 1001)
        
        var flag = true
        while flag {
            recv = client.recv_dic
            if recv.count > 1 {
                flag = false
            }
        }
        
        if recv["code"] == "200" { return true }
        else { return false }
    }
    
    func getGroupInfo() -> [String:Any]? {
        var infoDic: [String:Any]?

        GroupInfoListener = database.collection("users")
            .document(currentUID)
            .collection("chats")
            .document(otherUID)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let document = documentSnapshot else {
                  print("Error fetching document: \(error!)")
                  return
                }
                guard let data = document.data() else {
                  print("Document data was empty.")
                  return
                }
                print("Current data: \(data)")
                
                DispatchQueue.main.async {
                    infoDic = data
                }
              }

        // Connect server and send msgs
        client.connectServer()
        let msg = "/GetGroupInfo \(cookies) \(currentUID) \(otherUID)"
        client.sendMessage(msg, type: 1001)
        
        var flag = true
        while flag {
            recv = client.recv_dic
            if recv.count > 1 {
                flag = false
            }
        }
        
        if recv["code"] == "200" {  }
        else {  }
        
        
        return infoDic
    }
    
    func stringValueDic(_ str: String) -> [String : Any]?{
            let data = str.data(using: String.Encoding.utf8)
            if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
                return dict
            }
            return nil
        }
    
    func addPersontoGroup(name: String, pid: [String], expid: [String]) -> Bool{
        let new = pid + expid
        var result = false
        let newMessageId = UUID().uuidString
        let dateString = ISO8601DateFormatter().string(from: Date())
        
        let hellodata = [
            "text": "Enter Group!",
            "sender": currentUID,
            "sender name": currentUsername,
            "date": dateString
        ]
        
        let data = [
            "created" : "true",
            "receiver" : otherUID,
            "hasUnreadMsg" : "true",
            "chatname" : name, //chat name
            "personIDs" : new
        ] as [String : Any]
        
        new.forEach{ i in
            database.collection("users")
                .document(i)
                .collection("chats")
                .document(otherUID).setData(data)
            
                database.collection("users")
                    .document(i)
                    .collection("chats")
                    .document(otherUID)
                    .collection("messages")
                    .document(newMessageId)
                    .setData(hellodata)
            
            // Connect server and send msgs
            client.connectServer()
            let msg = "/InviteToGroup \(cookies) \(currentUID) \(otherUID) \(i)"
            client.sendMessage(msg, type: 1001)
            
            var flag = true
            while flag {
                recv = client.recv_dic
                if recv.count > 1 {
                    flag = false
                }
            }
            if recv["code"] == "200" { result = true }
        }
        return result
    }
}

// Update info

extension AppStateModel {
    //将图片转表示base64值的字符串
    func imageToBase64(image: UIImage) -> String {
        //将获取的图片通过jpegData(compressionQuality: 1.0)方法转成Data类型的数据。
        //参数1.0表示不压缩，因为jpeg是有损格式，jpg和jpeg都用这个方法。无损格式PNG使用pngData()方法转换，没有参数，也就是不压缩。
        let imageData: Data? = image.jpegData(compressionQuality: 1.0)
        let str: String = imageData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        //返回
        return str
    }
    
    //将表示base64值的字符串转为图片
    func base64ToImage(imageData: Data?) -> UIImage {
        let uiimage: UIImage = UIImage.init(data: imageData!)!
        return uiimage
    }

    func updateImg(img: UIImage){
        let imgString = imageToBase64(image: img)
        //首先将表示base64值的字符串转为Data类型的数据
        var data: Data? = Data(base64Encoded: imgString, options: .ignoreUnknownCharacters)
            
        let x = imgString
        let y = imageToBase64(image: UIImage(imageLiteralResourceName: "snow1"))
        if x==y {
            print("$$$222 True")
        }
        else{
            print("$$$222 False")
        }
        
        database.collection("users")
            .document(currentUID)
            .updateData(["img": imgString])
    }
    
    func updatePwd(password: String) -> Bool{
        // Connect server and send msgs
        client.connectServer()
        let msg = "/ChangeUserPassword \(cookies) \(password)"
        client.sendMessage(msg, type: 1001)
        
        //        var recv : [String:String] = [:]
        var flag = true
        while flag {
            recv = client.recv_dic
            if recv.count > 1 {
                flag = false
            }
        }

        // if server said OK
        if recv["code"] == "200" {
            Auth.auth().currentUser?.updatePassword(to: password) { error in
                // Password change sucussfully
            }
            return true
        } else {
            return false
        }
    }
    
    func updateUsername(name: String) -> Bool{
        // Connect server and send msgs
        client.connectServer()
        database.collection("users")
            .document(currentUID)
            .updateData(["username":name])
        
        let msg = "/ChangeUserNickname \(cookies) \(name)"
        client.sendMessage(msg, type: 1001)
        
        var flag = true
        while flag {
            recv = client.recv_dic
            if recv.count > 1 {
                flag = false
            }
        }
        
        // if server said OK
        if recv["code"] == "200" {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChanges { error in
                self.currentUsername = name
            }
            return true
        }
        else {
            return false
        }
    }
    
    func updateEmail(email: String) -> Bool{
        ((Auth.auth().currentUser?.updateEmail(to: email) { error in
            self.currentEmail = email
        }) != nil)
    }
    
    func getCurrentUserInfo() -> Bool{
        // Connect server and send msgs
        client.connectServer()
        let msg = "/GetUserInfo \(cookies) \(currentUID) \(currentUID)"
        client.sendMessage(msg, type: 1001)
        
        //        var recv : [String:String] = [:]
        var flag = true
        while flag {
            recv = client.recv_dic
            if recv.count > 1 {
                flag = false
            }
        }
        
        // if server said OK
        if recv["code"] == "200" {
            let uid = self.client.recv_dic["UID"]!
            let name = self.client.recv_dic["Nickname"]
            
            return true
        }
        else {
            return false
        }
        
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            let email = user.email
            let photoURL = user.photoURL
            var multiFactorString = "MultiFactor: "
            for info in user.multiFactor.enrolledFactors {
                multiFactorString += info.displayName ?? "[DispayName]"
                multiFactorString += " "
            }
            // ...
        }
    }
    
    func updateChatInfo(name: String) {
        database.collection("users")
            .document(currentUID)
            .collection("chats")
            .document(otherUID)
            .updateData(["chatname":name])
        
        database.collection("users")
            .document(otherUID)
            .collection("chats")
            .document(currentUID)
            .updateData(["chatname":name])
    }
    
}


// Sign In & Sign Up

extension AppStateModel {
    func signIn(uid: String, password: String) -> Bool {
        client.connectServer()
        let msg = "/Login \(uid) \(password)"
        client.sendMessage(msg, type: 1001)
        
        var flag = true
        while flag {
            recv = client.recv_dic
            if recv.count > 1 {
                flag = false
            }
        }
        
        // if server said OK
        if recv["code"] == "200" {
            let cookies = recv["cookies"]!
            // Get email from DB
            database.collection("users").document(uid).getDocument { [weak self] snapshot, error in
                guard let email = snapshot?.data()?["email"] as? String, error == nil else {
                    return
                }
                guard let username = snapshot?.data()?["username"] as? String, error == nil else {
                    return
                }
                guard let imgStr = snapshot?.data()?["img"] as? String, error == nil else {
                    return
                }
                var data: Data? = Data(base64Encoded: imgStr, options: .ignoreUnknownCharacters)
                
                let x = imgStr
                let y = self!.imageToBase64(image: UIImage(imageLiteralResourceName: "snow1"))
                if x==y {
                    print("$$$ True")
                }
                else{
                    print("$$$ False")
                }
                
                // Try to sign in
                self?.auth.signIn(withEmail: email, password: password, completion: { result, error in
                    guard error == nil, result != nil else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self?.currentUID = uid
                        self?.currentEmail = email
                        self?.currentImg = imgStr
                        self?.currentUsername = username
                        self?.showingSignIn = false
                        self?.currentUser.id = uid
                        self?.currentUser.name = username
                        self?.currentUser.img = Image(uiImage: self!.base64ToImage(imageData: data))
                        self?.cookies = cookies
                        self?.getConversations()
                    }
                    
                })
            }
            
            
            return true
        }
        else {
            return false
        }
        
        //        let dateString = ISO8601DateFormatter().string(from: Date())
        
    }
    
    func signUp(email: String, username: String, password: String) -> Bool{
        // Connect server and send msgs
        client.connectServer()
        let name = username.replacingOccurrences(of: " ", with: "%20")
        let msg = "/Reg \(password) \(name)"
        client.sendMessage(msg, type: 1001)
        
        var flag = true
        while flag {
            recv = client.recv_dic
            if recv.count > 1 {
                flag = false
            }
        }
        
        // if server said OK
        if recv["code"] == "200" {
            let uid = self.client.recv_dic["UID"]!
            // Create Account in DB
            auth.createUser(withEmail: email, password: password) { [weak self] result, error in
                guard result != nil, error == nil else {
                    return
                }
                let imgStr: String = (self?.imageToBase64(image: UIImage(named: "snow1")!))!
                // Insert username into database
                let data = [
                    "email": email,
                    "username": username,
                    "img": imgStr,
                    "id": uid
                ] as [String : Any]
                
                self?.database
                    .collection("users")
                    .document(uid)
                    .setData(data) { error in
                        guard error == nil else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self?.currentUsername = username
                            self?.currentEmail = email
                            self?.currentImg = "snow1"
                            self?.currentUID = uid
                            self?.currentUser.id = uid
                            self?.currentUser.name = username
                            self?.currentUser.img = Image("snow1")
                            self?.showingSignIn = false
                        }
                    }
            }
            return true
        }
        else {
            return false
        }
    }
    
    func signOut() -> Bool{
        // Connect server and send msgs
        client.connectServer()
        let msg = "/Logout \(self.cookies)"
        client.sendMessage(msg, type: 1001)
        
        var flag = true
        while flag {
            recv = client.recv_dic
            if recv.count > 1 {
                flag = false
            }
        }
        
        if recv["code"] == "200" {
            client.disconnectServer()
            
            do {
                try auth.signOut()
                self.showingSignIn = true
            }
            catch {
                print(error)
            }
            return true
        }
        else {
            return false
        }
        
    }
}

extension Array {
    // 从数组中返回一个随机元素
    public var sample: Element? {
        //如果数组为空，则返回nil
        guard count > 0 else { return nil }
        let randomIndex = Int(arc4random_uniform(UInt32(count)))
        return self[randomIndex]
    }
}
