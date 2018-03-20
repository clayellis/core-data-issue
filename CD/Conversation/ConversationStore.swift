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

extension ConversationStoreProtocol {
    func store(_ conversation: Conversation) {
        print("Storing: \(conversation)")
        store([conversation])
    }
}

class ConversationStore: Store, ConversationStoreProtocol {
    func store(_ conversations: [Conversation]) {
        coreDataStack.performBackgroundTask { context in
            for conversation in conversations {
                // 1. Fetch or insert
                let conversationData = try context.fetchOrInsert(conversation)

                // 2. Update
                conversationData.configure(with: conversation, in: context)
            }

            // 3. Save
            try context.save()
        }
    }
}
