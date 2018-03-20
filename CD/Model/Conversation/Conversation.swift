//
//  Conversation.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

struct Conversation {
    let contact: Contact
    let mostRecentMessage: Message

    var messageListID: String {
        return mostRecentMessage.messageListID
    }
}

extension Conversation: Model {
    typealias ModelDataType = ConversationData

    var id: String {
        return messageListID
    }

    init(data: ModelDataType) throws {
        contact = try! Contact(data: data.contact!)
        mostRecentMessage = try! Message(data: data.mostRecentMessage!)
    }
}
