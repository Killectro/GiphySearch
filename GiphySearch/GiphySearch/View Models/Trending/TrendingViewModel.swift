//
//  TrendingViewModel.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import UIKit
import RxSwift
import Moya

final class TrendingViewModel: NSObject {
    var provider: RxMoyaProvider<GiphyAPI>!

    var gifs = Variable<[Gif]>([])

    init(provider: RxMoyaProvider<GiphyAPI>) {
        self.provider = provider
    }
}

// MARK: - Networking
extension TrendingViewModel {
    func getTrending() -> Observable<Response> {
        // TODO: - Pagination
        return provider.request(GiphyAPI.trending(page: 0))
    }
}