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
public final class MessageData: NSManagedObject {}

extension MessageData: ModelData {
    typealias ModelType = Message

    static var idPropertyName: String {
        return "id"
    }

    @discardableResult
    convenience init(model: ModelType, context: NSManagedObjectContext) {
        self.init(context: context)
        configure(with: model, in: context)
    }

    func configure(with model: Message, in context: NSManagedObjectContext) {
        let message = model
        id = message.id
        messageListID = message.messageListID
        body = message.body
        timestamp = message.timestamp as NSDate
    }
}
