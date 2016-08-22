//
//  GiphyAPI.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import Foundation
import RxSwift
import Moya

enum GiphyAPI {
    case search(searchString: String, page: Int)
    case trending(page: Int)
}

extension GiphyAPI: TargetType {
    var baseURL: NSURL { return NSURL(string: "http://api.giphy.com/v1/gifs/")! }
    var path: String {
        switch self {
        case .search:
            return "search"
        case .trending:
            return "trending"
        }
    }

    var method: Moya.Method {
        switch self {
        case .search, .trending:
            return .GET
        }
    }

    var parameters: [String : AnyObject]? {
        // Hard code the number of items per page.
        // This is the same as Giphy's default but we need it to calculate our offset,
        // so we will just pass it regardless
        let itemsPerPage = 25

        var params = [String:AnyObject]()
        switch self {
        case let .search(searchString, page):

            let offset = itemsPerPage * page

            params = [
                "q" : searchString.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "+"),
                "rating" : "r", // Keep it dirty, default to R rated
                "limit": itemsPerPage,
                "offset": offset
            ]
        case .trending(let page):
            let offset = itemsPerPage * page

            params = [
                "limit": itemsPerPage,
                "offset": offset
            ]
        }

        // Always append API key
        params["api_key"] = "dc6zaTOxFJmzC"

        return params
    }

    var sampleData: NSData {
        // Not using stubbed responses right now
        return NSData()
    }
}
