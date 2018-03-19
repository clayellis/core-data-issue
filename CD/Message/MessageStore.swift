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
                do {
                    // 1. Fetch or Create
                    let messageData = try context.fetch(message) ?? MessageData(context: context)

                    // 2. Update
                    messageData.configure(with: message)

                    // 3. If the message is part of a conversation...
                    let conversationRequest = ConversationData.fetchRequest(by: message.messageListID)
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
