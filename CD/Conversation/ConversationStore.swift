//
//  ConversationStore.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

class ConversationStore: Store {
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
                let conversationRequest = ConversationData.fetchRequest(
                    withPredicate: "messageListID == %@",
                    argumentArray: [conversation.messageListID])

                let conversationResult = try! context.fetch(conversationRequest).first

                let conversationData = conversationResult ?? ConversationData(context: context)

                let contactRequest = ContactData.fetchRequest(
                    withPredicate: "id == %@",
                    argumentArray: [conversation.contact.id])

                let contactData = try! context.fetch(contactRequest).first!

                let messageRequest = MessageData.fetchRequest(
                    withPredicate: "id == %@",
                    argumentArray: [conversation.mostRecentMessage.id])

                let messageData = try! context.fetch(messageRequest).first!

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
