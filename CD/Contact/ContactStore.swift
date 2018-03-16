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
    func store(contact: Contact) {
        store(contacts: [contact])
    }

    func store(contacts: [Contact]) {
        let context = coreDataStack.viewContext
        context.perform {
            for contact in contacts {
                ContactData(contact: contact, context: context)
            }

            do {
                print("ContactStore save")
                try context.save()
            } catch {
                print(error.humanReadableString)
            }

            for contact in contacts {
                // If the contact is part of a conversation, update the conversation
                let request: NSFetchRequest<ConversationData> = ConversationData.fetchRequest()
                request.predicate = NSPredicate(format: "contact.id == %@", contact.id)
                let results = try! context.fetch(request)

                guard let conversation = results.first else {
                    continue
                }

                print("ContactStore found conversation for contact: \(contact)")

                let contactRequest: NSFetchRequest<ContactData> = ContactData.fetchRequest()
                contactRequest.predicate = NSPredicate(format: "id == %@", contact.id)
                guard let contactResults = try? context.fetch(contactRequest), let contactData = contactResults.first else {
                    fatalError("Missing contact")
                }

                conversation.contact = contactData
            }

            do {
                print("ContactStore save")
                try context.save()
            } catch {
                print(error.humanReadableString)
            }
        }
    }
}
