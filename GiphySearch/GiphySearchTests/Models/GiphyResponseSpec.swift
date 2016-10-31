//
//  GiphyResponseSpec.swift
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

class GiphyResponseSpec: QuickSpec {
    override func spec() {

        let id = "test_id"
        let gif_url = "http://google.com"
        let height: Float = 50.0
        let width: Float = 100.0
        let offset = 100
        let limit = 25

        let data: [String: AnyObject] = [
            "data" : [
                [
                    "id" : id,
                    "images" : [
                        "downsized" : [
                            "url" : gif_url,
                            "height" : "\(height)",
                            "width" : "\(width)"
                        ]
                    ]
                ]
            ],
            "meta" : [
                "offset" : offset,
                "limit" : limit
            ]
        ]
        
        let map = Map(mappingType: .FromJSON, JSON: data)

        var response: GiphyResponse!
        beforeEach {
            response = GiphyResponse(map)
        }

        it("converts from JSON") {
            expect(response).toNot(beNil())
            expect(response!.limit) == limit
            expect(response!.offset) == offset
            expect(response!.gifs).toNot(beNil())
            expect(response!.gifs.count) == 1

            let gif = response.gifs[0]

            expect(gif.id) == id
            expect(gif.url.absoluteString) == gif_url
            expect(gif.height) == height
            expect(gif.width) == width
            expect(gif.aspectRatio) == width / height
        }
    }
}
