//
//  Model.swift
//  CD
//
//  Created by Clay Ellis on 3/19/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

protocol Model {
    associatedtype ModelDataType: NSManagedObject

    init(data: ModelDataType) throws
    var fetchRequest: NSFetchRequest<ModelDataType> { get }
    var id: String { get }
}

extension Model where ModelDataType: ModelData, ModelDataType.ModelType == Self {
    var fetchRequest: NSFetchRequest<ModelDataType> {
        return ModelDataType.fetchRequest(for: self)
    }
}

extension NSManagedObjectContext {
    func fetch<T>(_ fetchable: T) throws -> T.ModelDataType? where T: Model {
        let request = fetchable.fetchRequest
        return try fetch(request).first
    }

    func fetchOrInsert<T>(_ fetchable: T) throws -> T.ModelDataType where T: Model {
        return try fetch(fetchable) ?? T.ModelDataType(context: self)
    }
}
