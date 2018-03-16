//
//  ConversationData+CoreDataProperties.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//
//

import Foundation
import CoreData


extension ConversationData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConversationData> {
        return NSFetchRequest<ConversationData>(entityName: "ConversationData")
    }

    @NSManaged public var messageListID: String?
    @NSManaged public var contact: ContactData?
    @NSManaged public var mostRecentMessage: MessageData?

}
