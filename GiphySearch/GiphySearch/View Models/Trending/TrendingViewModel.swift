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

    var gifs: Observable<[Gif]>! { get set }
    var loadNextTrendingPage: Observable<Void>! { get set }
    var loadNextSearchPage: Observable<Void>! { get set }
}

final class TrendingViewModel: TrendingViewModelType {

    // MARK: - Public properties
    let searchText = Variable<String>("")
    let isSearching = Variable<Bool>(false)

    var gifs: Observable<[Gif]>!
    var loadNextTrendingPage: Observable<Void>!
    var loadNextSearchPage: Observable<Void>!

    // MARK: - Private properties
    fileprivate var provider: RxMoyaProvider<GiphyAPI>!

    // MARK: - Initialization
    init(provider: RxMoyaProvider<GiphyAPI>) {
        self.provider = provider

        setupGifs()
    }
}

// MARK: - Setup
private extension TrendingViewModel {

    func setupGifs() {
        let trendingGifs = recursivelyGetResults(.trending(page: 0), loadedSoFar: [])

        let searchGifs = searchText.asObservable().flatMapLatest { [weak self] text -> Observable<[Gif]> in
            guard let `self` = self else { return Observable.just([]) }

            if text.isEmpty {
                return Observable.just([])
            } else {
                return self.recursivelyGetResults(GiphyAPI.search(searchString: text, page: 0), loadedSoFar: [])
            }
        }

        gifs = Observable.combineLatest(trendingGifs, searchGifs, isSearching.asObservable()) { (trending, searched, isSearching) -> [Gif] in
            return isSearching ? searched : trending
        }.shareReplay(1)
    }
}

// MARK: - Networking
private extension TrendingViewModel {
    func recursivelyGetResults(_ token: GiphyAPI, loadedSoFar: [Gif]) -> Observable<[Gif]> {
        return loadPage(token).flatMap { [weak self] gifs -> Observable<[Gif]> in

            guard let `self` = self else { return Observable.just([]) }

            let newGifs = loadedSoFar + gifs

            var obs = [
                // Return our current list of GIFs
                Observable.just(newGifs)
            ]

            switch token {
            case let .trending(page):
                obs = obs + [
                    // Wait until we scroll to the bottom of the page
                    Observable.never().takeUntil(self.loadNextTrendingPage),

                    // Then load the next round of gifs
                    self.recursivelyGetResults(GiphyAPI.trending(page: page + 1), loadedSoFar: newGifs)
                ]
            case let .search(str, page):
                obs = obs + [
                    // Wait until we scroll to the bottom of the page
                    Observable.never().takeUntil(self.loadNextSearchPage),

                    // Then load the next round of gifs
                    self.recursivelyGetResults(GiphyAPI.search(searchString: str, page: page + 1), loadedSoFar: newGifs)
                ]
            }

            return Observable.concat(obs)
        }
    }

    func loadPage(_ token: GiphyAPI) -> Observable<[Gif]> {
        return self.provider.request(token)
            .observeOn(MainScheduler.instance)
            .do(onNext: { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            })
            .observeOn(SerialDispatchQueueScheduler(qos: .background))
            .filterSuccessfulStatusCodes()
            .retry(3)
            .mapObject(GiphyResponse.self)
            .map { res in
                return res.gifs!
            }
            .observeOn(MainScheduler.instance)
            .do(onNext: { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            .catchError { _ in
                return Observable.empty()
            }
    }
}
