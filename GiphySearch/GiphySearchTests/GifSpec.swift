//
//  GifSpec.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/19/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ObjectMapper
@testable
import GiphySearch

class GifSpec: QuickSpec {
    override func spec() {

        let id = "test_id"
        let gif_url = "http://google.com"
        let height: Float = 50.0
        let width: Float = 100.0
        let still_url = "http://apple.com"

        let data: [String: AnyObject] = [
            "id" : id,
            "images" : [
                "downsized" : [
                    "url" : gif_url,
                    "height" : "\(height)",
                    "width" : "\(width)"
                ],
                "downsized_still" : [
                    "url" : still_url
                ]
            ]
        ]

        let map = Map(mappingType: .FromJSON, JSONDictionary: data)

        var gif: Gif!
        beforeEach {
            gif = Gif(map)
        }

        it("converts from JSON") {
            expect(gif).toNot(beNil())
            expect(gif!.id) == id
            expect(gif!.url.absoluteString) == gif_url
            expect(gif!.stillUrl.absoluteString) == still_url
            expect(gif!.height) == height
            expect(gif!.width) == width
        }
    }
}
