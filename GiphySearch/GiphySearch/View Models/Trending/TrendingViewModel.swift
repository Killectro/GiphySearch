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
    var searchText: Variable<String> { get }
    var isSearching: Variable<Bool> { get }

    var gifs: Observable<[GifViewModelType]>! { get set }

    func updateObservables(searchPaginate: Observable<Void>, trendingPaginate: Observable<Void>)
}

final class TrendingViewModel: TrendingViewModelType {

    // MARK: - Public properties
    let searchText = Variable<String>("")
    let isSearching = Variable<Bool>(false)

    var gifs: Observable<[GifViewModelType]>!

    // MARK: - Private properties
    fileprivate var networkModel: TrendingNetworkModelType!

    // MARK: - Initialization
    init(provider: RxMoyaProvider<GiphyAPI>) {
        networkModel = TrendingNetworkModel(provider: provider)

        setupGifs()
    }

    // MARK: - Updating
    func updateObservables(searchPaginate: Observable<Void>, trendingPaginate: Observable<Void>) {

        networkModel.loadNextSearchPage = searchPaginate
        networkModel.loadNextTrendingPage = trendingPaginate
    }
}

// MARK: - Setup
private extension TrendingViewModel {

    func setupGifs() {
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
