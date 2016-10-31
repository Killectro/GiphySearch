//
//  GifViewModel.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import Foundation

final class GifViewModel {
    private var gif: Gif!

    var gifUrl: URL {
        return gif.url
    }

    init(gif: Gif) {
        self.gif = gif
    }
}
