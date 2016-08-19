//
//  StringFloatTransform.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import Foundation
import ObjectMapper

struct StringFloatTransform: TransformType {
    typealias Object = Float
    typealias JSON = String

    func transformFromJSON(value: AnyObject?) -> Float? {
        if let s = value as? String, v = Float(s) {
            return v
        }
        return nil
    }

    func transformToJSON(value: Float?) -> String? {
        return String(value)
    }
}