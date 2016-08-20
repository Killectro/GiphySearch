//
//  GifTableViewCell.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import UIKit
import RxSwift
import FLAnimatedImage
import SDWebImage
import SnapKit

final class GifTableViewCell: UITableViewCell {

    // MARK: - Public Properties
    var viewModel: GifViewModel? {
        didSet {
            gifImageView.sd_setImageWithURL(viewModel?.gifUrl)
        }
    }

    // MARK: - Private Properties
    private lazy var gifImageView: FLAnimatedImageView = {
        let view = FLAnimatedImageView()
        view.contentMode = .ScaleAspectFit
        return view
    }()

    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.addSubview(gifImageView)

        gifImageView.snp_makeConstraints { make in
            make.height.equalTo(200)
            make.centerY.equalTo(contentView.snp_centerY)
            make.trailing.equalTo(contentView.snp_trailingMargin)
            make.leading.equalTo(contentView.snp_leadingMargin)
        }
    }

    override func prepareForReuse() {
        gifImageView.animatedImage = nil
        gifImageView.image = nil
    }
}
