//
//  GifViewModel.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import Foundation

final class GifViewModel: NSObject {
    var gif: Gif!

    var gifUrl: NSURL {
        return gif.url
    }

    init(gif: Gif) {
        super.init()
        self.gif = gif
    }
}
