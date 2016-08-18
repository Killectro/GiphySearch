//
//  GifViewModel.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import Foundation
import RxSwift
import SwiftGifOrigin
import RxAlamofire

final class GifViewModel: NSObject {
    private var gif = Variable<Gif!>(nil)

    private var gifImage: Observable<UIImage?>!
    private var stillImage: Observable<UIImage?>!

    var isPlaying = Variable<Bool>(false)
    var displayImage: Observable<UIImage?>!

    init(gif: Gif) {
        super.init()

        self.gif = Variable<Gif!>(gif)

        // Retrieve the GIF data from the server and map it to an image
        gifImage = requestData(.GET, gif.url.absoluteString)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .UserInteractive))
            .map { res, data in
                return UIImage.gifWithData(data)
            }

        // Retrieve the still image from the server and map it to an image
        stillImage = requestData(.GET, gif.stillUrl.absoluteString)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .UserInteractive))
            .map { res, data in
                return UIImage(data: data)
            }

        displayImage = Observable.combineLatest(gifImage, stillImage, isPlaying.asObservable()) { (gif, still, isPlaying) in
            return isPlaying ? gif : still
        }
    }
}
