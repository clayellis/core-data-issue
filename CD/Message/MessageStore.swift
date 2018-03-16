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
               
                // If the message belongs to a conversation, and is more recent, update the conversation
                let request: NSFetchRequest<ConversationData> = ConversationData.fetchRequest()
                request.predicate = NSPredicate(format: "messageListID == %@", message.messageListID)
                let results = try! context.fetch(request)

                guard let conversation = results.first else {
                    continue
                }
                
                 print("MessageStore found conversation for message: \(message)")
                
                if let mostRecentMessage = conversation.mostRecentMessage,
                    message.timestamp <= mostRecentMessage.timestamp as Date! {
                     print("MessageStore does not need to update because message is not newer than current")
                    return
                }
                
                if conversation.mostRecentMessage?.id != message.id {
                    // Update message
                    // Check if message already exists
                    let request: NSFetchRequest<MessageData> = MessageData.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", message.id)
                    let messageResult = try! context.fetch(request)
                    
                    if let messageData = messageResult.first {
                        print("MessageStore already has message with given ID")
                        conversation.mostRecentMessage = messageData
                    } else {
                        // Create a new one
                        print("MessageStore creating message with given ID")
                        let newMessageData = MessageData(message: message, context: context)
                        conversation.mostRecentMessage = newMessageData
                    }
                } else {
                    // Nothing to do
                    return
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
