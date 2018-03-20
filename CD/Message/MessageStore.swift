//
//  MessageStore.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

protocol MessageStoreProtocol {
    func store(_ message: Message)
    func store(_ messages: [Message])
}

extension MessageStoreProtocol {
    func store(_ message: Message) {
        print("Storing: \(message)")
        store([message])
    }
}

class MessageStore: Store, MessageStoreProtocol {
    func store(_ messages: [Message]) {
        coreDataStack.performBackgroundTask { context in
            for message in messages {
                // 1. Fetch or insert
                let messageData = try context.fetchOrInsert(message)

                // 2. Update
                messageData.configure(with: message, in: context)

                // 3. If the message is part of a conversation...
                let conversationRequest = ConversationData.fetchRequest(by: message.messageListID)
                guard let conversationData = try context.fetch(conversationRequest).first else {
                    continue
                }

                // ... and it is more recent, update the conversation.
                if message.timestamp > conversationData.mostRecentMessage!.timestamp as Date! {
                    conversationData.mostRecentMessage = messageData
                }
            }

            // 3. Save
            try context.save()
        }
    }
}
