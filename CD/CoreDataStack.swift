//
//  CoreDataStack.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

    private var container: NSPersistentContainer!

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    var backgroundContext: NSManagedObjectContext {
        let context = container.newBackgroundContext()
        configure(context: context)
        return context
    }

    init(modelName: String, url: URL) {
        let description = NSPersistentStoreDescription()
        description.shouldAddStoreAsynchronously = true
        description.url = url

        container = NSPersistentContainer(name: modelName)
        container.persistentStoreDescriptions = [description]
    }

    func loadStore(_ completion: @escaping (Error?) -> Void) {
        container.loadPersistentStores { description, error in
            guard error == nil else {
                completion(error)
                return
            }

            print("Persistent Store: \(description)")
            self.configure(context: self.container.viewContext)
            completion(nil)
        }
    }

    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { context in
            self.configure(context: context)
            task(context)
        }
    }

    private func configure(context: NSManagedObjectContext) {
        context.automaticallyMergesChangesFromParent = true
//        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
}
