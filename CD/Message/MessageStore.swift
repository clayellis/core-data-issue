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

    }
}
