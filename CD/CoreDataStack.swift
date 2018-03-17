//
//  CoreDataStack.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataStackProtocol {
    init(modelName: String, url: URL?)
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void)
    func loadStore(_ completion: @escaping (Error?) -> Void)
}

class ContainerStack: CoreDataStackProtocol {

    private var container: NSPersistentContainer!
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    var backgroundContext: NSManagedObjectContext {
        let context = container.newBackgroundContext()
        configure(context: context)
        return context
    }

    required init(modelName: String, url: URL? = nil) {
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
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
}

class ContextualStack: CoreDataStackProtocol {

    private let _storeContext: NSManagedObjectContext
    private let _viewContext: NSManagedObjectContext
    private let _backgroundContext: NSManagedObjectContext

    var viewContext: NSManagedObjectContext {
        return _viewContext
    }

    var backgroundContext: NSManagedObjectContext {
        return _backgroundContext
    }

    required init(modelName: String, url: URL? = nil) {
        let model = NSManagedObjectModel.mergedModel(from: [.main])!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]

        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)

        if let storeURL = coordinator.persistentStores.first?.url {
            print("Added store at: \(storeURL)")
        }

        _storeContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        _storeContext.persistentStoreCoordinator = coordinator
        _storeContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        _viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        _viewContext.parent = _storeContext
        _viewContext.mergePolicy = _storeContext.mergePolicy

        _backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        _backgroundContext.parent = _viewContext
        _backgroundContext.mergePolicy = _viewContext.mergePolicy
    }

    func loadStore(_ completion: @escaping (Error?) -> Void) {
        completion(nil)
    }

    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void) {
        let context = backgroundContext
        context.performAndWait {
            task(context)
            self.saveContext(context, named: "background")
            self.saveContext(self.viewContext, named: "view")
            self.saveContext(self._storeContext, named: "_store")
        }
    }

    private func saveContext(_ context: NSManagedObjectContext, named name: String) {
        context.performAndWait {
            guard context.hasChanges else {
                return
            }

            do {
                try context.save()
            } catch {
                print("Failed to save \(name) context: \(error.humanReadableString)")
            }
        }
    }
}
