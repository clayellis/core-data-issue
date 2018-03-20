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
                do {
                    // 1. Fetch or Create
                    let contactData = try context.fetch(contact) ?? ContactData(context: context)

                    // 2. Update
                    contactData.configure(with: contact, in: context)
                } catch {
                    print("ContactStore error: \(error.humanReadableString)")
                    continue
                }
            }

            // 3. Save
            do {
                try context.save()
            } catch {
                print(error.humanReadableString)
            }
        }
    }
}
