//
//  Store.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation

class Store {
    let coreDataStack: CoreDataStackProtocol

    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
    }
}
