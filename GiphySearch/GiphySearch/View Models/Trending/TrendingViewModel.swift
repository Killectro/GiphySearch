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

protocol TrendingDisplayable {
    // MARK: Inputs

    /// Sets up this object with the provided observables
    ///
    /// - Parameters:
    ///   - paginate: When the user has scrolled to the bottom
    ///   - searchText: The text the user is typing
    func setupObservables(paginate: Observable<Void>, searchText: Observable<String>)

    // MARK: Outputs

    /// The GIFs received from the network. This will either be trending to searched GIFs depending on observables
    var gifs: Observable<[GifDisplayable]>! { get set }
}

final class TrendingViewModel: TrendingDisplayable {

    // MARK: - Public properties
    var gifs: Observable<[GifDisplayable]>!

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
