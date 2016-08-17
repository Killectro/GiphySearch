//
//  Gif.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import Foundation
import ObjectMapper

struct Gif {
    var id: String!
    var url: NSURL!
}

// MARK: - Mappable
extension Gif: Mappable {
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        url <- map["embed_url"]
    }
}
