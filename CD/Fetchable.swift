//
//  Fetchable.swift
//  CD
//
//  Created by Clay Ellis on 3/19/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

protocol Fetchable {
    associatedtype FetchedType: NSFetchRequestResult
    var fetchRequest: NSFetchRequest<FetchedType> { get }
    var fetchableID: String { get }
}

extension Fetchable where FetchedType: FetchRequestable, FetchedType.FetchableType == Self {
    var fetchRequest: NSFetchRequest<FetchedType> {
        return FetchedType.fetchRequest(for: self)
    }
}

extension NSManagedObjectContext {
    func fetch<T>(_ fetchable: T) throws -> T.FetchedType? where T: Fetchable {
        let request = fetchable.fetchRequest
        return try fetch(request).first
    }
}

protocol FetchRequestable: NSFetchRequestResult {
    associatedtype FetchableType: Fetchable

    static var fetchID: String { get }
    static func fetchRequest() -> NSFetchRequest<Self>
    static func fetchRequest(_ predicate: String, _ arguments: String...) -> NSFetchRequest<Self>
    static func fetchRequest(by id: String) -> NSFetchRequest<Self>
    static func fetchRequest(for object: FetchableType) -> NSFetchRequest<Self>
}

extension FetchRequestable {
    typealias Request = NSFetchRequest<Self>

    static func fetchRequest(for object: FetchableType) -> Request {
        return fetchRequest(by: object.fetchableID)
    }

    static func fetchRequest(by id: String) -> Request {
        return fetchRequest("\(fetchID) == %@", id)
    }

    static func fetchRequest(_ predicate: String, _ arguments: String...) -> Request {
        let request: Request = fetchRequest()
        request.predicate = NSPredicate(format: predicate, argumentArray: arguments)
        return request
    }
}
