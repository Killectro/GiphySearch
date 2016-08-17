//
//  GiphyResponse.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import Foundation
import ObjectMapper

/** This is a wrapper struct for the metadata returned from the API.
    It was created purely to allow for ease of mapping using ObjectMapper and Moya/RxSwift
 */
struct GiphyResponse {
    var limit: Int = 25
    var offset: Int = 0
    var gifs: [Gif]!
}

// MARK: - Mappable
extension GiphyResponse: Mappable {
    init?(_ map: Map) {
        mapping(map)
    }

    mutating func mapping(map: Map) {
        limit <- map["meta.limit"]
        offset <- map["meta.offset"]
        gifs <- map["data"]
    }
}