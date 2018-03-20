//
//  Model.swift
//  CD
//
//  Created by Clay Ellis on 3/19/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation
import CoreData

/// A model that can be represented by, and whose representation can be
/// fetched from, Core Data.
protocol Model {
    /// The backing Core Data model type.
    associatedtype ModelDataType: NSManagedObject

    /// Initializes `self` from a `ModelDataType` instance.
    /// - parameter data: The `ModelDataType` to initialize `self` from.
    /// - throws: If errors occur during initialization.
    init(data: ModelDataType) throws

    /// A Core Data fetch request to retrieve the `ModelDataType` instance
    /// that represents `self`.
    var fetchRequest: NSFetchRequest<ModelDataType> { get }

    /// A unique id for this instance that will be used for fetching
    /// the `ModelDataType` instance that represents `self.`
    var id: String { get }
}

// MARK: Default implementation for Model

extension Model where ModelDataType: ModelData, ModelDataType.ModelType == Self {
    var fetchRequest: NSFetchRequest<ModelDataType> {
        return ModelDataType.fetchRequest(for: self)
    }
}
