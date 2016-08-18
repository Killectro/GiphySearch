//
//  GifTableViewCell.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture

final class GifTableViewCell: UITableViewCell {

    // MARK: - Public Properties
    var viewModel: GifViewModel? {
        didSet { setupBindings() }
    }

    // MARK: - Private Properties
    @IBOutlet private var gifImageView: UIImageView!

    private var reusableDisposeBag = DisposeBag()


    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        gifImageView.image = nil
        reusableDisposeBag = DisposeBag()
    }
}

// MARK: - Setup
private extension GifTableViewCell {
    func setupBindings() {
        // Bind our image view to whatever comes back from the URL
        viewModel?.displayImage
            .observeOn(MainScheduler.instance)
            .bindTo(gifImageView.rx_image)
            .addDisposableTo(reusableDisposeBag)

        gifImageView.rx_gesture(.Tap)
            .subscribeNext { [weak self] _ in
                guard let vm = self?.viewModel else { return }

                vm.isPlaying.value = !vm.isPlaying.value
        }
        .addDisposableTo(reusableDisposeBag)
    }
}
