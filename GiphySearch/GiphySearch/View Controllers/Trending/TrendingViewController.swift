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
    var viewModel: TrendingViewModel!
    
    // MARK: - Private Properties
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Setup
private extension TrendingViewController {
    func setupBindings() {
        // Bind gifs to table view cells
        viewModel.gifs.asObservable()
            .bindTo(
                tableView.rx_itemsWithCellIdentifier("gifCell", cellType: UITableViewCell.self),
                curriedArgument: configureTableCell
            )
            .addDisposableTo(rx_disposeBag)

        // Bind the results from the Giphy API to our viewmodel's gifs array
        viewModel.getTrending()
            .filterSuccessfulStatusCodes()
            .mapObject(GiphyResponse)
            .map { res in
                return res.gifs
            }
            .catchError(presentError)
            .bindTo(viewModel.gifs)
            .addDisposableTo(rx_disposeBag)
    }

    func configureTableCell(row: Int, gif: Gif, cell: UITableViewCell) {
        cell.textLabel?.text = "height \(gif.height) -- width \(gif.width)"
    }
}

// MARK: - Error handling
private extension TrendingViewController {
    func presentError(error: ErrorType) -> Observable<[Gif]> {
        let desc = (error as NSError).localizedDescription

        let alertController = UIAlertController(title: "Whoops", message: desc, preferredStyle: .Alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .Default) { [weak self] _ -> Void in
            self?.dismissViewControllerAnimated(true, completion: nil)
        })

        self.presentViewController(alertController, animated: true, completion: nil)
        
        return .empty()
    }
}
