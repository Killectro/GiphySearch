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
import SDWebImage

final class TrendingViewController: UIViewController {

    // MARK: - Public Properties
    var viewModel: TrendingViewModel!
    
    // MARK: - Private Properties
    private let startLoadingOffset: CGFloat = 20.0

    @IBOutlet private var noResultsView: UIView!
    @IBOutlet var sadFaceImage: UIImageView! {
        didSet {
            sadFaceImage.tintColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        }
    }
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!

    private var mostRecentlyDisplayedIndexPath: [NSIndexPath]!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // SDWebImage automatically wipes mem cache when it receives a mem warning so do nothing here
    }

    // Determine whether or not we're near the bottom of the table and should paginate
    func tableView(tableView: UITableView, offsetIsNearBottom contentOffset: CGPoint) -> Bool {
        let isAtBottom = contentOffset.y + tableView.frame.height + startLoadingOffset > tableView.contentSize.height
        let hasContent = tableView.contentSize.height > tableView.frame.height

        return isAtBottom && hasContent
    }
}

// MARK: - Setup
private extension TrendingViewController {
    func setupBindings() {
        setupTableView()
        setupSearch()
        setupPagination()
    }

    func setupSearch() {
        let search = searchBar.rx_text
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .shareReplay(1)

        // Bind the search bar text to the view model's search text
        search
            .bindTo(viewModel.searchText)
            .addDisposableTo(rx_disposeBag)

        // Map the search bar text to isSearching on the view model which toggles which set of gifs to show
        search.map { $0.characters.count > 0 }
            .bindTo(viewModel.isSearching)
            .addDisposableTo(rx_disposeBag)
    }

    func setupTableView() {
        // Bind gifs to table view cells
        viewModel.gifs.asObservable()
            .bindTo(
                tableView.rx_itemsWithCellIdentifier("gifCell", cellType: GifTableViewCell.self),
                curriedArgument: configureTableCell
            )
            .addDisposableTo(rx_disposeBag)

        viewModel.gifs
            .map { gifs in gifs.count != 0 }
            .bindTo(noResultsView.rx_hidden)
            .addDisposableTo(rx_disposeBag)
    }

    func setupPagination() {
        // Trigger a new page load when near the bottom of the page
        viewModel.loadNextSearchPage = tableView.rx_contentOffset
            .filter { [weak self] offset in
                guard let strongSelf = self else { return false }
                return (strongSelf.tableView(strongSelf.tableView, offsetIsNearBottom: offset) && strongSelf.viewModel.isSearching.value)
            }
            .flatMap { _ in return Observable.just() }

        // Trigger a new page load when near the bottom of the page
        viewModel.loadNextTrendingPage = tableView.rx_contentOffset
            .filter { [weak self] offset in
                guard let strongSelf = self else { return false }
                return (strongSelf.tableView(strongSelf.tableView, offsetIsNearBottom: offset) && !strongSelf.viewModel.isSearching.value)
            }
            .flatMap { _ in return Observable.just() }

        // Hide the keyboard when we're scrolling
        tableView.rx_contentOffset.subscribeNext { [weak self] _ in
            guard let strongSelf = self else { return }

            if strongSelf.searchBar.isFirstResponder() {
                strongSelf.searchBar.resignFirstResponder()
            }
        }
        .addDisposableTo(rx_disposeBag)
    }

    func configureTableCell(row: Int, gif: Gif, cell: GifTableViewCell) {
        cell.viewModel = GifViewModel(gif: gif)
    }
}
