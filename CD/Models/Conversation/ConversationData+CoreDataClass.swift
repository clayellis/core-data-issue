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
public final class ConversationData: NSManagedObject {}

extension ConversationData: ModelData {
    typealias ModelType = Conversation

    static var idPropertyName: String {
        return "messageListID"
    }

    @discardableResult
    convenience init(model: ModelType, context: NSManagedObjectContext) {
        self.init(context: context)
        configure(with: model, in: context)
    }

    func configure(with model: Conversation, in context: NSManagedObjectContext) {
        let conversation = model
        messageListID = conversation.messageListID

        if contact == nil {
            contact = ContactData(context: context)
        }
        contact?.configure(with: conversation.contact, in: context)

        // If a most recent message already exists...
        if let message = mostRecentMessage {
            // ... And the id is different from the incoming message
            if conversation.mostRecentMessage.id != message.id {
                do {
                    // 1. Fetch or create
                    let request = MessageData.fetchRequest(by: conversation.mostRecentMessage.id)
                    let messageData = try context.fetch(request).first ?? MessageData(context: context)

                    // 2. Update
                    messageData.configure(with: conversation.mostRecentMessage, in: context)
                    mostRecentMessage = messageData
                } catch {
                    print("MessageData fetch failed")
                }
            } else {
                // Otherwise, configure the existing message.
                message.configure(with: conversation.mostRecentMessage, in: context)
            }
        } else {
            // Otherwise, create and configure most recent message.
            mostRecentMessage = MessageData(context: context)
            mostRecentMessage?.configure(with: conversation.mostRecentMessage, in: context)
        }
    }
}
