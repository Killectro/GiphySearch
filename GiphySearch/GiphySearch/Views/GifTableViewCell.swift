//
//  GifTableViewCell.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher
import SnapKit

final class GifTableViewCell: UITableViewCell {

    // MARK: - Public Properties
    var viewModel: GifViewModelType? {
        didSet {
            gifImageView.kf.setImage(with: viewModel?.gifUrl)
        }
    }

    // MARK: - Private Properties
    fileprivate lazy var gifImageView: AnimatedImageView = {
        let view = AnimatedImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    // MARK: - View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.addSubview(gifImageView)

        gifImageView.snp.makeConstraints { make in
            make.height.equalTo(200)
            make.centerY.equalTo(contentView.snp.centerY)
            make.trailing.equalTo(contentView.snp.trailingMargin)
            make.leading.equalTo(contentView.snp.leadingMargin)
        }
    }

    override func prepareForReuse() {
        gifImageView.image = nil
    }
}
