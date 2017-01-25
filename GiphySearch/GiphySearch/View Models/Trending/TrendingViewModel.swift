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

protocol TrendingViewModelType {
    var gifs: Observable<[GifViewModelType]>! { get set }

    func setupObservables(paginate: Observable<Void>, searchText: Observable<String>)
}

final class TrendingViewModel: TrendingViewModelType {

    // MARK: - Public properties
    var gifs: Observable<[GifViewModelType]>!

    // MARK: - Private properties
    fileprivate var networkModel: TrendingNetworkModelType

    // MARK: - Initialization
    init(provider: RxMoyaProvider<GiphyAPI>) {
        networkModel = TrendingNetworkModel(provider: provider)
    }

    // MARK: - Updating

    func setupObservables(paginate: Observable<Void>, searchText: Observable<String>) {
        let isSearching = searchText.map { $0.characters.count > 0 }
        let page = paginate.withLatestFrom(isSearching)

        networkModel.loadNextSearchPage = page.filter { $0 }.map { _ in () }
        networkModel.loadNextTrendingPage = page.filter { !$0 }.map { _ in () }

        setupGifs(isSearching: isSearching, searchText: searchText)
    }
}

// MARK: - Setup
private extension TrendingViewModel {

    func setupGifs(isSearching: Observable<Bool>, searchText: Observable<String>) {
        let trendingGifs = networkModel.recursivelyGetResults(.trending(page: 0), loadedSoFar: [])

        let searchGifs = searchText.asObservable().flatMapLatest { [weak self] text -> Observable<[Gif]> in
            guard let `self` = self else { return Observable.just([]) }

            if text.isEmpty {
                return Observable.just([])
            } else {
                return self.networkModel.recursivelyGetResults(GiphyAPI.search(searchString: text, page: 0), loadedSoFar: [])
            }
        }

        gifs = Observable.combineLatest(trendingGifs, searchGifs, isSearching.asObservable()) { (trending, searched, isSearching) -> [Gif] in
            return isSearching ? searched : trending
        }
        .map { $0.map(GifViewModel.init) }
        .shareReplay(1)
    }
}
