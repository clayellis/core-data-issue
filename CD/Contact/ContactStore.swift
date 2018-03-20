//
//  ContactStore.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

protocol ContactStoreProtocol {
    func store(_ contact: Contact)
    func store(_ contacts: [Contact])
}

extension ContactStoreProtocol {
    func store(_ contact: Contact) {
        print("Storing: \(contact)")
        store([contact])
    }
}

class ContactStore: Store, ContactStoreProtocol {
    func store(_ contacts: [Contact]) {
        coreDataStack.performBackgroundTask { context in
            for contact in contacts {
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
