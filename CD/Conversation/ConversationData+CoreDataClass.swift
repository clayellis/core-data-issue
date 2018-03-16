//
//  ConversationData+CoreDataClass.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ConversationData)
public class ConversationData: NSManagedObject {
    @discardableResult
    convenience init(conversation: Conversation, context: NSManagedObjectContext) {
        self.init(context: context)
        messageListID = conversation.messageListID
        contact = ContactData(contact: conversation.contact, context: context)
        mostRecentMessage = MessageData(message: conversation.mostRecentMessage, context: context)
    }
}
