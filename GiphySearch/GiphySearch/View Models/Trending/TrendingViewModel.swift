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

    // MARK: - Private properties
    private var trendingGifs: Observable<[Gif]>?
    private var searchGifs: Observable<[Gif]>?
    private var provider: RxMoyaProvider<GiphyAPI>!


    // MARK: - Public properties
    var searchText = Variable<String>("")
    var isSearching = Variable<Bool>(false)

    var gifs: Observable<[Gif]>!
    var loadNextTrendingPage: Observable<Void>!
    var loadNextSearchPage: Observable<Void>!

    init(provider: RxMoyaProvider<GiphyAPI>) {
        super.init()

        self.provider = provider

        setupTrending()
        setupSearchResults()
        setupGifs()
    }
}

// MARK: - Networking & Setup
private extension TrendingViewModel {
    func setupTrending() {
        trendingGifs = recursivelyGetResults(.trending(page: 0), loadedSoFar: [])
    }

    func setupSearchResults() {
        // TODO: - Pagination
        searchGifs = searchText.asObservable().flatMap { text -> Observable<[Gif]> in
            if text.isEmpty {
                return Observable.just([])
            } else {
                return self.recursivelyGetResults(GiphyAPI.search(searchString: text, page: 0), loadedSoFar: [])
            }
        }
    }

    func setupGifs() {
        gifs = Observable.combineLatest(trendingGifs!.asObservable(), searchGifs!.asObservable(), isSearching.asObservable()) { (trending, searched, isSearching) -> [Gif] in
            return isSearching ? searched : trending
        }
    }
}

private extension TrendingViewModel {
    func recursivelyGetResults(token: GiphyAPI, loadedSoFar: [Gif]) -> Observable<[Gif]> {
        return loadPage(token).flatMap { gifs -> Observable<[Gif]> in

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

            return obs.concat()
        }
    }

    func loadPage(token: GiphyAPI) -> Observable<[Gif]> {
        return self.provider.request(token)
            .debug()
            .filterSuccessfulStatusCodes()
            .retry(3)
            .mapObject(GiphyResponse)
            .map { res in
                return res.gifs!
            }
            .catchError { err in
                print(err)
                return Observable.empty()
            }
    }
}
