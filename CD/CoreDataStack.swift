//
//  CoreDataStack.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

private let mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//private let mergePolicy = NSOverwriteMergePolicy
//private let mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

protocol CoreDataStackProtocol {
    init(modelName: String, url: URL?, type: String)
    var viewContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void)
    func loadStore(_ completion: @escaping (Error?) -> Void)
    func close()
}

class CoreDataStack: CoreDataStackProtocol {

    private let coordinator: NSPersistentStoreCoordinator
    private let _storeContext: NSManagedObjectContext
    private let _viewContext: NSManagedObjectContext

    var viewContext: NSManagedObjectContext {
        return _viewContext
    }

    var backgroundContext: NSManagedObjectContext {
        return newBackgroundContext()
    }

    required init(modelName: String, url: URL? = nil, type: String) {
        let model = NSManagedObjectModel.mergedModel(from: [.main])!
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]

        try! coordinator.addPersistentStore(ofType: type, configurationName: nil, at: url, options: options)

        if let storeURL = coordinator.persistentStores.first?.url {
            print("Added store at: \(storeURL)")
        }

        _storeContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        _storeContext.persistentStoreCoordinator = coordinator
        _storeContext.mergePolicy = mergePolicy

        _viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        _viewContext.parent = _storeContext
        _viewContext.mergePolicy = _storeContext.mergePolicy
    }

    func loadStore(_ completion: @escaping (Error?) -> Void) {
        completion(nil)
    }

    private func newBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = _viewContext
        context.mergePolicy = _viewContext.mergePolicy
        return context
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

    func close() {
        for store in coordinator.persistentStores {
            guard let url = store.url else {
                continue
            }
            do {
                try coordinator.destroyPersistentStore(at: url, ofType: store.type, options: nil)
            } catch {
                print(error.humanReadableString)
            }
        }
    }
}
