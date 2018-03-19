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
public final class ContactData: NSManagedObject {
    @discardableResult
    convenience init(contact: Contact, context: NSManagedObjectContext) {
        self.init(context: context)
        configure(with: contact)
    }

    func configure(with contact: Contact) {
        id = contact.id
        name = contact.name
    }
}

extension ContactData: FetchRequestable {
    typealias FetchableType = Contact

    static var fetchID: String {
        return "id"
    }
}
