//
//  CoreDataStack.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

/// A stack that provides contexts and conveniences for working with Core Data.
protocol CoreDataStackProtocol {
    /// The managed object context associated with the main queue.
    var viewContext: NSManagedObjectContext { get }

    /// Creates a private managed object context.
    func newBackgroundContext() -> NSManagedObjectContext

    /// Executes the task against a new private queue context.
    /// - parameter task: The task to perform.
    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) throws -> Void)

    /// Tears down and cleans up the stack for testing.
    func tearDown()
}

class CoreDataStack: CoreDataStackProtocol {

    private let coordinator: NSPersistentStoreCoordinator
    private let storeContext: NSManagedObjectContext

    let viewContext: NSManagedObjectContext

    init(modelName: String, url: URL? = nil, type: String) throws {
        let model = NSManagedObjectModel.mergedModel(from: [.main])!
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]

        try coordinator.addPersistentStore(ofType: type, configurationName: nil, at: url, options: options)

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

    func tearDown() {
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

    /// Configures a managed object context.
    private func configure(_ context: NSManagedObjectContext) {
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
    }

    /// Returns the name of the managed object context.
    private func name(from context: NSManagedObjectContext) -> String {
        if context == self.storeContext {
            return "store"
        } else if context == self.viewContext {
            return "view"
        } else {
            return "background"
        }
    }

    /// Saves a managed object context synchronously if it has changes.
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
