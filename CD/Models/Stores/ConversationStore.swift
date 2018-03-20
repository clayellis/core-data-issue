//
//  ConversationStore.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

class ConversationStore: Store<Conversation> {
    override func store(_ models: [Conversation]) {
        coreDataStack.performBackgroundTask { context in
            for conversation in models {
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
