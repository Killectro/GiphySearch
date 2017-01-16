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
    var baseURL: URL { return URL(string: "http://api.giphy.com/v1/gifs/")! }
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
            return .get
        }
    }

    var parameters: [String : Any]? {
        // Hard code the number of items per page.
        // This is the same as Giphy's default but we need it to calculate our offset,
        // so we will just pass it regardless
        let itemsPerPage = 25

        var params = [String:Any]()
        switch self {
        case let .search(searchString, page):

            let offset = itemsPerPage * page

            params = [
                "q" : searchString.lowercased().replacingOccurrences(of: " ", with: "+"),
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

    var task: Task {
        return .request
    }

    var sampleData: Data {
        // Not using stubbed responses right now
        return Data()
    }
}
