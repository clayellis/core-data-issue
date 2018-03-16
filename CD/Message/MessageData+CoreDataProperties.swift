//
//  MessageData+CoreDataProperties.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//
//

import Foundation
import CoreData


extension MessageData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageData> {
        return NSFetchRequest<MessageData>(entityName: "MessageData")
    }

    @NSManaged public var id: String?
    @NSManaged public var messageListID: String?
    @NSManaged public var body: String?
    @NSManaged public var conversation: ConversationData?

}
