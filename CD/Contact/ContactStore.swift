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

    }
}
