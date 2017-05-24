//
//  SearchTableViewController.swift
//  AlgoliaDemo
//
//  Created by Ben Rothschild on 5/21/17.
//  Copyright © 2017 Ben Rothschild. All rights reserved.
//

import AlgoliaSearch
import InstantSearchCore
import AFNetworking
import UIKit


class SearchTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, SearchProgressDelegate {

    var searchController: UISearchController!
    var searchProgressController: SearchProgressController!
    
    var itemSearcher: Searcher!
    var itemHits: [JSONObject] = []
    var originIsLocal: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        // Algolia Search
        itemSearcher = Searcher(index: AlgoliaManager.sharedInstance.itemsIndex, resultHandler: self.handleSearchResults)
        itemSearcher.params.hitsPerPage = 15
        itemSearcher.params.attributesToRetrieve = ["name", "yelp_rating", "merchant_logo", "review_count", "item_name", "item_description"]
        itemSearcher.params.attributesToHighlight = ["name", "item_description", "item_name"]
        
        // Search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("Search for food", comment: "")
        
        // Add the search bar
        tableView.tableHeaderView = self.searchController!.searchBar
        definesPresentationContext = true
        searchController!.searchBar.sizeToFit()
        
        // Configure search progress monitoring.
        searchProgressController = SearchProgressController(searcher: itemSearcher)
        searchProgressController.delegate = self
        
        // First load
        updateSearchResults(for: searchController)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemHits.count
    }
    
    
    // MARK: - Search
    func updateSearchResults(for searchController: UISearchController) {
        print("new search")
        print(searchController.searchBar.text ?? "hi")
        itemSearcher.params.query = searchController.searchBar.text
        itemSearcher.search()
    }

    private func handleSearchResults(results: SearchResults?, error: Error?) {
        
        guard let results = results else { return }
        if results.page == 0 {
            itemHits = results.hits
        } else {
            itemHits.append(contentsOf: results.hits)
        }
//        print(itemHits)
        originIsLocal = results.content["origin"] as? String == "local"
        self.tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath) as! ResultsCell
        
        // Load more?
        if indexPath.row + 5 >= itemHits.count {
            itemSearcher.loadMore()
        }
        
        // Configure the cell...
        
        let item = Record(json: itemHits[indexPath.row])

        cell.nameLabel?.highlightedText = item.item_name_highlighted
        cell.restaurantLabel?.highlightedText = item.restaurant_name_highlighted
        cell.yelpLabel?.text = item.yelp_rating != nil ? "\(item.yelp_rating!) Stars" : nil
        cell.descriptionLabel?.highlightedText = item.item_description_highlighted
        cell.imageView?.cancelImageDownloadTask()
        if let url = item.merchant_logo {
            cell.imageView?.setImageWith(url)
        }
        else {
            cell.imageView?.image = nil
        }
        cell.backgroundColor = originIsLocal ? AppDelegate.colorForLocalOrigin : UIColor.white
        
        return cell
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    }
    
    func searchDidStart(_ searchProgressController: SearchProgressController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func searchDidStop(_ searchProgressController: SearchProgressController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }


}
