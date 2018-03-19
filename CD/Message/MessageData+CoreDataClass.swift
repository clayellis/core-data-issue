//
//  MessageData+CoreDataClass.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MessageData)
public final class MessageData: NSManagedObject {
    @discardableResult
    convenience init(message: Message, context: NSManagedObjectContext) {
        self.init(context: context)
        configure(with: message)
    }

    func configure(with message: Message) {
        id = message.id
        messageListID = message.messageListID
        body = message.body
        timestamp = message.timestamp as NSDate
    }
}

extension MessageData: FetchRequestable {
    typealias FetchableType = Message

    static var fetchID: String {
        return "id"
    }
}
