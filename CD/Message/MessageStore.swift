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
                MessageData(message: message, context: context)
            }

            do {
                print("MessageStore save")
                try context.save()
            } catch {
                print(error.humanReadableString)
            }

            for message in messages {
                // If the message belongs to a conversation, and is more recent, update the conversation
                let request: NSFetchRequest<ConversationData> = ConversationData.fetchRequest()
                request.predicate = NSPredicate(format: "messageListID == %@", message.messageListID)
                let results = try! context.fetch(request)

                guard let conversation = results.first else {
                    continue
                }

                print("MessageStore found conversation for message: \(message)")

                let messageRequest: NSFetchRequest<MessageData> = MessageData.fetchRequest()
                messageRequest.predicate = NSPredicate(format: "id == %@", message.id)
                guard let messageResults = try? context.fetch(messageRequest), let messageData = messageResults.first else {
                    fatalError("Missing message")
                }

                if message.timestamp > conversation.mostRecentMessage!.timestamp as Date! {
                    conversation.mostRecentMessage = messageData
                }
            }

            do {
                print("MessageStore save")
                try context.save()
            } catch {
                print(error.humanReadableString)
            }
        }
    }
}
