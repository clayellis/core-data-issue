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
public final class ContactData: NSManagedObject {}

extension ContactData: ModelData {
    typealias ModelType = Contact

    static var idPropertyName: String {
        return "id"
    }

    @discardableResult
    convenience init(model: ModelType, context: NSManagedObjectContext) {
        self.init(context: context)
        configure(with: model, in: context)
    }

    func configure(with model: Contact, in context: NSManagedObjectContext) {
        let contact = model
        id = contact.id
        name = contact.name
    }
}
