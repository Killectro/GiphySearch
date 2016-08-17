//
//  GifTableViewCell.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import UIKit
import RxSwift

final class GifTableViewCell: UITableViewCell {

    // MARK: - Public Properties
    var viewModel: GifViewModel! {
        didSet {
            setupBindings()
        }
    }

    // MARK: - Private Properties
    @IBOutlet private var gifImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {

    }
}

// MARK: - Setup
extension GifTableViewCell {
    func setupBindings() {
        // Bind our image view to whatever comes back from the URL
        viewModel.gifImage.asObservable()
            .observeOn(MainScheduler.instance)
            .bindTo(gifImageView.rx_image)
            .addDisposableTo(rx_disposeBag)


    }
}