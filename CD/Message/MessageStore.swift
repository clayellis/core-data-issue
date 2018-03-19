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

class MessageStoreUpdateStrategy: Store, MessageStoreProtocol {
    func store(_ messages: [Message]) {
        coreDataStack.performBackgroundTask { context in
            for message in messages {
                do {
                    // 1. Fetch or Create
                    let messageRequest: NSFetchRequest<MessageData> = MessageData.fetchRequest()
                    messageRequest.predicate = NSPredicate(format: "id == %@", message.id)
                    let messageData = try context.fetch(messageRequest).first ?? MessageData(context: context)

                    // 2. Update
                    messageData.configure(with: message)

                    // 3. If the message is part of a conversation...
                    let conversationRequest: NSFetchRequest<ConversationData> = ConversationData.fetchRequest()
                    conversationRequest.predicate = NSPredicate(format: "messageListID == %@", message.messageListID)

                    guard let conversationData = try context.fetch(conversationRequest).first else {
                        continue
                    }

                    // ... and it is more recent, update the conversation.
                    if message.timestamp > conversationData.mostRecentMessage!.timestamp as Date! {
                        conversationData.mostRecentMessage = messageData
                    }
                } catch {
                    print("MessageStore error: \(error.humanReadableString)")
                    continue
                }
            }

            // 3. Save
            do {
                try context.save()
            } catch {
                print(error.humanReadableString)
            }
        }
    }
}

class MessageStore: Store, MessageStoreProtocol {
    func store(_ messages: [Message]) {
        coreDataStack.performBackgroundTask { context in
            // 1. Insert
            for message in messages {
                MessageData(message: message, context: context)
            }

            // 2. Save
            do {
                try context.save()
            } catch {
                print(error.humanReadableString)
            }

            
            for message in messages {
                // 3. Fetch conversation
                // If the message belongs to a conversation, and is more recent, update the conversation
                let request: NSFetchRequest<ConversationData> = ConversationData.fetchRequest()
                request.predicate = NSPredicate(format: "messageListID == %@", message.messageListID)
                let results = try! context.fetch(request)

                guard let conversation = results.first else {
                    continue
                }

                // 4. Fetch message
                let messageRequest: NSFetchRequest<MessageData> = MessageData.fetchRequest()
                messageRequest.predicate = NSPredicate(format: "id == %@", message.id)
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
                try context.save()
            } catch {
                print(error.humanReadableString)
            }
        }
    }
}
