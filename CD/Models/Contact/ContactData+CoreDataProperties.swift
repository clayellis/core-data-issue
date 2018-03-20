//
//  ContactData+CoreDataProperties.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactData> {
        return NSFetchRequest<ContactData>(entityName: "ContactData")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var conversation: ConversationData?

}
