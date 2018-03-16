//
//  MessageStore.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

class MessageStore: Store {
    func store(message: Message) {
        store(messages: [message])
    }

    func store(messages: [Message]) {
        coreDataStack.performBackgroundTask { context in
            for message in messages {
                let messageData = MessageData(message: message, context: context)

                // If the message belongs to a conversation, and is more recent, update the conversation
                let request: NSFetchRequest<ConversationData> = ConversationData.fetchRequest()
                request.predicate = NSPredicate(format: "messageListID == %@", message.messageListID)
                let results = try! context.fetch(request)

                guard let conversation = results.first else {
                    continue
                }

                if message.timestamp > conversation.mostRecentMessage!.timestamp as Date! {
                    conversation.mostRecentMessage = messageData
                }
            }
        }
    }
}
