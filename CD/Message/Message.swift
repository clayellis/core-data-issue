//
//  Message.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

struct Message {
    let id: String
    let messageListID: String
    let body: String
    let timestamp: Date
}

extension Message: Model {
    typealias ModelDataType = MessageData

    init(data: ModelDataType) throws {
        id = data.id!
        messageListID = data.messageListID!
        body = data.body!
        timestamp = data.timestamp! as Date
    }
}
