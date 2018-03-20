//
//  Store.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation

protocol StoreProtocol {
    associatedtype StoredModel: Model

    func store(_ model: StoredModel)
    func store(_ models: [StoredModel])
}

class Store<T: Model>: StoreProtocol {
    typealias StoredModel = T

    let coreDataStack: CoreDataStackProtocol

    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
    }

    func store(_ model: T) {
        print("Storing: \(model)")
        store([model])
    }

    func store(_ models: [T]) {
        fatalError("Unimplemented")
    }
}
