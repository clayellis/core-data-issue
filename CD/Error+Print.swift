//
//  Error+Print.swift
//  CD
//
//  Created by Clay Ellis on 3/16/18.
//  Copyright © 2018 Clay Ellis. All rights reserved.
//

import Foundation

extension Error {
    var humanReadableString: String {
        let info = (self as NSError)
        return String(describing: info)
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\", with: "")
    }
}
