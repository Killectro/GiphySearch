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
    var smallUrl: NSURL!
    var height: Float!
    var width: Float!
}

// MARK: - Mappable
extension Gif: Mappable {
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        url <- (map["images.downsized.url"], URLTransform())
        height <- (map["images.downsized.height"], StringFloatTransform())
        width <- (map["images.downsized.width"], StringFloatTransform())
//        smallUrl <- (map["images.downsized.url"], URLTransform())
    }
}
