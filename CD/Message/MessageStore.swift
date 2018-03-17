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
    func store(_ message: Message) {
        store([message])
    }

    func store(_ messages: [Message]) {
        coreDataStack.performBackgroundTask { context in
            // 1. Insert
            for message in messages {
                MessageData(message: message, context: context)
            }

            // 2. Save
            do {
                print("MessageStore save")
                try context.save()
            } catch {
                print(error.humanReadableString)
            }

            
            for message in messages {
                // 3. Fetch conversation
                // If the message belongs to a conversation, and is more recent, update the conversation
                let request = ConversationData.fetchRequest(withPredicate: "messageListID == %@", argumentArray: [message.messageListID])
                let results = try! context.fetch(request)

                guard let conversation = results.first else {
                    continue
                }

                print("MessageStore found conversation for message: \(message)")

                // 4. Fetch message
                let messageRequest = MessageData.fetchRequest(withPredicate: "id == %@", argumentArray: [message.id])
                guard let messageResults = try? context.fetch(messageRequest), let messageData = messageResults.first else {
                    fatalError("Missing message")
                }

                // 5. Update relationship
                if message.timestamp > conversation.mostRecentMessage!.timestamp as Date! {
                    conversation.mostRecentMessage = messageData
                }
            }

            // 6. Save
            do {
                print("MessageStore save")
                try context.save()
            } catch {
                print(error.humanReadableString)
            }
        }
    }
}
