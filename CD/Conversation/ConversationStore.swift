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

    }
}