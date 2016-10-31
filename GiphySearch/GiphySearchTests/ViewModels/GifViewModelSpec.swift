//
//  GifViewModelSpec.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/20/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ObjectMapper
@testable
import GiphySearch

class GifViewModelSpec: QuickSpec {
    override func spec() {
        let id = "test_id"
        let gif_url = "http://google.com"
        let height: Float = 50.0
        let width: Float = 100.0

        let data: NSDictionary = [
            "id" : id,
            "images" : [
                "downsized" : [
                    "url" : gif_url,
                    "height" : "\(height)",
                    "width" : "\(width)"
                ]
            ]
        ]

        let map = Map(mappingType: .FromJSON, JSON: data)

        var gif: Gif!
        var viewModel: GifViewModel!

        beforeEach {
            gif = Gif(map)
            viewModel = GifViewModel(gif: gif)
        }

        it("initializes from GIF") {
            expect(viewModel).toNot(beNil())
            expect(viewModel.gifUrl.absoluteString).to(equal(gif_url))
        }
    }
}
