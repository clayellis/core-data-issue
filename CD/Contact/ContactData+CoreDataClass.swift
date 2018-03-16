//
//  ContactData+CoreDataClass.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ContactData)
public class ContactData: NSManagedObject {
    convenience init(contact: Contact, context: NSManagedObjectContext) {
        self.init(context: context)
        id = contact.id
        name = contact.name
    }
}
