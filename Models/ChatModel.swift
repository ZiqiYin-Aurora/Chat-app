//
//  ChatModel.swift
//  Chatting
//
//  Created by Yin Celia on 2021/10/17.
//

import Foundation
import FirebaseFirestoreSwift
import SwiftUI

struct Chat: Hashable, Identifiable {
    let id: String
    var name: String
    //var person: [Person]
//    var img: String
    var img: Image
    var personIDs: [String]
    var messages: [Message]
    var hasUnreadMsg: Bool
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == rhs.id && lhs.personIDs == rhs.personIDs && lhs.messages == rhs.messages && lhs.hasUnreadMsg == rhs.hasUnreadMsg
        }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(personIDs)
        hasher.combine(messages)
        hasher.combine(hasUnreadMsg)
    }
}

enum MessageType: String {
    case sent
    case received
}

struct Message: Hashable {
    let id = UUID()
    let text: String
    let type: MessageType
    let date: Date // Date
    let sender: String
    
    init(text: String, type: MessageType, date: Date, sender: String) {
        self.date = date
        self.text = text
        self.type = type
        self.sender = sender
    }
    
    init(text: String, type: MessageType, sender: String) {
        self.init(text: text, type: type, date: Date(), sender: sender)
    }
}

struct Person: Identifiable {
//    let id = UUID()
    var id: String
    var name: String
//    var imgString: String
    var img: Image
    
}

// for group members' photos
struct Photo: Identifiable {
    var id = UUID()
    var name: String
}


