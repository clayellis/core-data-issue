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
        coreDataStack.performBackgroundTask { context in
            for contact in contacts {
                let contactData = ContactData(contact: contact, context: context)

                // If the contact is part of a conversation, update the conversation
                let request: NSFetchRequest<ConversationData> = ConversationData.fetchRequest()
                request.predicate = NSPredicate(format: "contact.id == %@", contact.id)
                let results = try! context.fetch(request)

                guard let conversation = results.first else {
                    continue
                }

                conversation.contact = contactData
            }

            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
}
