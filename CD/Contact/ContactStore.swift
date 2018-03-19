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

class ContactStoreUpdateStrategy: Store, ContactStoreProtocol {
    func store(_ contact: Contact) {
        print("Storing: \(contact)")
        store([contact])
    }

    func store(_ contacts: [Contact]) {
        coreDataStack.performBackgroundTask { context in
            for contact in contacts {
                do {
                    // 1. Fetch or Create
                    let request: NSFetchRequest<ContactData> = ContactData.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", contact.id)
                    let result = try context.fetch(request).first
                    let contactData = result ?? ContactData(context: context)

                    // 2. Update
                    contactData.configure(with: contact)
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

class ContactStore: Store, ContactStoreProtocol {
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
                let request: NSFetchRequest<ConversationData> = ConversationData.fetchRequest()
                request.predicate = NSPredicate(format: "contact.id == %@", contact.id)
                let results = try! context.fetch(request)

                guard let conversation = results.first else {
                    continue
                }

                print("ContactStore found conversation for contact: \(contact)")

                // 4. Fetch contact
                let contactRequest: NSFetchRequest<ContactData> = ContactData.fetchRequest()
                contactRequest.predicate = NSPredicate(format: "id == %@", contact.id)
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
