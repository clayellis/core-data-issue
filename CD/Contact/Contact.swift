//
//  Contact.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

struct Contact {
    let id: String
    let name: String
}

extension Contact: Fetchable {
    typealias ResultType = ContactData

    var fetchableID: String {
        return name
    }

    var fetchRequest: NSFetchRequest<ContactData> {
        return ContactData.fetchRequest(for: self)
    }
}
