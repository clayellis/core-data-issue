//
//  ConversationStore.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

protocol ConversationStoreProtocol {
    func store(_ conversation: Conversation)
    func store(_ conversations: [Conversation])
}

class ConversationStoreUpdateStrategy: Store, ConversationStoreProtocol {
    func store(_ conversation: Conversation) {
        print("Storing: \(conversation)")
        store([conversation])
    }

    func store(_ conversations: [Conversation]) {
        coreDataStack.performBackgroundTask { context in
            for conversation in conversations {
                do {
                    // 1. Fetch or create
                    let request: NSFetchRequest<ConversationData> = ConversationData.fetchRequest()
                    request.predicate = NSPredicate(format: "messageListID == %@", conversation.messageListID)
                    let conversationData = try context.fetch(request).first ?? ConversationData(context: context)

                    // 2. Update
                    conversationData.configure(conversation: conversation, context: context)
                } catch {
                    print("ConversationStore error: \(error.humanReadableString)")
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

class ConversationStore: Store, ConversationStoreProtocol {
    func store(_ conversation: Conversation) {
        store([conversation])
    }

    func store(_ conversations: [Conversation]) {
        coreDataStack.performBackgroundTask { context in
            // 1. Insert
            for conversation in conversations {
                ContactData(contact: conversation.contact, context: context)
                MessageData(message: conversation.mostRecentMessage, context: context)
            }

            // 2. Save
            do {
                print("ConversationStore save")
                try context.save()
            } catch {
                print(error.humanReadableString)
            }

            // 3. Fetch
            for conversation in conversations {
                let conversationRequest: NSFetchRequest<ConversationData> = ConversationData.fetchRequest()
                conversationRequest.predicate = NSPredicate(format: "messageListID == %@", conversation.messageListID)
                let conversationResult = try! context.fetch(conversationRequest).first
                let conversationData = conversationResult ?? ConversationData(context: context)

                let contactRequest: NSFetchRequest<ContactData> = ContactData.fetchRequest()
                contactRequest.predicate = NSPredicate(format: "id == %@", conversation.contact.id)
                let contactData = try! context.fetch(contactRequest).first

                let messageRequest: NSFetchRequest<MessageData> = MessageData.fetchRequest()
                messageRequest.predicate = NSPredicate(format: "id == %@", conversation.mostRecentMessage.id)
                let messageData = try! context.fetch(messageRequest).first

                // 4. Update
                conversationData.messageListID = conversation.messageListID
                conversationData.contact = contactData
                conversationData.mostRecentMessage = messageData
            }

            // 5. Save
            do {
                print("ConversationStore save")
                try context.save()
            } catch {
                print(error.humanReadableString)
            }
        }
    }
}
