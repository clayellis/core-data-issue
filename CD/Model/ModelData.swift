//
//  ModelData.swift
//  CD
//
//  Created by Clay Ellis on 3/19/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

protocol ModelData: NSFetchRequestResult {
    associatedtype ModelType: Model

    static var idPropertyName: String { get }
    @discardableResult init(model: ModelType, context: NSManagedObjectContext)
    func configure(with model: ModelType, in context: NSManagedObjectContext)
    static func fetchRequest() -> NSFetchRequest<Self>
    static func fetchRequest(_ predicate: String, _ arguments: String...) -> NSFetchRequest<Self>
    static func fetchRequest(by id: String) -> NSFetchRequest<Self>
    static func fetchRequest(for object: ModelType) -> NSFetchRequest<Self>
}

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
