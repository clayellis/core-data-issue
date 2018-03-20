//
//  ModelData.swift
//  CD
//
//  Created by Clay Ellis on 3/19/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

/// A Core Data managed object that represents a `Model`.
protocol ModelData: NSFetchRequestResult {

    /// The `Model` that this instance represents.
    associatedtype ModelType: Model

    /// The name of the property which uniquely identifies this instance.
    static var idPropertyName: String { get }

    /// Initializes `self` from an instance of its `ModelType` in a context.
    /// - parameter model: The instance of `self`'s `ModelType` from which `self` should be initialized.
    /// - parameter context: The managed object context `self` will be inserted into.
    @discardableResult init(model: ModelType, context: NSManagedObjectContext)

    /// Configures `self` with an instance of its `ModelType` in a context.
    /// - parameter model: The instance of `self`'s `ModelType` with which `self` should be configured.
    /// - parameter context: The managed object context `self` exists within.
    func configure(with model: ModelType, in context: NSManagedObjectContext)

    /// Returns blank fetch request for `Self`.
    static func fetchRequest() -> NSFetchRequest<Self>

    /// Returns a fetch request with a predicate for `Self`.
    /// - parameter predicate: The predicate string that the fetch request will use for filtering.
    /// - parameter arguments: The arguments used in the predicate string.
    static func fetchRequest(_ predicate: String, _ arguments: String...) -> NSFetchRequest<Self>

    /// Returns a fetch request with a predicate filtering by `Self.idPropertyName`.
    /// - parameter id: The id used to filter to a specific instance of `Self`.
    static func fetchRequest(by id: String) -> NSFetchRequest<Self>

    /// Returns a fetch request with a predicate filtering to a specific object.
    ///
    /// Uses `fetchRequest(by id:)` and `object.id`.
    /// - parameter object: The instance of `ModelType` to filter against and fetch.
    static func fetchRequest(for object: ModelType) -> NSFetchRequest<Self>
}

// MARK: Default implementations for ModelData

extension ModelData {
    typealias Request = NSFetchRequest<Self>

    static func fetchRequest(for object: ModelType) -> Request {
        return fetchRequest(by: object.id)
    }

    static func fetchRequest(by id: String) -> Request {
        return fetchRequest("\(idPropertyName) == %@", id)
    }

    static func fetchRequest(_ predicate: String, _ arguments: String...) -> Request {
        let request: Request = fetchRequest()
        request.predicate = NSPredicate(format: predicate, argumentArray: arguments)
        return request
    }
}
