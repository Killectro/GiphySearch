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

    var gifImage = BehaviorSubject<UIImage?>(value: nil)

    init(gif: Gif) {
        super.init()

        self.gif = Variable<Gif!>(gif)

        // Retrieve the GIF data from the server and map it to an image
        requestData(.GET, gif.url.absoluteString)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .UserInteractive))
            .map { res, data in
                return UIImage.gifWithData(data)
            }
//            .observeOn(MainScheduler.instance)
            .bindTo(gifImage)
            .addDisposableTo(rx_disposeBag)
    }
}