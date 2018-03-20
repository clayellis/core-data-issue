//
//  ContactStore.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

class ContactStore: Store<Contact> {
    override func store(_ models: [Contact]) {
        coreDataStack.performBackgroundTask { context in
            for contact in models {
                // 1. Fetch or insert
                let contactData = try context.fetchOrInsert(contact)

                // 2. Update
                contactData.configure(with: contact, in: context)
            }

            // 3. Save
            try context.save()
        }
    }
}
