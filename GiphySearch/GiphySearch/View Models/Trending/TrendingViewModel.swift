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

final class TrendingViewModel {

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
        self.provider = provider

        setupTrending()
        setupSearchResults()
        setupGifs()
    }
}

// MARK: - Setup
private extension TrendingViewModel {
    func setupTrending() {
        trendingGifs = recursivelyGetResults(.trending(page: 0), loadedSoFar: [])
    }

    func setupSearchResults() {
        searchGifs = searchText.asObservable().flatMapLatest { [weak self] text -> Observable<[Gif]> in
            guard let strongSelf = self else { return Observable.just([]) }

            if text.isEmpty {
                return Observable.just([])
            } else {
                return strongSelf.recursivelyGetResults(GiphyAPI.search(searchString: text, page: 0), loadedSoFar: [])
            }
        }
    }

    func setupGifs() {
        gifs = Observable.combineLatest(trendingGifs!.asObservable(), searchGifs!.asObservable(), isSearching.asObservable()) { (trending, searched, isSearching) -> [Gif] in
            return isSearching ? searched : trending
        }
    }
}

// MARK: - Networking
private extension TrendingViewModel {
    func recursivelyGetResults(token: GiphyAPI, loadedSoFar: [Gif]) -> Observable<[Gif]> {
        return loadPage(token).flatMap { [weak self] gifs -> Observable<[Gif]> in

            guard let strongSelf = self else { return Observable.just([]) }

            let newGifs = loadedSoFar + gifs

            var obs = [
                // Return our current list of GIFs
                Observable.just(newGifs)
            ]

            switch token {
            case let .trending(page):
                obs = obs + [
                    // Wait until we scroll to the bottom of the page
                    Observable.never().takeUntil(strongSelf.loadNextTrendingPage),

                    // Then load the next round of gifs
                    strongSelf.recursivelyGetResults(GiphyAPI.trending(page: page + 1), loadedSoFar: newGifs)
                ]
            case let .search(str, page):
                obs = obs + [
                    // Wait until we scroll to the bottom of the page
                    Observable.never().takeUntil(strongSelf.loadNextSearchPage),

                    // Then load the next round of gifs
                    strongSelf.recursivelyGetResults(GiphyAPI.search(searchString: str, page: page + 1), loadedSoFar: newGifs)
                ]
            }

            return obs.concat()
        }
    }

    func loadPage(token: GiphyAPI) -> Observable<[Gif]> {
        return self.provider.request(token)
            .subscribeOn(MainScheduler.instance)
            .doOn(onNext: { res in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            })
            .filterSuccessfulStatusCodes()
            .retry(3)
            .mapObject(GiphyResponse)
            .map { res in
                return res.gifs!
            }
            .subscribeOn(MainScheduler.instance)
            .doOn(onNext: { res in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            .catchError { err in
                print(err)
                return Observable.empty()
            }
    }
}
