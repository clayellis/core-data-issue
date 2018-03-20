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
    init(modelName: String, url: URL?, type: String)
    var viewContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) throws -> Void)
    func loadStore(_ completion: @escaping (Error?) -> Void)
    func close()
}

class CoreDataStack: CoreDataStackProtocol {

    private let coordinator: NSPersistentStoreCoordinator
    private let storeContext: NSManagedObjectContext

    let viewContext: NSManagedObjectContext

    required init(modelName: String, url: URL? = nil, type: String) {
        let model = NSManagedObjectModel.mergedModel(from: [.main])!
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]

        try! coordinator.addPersistentStore(ofType: type, configurationName: nil, at: url, options: options)

        if let storeURL = coordinator.persistentStores.first?.url {
            print("Added store at: \(storeURL)")
        }

        storeContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        storeContext.persistentStoreCoordinator = coordinator

        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.parent = storeContext

        [storeContext, viewContext].forEach(configure)
    }

    // MARK: - Public

    func loadStore(_ completion: @escaping (Error?) -> Void) {
        completion(nil)
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = viewContext
        configure(context)
        return context
    }

    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) throws -> Void) {
        let context = newBackgroundContext()
        context.performAndWait {
            do {
                try task(context)
                self.saveContext(self.viewContext)
                self.saveContext(self.storeContext)
            } catch {
                let contextName = self.name(from: context)
                print("An error occurred while performing a task on the \(contextName) context: \(error.humanReadableString)")
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

    // MARK: - Private

    private func configure(_ context: NSManagedObjectContext) {
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
    }

    private func name(from context: NSManagedObjectContext) -> String {
        if context == self.storeContext {
            return "store"
        } else if context == self.viewContext {
            return "view"
        } else {
            return "background"
        }
    }

    private func saveContext(_ context: NSManagedObjectContext) {
        context.performAndWait {
            guard context.hasChanges else {
                return
            }

            do {
                try context.save()
            } catch {
                let contextName = self.name(from: context)
                print("Failed to save \(contextName) context: \(error.humanReadableString)")
            }
        }
    }
}
