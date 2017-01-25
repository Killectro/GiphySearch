//
//  TrendingViewController.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx
import Moya
import Moya_ObjectMapper

final class TrendingViewController: UIViewController {

    // MARK: - Public Properties
    var viewModel: TrendingDisplayable!

    // MARK: - Private Properties
    fileprivate let startLoadingOffset: CGFloat = 20.0

    @IBOutlet fileprivate var noResultsView: UIView!
    @IBOutlet var sadFaceImage: UIImageView! {
        didSet {
            sadFaceImage.tintColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        }
    }
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var searchBar: UISearchBar!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // SDWebImage automatically wipes mem cache when it receives a mem warning so do nothing here
    }
}

// MARK: - Setup
private extension TrendingViewController {
    func setupBindings() {
        setupViewModel()
        setupKeyboard()
    }

    func setupViewModel() {
        let searchText = searchBar.rx.text.orEmpty
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .shareReplay(1)

        let paginate = tableView.rx
            .contentOffset
            .filter { [weak self] offset in
                guard let `self` = self else { return false }

                return self.tableView.isNearBottom(threshold: self.startLoadingOffset)
            }
            .flatMap { _ in return Observable.just() }

        viewModel.setupObservables(paginate: paginate, searchText: searchText)

        // Bind our table view to our result GIFs once we set up our view model
        setupTableView()
    }

    func setupTableView() {
        // Bind gifs to table view cells
        viewModel.gifs
            .bindTo(
                tableView.rx.items(cellIdentifier: "gifCell", cellType: GifTableViewCell.self),
                curriedArgument: configureTableCell
            )
            .addDisposableTo(rx_disposeBag)

        viewModel.gifs
            .map { gifs in gifs.count != 0 }
            .bindTo(noResultsView.rx.isHidden)
            .addDisposableTo(rx_disposeBag)
    }

    func setupKeyboard() {
        // Hide the keyboard when we're scrolling
        tableView.rx.contentOffset.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }

            if self.searchBar.isFirstResponder {
                self.searchBar.resignFirstResponder()
            }
        })
        .addDisposableTo(rx_disposeBag)
    }

    func configureTableCell(_ row: Int, viewModel: GifDisplayable, cell: GifTableViewCell) {
        cell.viewModel = viewModel
    }
}
