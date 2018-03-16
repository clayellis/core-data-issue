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
        return container.newBackgroundContext()
    }

    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(task)
    }

    func loadStore(_ completion: @escaping (Error?) -> Void) {
        container.loadPersistentStores { [weak container] description, error in
            guard error == nil else {
                completion(error)
                return
            }

            print("Persistent Store: \(description)")
            container?.viewContext.automaticallyMergesChangesFromParent = true
            container?.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            completion(nil)
        }
    }

    init(modelName: String) {
        let description = NSPersistentStoreDescription()
        description.shouldAddStoreAsynchronously = true
        description.url = URL(fileURLWithPath: "/Users/clay/Desktop/CD/CD.sqlite")

        container = NSPersistentContainer(name: modelName)
        container.persistentStoreDescriptions = [description]
    }
}
