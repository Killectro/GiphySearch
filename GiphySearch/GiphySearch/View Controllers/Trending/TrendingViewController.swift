//
//  TrendingViewController.swift
//  GiphySearch
//
//  Created by DJ Mitchell on 8/17/16.
//  Copyright © 2016 Killectro. All rights reserved.
//

import UIKit

final class TrendingViewController: UIViewController {

    // MARK: - Public Properties
    var viewModel: TrendingViewModel!
    
    // MARK: - Private Properties
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
