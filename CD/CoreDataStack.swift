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

    init(modelName: String) {
        let description = NSPersistentStoreDescription()
        description.shouldAddStoreAsynchronously = true

        container = NSPersistentContainer(name: modelName)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { [weak container] description, error in
            if let error = error {
                fatalError("Error occurred while loading persistent stores: \(error)")
            }

            print("Persistent Store: \(description)")
            container?.viewContext.automaticallyMergesChangesFromParent = true
            container?.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        }
    }
}
