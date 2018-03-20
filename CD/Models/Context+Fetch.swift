//
//  Context+Fetch.swift
//  CD
//
//  Created by Clay Ellis on 3/19/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    /// Fetches and returns the `ModelDataType` instance that represents the object
    /// if one exists, otherwise returns `nil`.
    /// - parameter fetchable: The object whose representative will be fetched.
    func fetch<T>(_ fetchable: T) throws -> T.ModelDataType? where T: Model {
        let request = fetchable.fetchRequest
        return try fetch(request).first
    }

    /// Fetches the `ModelDataType` instance that represents the object, otherwise
    /// a new instance is created and inserted.
    /// - parameter fetchable: The object whose representative will be fetched.
    /// - returns: Either the fetched object (if it existed) or the inserted instance.
    func fetchOrInsert<T>(_ fetchable: T) throws -> T.ModelDataType where T: Model {
        return try fetch(fetchable) ?? T.ModelDataType(context: self)
    }
}
