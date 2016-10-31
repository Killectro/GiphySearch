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
    var url: URL!
    var height: Float!
    var width: Float!

    var aspectRatio: Float {
        return width / height
    }
}

// MARK: - Mappable
extension Gif: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        url <- (map["images.downsized.url"], URLTransform())
        height <- (map["images.downsized.height"], StringFloatTransform())
        width <- (map["images.downsized.width"], StringFloatTransform())
    }
}
