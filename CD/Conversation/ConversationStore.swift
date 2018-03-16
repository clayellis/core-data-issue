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
    func store(conversation: Conversation) {
        store(conversations: [conversation])
    }

    func store(conversations: [Conversation]) {
        coreDataStack.performBackgroundTask { context in
            for conversation in conversations {
                ConversationData(conversation: conversation, context: context)
            }

            do {
                print("ConversationStore save")
                try context.save()
            } catch {
                print(error.humanReadableString)
            }
        }
    }
}
