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
public class MessageData: NSManagedObject {
    @discardableResult
    convenience init(message: Message, context: NSManagedObjectContext) {
        self.init(context: context)
        id = message.id
        messageListID = message.messageListID
        body = message.body
        timestamp = message.timestamp as NSDate
    }
}
