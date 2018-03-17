//
//  ContactStore.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

class ContactStore: Store {
    func store(_ contact: Contact) {
        store([contact])
    }

    func store(_ contacts: [Contact]) {
        coreDataStack.performBackgroundTask { context in
            // 1. Insert
            for contact in contacts {
                ContactData(contact: contact, context: context)
            }

            // 2. Save
            do {
                print("ContactStore save")
                try context.save()
            } catch {
                print(error.humanReadableString)
            }

            for contact in contacts {
                // 3. Fetch conversation
                // If the contact is part of a conversation, update the conversation
                let request = ConversationData.fetchRequest(withPredicate: "contact.id == %@", argumentArray: [contact.id])
                let results = try! context.fetch(request)

                guard let conversation = results.first else {
                    continue
                }

                print("ContactStore found conversation for contact: \(contact)")

                // 4. Fetch contact
                let contactRequest = ContactData.fetchRequest(withPredicate: "id == %@", argumentArray: [contact.id])
                guard let contactResults = try? context.fetch(contactRequest), let contactData = contactResults.first else {
                    fatalError("Missing contact")
                }

                // 5. Update relationship
                conversation.contact = contactData
            }

            // 6. Save
            do {
                print("ContactStore save")
                try context.save()
            } catch {
                print(error.humanReadableString)
            }
        }
    }
}
